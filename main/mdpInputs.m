%interactive job - set values
%limits
frc.stagelimit = false; %toggle limit on stages
frc.stagelimitval = 10; %[h] limit on stages
frc.Flimit = false; %to shorten runtime
frc.Flimitval = 200; %number of forecasts to simulate
%one simulation types
sim.pb = false; %toggle for posterior bound in one sim
sim.sl = false; %toggle for simple logic in one sim
sim.slv2 = false; %toggle for simple logic v2 in one sim
%multiple simulation types
sim.tdsens = true; %2-D sensitivity analysis
sim.senssm = false; %sensitivity small multiple
%battery discretization
sim.use_d_n = true; %battery discretization set by constant delta
sim.exdist = false; %batt disc set externally (multiple only, outdated)

if ~exist('batchtype','var')
    batchtype = [];
    batchsim =[];
    batchpar1 = [];
    patchpar2 = [];
end
if isequal(batchtype,'tds')
    sim.tdsens = true;
    if isequal(batchsim,'mdp')
        sim.pb = false;
        sim.sl = false;
        sim.slv2 = false;
    elseif isequal(batchsim,'pbo')
        sim.pb = true;
        sim.sl = false;
        sim.slv2 = false;
    elseif isequal(batchsim,'slo')
        sim.pb = false;
        sim.sl = true;
        sim.slv2 = false;
    elseif isequal(batchsim,'sl2')
        sim.pb = false;
        sim.sl = false;
        sim.slv2 = true;
    end
    if isequal(batchpar1,'emx') && isequal(batchpar2,'wcd')
        sim.tuning_array1 = [1000 2500 5000:5000:35000]; %[Wh]
        %sim.tuning_array1 = [1000 2500]; %[Wh]
        sim.tuning_array2 = [2 3 4 5];
        sim.tuned_parameter{1} = 'emx'; %E max
        sim.tuned_parameter{2} = 'wcd'; %wec characteristic diameter
    elseif isequal(batchpar1,'eps') && isequal(batchpar2,'nll')
        sim.tuning_array1 = [0.1 0.5 1 5 10 100 1000 10000 100000]; %[~]
        sim.tuning_array2 = 1;
        sim.tuned_parameter{1} = 'eps'; %epsilon
        sim.tuned_parameter{2} = 'nll';
        beta_on = true;
    end
elseif isequal(batchtype,'ssm')
    sim.senssm = true;
    if isequal(batchsim,'mdp')
        sim.pb = false;
        sim.sl = false;
        sim.slv2 = false;
    elseif isequal(batchsim,'pbo')
        sim.pb = true;
        sim.sl = false;
        sim.slv2 = false;
    elseif isequal(batchsim,'slo')
        sim.pb = false;
        sim.sl = true;
        sim.slv2 = false;
    elseif isequal(batchsim,'sl2')
        sim.pb = false;
        sim.sl = false;
        sim.slv2 = true;
    end
    batchpar1 = [];
    batcharr1 = [];
    patchpar2 = [];
    batcharr2 = [];
end
     
%SIM parameters:
sim.brpar = false;         %parallelizing backward recursions (outdated)
sim.expar = true;           %parallelizing simulations (def true)
sim.notif = 500;             %notifications every __ forecasts
sim.debug = false;          %include debugging variables in output
sim.debug_brpar = false;      %debug HPC runtime and overhead
sim.corelim = 2;            % numcores > corelim == using HPC
if feature('numcores') > sim.corelim  %check to see if HPC
    sim.hpc = true;
    sim.mw = 36; %max workers
else %not using an HPC
    sim.hpc = false;
    sim.mw = 0; %max workers
    sim.expar = false;
    sim.brpar = false;
end

%FORECAST parameters:
frc.sub = 3;                    %[hr] model spin up buffer

%AMP parameters:
amp.E_max = 10000;                      %[Wh], maximum battery capacity
if ~sim.hpc 
    amp.E_max = 10000; %shorten runtime if using laptop
end
%amp.E = linspace(0,amp.E_max,mdp.n);   %[Wh], discretized battery state
amp.Ps = [1 45 450 600];                %[W], power consumption per
amp.sdr = 3;                            %[%/month] self discharge rate
amp.fpr = 0.70;                         %simple logic full power ratio
amp.mpr = 0.65;                         %simple logic medium power ratio
amp.lpr = 0.15;                         %simple logic low power ratio
amp.tt = [12 3];                        %[h], time til depletion thresholds

%MDP parameters:
mdp.n = 25;                       %number of states [outdated]
mdp.d_n = 40;                       %[kWh] energy between states
mdp.m = 4;                          %number of actions
mdp.eps = 1;                      %aggressiveness factor
mdp.mu = mdp.eps*[1 .8 .2 0];       %functional penalties
%pseudocode start - enter this into simulate wamp (post sensitivity update)
% mdp.mu_mult = 5;
% mdp.mu = 1/(mdp.mu_mult)* ...
%     beta(mdp.d_n,0:mdp.d_n:amp.E_max,amp.E_max,mdp,b,mdp_lb);     
%pseudocode end - above goes in simulate wamp post sensitivity update
mdp.beta_lb = 0.5;           %lower bound % (of starting charge) for beta()
mdp.dt = 1;                         %time between stages
mdp.b = 0;                          %battery steepness [1: on, 0: off]
if exist('beta_on','var')
    mdp.b = 1;
end
mdp.alpha = .99;                    %discount factor

%WEC parameters:
wec.eta_ct = 0.6;           %[~], electrical efficiency
wec.h = 0.10;               %percent of rated power as house load
wec.B = 3;                  %[m]
wec.rho = 1020;             %[kg/m^3]
wec.g = 9.81;               %[m/s^2]
wec.Hs_ra = 4.5;              %[m] - 2 is default
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
if ~isfield(sim,'tuning_array') && ~isfield(sim,'tuned_parameter') ...
        && ~sim.senssm && sim.tdsens
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

%override batch variables
if exist('batchbeta','var')
    mdp.b = batchbeta;
end
if exist('batcheps','var')
    mdp.eps = batcheps;
    mdp.mu = mdp.eps*[1 .8 .2 0];       %functional penalties
end

