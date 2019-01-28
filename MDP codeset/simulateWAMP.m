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

%preallocate outputs
output.E_sim = zeros(sim.F,1); %initialize battery time series
output.a_sim = zeros(sim.F,1); %initialize action time series
output.Pw_sim = zeros(sim.F,1); %initialize power from WEC time series
output.Pa_sim = zeros(sim.F,1); %initialize power to AMP time series
output.Pw_error = zeros(ceil((mdp.T-1)/24),sim.F); %initialize error matrix
output.val_Jstar = zeros(sim.F,1); %initialize Jstar time series
output.val_all = zeros(mdp.n,mdp.m,mdp.T+1,sim.F); %initialize all J
output.val_togo = zeros(mdp.n,mdp.T+1,sim.F); %initiaze val to go matrix
output.beta = zeros(sim.F,1); %initialize beta time series
if sim.debug
    output.policy_all = zeros(mdp.n,mdp.T,sim.F); %initialize policy all matrix
    output.state_evol_all = zeros(mdp.n,mdp.m,mdp.T+1,sim.F); %initalize state matrix
    output.wave_params_mdp = zeros(2,mdp.T,sim.F); %initialize mdp wave params
    output.wave_params_sim = zeros(2,sim.F); %initialize sim wave params
end

%set initial values
output.E_sim(1) = amp.E_start; %set initial value of battery time series
output.beta(1) = beta(amp.E_start,amp,mdp); %set initial beta value

%set default values
output.abridged = false; %default: simulation is not posterior bound abridged

%RUN SIMULATION
for f=1:sim.F %over each forecast
    %print status to command window
    if mod(f-1,sim.notif) == 0 && f-1 > 0 && ~sim.multiple
        disp([num2str(f-1) ' out of ' num2str(sim.F) ...
            ' forecasts complete after ' num2str(round(toc(tSim)/60,2)) ' minutes.'])
    end
    
    %abridge simulation if using posterior bound to full duration
    if f > size(FM_P,2) - (mdp.T-1) && sim.pb
        output.abridged = true; %simulation has been abridged
        %print status to command window
        if sim.multiple
            disp(['Simulation ' num2str(sim.s) ' out of ' num2str(sim.S) ...
                ' complete after ' num2str(round(toc(tSim)/60,2)) ' minutes.'])
        else
            disp(['Simulation complete after ' num2str(round(toc(tTot)/60,2)) ' minutes.'])
        end
        break
    end
    
    %FIND CURRENT STATE
    [~,ind_E_sim] = min(abs(amp.E-output.E_sim(f))); %find index of current state
    
    %BACKWARD RECURSION
    if sim.debug
        [Jstar,policy,compare,state_evol,wec_power] = ...
            backwardRecursion(FM_P,mdp,amp,sim,f);
        %DOCUMENT BELLMANS (AND DEBUG) VALUES
        output.val_all(:,:,:,f) = compare(:,:,:);       %all values
        output.val_Jstar(f,:) = Jstar(ind_E_sim,1);     %optimal value
        output.val_togo(:,:,f) = Jstar;                 %value to go
        output.policy_all(:,:,f) = policy;              %policy all
        output.state_evol_all(:,:,:,f) = state_evol;    %state evolution
        output.wec_power_mdp(:,:,f) = wec_power;        %power from wec (mdp)
        output.wec_power_sim(:,f) = FM_P(1,f,2);        %power from wec (sim)
    else
        [Jstar,policy,compare] = ...
            backwardRecursion(FM_P,mdp,amp,sim,f);
        %DOCUMENT BELLMANS
        output.val_all(:,:,:,f) = compare(:,:,:);       %all values
        output.val_Jstar(f,:) = Jstar(ind_E_sim,1);     %optimal value
        output.val_togo(:,:,f) = Jstar;                 %value to go
    end
    
    %EVOLVE SIMULATION:
    output.a_sim(f) = policy(ind_E_sim,1); %find action given current state
    output.Pw_sim(f) = FM_P(1,f,2); %find power produced by WEC
    output.Pa_sim(f) = powerToAMP(output.Pw_sim(f),output.E_sim(f),amp,mdp, ...
        sim); %find power to AMP
    output.E_sim(f+1) = output.E_sim(f) - mdp.dt*(amp.Ps(output.a_sim(f)) ...
        - output.Pa_sim(f));  %find energy in next state
    output.beta(f+1) = beta(output.E_sim(f+1),amp,mdp); %document beta value
    [~,ind_E_sim_evolved] = min(abs(amp.E - ...
        output.E_sim(f+1))); %find evolved index
    output.E_sim(f+1) = amp.E(ind_E_sim_evolved); %discretize energy in next state
    
    %COMPUTE ERROR IN FORECAST
    if f > 1
        output.Pw_error(:,f) = calcSimError(FM_P,mdp,f);
    end
    
    %PERFORMANCE METRICS
    %percent for each operational state and average output power
    [output.apct,output.power_avg,output.beta_avg,output.E_sim_ind] = ...
        calcPerfMetrics(amp,mdp,output);
    
    %print status to command window
    if (sim.multiple && f == sim.F)
        disp(['Simulation ' num2str(sim.s) ' out of ' num2str(sim.S) ...
            ' complete after ' num2str(round(toc(tSim)/60,2)) ' minutes.'])
    elseif f == sim.F
        disp(['Simulation complete after ' num2str(round(toc(tTot)/60,2)) ' minutes.'])
    end
    
end

