function [policy,Jstar,compare,state_evol,wec_power] = ...
    backwardRecursion(FM_P,mdp,amp,sim,wec,frc,f)

%preallocate backward recursion matrices
policy = zeros(mdp.n,mdp.T); %optimal action for each state and stage
compare = zeros(mdp.n,mdp.m,mdp.T+1); %compares the value of each action
Jstar = zeros(mdp.n,mdp.T+1); %values to go for each state and stage
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
    if frc.add_err %add error to forecasted (mdp) power
        if frc.err_type == 1 %randomizer
            P_fc = FM_P(t,f,2)*frc.rand(f);
        elseif frc.err_type == 2 %sinusoidal error
            P_fc = FM_P(t,f,2)*frc.sinu(f);
        end
    else %no error to forecasted power
        P_fc = FM_P(t,f,2);
    end
    if sim.pb == 1  %posterior bound power
        P_pb = FM_P(1,f+t-1,2);
    else
        P_pb = [];
    end
    %reduce overhead by unpacking variables from matrices and structs
    Jstar_t1 = Jstar(:,t+1); %Jstar one time step ahead
    E = amp.E; %discretized battery capacities
    Ps = amp.Ps; %sensor loads
    sdr = amp.sdr; %self discharge rate
    E_max = amp.E_max; %maximum battery capacity
    dt = mdp.dt; %time discretization
    pb = sim.pb; %posterior bound toggle
    %b = mdp.b; %b value for beta function
    %beta_lb = mdp.beta_lb; %lower bound for beta function
    mu = mdp.mu; %sensing penalties
    alpha = mdp.alpha; %discount factor
    m = mdp.m; %number of states
    for s = 1:mdp.n %over all states
        [Jstar_s(s),policy_s(s),compare_sa(s,:),state_evol_sa(s,:)] = ...
            evaluateActions(Jstar_t1,P_fc,P_pb,E,Ps,sdr,E_max, ...
            dt,pb,mu,alpha,m,t,s);
    end
    Jstar(:,t) = Jstar_s;
    policy(:,t) = policy_s;
    if sim.debug
        compare(:,:,t) = compare_sa;
        state_evol(:,:,t) = state_evol_sa;
    end
end

