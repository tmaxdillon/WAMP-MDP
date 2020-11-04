%forecast parameters
frc.stagelimit = false;          %toggle limit on stages
frc.stagelimitval = 90;         %[h] limit on stages
frc.sub = 3;                    %[hr] model spin up buffer
frc.Flimit = false;             %to shorten runtime
frc.Flimitval = 100;            %number of forecasts to simulate

%MDP parameters:
mdp.n = 1000;                       %number of states
mdp.m = 4;                          %number of actions
mdp.eps = 100;                      %aggressiveness factor
mdp.mu = mdp.eps*[1 .8 .2 0];       %functional penalties
mdp.beta_lb = 2;                    %lower bound % (of starting charge) for beta()
mdp.dt = 1;                         %time between stages
mdp.b = 1;                          %battery steepness
mdp.alpha = .99;                    %discount factor

%AMP parameters:
amp.E_max = 2500;                       %[Wh], maximum battery capacity
%amp.E = linspace(0,amp.E_max,mdp.n);   %[Wh], discretized battery state
amp.Ps = [1 45 450 600];                %[W], power consumption per
amp.sdr = 3;                            %[%/month] self discharge rate
amp.fpr = 0.70;                         %simple logic full power ratio
amp.mpr = 0.65;                         %simple logic medium power ratio
amp.lpr = 0.15;                         %simple logic low power ratio

%WEC parameters:
wec.eta_ct = 0.6;           %[~], electrical efficiency
wec.h = 0.10;               %percent of rated power as house load
wec.B = 4;                  %[m]
wec.rho = 1020;             %[kg/m^3]
wec.g = 9.81;               %[m/s^2]
wec.Hs_ra = 4;              %[m]
wec.Tp_ra = 9;              %[s]
wec.F = getWecSimInterp();  %3-d interpolant (Tp, Hs, B) from wecsim
wec.FO = false;             %toggle fred. olsen

% wec.Hsm = 1;            %[m], height median
% wec.Tpm = 7;            %[s], period median
% wec.w = 60;             %[~], width of normal dist
% wec.r = 2;              %[kW], rated (max) power of device
% wec.tp_N = 1000;        %discretization for Tp skewed gaussian fit
% wec.med_prob = 0.1;     %median probability for fitting skewed gaussian
% wec.tp_res = 0.3;       %multiplier on median tp for resonance
% wec.tp_rated = 1;       %multiplier on median tp for rated power
% wec.hs_res = 1;         %multiplier on median hs for resonance
% wec.hs_rated = 2;       %multiplier on median hs for rated power
% wec.cutout = 15;        %wavepower X times ratedpower initiates cutout

%SIM parameters:
sim.pb = false;             %toggle for posterior bound in one sim
sim.sl = false;             %toggle for simple logic in one sim
sim.notif = 100;            %notifications every __ forecasts
sim.debug = false;          %include debugging variables in output
sim.multiple = false;       %multiple simulations?
sim.multiple_pb = true;     %toggle for posterior bound comparison
sim.multiple_sl = false;    %toggle for simple logic comparison
if feature('numcores') > 2  %check to see if HPC
    sim.hpc = true;
else
    sim.hpc = false;
end
sim.mw = 36;                %max workers

%sensitivity parameters
% sim.tuned_parameter = 'eps'; %epsilon
% sim.tuning_array = []; 
% sim.tuned_parameter = 'sub'; %spin up buffer
% sim.tuning_array = []; 
% sim.tuned_parameter = 'slv'; %stage limit value
% sim.tuning_array = [180 130 80 60 40 20]; 
sim.tuned_parameter = 'emx'; %maximum storage capacity
sim.tuning_array = [2500 5000 7500 10000 12500];

