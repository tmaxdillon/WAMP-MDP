function [Jstar,policy,compare_a,state_evol_a] = ...
    evaluateActions(Jstar,P_fc,P_pb,amp,mdp,pb,wec,t,s)

%preallocate
state_evol_a = zeros(1,mdp.m);
compare_a = zeros(1,mdp.m);

for a=1:mdp.m %over all actions
    %1: compute evolution of battery
    if pb == 0 % using forecast
        [~,E_evolved] = powerToBattery(P_fc, ...
            amp.E(s),amp.Ps(a),amp,mdp,wec);
    elseif pb == 1 % posterior bound
        [~,E_evolved] = powerToBattery(P_pb, ...
            amp.E(s),amp.Ps(a),amp,mdp,wec);
    end
    %2: find the state index of the evolved battery
    [~,state_evol_a(a)] = min(abs(amp.E - E_evolved));
    %3: compute the 'value' of this action via bellman's equation
    compare_a(a) = beta(amp.E(s),amp,mdp) + mdp.mu(a) +  ...
        Jstar(state_evol_a(a),t+1)*mdp.alpha^t;
    %  ^ maybe divide Jstar by t as an alternative to discount factor?
end

%compare the value of the four actions, finding the optimal
%value to go and the optimal policy
[Jstar,policy] = min(compare_a);
%disp(['Jstar equals = ' num2str(Jstar)])

end

