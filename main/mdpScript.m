%created by Trent Dillon on July 30th 2018
%code simulates Markov Decision Process algorithm of WAMP system
%multiple or one-off simulations are enabled

%clearvars

%% to do

%old goals
%1 - have meta data for multiple runs
%3 - discount factor runs
%3 - adapt visMultSims so it can handle multiple mult sims
%1 - n sensitivity analysis
%1 - add error visualization (visSimError and visMultError(?))
%5 - add uncertainty parameter (rubust MDP)
%5 - get more data
%5 - try smoothing over outages (reconstruct Hs and Tp)
%5 - maximum/minimum charge/discharge rates into battery model

%new things I have noticed...
% - add capacity fading to simulateWAMP

%% simulate OO-WEC

%load forecast matrix
if ~exist('FM','var')
    load('WETSForecastMatrix')
    FM = WETSForecastMatrix.FM_subset;
    clear WETSForecastMatrix
end
mdpInputs
%disp(['Nominal beta = ' num2str(mdp.b) ' and epsilon = ' num2str(mdp.eps)])

tTot = tic;
if sim.tdsens %two dimensional sensitivity analysis
    multStruct = doTdSens(FM,amp,frc,mdp,sim,wec,tTot);
elseif sim.senssm %sensitivity small multiple
    [eta,whl,rhs,rtp,sdr,slt,tbs,ebs,dfr,sub,s0] = ...
        doSensSM(FM,amp,frc,mdp,sim,wec,tTot);
elseif sim.pyssm %python parallelized sensitivivity small multiple
    pySsmStruct = doPySsm(FM,amp,frc,mdp,sim,wec,tTot);
else %single simulation
    disp('Simulation beginning')
    sim.expar = false;
    output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot); %run simulation
    simStruct.output = output;
    simStruct.amp = amp;
    simStruct.FM = FM;
    simStruct.frc = frc;
    simStruct.mdp = mdp;
    simStruct.sim = sim;
    simStruct.wec = wec;
    disp(['Simulation complete after ' num2str(round(toc(tTot)/60,2))  ...
            ' minutes.'])
end

clear i tTot