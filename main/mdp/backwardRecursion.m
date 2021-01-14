function [policy,Jstar,compare,state_evol,wec_power] = ...
    backwardRecursion(FM_P,mdp,amp,sim,wec,f)

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
%     %ORIGINAL LOOP
%     for s=1:mdp.n %over all states
%         for a=1:mdp.m %over all actions            
%             %1: compute evolution of battery            
%             if sim.pb == 0 % using forecast
%                 if sim.debug
%                     wec_power(t) = FM_P(t,f,2); %power produced by wec
%                 end
%                 [~,E_evolved] = powerToBattery(FM_P(t,f,2),amp.E(s), ...
%                     amp.Ps(a),amp,mdp,wec);                
%             elseif sim.pb == 1 % posterior bound
%                 if sim.debug
%                     wec_power(t) = FM_P(1,f+t-1,2); %power produced by wec
%                 end
%                 [~,E_evolved] = powerToBattery(FM_P(1,f+t-1,2), ...
%                 amp.E(s),amp.Ps(a),amp,mdp,wec);
%             end            
%             %2: find the state index of the evolved battery
%             [~,state_evol(s,a,t)] = min(abs(amp.E - E_evolved));            
%             %3: compute the 'value' of this action via bellman's equation
%             compare(s,a,t) = beta(amp.E(s),amp,mdp) + mdp.mu(a) +  ...
%                 Jstar(state_evol(s,a,t),t+1)*mdp.alpha^t;          
%         end        
%         %compare the value of the four actions, finding the optimal
%         %value to go and the optimal policy
%         [Jstar(s,t),policy(s,t)] = min(compare(s,:,t));
%         %  ^ maybe divide Jstar by t as an alternative to discount factor?
%     end
    %PARALLELIZED EQUIVALENT
    for s=1:mdp.n
        [Jstar_s(s),policy_s(s),compare_a,state_evol_a] = ...
            evaluateActions(Jstar,FM_P,amp,mdp,sim,wec,f,t,s);
        %compare the value of the four actions, finding the optimal
        %value to go and the optimal policy
        %[Jstar_s(s),policy_s(s)] = min(compare_sa(s,:));
        compare_sa(s,:) = compare_a;
        state_evol_sa(s,:) = state_evol_a;
    end
    Jstar(:,t) = Jstar_s;
    policy(:,t) = policy_s;
    compare(:,:,t) = compare_sa;
    state_evol(:,:,t) = state_evol_sa;
end


