function [compare_a,state_evol_a] = ...
    evaluateActions(Jstar,FM_P,amp,mdp,sim,wec,f,t,s)

%preallocate
state_evol_a = zeros(1,mdp.m);
compare_a = zeros(1,mdp.m);

for a=1:mdp.m %over all actions
    %1: compute evolution of battery
    if sim.pb == 0 % using forecast
        [~,E_evolved] = powerToBattery(FM_P(t,f,2),amp.E(s), ...
            amp.Ps(a),amp,mdp,wec);
    elseif sim.pb == 1 % posterior bound
        [~,E_evolved] = powerToBattery(FM_P(1,f+t-1,2), ...
            amp.E(s),amp.Ps(a),amp,mdp,wec);
    end
    %2: find the state index of the evolved battery
    [~,state_evol_a(a)] = min(abs(amp.E - E_evolved));
    %3: compute the 'value' of this action via bellman's equation
    compare_a(a) = beta(amp.E(s),amp,mdp) + mdp.mu(a) +  ...
        Jstar(state_evol_a(a),t+1)*mdp.alpha^t;
end

end

