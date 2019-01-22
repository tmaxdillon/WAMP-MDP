function [Jstar,policy,compare,state_evol,wave_params] = ...
    backwardRecursion(FM,mdp,amp,wec,sim,f)

%preallocate backward recursion matrices
Jstar = zeros(mdp.n,mdp.T+1);   %optimal values to go for each state and stage
policy = zeros(mdp.n,mdp.T);    %optimal policy (action) for each state and stage
compare = zeros(mdp.n,mdp.m,mdp.T+1); %array to compare the value of each action
state_evol = zeros(mdp.n,mdp.m,mdp.T+1); %state evolution matrix
if sim.debug
    wave_params = zeros(2,mdp.T); %wave parameters
end

%find extent of forecast, Tf (which depends on how recent the forecast
%is) by searching for start of NaN values
pts = find(isnan(FM(:,f,2)) == 0);
Tf = max(pts)-1;

%exclude forecasts impacted by model spin up by finding limit
if Tf >= mdp.stagelimitval-mdp.sub
    lim = mdp.sub - (mdp.stagelimitval - Tf) + 1;
else
    lim = 0;
end

%add stage limit if there is a stage limit and it applies
if mdp.stagelimit && mdp.stagelimitval < Tf
    Tf = mdp.stagelimitval;
end

for t=Tf:-1:1 %over all stages, starting backward (backward recursion)
    for s=1:mdp.n %over all states
        for a=1:mdp.m %all possible actions
            
            %1: compute evolution of battery:
            % current charge - time*(power consumed - power produced)
            if sim.pb == 0
                %avoid using model spin up forecast
                if t <= lim
                    if sim.debug
                        wave_params(1,t) = FM(1,lim+1,2); %Hs
                        wave_params(2,t) = FM(1,lim+1,3); %Tp
                    end
                    E_evolved = amp.E(s) - mdp.dt*(amp.Ps(a) - ...
                        powerToAMP(powerFromWEC(FM(lim+1,f,2),FM(lim+1,f,3),wec), ...
                        amp.E(s),amp,mdp,sim));
                else
                    if sim.debug
                        wave_params(1,t) = FM(1,t,2); %Hs
                        wave_params(2,t) = FM(1,t,3); %Tp
                    end
                    E_evolved = amp.E(s) - mdp.dt*(amp.Ps(a) - ...
                        powerToAMP(powerFromWEC(FM(t,f,2),FM(t,f,3),wec), ...
                        amp.E(s),amp,mdp,sim));
                end
            elseif sim.pb == 1
                %[~,fptc] = find(FM(1,:,1) == FM(t+1,f,1));
                %more robust, but slower ^
                wave_params(1,t) = FM(1,f+t-1,2); %Hs
                wave_params(2,t) = FM(1,f+t-1,3); %Tp
                E_evolved = amp.E(s) - mdp.dt*(amp.Ps(a) - ...
                    powerToAMP(powerFromWEC(FM(1,f+t-1,2),FM(1,f+t-1,3),wec), ...
                    amp.E(s),amp,mdp,sim));
            end
            
            %2: find the state index of the evolved battery
            [~,state_evol(s,a,t)] = min(abs(amp.E - E_evolved));
            
            %3: compute the 'value' of this action via bellman's equation
            % (keep in mind larger values are undesireable)
            compare(s,a,t) = beta(amp.E(s),amp,mdp) + mdp.mu(a) +  ...
                Jstar(state_evol(s,a,t),t+1);
            
        end
        
        %compare the value of the four actions, finding the optimal
        %value to go and the optimal policy
        [Jstar(s,t),policy(s,t)] = min(compare(s,:,t));
        
    end
end
end

