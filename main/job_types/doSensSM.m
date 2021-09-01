function [s1,s2,s3,s4,s5,s6,s7,s8,s9,s10] = ...
    doSensSM(FM,amp,frc,mdp,sim,wec,tTot)

n = 10; %sensitivity discretization
p = 10; %number of sensitivity parameters
%set up tuning capacity array
if sim.ssm_ca %capacity analysis turned on
    batts = [1000 2500 5000:5000:35000]; %[Wh]
    wecs = [2 3 4 5]; %[m]
    c = length(batts)*length(wecs); %number of capacity combinations    
    [W,B] = meshgrid(batts,wecs); 
    tc = [reshape(B,[c 1]) reshape(W,[c 1])]; %tuning capacity array
else %just analyzing one capacity combination
    c = 1; %number of capacity combinations
    tc = [wec.B amp.E_max]; %tuning capacity array
    batts = amp.E_max; %for reshaping multStruct
    wecs = wec.B; %for reshaping multStruct
end

%preallocate ta
ta = zeros(n,p,c);

%set up tuning matrix and tuned parameter names
for i = 1:c
    %POWER SYSTEM PARAMETERS
    tp{1} = 'eta'; %conversion and transmission efficiency
    ta(1,:,i) = linspace(0.4,1,n);
    tp{2} = 'whl'; %wec hotel load
    ta(2,:,i) = linspace(0,.18,n);
    tp{3} = 'rhs'; %rated significant wave height
    ta(3,:,i) = linspace(0.5,5,n);
    tp{4} = 'rtp'; %rated peak period
    ta(4,:,i) = linspace(5,14,n);
    tp{5} = 'sdr'; %self discharge rate
    ta(5,:,i) = linspace(0,9,n);
    %MARKOV DECISION PROCESS PARAMETERS
    tp{6} = 'slt'; %stage limit
    ta(6,:,i) = linspace(18,180,n);
    tp{7} = 'tbs'; %time between stages
    ta(7,:,i) = linspace(1,19,n);
    tp{8} = 'ebs'; %energy between states
    ta(8,:,i) = linspace(17.5,40,n);
    tp{9} = 'dfr'; %discount factor
    ta(9,:,i) = linspace(.5,.99,n);
    tp{10} = 'sub'; %spin up buffer
    ta(10,:,i) = linspace(0,9,n);
end

%preallocate and print simulation combinations
clear multStruct
multStruct(p*n) = struct();
if sim.pb
    sim_type = ' [Posterior Bound] ';
elseif sim.sl
    sim_type = ' [Simple Logic] ';
elseif sim.slv2
    sim_type = ' [Simple Logic 2] ';
else
    sim_type = ' [Markov Decision Process] ';
end
disp(['Beginning sensitivity small multiple using' sim_type ...
    '. There are ' num2str(p*n*c) ' combinations.'])
if sim.ssm_ca
    disp('(capacity analysis turned on)')
end
disp('Paramater ranges:')
DT = table([ta(1,1,1) ta(1,end,1)],[ta(2,1,1) ta(2,end,1)], ...
    [ta(3,1,1) ta(3,end,1)],[ta(4,1,1) ta(4,end,1)], ...
    [ta(5,1,1) ta(5,end,1)],[ta(6,1,1) ta(6,end,1)], ...
    [ta(7,1,1) ta(7,end,1)],[ta(8,1,1) ta(8,end,1)], ...
    [ta(9,1,1) ta(9,end,1)],[ta(10,1,1) ta(10,end,1)], ...
    'VariableNames',{tp{1},tp{2},tp{3},tp{4}, ...
    tp{5},tp{6},tp{7},tp{8},tp{9},tp{10}});
disp(DT)

%assemble tuning cell S1
sim.p = p; %number of parameters
sim.n = n; %number of discrete elements of each parameter
sim.c = c; %number of wec/battery capacity combinations
sim.S1{1} = reshape(permute(ta,[2 1 3]),[p*n*c 1]); %parameter value
sim.S1{2} = repmat(repelem(tp',p),[c 1]); %parameter name
sim.S1{3} = repelem(tc(:,1),p*n); %WEC size
sim.S1{4} = repelem(tc(:,2),p*n); %battery capacity
%set number of cores
if isempty(gcp('nocreate')) && sim.hpc && ~sim.brpar
    cores = feature('numcores'); %find number of cores
    if cores > sim.corelim %only start if using HPC
        parpool(cores);
    end
end

%parallization loop
multStruct(p*n*c) = struct();
parfor (i = 1:(p*n*c),sim.mw)
    output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot,i);
    %comment out everything except output structure to reduce file size
    %multStruct(i).amp = amp;
    %multStruct(i).frc = frc;
    %multStruct(i).mdp = mdp;
    multStruct(i).output = output;
    %multStruct(i).sim = sim;
    %multStruct(i).wec = wec;
end

%print results to screen
if sim.expar
    for i = 1:length(multStruct)
        multStruct(i).output.results
    end
end

%organize data output
multStruct = squeeze(reshape(multStruct,[n p length(wecs) length(batts)]));
%unpack multstruct into s1, s2, etc.
% s1 = multStruct(1:1*p);
% s2 = multStruct(1*p+1:2*p);
% s3 = multStruct(2*p+1:3*p);
% s4 = multStruct(3*p+1:4*p);
% s5 = multStruct(4*p+1:5*p);
% s6 = multStruct(5*p+1:6*p);
% s7 = multStruct(6*p+1:7*p);
% s8 = multStruct(7*p+1:8*p);
% s9 = multStruct(8*p+1:9*p);
% s10 = multStruct(9*p+1:10*p);
s1 = squeeze(multStruct(:,1,:,:));
s2 = squeeze(multStruct(:,2,:,:));
s3 = squeeze(multStruct(:,3,:,:));
s4 = squeeze(multStruct(:,4,:,:));
s5 = squeeze(multStruct(:,5,:,:));
s6 = squeeze(multStruct(:,6,:,:));
s7 = squeeze(multStruct(:,7,:,:));
s8 = squeeze(multStruct(:,8,:,:));
s9 = squeeze(multStruct(:,9,:,:));
s10 = squeeze(multStruct(:,10,:,:));

%TBD: baseline results, s0 - will need to code this into the parfor loop
disp([num2str(n*p*c) ' simulations complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes. '])
    
end

