%created by Trent Dillon on July 30th 2018
%code simulates Markov Decision Process algorithm of WAMP system
%multiple or one-off simulations are enabled

clearvars -except FM, close all, clc

%% to do

%1 - visualize these power matrices...
%2 - capture width and CWR as output for diagnostics
%3 - discount factor runs
%3 - adapt visMultSims so it can handle multiple mult sims
%2 - n sensitivity analysis
%2 - add error visualization (visSimError and visMultError(?))
%5 - add uncertainty parameter (rubust MDP)
%5 - get more data
%5 - try smoothing over outages (reconstruct Hs and Tp)
%5 - maximum/minimum charge/discharge rates into battery model

%% simulate OO-WEC

%load forecast matrix
if ~exist('FM','var')
    load('WETSForecastMatrix')
    FM = WETSForecastMatrix.FM_subset;
    clear WETSForecastMatrix
end
mdpInputs

tTot = tic;
if sim.multiple
    % multiple simulation setup
    sim.S = length(sim.tuning_array); %simulation index
    multStruct(sim.S) = struct();
    sim.pb = false;
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
    simStruct.output = output;
    simStruct.amp = amp;
    simStruct.FM = FM;
    simStruct.FM = frc; 
    simStruct.FM = mdp; 
    simStruct.FM = sim; 
    simStruct.FM = wec; 
end

clear i tTot

% % save and visualize MDP outputs
% if sim.multiple
%     name = ['multSim_' sim.tuned_parameter  num2str(sim.S)];
%     stru.(name) = multStruct;
%     save([name '.mat'],'-struct','stru','-v7.3');
%     visMultSims(stru.(name))
% else
%     %set name
%     name = ['sim_n' num2str(mdp.n) 'eps' num2str(mdp.eps) ...
%         'sub' num2str(frc.sub) ];
%     if sim.pb
%         name = [name 'pb'];
%     end
%     stru.(name).amp = amp;
%     stru.(name).wec = wec;
%     stru.(name).mdp = mdp;
%     stru.(name).output = output;
%     stru.(name).sim = sim;
%     stru.(name).FM = FM;
%     save([name '.mat'],'-struct','stru','-v7.3');
%     visMDPSim(stru.(name))
% end

clear stru name
