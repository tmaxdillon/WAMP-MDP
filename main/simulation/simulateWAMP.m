function [output] = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot)
%SIMULATEWAMP simulates performance of WAMP under backward recursive
%Markov Decision Process operational decision-making

%print status to command window
if sim.multiple
    disp(['Simulation ' num2str(sim.s) ' out of ' num2str(sim.S) ...
        ' beginning after ' num2str(round(toc(tTot)/60,2)) ' minutes. ' ...
        sim.tuned_parameter ' tuned to ' ...
        num2str(sim.tuning_array(sim.s)) '.'])
else
    disp('Simulation beginning')
end
tSim = tic;

%modify forecast matrix based on user settings for buffer and limit val
[FM_P,FM_mod] = modifyFM(FM,frc,wec);
mdp.T = size(FM_P,1); %number of stages
output.FM_P = FM_P;
output.FM_mod = FM_mod;

%simulation extent (number of forecasts)
if frc.Flimit
    sim.F = frc.Flimitval;
else
    sim.F = size(FM_P,2);         
end

%discretize battery
if sim.hpc && sim.hr_on %high discretization
    amp.E = linspace(0,amp.E_max,mdp.n); %[Wh], discretized battery state
else %discretize to ensure there's a state lower than Ps(2)
    amp.E = 0:amp.Ps(2)-5:amp.E_max; %[Wh], discretized battery state
    mdp.n = length(amp.E);
end
disp(['n = ' num2str(mdp.n)])
amp.E_start = amp.E(round(length(amp.E)/2)); %[Wh], starting battery level

%preallocate outputs
output.E_sim = zeros(sim.F,1); %battery time series
output.a_sim = zeros(sim.F,1); %action time series
output.Pw_sim = zeros(sim.F,1); %power from WEC time series
output.Pb_sim = zeros(sim.F,1); %net power sent to battery time series
output.wec.cw = zeros(sim.F,1); %capture width
output.wec.cwr = zeros(sim.F,1); %capture width ratio
output.Pw_error = zeros(ceil((mdp.T-1)/24),sim.F); %error matrix
output.beta = zeros(sim.F,1); %beta time series
if sim.debug
    output.val_Jstar = zeros(sim.F,1); %Jstar time series
    output.val_all = zeros(mdp.n,mdp.m,mdp.T+1,sim.F); %all J
    output.val_togo = zeros(mdp.n,mdp.T+1,sim.F); %val to go matrix
    output.policy_all = zeros(mdp.n,mdp.T,sim.F); %policy all matrix
    output.state_evol_all = zeros(mdp.n,mdp.m,mdp.T+1,sim.F); %state matrix
    output.wec_power_mdp = zeros(mdp.T,sim.F); %mdp wave params
    output.wec_power_sim = zeros(1,sim.F); %sim wave params
end

%set initial output values
output.E_sim(1) = amp.E_start; %set initial value of battery time series
output.beta(1) = beta(amp.E_start,amp,mdp); %set initial beta value

%set default values
output.abridged = false; %default: not posterior bound abridged
if sim.sl %simple logic
    sim.pb = false;
end

%RUN SIMULATION
for f=1:sim.F %over each forecast
    %print status to command window
    if mod(f-1,sim.notif) == 0 && f-1 > 0 && ~sim.multiple
        disp([num2str(f-1) ' out of ' num2str(sim.F) ...
            ' forecasts complete after ' num2str(round(toc(tSim)/60,2)) ...
            ' minutes.'])
    end   
    output.Pw_sim(f) = FM_P(1,f,2); %power produced by WEC        
    if sim.sl %SIMPLE LOGIC
        if output.E_sim(f) > amp.fpr*amp.E_max
            output.a_sim(f) = 4;
        elseif output.E_sim(f) > amp.mpr*amp.E_max
            output.a_sim(f) = 3;
        elseif output.E_sim(f) > amp.lpr*amp.E_max
            output.a_sim(f) = 2;
        else
            output.a_sim(f) = 1;
        end            
    else %MDP LOGIC                
        %abridge simulation if using posterior bound to full duration
        if f > size(FM_P,2) - (mdp.T-1) && sim.pb
            output.abridged = true; %simulation has been abridged
            %print status to command window
            if sim.multiple
                disp(['Simulation ' num2str(sim.s) ' out of ' ...
                    num2str(sim.S) ' complete after ' ...
                    num2str(round(toc(tSim)/60,2)) ' minutes.'])
            else
                disp(['Simulation complete after ' ...
                    num2str(round(toc(tTot)/60,2)) ' minutes.'])
            end
            break
        end        
        %FIND CURRENT STATE
        [~,ind_E_sim] = min(abs(amp.E-output.E_sim(f))); %index of state       
        %BACKWARD RECURSION
        if sim.debug
            if sim.hpc
                [policy,Jstar,compare,state_evol,wec_power] = ...
                    backwardRecursion_par(FM_P,mdp,amp,sim,wec,f);
            else
                [policy,Jstar,compare,state_evol,wec_power] = ...
                    backwardRecursion(FM_P,mdp,amp,sim,wec,f);
            end
            %DOCUMENT BELLMANS (AND DEBUG) VALUES
            output.val_all(:,:,:,f) = compare(:,:,:); %all values
            output.val_Jstar(f,:) = Jstar(ind_E_sim,1); %optimal value
            output.val_togo(:,:,f) = Jstar; %value to go
            output.policy_all(:,:,f) = policy; %policy all
            output.state_evol_all(:,:,:,f) = state_evol; %state evolution
            output.wec_power_mdp(:,f) = wec_power; %power from wec (mdp)
            output.wec_power_sim(f) = FM_P(1,f,2); %power from wec (sim)
        else
            if sim.hpc
                [policy] = backwardRecursion_par(FM_P,mdp,amp,sim,wec,f);
            else
                [policy] = backwardRecursion(FM_P,mdp,amp,sim,wec,f);
            end
        end        
        %EVOLVE SIMULATION:
        output.a_sim(f) = policy(ind_E_sim,1); %action given current state
    end
    [output.Pb_sim(f),E_evolved] = powerToBattery(output.Pw_sim(f), ...
        output.E_sim(f),amp.Ps(output.a_sim(f)), ...
        amp,mdp,wec); %net power sent to battery
    output.beta(f+1) = beta(E_evolved,amp,mdp); %document beta value
    [~,ind_E_sim_evolved] = min(abs(amp.E - E_evolved)); %evolved index
    output.E_sim(f+1) = amp.E(ind_E_sim_evolved); %discretized energy state    
    output.wec.cw(f) = FM_P(1,f,3); %capture width
    output.wec.cwr(f) = FM_P(1,f,4); %capture width ratio    
    %COMPUTE ERROR IN FORECAST
    if f > 1
        output.Pw_error(:,f) = calcSimError(FM_P,mdp,f);
    end
    %PERFORMANCE METRICS
    %percent for each operational state and average output power
    [output.apct,output.power_avg,output.beta_avg,output.E_sim_ind] = ...
        calcPerfMetrics(amp,mdp,output);
end

%print status to command window
if sim.multiple
    disp(['Simulation ' num2str(sim.s) ' out of ' num2str(sim.S) ...
        ' complete after ' num2str(round(toc(tSim)/60,2)) ' minutes.'])
else
    disp(['Simulation complete after ' num2str(round(toc(tTot)/60,2))  ...
        ' minutes.'])
end

%store wec info
output.wec.rp = (wec.B*wec.F(wec.Tp_ra,wec.Hs_ra,wec.B)*wec.eta_ct* ...
    (1/(16*4*pi))*wec.rho*wec.g^2* ... 
    wec.Hs_ra^2*wec.Tp_ra)/(1+wec.h); %rated power
output.wec.cw_avg = mean(output.wec.cw); %average capture width
output.wec.cwr_avg = mean(output.wec.cwr); %average capture width ratio
output.wec.CF = mean(output.Pw_sim)/output.wec.rp; %capacity factor

%print results
results.power_avg = output.power_avg;
results.beta_avg = output.beta_avg;
results



