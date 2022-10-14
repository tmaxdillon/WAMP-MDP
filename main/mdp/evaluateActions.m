function [Jstar,tau,policy,compare_a,state_evol_a] = ...
    evaluateActions(Jstar_t1,tau_t1,P_fc,P_pb,E,Ps,sdr,E_max,dt,pb, ...
    mu,alpha,m,t,s,blogic,tautog,tau_x,theta_a)

%preallocate
state_evol_a = zeros(1,m);
compare_a = zeros(1,m);
tau_a = zeros(1,m);

for a=1:m %over all actions
    %1: compute evolution of battery and find actual achievable action
    if pb == 0 % using forecast
        [~,a_act,~,E_evolved] = ...
            powerBalance(P_fc,E(s),a,sdr,E_max,Ps,dt,blogic);
    elseif pb == 1 % posterior bound
        [~,a_act,~,E_evolved] = ...
            powerBalance(P_pb,E(s),a,sdr,E_max,Ps,dt,blogic);
    end
    %2: find the state index of the evolved battery
    [~,state_evol_a(a)] = min(abs(E - E_evolved));
    %3: compute the 'value' of this action via bellman's equation
    if tautog
        if a_act >= 3 %full power, turn tau off
            tau_a(a) = 0;
        else %didn't enter full power, increase tau by 1
            tau_a(a) = tau_t1(state_evol_a(a)) + 1;
        end
    else
        tau_a(a) = 0;
    end
    compare_a(a) = mu(a_act) + Jstar_t1(state_evol_a(a))*alpha^t ...
        + (tau_x^tau_a(a)-1) + theta_a(a_act);
    %  ^ maybe divide Jstar by t as an alternative to discount factor?
end

%compare the value of the four actions, finding the optimal
%value to go and the optimal policy
[Jstar,policy] = min(compare_a);
tau = tau_a(policy); %record tau for next time step
%disp(['Jstar equals = ' num2str(Jstar)])

end

