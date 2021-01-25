function [policy,Jstar,compare,state_evol,wec_power] = ...
    backwardRecursion_par(FM_P,mdp,amp,sim,wec,f)

%preallocate backward recursion matrices
policy = zeros(mdp.n,mdp.T); %optimal action for each state and stage
compare = zeros(mdp.n,mdp.m,mdp.T+1); %compares the value of each action
Jstar = zeros(mdp.n,mdp.T+1);   %values to go for each state and stage
state_evol = zeros(mdp.n,mdp.m,mdp.T+1); %state evolution matrix
if sim.debug
    wec_power = zeros(1,mdp.T); %wec power for debugging
end

pb = sim.pb; %posterior bound toggle

%find extent of forecast, Tf (which depends on how recent the forecast
%is) by searching for start of NaN values
Tf = find(~isnan(FM_P(:,f,2)),1,'last');
for t=Tf:-1:1 %over all stages, starting backward (backward recursion)
    if sim.debug
        wec_power(t) = FM_P(t,f,2); %power produced by wec
    end
    %parallelization setup
    if isempty(gcp('nocreate')) %no parallel pool running
        cores = feature('numcores'); %find number of cores
        %if cores > 1 %only start if using HPC (1 if debug in matlab ide)
        parpool(cores);
        %end
    end
    %preallocate
    %compare_sa = zeros(mdp.n,mdp.m);
    %state_evol_sa = zeros(mdp.n,mdp.m);
    P_fc = FM_P(t,f,2); %forecast power
    P_pb = FM_P(1,f+t-1,2); %posterior bound power
    tsltic = tic;
    parfor (s = 1:mdp.n,sim.mw) %over all states in parallel
        tic;
        [Jstar_s(s),policy_s(s),compare_a,state_evol_a] = ...
            evaluateActions(Jstar,P_fc,P_pb,amp,mdp,pb,wec,t,s);
%         [Jstar_s(s),policy_s(s),compare_a,state_evol_a] = ...
%             evaluateActions(Jstar,FM_P,amp,mdp,sim,wec,f,t,s);
        compare_sa(s,:) = compare_a;
        state_evol_sa(s,:) = state_evol_a;
        %disp(['s = ' num2str(s) ' of ' num2str(mdp.n)  ...
        %    ' t = ' num2str(t) ' f = ' num2str(f)])
        tea(s) = toc*1000;
    end
    tsl(t) = toc(tsltic)*1000;
    disp(['Par max ea RT = ' num2str(round(max(tea),2)) 'ms.'])
    Jstar(:,t) = Jstar_s;
    policy(:,t) = policy_s;
    compare(:,:,t) = compare_sa;
    state_evol(:,:,t) = state_evol_sa;
    
end

disp(['Par state loop mean RT = ' num2str(round(mean(tsl),2)) 'ms.'])


