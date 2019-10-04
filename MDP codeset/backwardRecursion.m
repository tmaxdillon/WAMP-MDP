function [Jstar,policy,compare,state_evol,wec_power] = ...
    backwardRecursion(FM_P,mdp,amp,sim,wec,f)

%preallocate backward recursion matrices
Jstar = zeros(mdp.n,mdp.T+1);   %optimal values to go for each state and stage
policy = zeros(mdp.n,mdp.T);    %optimal policy (action) for each state and stage
compare = zeros(mdp.n,mdp.m,mdp.T+1); %array to compare the value of each action
state_evol = zeros(mdp.n,mdp.m,mdp.T+1); %state evolution matrix
if sim.debug
    wec_power = zeros(1,mdp.T); %wec power for debugging
end

%find extent of forecast, Tf (which depends on how recent the forecast
%is) by searching for start of NaN values
pts = find(isnan(FM_P(:,f,2)) == 0);
Tf = max(pts);

for t=Tf:-1:1 %over all stages, starting backward (backward recursion)
    for s=1:mdp.n %over all states
        for a=1:mdp.m %over all actions
                      
            %1: compute evolution of battery:
            % using forecast
            if sim.pb == 0
                if sim.debug
                    wec_power(t) = FM_P(t,f,2); %power produced by wec
                end
                [~,E_evolved] = powerToBattery(FM_P(t,f,2),amp.E(s), ... 
                    amp,mdp,wec);
                % posterior bound
            elseif sim.pb == 1
                if sim.debug
                    wec_power(t) = FM_P(1,f+t-1,2); %power produced by wec
                end
                [~,E_evolved] = powerToBattery(FM_P(1,f+t-1,2),amp.E(s), ... 
                    amp,mdp,wec);
            end
            
            %2: find the state index of the evolved battery
            [~,state_evol(s,a,t)] = min(abs(amp.E - E_evolved));
            
            %3: compute the 'value' of this action via bellman's equation
            compare(s,a,t) = beta(amp.E(s),amp,mdp) + mdp.mu(a) +  ...
                Jstar(state_evol(s,a,t),t+1);
            
        end
        
        %compare the value of the four actions, finding the optimal
        %value to go and the optimal policy
        [Jstar(s,t),policy(s,t)] = min(compare(s,:,t));
        
    end
end


