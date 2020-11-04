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
        if cores > 2 %only start if using HPC
            parpool(cores);
        end
    end
    %preallocate
    compare_sa = zeros(mdp.n,mdp.m);
    state_evol_sa = zeros(mdp.n,mdp.m);
    parfor (s = 1:mdp.n,sim.mw) %over all states in parallel
        [compare_sa(s,:),state_evol_sa(s,:)] = ...
            evaluateActions(Jstar,FM_P,amp,mdp,sim,wec,f,t,s);
        %compare the value of the four actions, finding the optimal
        %value to go and the optimal policy
        [Jstar_s(s),policy_s(s)] = min(compare_sa(s,:));
    end
    Jstar(:,t) = Jstar_s;
    policy(:,t) = policy_s;
    compare(:,:,t) = compare_sa;
    state_evol(:,:,t) = state_evol_sa;
    
end


