function [Jstar,policy,compare_a,state_evol_a] = ...
    evaluateActions(Jstar_t1,P_fc,P_pb,E,Ps,sdr,E_max,dt,pb,FO, ...
    b,beta_lb,mu,alpha,m,t,s)

%preallocate
state_evol_a = zeros(1,m);
compare_a = zeros(1,m);

for a=1:m %over all actions
    %1: compute evolution of battery
    if pb == 0 % using forecast
        [~,E_evolved] = powerToBattery(P_fc, ...
            E(s),Ps(a),sdr,E_max,dt,FO);
    elseif pb == 1 % posterior bound
        [~,E_evolved] = powerToBattery(P_pb, ...
            E(s),Ps(a),sdr,E_max,dt,FO);
    end
    %2: find the state index of the evolved battery
    [~,state_evol_a(a)] = min(abs(E - E_evolved));
    %3: compute the 'value' of this action via bellman's equation
    compare_a(a) = beta(E(s),E,E_max,b,beta_lb) + mu(a) +  ...
        Jstar_t1(state_evol_a(a))*alpha^t;
    %  ^ maybe divide Jstar by t as an alternative to discount factor?
end

%compare the value of the four actions, finding the optimal
%value to go and the optimal policy
[Jstar,policy] = min(compare_a);
%disp(['Jstar equals = ' num2str(Jstar)])

end

