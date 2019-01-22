function [output] = simulateWAMP(FM,amp,mdp,sim,wec,tTot)
%SIMULATEWAMP simulates performance of WAMP under backward recursive
%Markov Decision Process operational decision-making

%preallocate outputs
output.E_sim = zeros(sim.F,1); %initialize battery time series
output.a_sim = zeros(sim.F,1); %initialize action time series
output.Pw_sim = zeros(sim.F,1); %initialize power from WEC time series
output.Pa_sim = zeros(sim.F,1); %initialize power to AMP time series
output.Pw_error = zeros(ceil(mdp.T/24),sim.F); %initialize error matrix
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

%RUN SIMULATION
for f=1:sim.F %over each forecast
    %print status to command window
    if mod(f-1,sim.notif) == 0 && f-1 > 0 && ~sim.multiple
        disp([num2str(f-1) ' out of ' num2str(sim.F) ...
            ' forecasts complete after ' num2str(round(toc(tSim)/60,2)) ' minutes.'])
    end
    
    %abridge simulation if using posterior bound to full duration
    if f > size(FM,2) - mdp.T && sim.pb
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
        [Jstar,policy,compare,state_evol,wave_params] = ...
            backwardRecursion(FM,mdp,amp,wec,sim,f);
        %DOCUMENT BELLMANS (AND DEBUG) VALUES
        %all values
        output.val_all(:,:,:,f) = compare(:,:,:);
        %optimal value
        output.val_Jstar(f,:) = Jstar(ind_E_sim,1);
        %value to go
        output.val_togo(:,:,f) = Jstar;
        %policy all
        output.policy_all(:,:,f) = policy;
        %state evolution
        output.state_evol_all(:,:,:,f) = state_evol;
        %wave parameters
        output.wave_params_mdp(:,:,f) = wave_params;
        output.wave_params_sim(:,f) = [FM(1,f,2) ; FM(1,f,3)];
    else
        [Jstar,policy,compare] = ...
            backwardRecursion(FM,mdp,amp,wec,sim,f);
        %DOCUMENT BELLMANS
        %all values
        output.val_all(:,:,:,f) = compare(:,:,:);
        %optimal value
        output.val_Jstar(f,:) = Jstar(ind_E_sim,1);
        %value to go
        output.val_togo(:,:,f) = Jstar;
    end
    
    %EVOLVE SIMULATION:
    output.a_sim(f) = policy(ind_E_sim,1); %find action given current state
    output.Pw_sim(f) = powerFromWEC(FM(1,f,2),FM(1,f,3), ...
        wec); %find power produced by WEC
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
        output.Pw_error(:,f) = calcSimError(FM,mdp,wec,f);
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

