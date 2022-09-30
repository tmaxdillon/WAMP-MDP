function [Jstar] = ...
    simpleLogicRecursion(FM_P,mdp,amp,sim,wec,v,f)

%preallocate
Jstar = zeros(mdp.n,mdp.T+1); %values to go for each state and stage
tau = zeros(mdp.n,mdp.T+1); %tau penalty values for each state 
tau_a = zeros(1,mdp.m);
state_evol_a = zeros(1,mdp.m);

%find extent of forecast, Tf (which depends on how recent the forecast
%is) by searching for start of NaN values
Tf = find(~isnan(FM_P(:,f,2)),1,'last');
for t=Tf:-1:1 %over all stages, starting backward (backward recursion)
    %reduce overhead by unpacking variables from matrices and structs
    Jstar_t1 = Jstar(:,t+1); %Jstar one time step ahead
    tau_t1 = tau(:,t+1); %time penalty one step ahead
    %P_fc = FM_P(t,f,2); %forecast power, which should be used? fc or pb?
    P_pb = FM_P(1,f+t-1,2); %posterior bound power
    E = amp.E; %discretized battery capacities
    Ps = amp.Ps; %sensor loads
    sdr = amp.sdr; %self discharge rate
    E_max = amp.E_max; %maximum battery capacity
    dt = mdp.dt; %time discretization
    pb = sim.pb; %posterior bound toggle
    FO = wec.FO; %fred olsen toggle
    mu = mdp.mu; %sensing penalties
    alpha = mdp.alpha; %discount factor
    m = mdp.m; %number of states
    blogic = amp.blogic; %bottom out logic
    tautog = mdp.tau; %tau toggle
    tt = amp.tt; %time til depletion thresholds
    for s = 1:mdp.n %over all states in parallel
        %1: find action given battery state
        if v == 1 %version 1
            if E(s) > amp.fpr*E_max
                a = 4;
            elseif E(s) > amp.mpr*E_max
                a = 3;
            elseif E(s) > amp.lpr*E_max
                a = 2;
            else
                a = 1;
            end
        elseif v == 2 %version 2
            tte = E(s)/(amp.Ps(3) - P_pb + E(s)*sdr/(100*30*24)); %[h]
            if tte < 0 %producing more power than consuming, full power
                a = 4;
            elseif tte > tt(1) %more than tt(1) hours to deplation, med power
                a = 3;
            elseif tte > tt(2) %more than tt(2) hours to depletion, low power
                a = 2;
            else %less than three hours to deplation, survival mode
                a = 1;
            end
        elseif v == 3
            a = 4;
        end
        %2: compute evolution of battery
%         [~,E_evolved] = powerToBattery(P_pb, ...
%             E(s),Ps(a),sdr,E_max,dt,FO);
        [~,a_act,~,E_evolved] = ...
            powerBalance(P_pb,E(s),a,sdr,E_max,Ps,dt,blogic);
        %do I use P_pb or P_fc?, ask Archis
        %3: find the state index of the evolved battery
        [~,state_evol_a(a)] = min(abs(E - E_evolved));
        %4: compute the 'value' of this action via bellman's equation
        if tautog
            if a_act >= 3 %full power, turn tau off
                tau_a(a) = 0;
            else %didn't enter full power, increase tau by 1
                tau_a(a) = tau_t1(state_evol_a(a)) + 1;
            end
        else
            tau_a(a) = 0;
        end
        Jstar(s,t) = mu(a_act) + Jstar_t1(state_evol_a(a))*alpha^t ...
            +tau_a(a);
    end
end

end

