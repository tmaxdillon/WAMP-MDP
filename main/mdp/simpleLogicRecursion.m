function [Jstar] = ...
    simpleLogicRecursion(FM_P,mdp,amp,sim,wec,f)

Jstar = zeros(mdp.n,mdp.T+1); %values to go for each state and stage

%find extent of forecast, Tf (which depends on how recent the forecast
%is) by searching for start of NaN values
Tf = find(~isnan(FM_P(:,f,2)),1,'last');
for t=Tf:-1:1 %over all stages, starting backward (backward recursion)
    %reduce overhead by unpacking variables from matrices and structs
    Jstar_t1 = Jstar(:,t+1); %Jstar one time step ahead
    P_fc = FM_P(t,f,2); %forecast power
    P_pb = FM_P(1,f+t-1,2); %posterior bound power
    E = amp.E; %discretized battery capacities
    Ps = amp.Ps; %sensor loads
    sdr = amp.sdr; %self discharge rate
    E_max = amp.E_max; %maximum battery capacity
    dt = mdp.dt; %time discretization
    pb = sim.pb; %posterior bound toggle
    FO = wec.FO; %fred olsen toggle
    b = mdp.b; %b value for beta function
    beta_lb = mdp.beta_lb; %lower bound for beta function
    mu = mdp.mu; %sensing penalties
    alpha = mdp.alpha; %discount factor
    m = mdp.m; %number of states
    for s = 1:mdp.n %over all states in parallel
%         [Jstar_s(s),policy_s(s),compare_sa(s,:),state_evol_sa(s,:)] = ...
%             evaluateActions(Jstar_t1,P_fc,P_pb,E,Ps,sdr,E_max, ...
%             dt,pb,FO,b,beta_lb,mu,alpha,m,t,s);
        %1: find action given battery state
        if E(s) > amp.fpr*E_max
            a = 4;
        elseif E(s) > amp.mpr*E_max
            a = 3;
        elseif E(s) > amp.lpr*E_max
            a = 2;
        else
            a = 1;
        end
        %2: compute evolution of battery
        [~,E_evolved] = powerToBattery(P_pb, ...
            E(s),Ps(a),sdr,E_max,dt,FO);
            %do I use P_pb or P_fc?
        %3: find the state index of the evolved battery
        [~,state_evol_a(a)] = min(abs(E - E_evolved));
        %4: compute the 'value' of this action via bellman's equation
        Jstar(s,t) = beta(E(s),E,E_max,b,beta_lb) + mu(a) + ...
            Jstar_t1(state_evol_a(a))*alpha^t;
    end
end

end

