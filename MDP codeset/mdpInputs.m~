%forecast parameters
frc.stagelimit = false;          %toggle limit on stages
frc.stagelimitval = 8;          %[h] limit on stages
frc.sub = 0;                    %[hr] model spin up buffer

%MDP parameters:
mdp.n = 20;                     %number of states
mdp.m = 4;                      %number of actions
mdp.eps = 7;                    %aggressiveness factor
mdp.mu = mdp.eps*[1 .9 .1 0];   %functional penalties
mdp.beta_lb = 0.75;             %lower bound % for beta()
mdp.b = 1;                      %steepness factor for beta()
mdp.dt = 1;                     %time between stages

%AMP parameters:
amp.E_max = 5000;                       %[Wh], maximum battery capacity
amp.E = linspace(0,amp.E_max,mdp.n);    %[Wh], discretized battery state
amp.E_start = amp.E(round(mdp.n/2));    %[Wh], starting battery level
amp.Ps = [1 45 450 600];                %[W], power consumption per
amp.sdr = 2;                            %[%/month] self discharge rate

%WEC parameters:
wec.Hsm = 2;            %[m], height median
wec.Tpm = 8;            %[s], period median
wec.w = 60;             %[~], width of normal dist
wec.r = 5000;           %[W], rated (max) power of device
wec.cw = 1;             %[m], capture width at peak
wec.eta_ct = 0.6;       %[~], conversion efficiency
wec.house = 0.10;       %percent of rated power as house load
wec.FO = false;         %toggle fred olsen 
wec.tp_N = 1000;        %discretization for Tp skewed gaussian fit
wec.med_prob = 0.1;     %median probability for fitting skewed gaussian
wec.tp_res = 0.3;       %multiplier on median tp for resonance
wec.tp_rated = 1;       %multiplier on median tp for rated power
wec.hs_res = 1;         %multiplier on median hs for resonance
wec.hs_rated = 2;       %multiplier on median hs for rated power

%SIM parameters:
sim.F = size(FM,2);         %simulation extent (number of forecasts)
sim.pb = false;             %toggle for posterior bound
sim.notif = 1000;           %notifications every __ forecasts
sim.debug = false;          %include debugging variables in output
sim.multiple = false;       %multiple simulations?
sim.multiple_pb = true;     %toggle for pb comparison

%sensitivity parameters
sim.tuned_parameter = 'eps'; %epsilon
sim.tuning_array = []; 
sim.tuned_parameter = 'sub'; %spin up buffer
sim.tuning_array = []; 
sim.tuned_parameter = 'slv'; %stage limit value
sim.tuning_array = [180 130 80 60 40 20]; 

