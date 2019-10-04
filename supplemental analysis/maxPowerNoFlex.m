%created by Trent Dillon on July 30th
%code computes the MAXIMUM power the WAMP system can consume continually if
%there is no flexibility in its operation

%inputs: wave time series, wec modeling, wec-to-amp

clearvars -except FM, close all, clc
%% load data

load('WETSForecastMatrix')

FM = WETSForecastMatrix.FM_subset;

clear WETSForecastMatrix

%% set up structures

%WEC parameters:
wec.Hsc = 4;            %[m], height center
wec.Tpc = 9;            %[s], period center
wec.w = 15;             %[~], width of normal dist
wec.r = 15000;          %[W], rated (max) power of device
wec.cw = 1;             %[m], capture width at peak
wec.eta_ct = 0.6;       %[~], conversion efficiency

t  = FM(1,:,1);
Hs = FM(1,:,2);
Tp = FM(1,:,3);

%MDP parameters:
mdp.n = 20;                             %number of states
mdp.dt = 1;                             %[hr] time step

%AMP parameters:
amp.E_max = 5000;                       %[Wh], maximum battery capacity
amp.E = linspace(0,amp.E_max,mdp.n);    %[Wh], discretized battery state
amp.E_start = amp.E(round(mdp.n/2));    %[Wh], starting battery level
amp.Ps = [1 45 450 600];                %[W], power consumption per operational mode

%SIM parameters:
sim.E_ceil = true;

%% run function

mpnfFunction(Hs,Tp,t,wec,amp)
