function [output] = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot,i)
%SIMULATEWAMP simulates performance of WAMP under backward recursive
%Markov Decision Process operational decision-making

%PRINT START
%print status to screen if not doing external parallelization
if ~sim.expar && sim.notif
    if sim.tdsens
        disp(['Simulation ' num2str(i) ' beginning after ' ...
            num2str(round(toc(tTot)/60,2)) ' minutes. ' ...
            sim.tuned_parameter{1} ' tuned to ' ...
            num2str(sim.S1(i)) ' and ' ...
            sim.tuned_parameter{2} ' tuned to ' ...
            num2str(sim.S2(i)) '.'])
    elseif sim.senssm
        disp(['Simulation ' num2str(i) ' beginning after ' ...
            num2str(round(toc(tTot)/60,2)) ' minutes. ' ...
            char(sim.S1{2}(i)) ' tuned to ' ...
            num2str(sim.S1{1}(i))'.'])
    end
    tSim = tic;
end

%SENSITIVITY ANALYSIS
%update sensitivity analysis
if sim.tdsens || sim.senssm || sim.pyssm
    [FM,amp,frc,mdp,sim,wec] = updateSensitivity(FM,amp,frc,mdp,sim,wec,i);
else %not sensitivity, set i value for calcPerfMetrics
    i = nan;
end

%VARIOUS SETUP ITEMS
%1: modify forecast matrix based on user settings for buffer and limit val
[FM_P,FM_mod] = modifyFM(FM,frc,mdp,wec);
mdp.T = size(FM_P,1); %number of stages
%mdp.T_arr = 1:mdp.dt:size(FM_P,1); %stage array
output.FM_P = FM_P;
output.FM_mod = FM_mod;
%2: simulation extent (number of forecasts)
if frc.Flimit
    sim.F = frc.Flimitval;
else
    sim.F = size(FM_P,2);
end
%3: discretize battery by element size (default)
amp.E = 0:mdp.d_n:amp.E_max;
mdp.n = length(amp.E);
if ~sim.expar && sim.notif
    disp(['n = ' num2str(mdp.n) ' and d_n = ' num2str(mdp.d_n)])
end
amp.E_start = amp.E(round(length(amp.E)* ...
    amp.est)); %[Wh], starting battery level
%4: preallocate outputs
output.E_sim = zeros(sim.F,1); %battery time series
output.E_true = zeros(sim.F,1); %true battery time series
output.a_sim = zeros(sim.F,1); %action time series
output.a_act_sim = zeros(sim.F,1); %actual action time series
output.Pw_sim = zeros(sim.F,1); %power from WEC time series
output.P_sim = zeros(sim.F,1); %power for sensing time series
output.D_sim = zeros(sim.F,1); %power discarded time series
%output.Pb_sim = zeros(sim.F,1); %net power sent to battery time series
output.wec.cw = zeros(sim.F,1); %capture width
output.wec.cwr = zeros(sim.F,1); %capture width ratio
output.error.val = zeros(ceil((mdp.T*mdp.dt-1)/24),sim.F); %error matrix
output.error.zero = nan(size(output.error.val)); %zero when power is zero
%output.beta = zeros(sim.F,1); %beta time series
output.val_Jstar = zeros(sim.F,1); %Jstar time series
if sim.debug
    output.val_all = zeros(mdp.n,mdp.m,mdp.T+1,sim.F); %all J
    output.tau_all = zeros(mdp.n,mdp.T+1,sim.F); %tau penalty all matrix
    output.val_togo = zeros(mdp.n,mdp.T+1,sim.F); %val to go matrix
    output.policy_all = zeros(mdp.n,mdp.T,sim.F); %policy all matrix
    output.state_evol_all = zeros(mdp.n,mdp.m,mdp.T+1,sim.F); %state matrix
    output.wec_power_mdp = zeros(mdp.T,sim.F); %mdp wave params
    output.wec_power_sim = zeros(1,sim.F); %sim wave params
end
%5: set initial output values
output.E_sim(1) = amp.E_start; %set initial value of battery time series
output.E_true(1) = amp.E_start;
dE(1) = output.E_true(1) - output.E_sim(1);
%6: set default values
output.abridged = false; %default: not posterior bound abridged
if sim.sl || sim.slv2 %simple logic
    sim.pb = false;
end

%RUN SIMULATION
for f=1:1:sim.F %over each forecast
    %print status to command window
    if mod(f-1,sim.d_notif) == 0 && f-1 > 0 && ~sim.expar && sim.notif
        disp([num2str(f-1) ' out of ' num2str(sim.F) ...
            ' forecasts complete after ' num2str(round(toc(tSim)/60,2)) ...
            ' minutes.'])
    end
    %abridge at posterior bound limit for various reasons (all the time?)
    if f > frc.abr_val && ...
            (sim.tdsens || sim.senssm || sim.sl || sim.slv2 || ...
            sim.pyssm || frc.pb_abr)
        output.abridged = true; %simulation has been abridged
        %print status to command window if not external parallelization
        if ~sim.expar && sim.notif
            if sim.tdsens
                disp(['Simulation ' num2str(i) ' out of ' ...
                    num2str(sim.S) ' complete after ' ...
                    num2str(round(toc(tSim)/60,2)) ' minutes.'])
            else
                disp(['Simulation complete after ' ...
                    num2str(round(toc(tTot)/60,2)) ' minutes.'])
            end
        end
        break
    end
    %find power and state
    output.Pw_sim(f) = FM_P(1,f,2); %power produced by WEC
    [~,ind_E_sim] = min(abs(amp.E-output.E_sim(f))); %index of state
    %SIMPLE LOGIC - SoC BASED
    if sim.sl
        if output.E_sim(f) > amp.fpr*amp.E_max
            output.a_sim(f) = 4;
        elseif output.E_sim(f) > amp.mpr*amp.E_max
            output.a_sim(f) = 3;
        elseif output.E_sim(f) > amp.lpr*amp.E_max
            output.a_sim(f) = 2;
        else
            output.a_sim(f) = 1;
        end
        [Jstar] = simpleLogicRecursion(FM_P,mdp,amp,sim,wec,1,f);
        output.val_Jstar(f) = Jstar(ind_E_sim,1); %optimal value
    %SIMPLE LOGIC v2 - DURATION BASED
    elseif sim.slv2
        tte = output.E_sim(f)/(amp.Ps(3) - output.Pw_sim(f) + ...
            output.E_sim(f)*amp.sdr/(100*30*24)); %[h]
        if tte < 0 %producing more power than consuming, full power
            output.a_sim(f) = 4;
        elseif tte > amp.tt(1) %more than tt_1 hrs to empty, medium power
            output.a_sim(f) = 3;
        elseif tte > amp.tt(2) %more than tt_2 hrs to empty, low power
            output.a_sim(f) = 2;
        else %less than tt_2 hours to empty, survival mode
            output.a_sim(f) = 1;
        end
        [Jstar] = simpleLogicRecursion(FM_P,mdp,amp,sim,wec,2,f);
        output.val_Jstar(f) = Jstar(ind_E_sim,1); %optimal value
    %SIMPLE LOGIC V3 - GREEDY
    elseif sim.slv3
        output.a_sim(f) = 4;
        [Jstar] = simpleLogicRecursion(FM_P,mdp,amp,sim,wec,3,f);
        output.val_Jstar(f) = Jstar(ind_E_sim,1); %optimal value
    %SIMPLE LOGIC V4 - DURATION BASED V2
    elseif sim.slv4
        dv = datevec(FM_P(1,f,1)); %get matlab serial into datevec
        if rem(dv(4),mdp.tp) <= mdp.tsl
            output.a_sim(f) = 4;
        else
            tte = output.E_sim(f)/(amp.Ps(3) - output.Pw_sim(f) + ...
                output.E_sim(f)*amp.sdr/(100*30*24)); %[h]
            if tte < 0 %producing more power than consuming, full power
                output.a_sim(f) = 4;
            elseif tte > amp.tt(1) %more than tt_1 hrs to empty, med power
                output.a_sim(f) = 3;
            elseif tte > amp.tt(2) %more than tt_2 hrs to empty, low power
                output.a_sim(f) = 2;
            else %less than tt_2 hours to empty, survival mode
                output.a_sim(f) = 1;
            end
        end
        [Jstar] = simpleLogicRecursion(FM_P,mdp,amp,sim,wec,2,f);
        output.val_Jstar(f) = Jstar(ind_E_sim,1); %optimal value
    %MDP AND POSTERIOR BOUND
    else
        %BACKWARD RECURSION
        if rem(f-1,mdp.dt) == 0 %time to make a decision based on stage
            if sim.debug %if debugging mdp
                [policy,Jstar,tau,compare,state_evol,wec_power] = ...
                    backwardRecursion(FM_P,mdp,amp,sim,wec,frc,f);
                %DOCUMENT BELLMANS (AND DEBUG) VALUES
                output.val_all(:,:,:,f) = compare(:,:,:); %all values
                output.tau_all(:,:,f) = tau; %tau penalty matrix
                output.val_Jstar(f) = Jstar(ind_E_sim,1); %optimal value
                output.val_togo(:,:,f) = Jstar; %value to go
                output.policy_all(:,:,f) = policy; %policy all
                output.state_evol_all(:,:,:,f) = state_evol; %state evol
                output.wec_power_mdp(:,f) = wec_power; %P from wec (mdp)
                output.wec_power_sim(f) = FM_P(1,f,2); %P from wec (sim)
%             elseif sim.debugpbo %posterior bound debugging sept 2022
%                 sim.pb = 0;
%                 [policy_mdp,Jstar_mdp] = ...
%                     backwardRecursion(FM_P,mdp,amp,sim,wec,frc,f);
%                 [policy_pbo,Jstar_pbo] = ...
%                     backwardRecursion(FM_P,mdp,amp,sim,wec,frc,f);
            else %not debugging mdp
                [policy,Jstar] = ...
                    backwardRecursion(FM_P,mdp,amp,sim,wec,frc,f);
            end
            %set action and opt val over next dt time steps based on policy
            if f+mdp.dt < sim.F
                output.a_sim(f:f+mdp.dt) = policy(ind_E_sim,1);
                output.val_Jstar(f:f+mdp.dt) = Jstar(ind_E_sim,1);
            else
                output.a_sim(f:end) = policy(ind_E_sim,1);
                output.val_Jstar(f:end) = Jstar(ind_E_sim,1);
            end
        end
    end
    %EVOLVE SIMULATION:
    %find power for sensing, power discarded and battery evolution
    [output.P_sim(f),output.a_act_sim(f),output.D_sim(f),E_evolved] = ...
        powerBalance(output.Pw_sim(f),output.E_sim(f), ...
        output.a_sim(f),amp.sdr,amp.E_max,amp.Ps,1,amp.blogic);
    [~,~,~,output.E_true(f+1)] = powerBalance(output.Pw_sim(f), ...
        output.E_true(f),output.a_act_sim(f),amp.sdr,amp.E_max, ...
        amp.Ps,1,3);
    if sim.round == 1 %round to nearest index
        [~,ind_E_sim_evolved] = min(abs(amp.E - E_evolved)); %evolved index
    elseif sim.round == 2 %round dynamically based on E_true
        [~,ind_temp] = min(abs(amp.E - E_evolved));
        truegreater = output.E_true(f+1) > E_evolved;
        trueless = output.E_true(f+1) < E_evolved;
        roundup = amp.E(ind_temp) > E_evolved;
        rounddown = amp.E(ind_temp) < E_evolved;
        if truegreater && rounddown && ...
                amp.E(ind_temp) < amp.E(end) %need to round up
            ind_E_sim_evolved = ind_temp + 1;
        elseif trueless && roundup %need to round down
            ind_E_sim_evolved = ind_temp - 1;
        else %stay as rounded
            ind_E_sim_evolved = ind_temp;
        end
    end
    output.E_sim(f+1) = amp.E(ind_E_sim_evolved); %discretized energy state
    if sim.debug_disc
        disp(['E_evolved = ' num2str(E_evolved)])
        disp(['E_sim = ' num2str(output.E_sim(f+1))])
        disp(['E_true = ' num2str(output.E_true(f+1))])
        dE(f+1) = output.E_true(f+1) - output.E_sim(f+1);
        disp(['dE = ' num2str(dE(f+1))])
        disp(['dEdE = ' num2str(dE(f+1)-dE(f))])
    end
    output.wec.cw(f) = FM_P(1,f,3); %capture width
    output.wec.cwr(f) = FM_P(1,f,4); %capture width ratio
    %calculate forecast error
    if f > mdp.dt && mdp.dt == 1 && ~sim.pyssm
        [output.error.val(:,f), output.error.zero(:,f)] ...
            = calcSimError(FM_P,mdp,f);
    else
        output.error.val(:,f) = nan;
        output.error.zero(:,f) = nan;
    end
end

%PERFORMANCE METRICS
%percent for each operational state and average output power
[output.apct,output.power_avg,output.E_sim_ind,~, ...
    output.J_recon] = calcPerfMetrics(amp,mdp,sim,wec,output,i,FM_P);

%PRINT END
%print status to command window
if ~sim.expar && sim.notif
    if sim.tdsens
        disp(['Simulation ' num2str(i) ' complete after ' ...
            num2str(round(toc(tSim)/60,2)) ' minutes.'])
    end
end
%store wec info
output.wec.rp = (wec.B*wec.F(wec.Tp_ra,wec.Hs_ra,wec.B)*wec.eta_ct* ...
    (1/(16*4*pi))*wec.rho*wec.g^2* ...
    wec.Hs_ra^2*wec.Tp_ra)/(1+wec.h); %rated power
output.wec.cw_avg = mean(output.wec.cw); %average capture width
output.wec.cwr_avg = mean(output.wec.cwr); %average capture width ratio
output.wec.CF = mean(output.Pw_sim)/output.wec.rp; %capacity factor
output.wec.E_max = amp.E_max; %battery size
output.wec.B = wec.B; %wec size
output.wec.Hs_ra = wec.Hs_ra; %rated wave height
output.wec.Tp_ra = wec.Tp_ra; %rated peak period
%print results
if sim.tdsens %two dimensional sensitivity analysis - print after
    output.results.(sim.tuned_parameter{1}) = sim.S1(i);
    output.results.(sim.tuned_parameter{2}) = sim.S2(i);
    output.results.power_avg = output.power_avg;
    %output.results.beta_avg = output.beta_avg;
elseif sim.senssm
    %clean up large uneccessary variables
    output = rmfield(output,'FM_P');
    output = rmfield(output,'FM_mod');
    output = rmfield(output,'Pw_error');
    %store sensitivity parameter and array for visualization
    output.tuned_parameter = sim.S1{2}(i);
    output.tuning_array = ...
        sim.S1{1}(i-rem(i-1,sim.n): ...
        i+(rem(sim.n-(i-ceil(i/sim.n)*sim.n),sim.n)));
    if sim.expar %save outputs for post-parellization
        output.results.(char(sim.S1{2}(i))) = sim.S1{1}(i);
        output.results.rp = output.wec.rp;
        output.results.E_max = output.wec.E_max;
        output.results.power_avg = output.power_avg;
    else %not parallelized, print outputs
        results.rp = output.wec.rp;
        results.E_max = output.wec.E_max;
        results.power_avg = output.power_avg;
        results
    end
elseif sim.pyssm
    %clean up large uneccessary variables
    output.FM_P_1 = squeeze(output.FM_P(1,:,:));
    output.FM_mod_1 = squeeze(output.FM_mod(1,:,:));
    if ~isequal(sim.tp,'bbb') %save extra for baseline
        output = rmfield(output,'FM_P');
        output = rmfield(output,'FM_mod');
    end
    %store sensitivity parameter and array for visualization
    output.tuned_parameter = sim.tp;
    output.tuning_array = sim.ta;
    output.ta_i = sim.ta_i;
    if sim.expar %save outputs for post-parellization
        output.results.(char(sim.tp)) = sim.ta(sim.ta_i);
        output.results.rp = output.wec.rp;
        output.results.E_max = output.wec.E_max;
        output.results.power_avg = output.power_avg;
    else %not parallelized, print outputs
        results.rp = output.wec.rp;
        results.E_max = output.wec.E_max;
        results.power_avg = output.power_avg;
        results
    end
else %single simulation, print results now
    results.rp = output.wec.rp;
    results.E_max = output.wec.E_max;
    results.power_avg = output.power_avg;
    results
end


