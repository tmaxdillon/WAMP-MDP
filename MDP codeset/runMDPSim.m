%created by Trent Dillon on July 30th 2018
%code simulates Markov Decision Process algorithm of WAMP system
%multiple or one-off simulations are enabled

clearvars -except FM, close all, clc

%% to do

%2 - discount factor runs
%2 - adapt visMultSims so it can handle multiple mult sims
%1 - n sensitivity analysis
%1 - add error visualization (visSimError and visMultError(?))
%4 - add uncertainty parameter (rubust MDP)
%4 - get more data
%4 - try smoothing over outages (reconstruct Hs and Tp)
%4 - maximum/minimum charge/discharge rates into battery model

%% setup

%load forecast matrix
if ~exist('FM','var')
    load('WETSForecastMatrix')
    FM = WETSForecastMatrix.FM_subset;
    clear WETSForecastMatrix
end

%forecast parameters
frc.stagelimit = true;          %toggle limit on stages
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

%WEC parameters:
wec.Hsc = 4;            %[m], height center
wec.Tpc = 9;            %[s], period center
wec.w = 15;             %[~], width of normal dist
wec.r = 15000;          %[W], rated (max) power of device
wec.cw = 1;             %[m], capture width at peak
wec.eta_ct = 0.6;       %[~], conversion efficiency

%SIM parameters:
sim.F = size(FM,2);         %simulation extent (number of forecasts)
sim.pb = false;             %toggle for posterior bound
sim.notif = 1000;           %notifications every __ forecasts
sim.debug = false;          %include debugging variables in output
sim.multiple = false;        %multiple simulations?

%% simulate WAMP (single or multiple simulations)

tTot = tic;
if sim.multiple
    % multiple simulation setup
    sim.tuning_array = [180 130 80 60 40 20]; %set sensitivity values
    sim.S = length(sim.tuning_array); %simulation index
    sim.tuned_parameter = 'SLval'; %for visualization lables
    sim.multiple_pb = true; %toggle for pb comparison
    multStruct(sim.S) = struct();
    sim.pb = false;
    for i = 1:sim.S
        sim.s = i;
        %%%%%%%%% TUNED PARAMETER UPDATE %%%%%%%%%%%%%%%%%
        %mdp.eps = sim.tuning_array(sim.s);
        %mdp.mu = mdp.eps*[1 .9 .1 0];
        %frc.sub = sim.tuning_array(sim.s);
        frc.stagelimitval = sim.tuning_array(sim.s);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('STOCHASTIC')
        output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot); %run simulation
        if sim.multiple_pb
            disp('POSTERIOR BOUND')
            sim.pb = true;
            pb = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot);
            multStruct(sim.s).pb.output = pb;
            multStruct(sim.s).pb.wec = wec;
            multStruct(sim.s).pb.mdp = mdp;
            multStruct(sim.s).pb.sim = sim;
            multStruct(sim.s).pb.FM = FM;
            sim.pb = false;
        end
        multStruct(sim.s).amp = amp;
        multStruct(sim.s).wec = wec;
        multStruct(sim.s).mdp = mdp;
        multStruct(sim.s).output = output;
        multStruct(sim.s).sim = sim;
        multStruct(sim.s).FM = FM;
        clear pb output
    end
    disp([num2str(sim.s) ' simulations complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes. '])
else
    output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot); %run simulation
end

clear i tTot

%% save and visualize MDP outputs

if sim.multiple
    name = ['multSim_' sim.tuned_parameter  num2str(sim.S)];
    stru.(name) = multStruct;
    save([name '.mat'],'-struct','stru','-v7.3');
    visMultSims(stru.(name))
else
    %set name
    name = ['sim_n' num2str(mdp.n) 'eps' num2str(mdp.eps) ...
        'sub' num2str(frc.sub) ];
    if sim.pb
        name = [name 'pb'];
    end
    stru.(name).amp = amp;
    stru.(name).wec = wec;
    stru.(name).mdp = mdp;
    stru.(name).output = output;
    stru.(name).sim = sim;
    stru.(name).FM = FM;
    save( ...
        [name '.mat'],'-struct','stru','-v7.3');
    visMDPSim(stru.(name))
end

clear stru name
