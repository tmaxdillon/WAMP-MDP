%interactive job - set values
mdp.d_n = 20; %[Wh] energy between states - 15-25
%forecast settings
frc.stagelimit = false; %toggle limit on stages
frc.stagelimitval = 2; %[h] limit on stages
frc.Flimit = false; %to shorten runtime
frc.Flimitval = 2; %number of forecasts to simulate
frc.add_err = false; %add error to forecast
frc.err_type = 1; %1: randomness multiplier 2: sinusoid
frc.pb_abr = true; %toggle on to abridge simulation to the pb limit always
frc.abr_val = 1790; %forecast abridge value
%simulation types
sim.pb = false; %toggle for posterior bound
sim.sl = false; %toggle for simple logic
sim.slv2 = false; %toggle for simple logic v2
sim.slv3 = true; %toggle for simple logic v3
%multiple simulation types
sim.tdsens = false; %2-D sensitivity analysis
sim.senssm = false; %sensitivity small multiple (outdated)
sim.ssm_ca = false; %sensitivity small multiple cap analysis (outdated)
sim.pyssm = false; %sensitivy small multiple (python)
%battery discretization
sim.use_d_n = true; %battery discretization set by constant delta
%sim.exdist = false; %batt disc set externally (multiple only, outdated)
sim.round = 2; %1: nearest disc value, 2: dynamic
%notifications
sim.notif = true; %surpress simulateWAMP notifications
sim.d_notif = 10; %notifications every __ forecasts

if ~exist('batchtype','var')
    batchtype = [];
    batchsim =[];
    batchpar1 = [];
    patchpar2 = [];
    batchbeta = [];
    batcheps = [];
    batcherr = [];
    batchlims = [];
    sim.tuning_array1 = [2500 5000:5000:35000]; %[Wh]
    sim.tuning_array2 = [2 3 4 5];
    sim.tuned_parameter{1} = 'emx'; %E max
    sim.tuned_parameter{2} = 'wcd'; %wec characteristic diameter
end
if batchlims %limits on
    frc.stagelimit = true; %toggle limit on stages
    frc.Flimit = true; %to shorten runtime
elseif ~batchlims %limits off
    frc.stagelimit = false; %toggle limit on stages
    frc.Flimit = false; %to shorten runtime
end
if isequal(batchtype,'tds')
    sim.tdsens = true;
    sim.senssm = false;
    sim.pyssm = false;
    if isequal(batchsim,'mdp')
        sim.pb = false;
        sim.sl = false;
        sim.slv2 = false;
        sim.sv3 = false;
    elseif isequal(batchsim,'pbo')
        sim.pb = true;
        sim.sl = false;
        sim.slv2 = false;
        sim.sv3 = false;
    elseif isequal(batchsim,'slo')
        sim.pb = false;
        sim.sl = true;
        sim.slv2 = false;
        sim.sv3 = false;
    elseif isequal(batchsim,'sl2')
        sim.pb = false;
        sim.sl = false;
        sim.slv2 = true;
        sim.sv3 = false;
    elseif isequal(batchsim,'sl3')
        sim.pb = false;
        sim.sl = false;
        sim.slv2 = false;
        sim.sv3 = true;
    end
    if isequal(batchpar1,'emx') && isequal(batchpar2,'wcd')
        sim.tuning_array1 = [2500 5000:5000:35000]; %[Wh]
        sim.tuning_array2 = [2 3 4 5];
        sim.tuned_parameter{1} = 'emx'; %E max
        sim.tuned_parameter{2} = 'wcd'; %wec characteristic diameter
    elseif isequal(batchpar1,'eps') && isequal(batchpar2,'nll')
        sim.tuning_array1 = [0.1 0.5 1 5 10 100 1000 10000 100000]; %[~]
        sim.tuning_array2 = 1;
        sim.tuned_parameter{1} = 'eps'; %epsilon
        sim.tuned_parameter{2} = 'nll';
        beta_on = true;
    elseif isequal(batchpar1,'ebs') && isequal(batchpar2,'wcd')
        sim.tuning_array1 = [0.1 0.5 1 3 5];
        sim.tuning_array2 = [2 3 4 5];
        sim.tuned_parameter{1} = 'ebs'; %energy between states
        sim.tuned_parameter{2} = 'wcd'; %wec characteristic diameter
    elseif isequal(batchpar1,'rhs') && isequal(batchpar2,'rtp')
        sim.tuning_array1 = [1 1.5 2 2.5 3];
        sim.tuning_array2 = [2 3 4 5 6 7 8 9 10 11 12 13 14 ...
            15 16 17 18 19 20 21];
        sim.tuned_parameter{1} = 'rhs'; %rated Hs
        sim.tuned_parameter{2} = 'rtp'; %rated Tp
    end
    if ~isempty(batcherr)
        frc.add_err = true; %add error to forecast
        frc.err_type = batcherr; %1: randomness multiplier 2: sinusoid
    end
elseif isequal(batchtype,'ssm') %outdated
%     sim.senssm = true;
%     sim.tdsens = false;
%     sim.pyssm = false;
%     if isequal(batchsim,'mdp')
%         sim.pb = false;
%         sim.sl = false;
%         sim.slv2 = false;
%     elseif isequal(batchsim,'pbo')
%         sim.pb = true;
%         sim.sl = false;
%         sim.slv2 = false;
%     elseif isequal(batchsim,'slo')
%         sim.pb = false;
%         sim.sl = true;
%         sim.slv2 = false;
%     elseif isequal(batchsim,'sl2')
%         sim.pb = false;
%         sim.sl = false;
%         sim.slv2 = true;
%     end
%     batchpar1 = [];
%     batcharr1 = [];
%     patchpar2 = [];
%     batcharr2 = [];
elseif isequal(batchtype,'pySsm')
    sim.pyssm = true;
    sim.tdsens = false;
    sim.senssm = false;
    sim.pb = false;
    sim.sl = false;
    sim.slv2 = false;
    sim.sv3 = false;
    sim.tp = tp;
    sim.ta_i = ta_i;
end

%SIM parameters:
sim.expar = true;           %parallelizing simulations (default true)
sim.debug = false;          %include debugging variables in output
sim.debug_disc = false;      %debug E discretization
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
frc.sub = 3; %[hr] model spin up buffer
Stemp = load('forecast_randomizer.mat'); %load forecast randomizer array
frc.rand = Stemp.forecast_randomizer; %store forecast randomizer array
Stemp = load('forecast_sinusoid.mat'); %load forecast sinusoid array
frc.sinu = Stemp.forecast_sinusoid; %store forecast sinusoid array

%AMP parameters:
amp.E_max = 2500;                      %[Wh], maximum battery capacity
if ~sim.hpc
    amp.E_max = 10000; %shorten runtime if using laptop
end
amp.est = 0.5;                          %battery starting fraction
amp.Ps = [1 45 450 600];                %[W], power consumption per
amp.sdr = 3;                            %[%/month] self discharge rate (3)
amp.fpr = 0.70;                         %simple logic full power ratio
amp.mpr = 0.65;                         %simple logic medium power ratio
amp.lpr = 0.15;                         %simple logic low power ratio
amp.tt = [12 3];                        %[h], time til depletion thresholds

%MDP parameters:
mdp.m = 4; %number of actions
mdp.eps = 1; %aggressiveness factor
mdp.mu = mdp.eps.*[1 .8 .2 0]; %functional penalties
mdp.beta_lb = 0.5; %lower bound % (of starting charge) for beta()
mdp.dt = 1; %time between stages
%mdp.b = 0; %battery steepness [1: on, 0: off]
% if exist('beta_on','var')
%     mdp.b = 1;
% end
mdp.alpha = .85; %discount factor

%WEC parameters:
wec.eta_ct = 0.6;               %[~], electrical efficiency, 0.6
wec.h = 0.10;                   %percent of rated power as house load
wec.B = 4;                      %[m]
wec.B_a = [2 3 4 5];            %array of B values
wec.rho = 1025;                 %[kg/m^3]
wec.g = 9.81;                   %[m/s^2]
% wec.Hs_ra_a = [3 3 2 1.5];    %[m] - 2 is old (?) default
% wec.Tp_ra_a = [8 8 12 14];      %[s] - 9 is default
wec.Hs_ra_a = [2.5 2.5 2.5 2.5];    %[m] - 2 is old (?) default
wec.Tp_ra_a = [10 10 10 10];      %[s] - 9 is default
wec.Hs_ra = interp1(wec.B_a,wec.Hs_ra_a,wec.B);
wec.Tp_ra = interp1(wec.B_a,wec.Tp_ra_a,wec.B);
wec.F = getWecSimInterp();      %3-d interpolant (Tp, Hs, B) from wecsim
wec.FO = false;                 %toggle fred. olsen

% %overwrite batch variables for beta and mu, can be commented out soon
% if ~isempty(batchbeta)
%     mdp.b = batchbeta;
% end
% if ~isempty(batcheps)
%     mdp.eps = batcheps;
%     mdp.mu = mdp.eps.*[1 .8 .2 0];       %functional penalties
% end

