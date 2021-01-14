%created by Trent Dillon on July 30th 2018
%code simulates Markov Decision Process algorithm of WAMP system
%multiple or one-off simulations are enabled

%clearvars -except FM, close all, clc

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

tTot = tic;
if sim.multiple %sensitivity analysis
    sim.S = length(sim.tuning_array); %sensitivity length
    %preallocate
    clear multStruct_mdp multStruct_pb multStruct_sl
    multStruct_mdp(sim.S) = struct();
    if sim.multiple_pb, multStruct_pb(sim.S) = struct(); end
    if sim.multiple_sl, multStruct_sl(sim.S) = struct(); end
    sim.pb = false;
    sim.sl = false;
    for i = 1:sim.S
        sim.s = i;
        if isequal(sim.tuned_parameter,'eps')
            mdp.eps = sim.tuning_array(i);
            mdp.mu = mdp.eps*[1 .9 .1 0];
        end
        if isequal(sim.tuned_parameter,'sub')
            frc.sub = sim.tuning_array(i);
        end
        if isequal(sim.tuned_parameter,'slv')
            frc.slv = sim.tuning_array(i);
        end
        if isequal(sim.tuned_parameter,'emx')
            amp.E_max = sim.tuning_array(i);
        end
        disp('STOCHASTIC')
        output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot); %run simulation
        if sim.multiple_pb
            disp('POSTERIOR BOUND')
            sim.pb = true;
            pb = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot);
            multStruct_pb(sim.s).amp = amp;
            multStruct_pb(sim.s).frc = frc;
            multStruct_pb(sim.s).output = pb;            
            multStruct_pb(sim.s).mdp = mdp;
            multStruct_pb(sim.s).sim = sim;
            multStruct_pb(sim.s).wec = wec;
            sim.pb = false;
        end
        if sim.multiple_sl
            disp('SIMPLE LOGIC')
            sim.sl = true;
            sl = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot); 
            multStruct_sl(sim.s).amp = amp;
            multStruct_sl(sim.s).frc = frc;
            multStruct_sl(sim.s).mdp = mdp;
            multStruct_sl(sim.s).output = sl;
            multStruct_sl(sim.s).sim = sim;
            multStruct_sl(sim.s).wec = wec;
            sim.sl = false;
        end
        multStruct_mdp(sim.s).amp = amp;
        multStruct_mdp(sim.s).frc = frc;
        multStruct_mdp(sim.s).mdp = mdp;
        multStruct_mdp(sim.s).output = output;
        multStruct_mdp(sim.s).sim = sim;
        multStruct_mdp(sim.s).wec = wec;
        clear pb sl output
    end
    disp([num2str(sim.s) ' simulations complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes. '])
    save('multStruct_pb','multStruct_pb','-v7.3')
    save('multStruct_sl','multStruct_sl','-v7.3')
    save('multStruct_mdp','multStruct_mdp','-v7.3')
else
    output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot); %run simulation
    simStruct.output = output;
    simStruct.amp = amp;
    simStruct.FM = FM;
    simStruct.frc = frc; 
    simStruct.mdp = mdp; 
    simStruct.sim = sim; 
    simStruct.wec = wec; 
end

clear i tTot