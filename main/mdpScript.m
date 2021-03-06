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

tTot = tic;
if sim.multiple %sensitivity analysis
    %assemble array
    m = length(sim.tuning_array1);
    n = length(sim.tuning_array2);
    [S1,S2] = meshgrid(sim.tuning_array1,sim.tuning_array2);
    sim.S1 = reshape(S1,[m*n 1]);
    sim.S2 = reshape(S2,[m*n 1]);
    %set number of cores
    if isempty(gcp('nocreate')) && sim.hpc && ~sim.brpar 
        cores = feature('numcores'); %find number of cores
        if cores > sim.corelim %only start if using HPC
            parpool(cores);
        end
    end
    %preallocate and print simulation combinations
    clear multStruct
    multStruct(m*n) = struct();
    disp(['Beginning sensitivity analysis between ' ...
        sim.tuned_parameter{1} ' and ' sim.tuned_parameter{2} ...
        ' of ' num2str(m*n) ' combinations:'])
    DT = table(sim.S1,sim.S2,'VariableNames', ...
        {sim.tuned_parameter{1},sim.tuned_parameter{2}});
    disp(DT)
    %set non expar (backward recursion par) settings
    if ~sim.expar
        sim.mw = 0; %max number of workers
    end
    %set battery discretization externally for multiple simulations
    if isequal(sim.tuned_parameter{1},'emx') && sim.exdist && ...
            ~sim.use_d_n
        E_temp = 0:amp.Ps(2)-5:max(sim.S1); %[Wh] discretized battery state
        mdp.n = length(E_temp);
        disp(['n = ' num2str(mdp.n) ' max E = ' num2str(max(sim.S1))])
    elseif isequal(sim.tuned_parameter{2},'emx') && sim.exdist && ...
            ~sim.use_d_n
        E_temp = 0:amp.Ps(2)-5:max(sim.S2); %[Wh] discretized battery state
        mdp.n = length(E_temp);
        disp(['n = ' num2str(mdp.n) ' max E = ' num2str(max(sim.S2))])
    end
    parfor (i = 1:m*n,sim.mw)
        output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot,i);
        multStruct(i).amp = amp;
        multStruct(i).frc = frc;
        multStruct(i).mdp = mdp;
        multStruct(i).output = output;
        multStruct(i).sim = sim;
        multStruct(i).wec = wec;
    end
    for i = 1:length(multStruct)
        multStruct(i).output.results
    end
    multStruct = reshape(multStruct,[n m]);
    disp([num2str(m*n) ' simulations complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes. '])
else %single simulation
    sim.expar = false;
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