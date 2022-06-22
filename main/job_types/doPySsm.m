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
if isempty(gcp('nocreate')) && sim.hpc && ~sim.brpar
    cores = feature('numcores'); %find number of cores
    if cores > sim.corelim %only start if using HPC
        parpool(cores);
    end
end

%preallocate and print simulation combinations
clear multStruct
pySsmStruct(c) = struct();

% %get s0, default results - think you'll just submit an mdpsim...
% output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot,nan);
% s0.amp = amp;
% s0.frc = frc;
% s0.mdp = mdp;
% s0.output = output;
% s0.sim = sim;
% s0.wec = wec;

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
    sim.ta = linspace(5,14,n);
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
    sim.ta = linspace(18,180,n);
    frc.stagelimit = true; frc.stagelimitval = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'tbs') %time between stages
    sim.ta = linspace(1,19,n);
    mdp.dt = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'ebs') %energy between states
    sim.ta = linspace(17.5,40,n);
    mdp.d_n = sim.ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' ...
        num2str(round(sim.ta(sim.ta_i),2))])
elseif isequal(sim.tp,'dfr') %discount factor
    sim.ta = linspace(.5,.99,n);
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
elseif isequal(sim.tp,'bbb')
    sim.ta = [];
    disp('Python ssm beginning for baseline case.')
end

%parallization loop
parfor (i = 1:c,sim.mw)
    output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot,i);
    pySsmStruct(i).output = output;
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

