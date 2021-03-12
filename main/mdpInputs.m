%interactive job
frc.stagelimit = true;          %toggle limit on stages
frc.stagelimitval = 100;         %[h] limit on stages
frc.Flimit = true;              %to shorten runtime
frc.Flimitval = 300;              %number of forecasts to simulate
sim.multiple = false;       %multiple simulations?
sim.pb = true;             %toggle for posterior bound in one sim
sim.sl = false;              %toggle for simple logic in one sim
sim.exdist = true;                  %battery discretization set externally

if ~exist('batchtype','var')
    batchtype = [];
    batchsim =[];
    batchpar1 = [];
    batcharr1 = [];
    patchpar2 = [];
    batcharr2 = [];
end
if isequal(batchtype,'mult')
    sim.multiple = true;
    if isequal(batchsim,'mdp')
        sim.pb = false;
        sim.sl = false;
    elseif isequal(batchsim,'pbo')
        sim.pb = true;
        sim.sl = false;
    elseif isequal(batchsim,'slo')
        sim.pb = false;
        sim.sl = true;
    end
    if isequal(batchpar1,'emx') && isequal(batchpar2,'wcd')
        sim.tuning_array1 = [1000 2500 5000:5000:25000]; %[Wh]
        sim.tuning_array2 = [2 3 4 5];
        sim.tuned_parameter{1} = 'emx'; %E max
        sim.tuned_parameter{2} = 'wcd'; %wec characteristic diameter
    end
end
     
%SIM parameters:
sim.hr_on = false;          %toggle enabling high res state space
sim.brpar = false;         %parallelized backward recursion
sim.expar = true;           %parallelized multiple simulations
sim.notif = 500;             %notifications every __ forecasts
sim.debug = true;          %include debugging variables in output
sim.debug_brpar = false;      %debug HPC runtime and overhead
sim.corelim = 1;            % numcores > corelim == using HPC
if feature('numcores') > sim.corelim  %check to see if HPC
    sim.hpc = true;
    sim.mw = 36; %max workers
else
    sim.hpc = false;
    sim.mw = 0; %max workers
end

%FORECAST parameters:
frc.sub = 3;                    %[hr] model spin up buffer

%MDP parameters:
mdp.n = 20;                       %number of states
mdp.m = 4;                          %number of actions
mdp.eps = 100000;                      %aggressiveness factor
mdp.mu = mdp.eps*[1 .8 .2 0];       %functional penalties
mdp.beta_lb = 0.5;                    %lower bound % (of starting charge) for beta()
mdp.dt = 1;                         %time between stages
mdp.b = 1;                          %battery steepness
mdp.alpha = .99;                    %discount factor

%AMP parameters:
amp.E_max = 500;                       %[Wh], maximum battery capacity
%amp.E = linspace(0,amp.E_max,mdp.n);   %[Wh], discretized battery state
amp.Ps = [1 45 450 600];                %[W], power consumption per
amp.sdr = 3;                            %[%/month] self discharge rate
amp.fpr = 0.70;                         %simple logic full power ratio
amp.mpr = 0.65;                         %simple logic medium power ratio
amp.lpr = 0.15;                         %simple logic low power ratio

%WEC parameters:
wec.eta_ct = 0.6;           %[~], electrical efficiency
wec.h = 0.10;               %percent of rated power as house load
wec.B = 2;                  %[m]
wec.rho = 1020;             %[kg/m^3]
wec.g = 9.81;               %[m/s^2]
wec.Hs_ra = 4;              %[m]
wec.Tp_ra = 9;              %[s]
wec.F = getWecSimInterp();  %3-d interpolant (Tp, Hs, B) from wecsim
wec.FO = false;             %toggle fred. olsen

%sensitivity parameters, CLEAR IF NOT RUNNING
% if isfield(sim,'tuned_parameter')
%     sim = rmfield(sim,'tuned_parameter');
% end
% if isfield(sim,'tuning_array')
%     sim = rmfield(sim,'tuning_array');
% end
if ~isfield(sim,'tuning_array') && ~isfield(sim,'tuned_parameter')
    sim.tuning_array1 = 1000:2000:17000;
    sim.tuning_array2 = [1 2 3 4 5 6];
    sim.tuned_parameter{1} = 'emx'; %rated Hs
    sim.tuned_parameter{2} = 'wcd'; %rated Tp
    % sim.tuned_parameter = 'eps'; %epsilon
    % sim.tuning_array = [];
    % sim.tuned_parameter = 'sub'; %spin up buffer
    % sim.tuning_array = [];
    % sim.tuned_parameter = 'slv'; %stage limit value
    % sim.tuning_array = [180 130 80 60 40 20];
    % sim.tuned_parameter = 'emx'; %maximum storage capacity
    % sim.tuning_array = [500 2500 5000 7500];
    % sim.tuned_parameter = 'ess'; %energy system size
    % sim.tuning_array = [3 4 5 6 ; 1500 3000 6000 10000];
end

