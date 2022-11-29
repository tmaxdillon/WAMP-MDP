function [pySsmStruct] = doPySsm(FM,amp,frc,mdp,sim,wec,tTot)

n = 10; %number of discrete sensitivity array values
%set up capacity arrays (S1 and S2)
batts = [2500 5000:5000:40000]; %[Wh]
wecs = [2 3 4 5]; %[m]
c = length(batts)*length(wecs); %number of capacity combinations
[S1,S2] = meshgrid(batts,wecs);
sim.S1 = reshape(S1,[c 1]);
sim.S2 = reshape(S2,[c 1]);
%set number of cores
if isempty(gcp('nocreate')) && sim.hpc
    cores = feature('numcores'); %find number of cores
    if cores > sim.corelim %only start if using HPC
        parpool(cores);
    end
end

%preallocate and print simulation combinations
clear multStruct
pySsmStruct(c) = struct();

%set sensitivity parameters
%POWER SYSTEM PARAMETERS
if isequal(sim.tp,'eta') %conversion and transmission efficiency
    sim.ta = linspace(0.4,1,n);  
    wec.eta_ct = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'whl') %wec hotel load
    sim.ta = linspace(0,.18,n);
    wec.h = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'rhs') %rated significant wave height
    sim.ta = linspace(0.5,5,n);
    wec.Hs_ra = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'rtp') %rated peak period
    sim.ta = linspace(6,15,n);
    wec.Tp_ra = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'sdr') %self discharge rate
    sim.ta = linspace(0,9,n);
    amp.sdr = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'est') %battery starting fraction
    sim.ta = linspace(0.1,1,n);
    amp.est = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
%MARKOV DECISION PROCESS PARAMETERS
elseif isequal(sim.tp,'slt') %stage limit
    %sim.ta = linspace(18,180,n);
    %sim.ta = linspace(4,166,n);
    sim.ta = [0 1 2 5 10 15 30 50 100 180];
    frc.stagelimit = true; frc.stagelimitval = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'tbs') %time between stages
    sim.ta = linspace(1,28,n);
    mdp.dt = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'ebs') %energy between states
    sim.ta = linspace(5,140,n);
    mdp.d_n = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'dfr') %discount factor
    %sim.ta = linspace(.55,1,n);
    sim.ta = linspace(.8,1,n);
    %sim.ta = [.999 .9999 .99999 .999999 .9999999 .99999999 .999999999 ...
        %.9999999999 .99999999999 1];
    mdp.alpha = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'sub') %spin up buffer
    sim.ta = linspace(0,9,n);
    frc.sub = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'tam')
    %sim.ta = [0 1 5 10 25 250 500 1000 1500 2000]; %old
    sim.ta = [0 .1 .25 .5 1 1.5 2 3 6 10]; %for zoom scale
    %sim.ta = [.001 .1 1 5 100 500 750 1000 1500 2000]; %for log scale
    mdp.tA = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'tpe')
    sim.ta = [1 2 4 6 8 10 12 16 20 24];
    mdp.tp = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'bbb')
    sim.ta = [];
    disp('Python ssm beginning for baseline case.')
end

%parallization loop
parfor (i = 1:c,sim.mw)
    output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot,i);
    pySsmStruct(i).output = output;
    if isequal(sim.tp,'bbb') %save extra fields for baseline
        pySsmStruct(i).amp = amp;
        pySsmStruct(i).frc = frc;
        pySsmStruct(i).mdp = mdp;
        pySsmStruct(i).sim = sim;
        pySsmStruct(i).wec = wec;
    end
end

%s0 default results? - likely will do this independently...

%print results to screen
if sim.expar
    for i = 1:length(pySsmStruct)
        pySsmStruct(i).output.results
    end
end

%organize data output
pySsmStruct = reshape(pySsmStruct,[length(wecs) length(batts)]);

disp([num2str(c) ' simulations complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes. '])
    
end

