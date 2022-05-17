function [pySsmStruct,s0] = doPySsm(FM,amp,frc,mdp,sim,wec,tTot)

%set up capacity arrays (S1 and S2)
batts = [2500 5000:10000:35000]; %[Wh]
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
multStruct(c) = struct();

%get s0, default results
output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot,nan);
s0.amp = amp;
s0.frc = frc;
s0.mdp = mdp;
s0.output = output;
s0.sim = sim;
s0.wec = wec;

%set sensitivity parameters
%POWER SYSTEM PARAMETERS
if isequal(sim.tp,'eta') %conversion and transmission efficiency
    ta = linspace(0.4,1,n);  
    wec.eta_ct = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
elseif isequal(sim.tp,'whl') %wec hotel load
    ta = linspace(0,.18,n);
    wec.h = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
elseif isequal(sim.tp,'rhs') %rated significant wave height
    ta = linspace(0.5,5,n);
    wec.Hs_ra = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
elseif isequal(sim.tp,'rtp') %rated peak period
    ta = linspace(5,14,n);
    wec.Tp_ra = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
elseif isequal(sim.tp,'sdr') %self discharge rate
    ta = linspace(0,9,n);
    amp.sdr = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
elseif isequal(sim.tp,'est') %battery starting fraction
    ta = linspace(0.1,1,n);
    amp.est = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
%MARKOV DECISION PROCESS PARAMETERS
elseif isequal(sim.tp,'slt') %stage limit
    ta = linspace(18,180,n);
    frc.stagelimit = true; frc.stagelimitval = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
elseif isequal(sim.tp,'tbs') %time between stages
    ta = linspace(1,19,n);
    mdp.dt = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
elseif isequal(sim.tp,'ebs') %energy between states
    ta = linspace(17.5,40,n);
    mdp.d_n = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
elseif isequal(sim.tp,'dfr') %discount factor
    ta = linspace(.5,.99,n);
    mdp.alpha = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
elseif isequal(sim.tp,'sub') %spin up buffer
    ta = linspace(0,9,n);
    frc.sub = ta(sim.ta_i);
    disp(['Python ssm beginning for ' sim.tp ' parameter set to index ' ...
        num2str(sim.ta_i) ' equating to ' num2str(round(ta(sim.ta_i),2))])
end

end

