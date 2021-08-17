function [s1,s2,s3,s4,s5,s6,s7,s8,s9,s10] = ...
    doSensSM(FM,amp,frc,mdp,sim,wec,tTot)

n = 10; %sensitivity discretization
p = 10; %number of sensitivity parameters
f = 2; %factor

%POWER SYSTEM PARAMETERS
tp{1} = 'eta'; %conversion and transmission efficiency
ta(1,:) = linspace(0.4,1,n);
tp{2} = 'whl'; %wec hotel load
ta(2,:) = linspace(0,.18,n);
tp{3} = 'rhs'; %rated significant wave height
ta(3,:) = linspace(0.5,5,n);
tp{4} = 'rtp'; %rated peak period
ta(4,:) = linspace(5,14,n);
tp{5} = 'sdr'; %self discharge rate
ta(5,:) = linspace(0,9,n);
%MARKOV DECISION PROCESS PARAMETERS
tp{6} = 'slt'; %stage limit
ta(6,:) = linspace(18,180,n);
tp{7} = 'tbs'; %time between stages
ta(7,:) = linspace(1,19,n);
tp{8} = 'ebs'; %energy between states
ta(8,:) = linspace(17.5,40,n);
tp{9} = 'dfr'; %discount factor
ta(9,:) = linspace(.5,.99,n);
tp{10} = 'sub'; %spin up buffer
ta(10,:) = linspace(0,9,n);

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
    '. There are ' num2str(p*n) ' combinations:'])
DT = table(ta(1,:),ta(2,:),ta(3,:),ta(4,:),ta(5,:),ta(6,:),ta(7,:), ...
    ta(8,:),ta(9,:),ta(10,:),'VariableNames',{tp{1},tp{2},tp{3},tp{4}, ...
    tp{5},tp{6},tp{7},tp{8},tp{9},tp{10}});
disp(DT)

%this block of code can (probably) eventually be commented out
%set non expar (backward recursion par) settings
if ~sim.expar
    sim.mw = 0; %max number of workers
end
%set battery discretization externally for multiple simulations, not
%default because sim.use_d_n is default
for i = 1:p
    if isequal(tp{i},'emx') && sim.exdist && ~sim.use_d_n
        E_temp = 0:amp.Ps(2)-5:max(tp{i,:}); %[Wh] discretized battery state
        mdp.n = length(E_temp);
        disp(['n = ' num2str(mdp.n) ' max E = ' num2str(max(tp{i,:}))])
    end
end

%assemble sensitivity array
sim.p = p; %number of parameters
sim.n = n; %number of discrete elements of each parameter
sim.S1 = reshape(ta',[p*n 1]); %sensitivity array
sim.tp = tp; %parameter names

%parallization loop
multStruct(p*n) = struct();
parfor (i = 1:(p*n),sim.mw)
    output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot,i);
    multStruct(i).amp = amp;
    multStruct(i).frc = frc;
    multStruct(i).mdp = mdp;
    multStruct(i).output = output;
    multStruct(i).sim = sim;
    multStruct(i).wec = wec;
end

%unpack multstruct into s1, s2, etc.
s1 = multStruct(1:1*p);
s2 = multStruct(1*p+1:2*p);
s3 = multStruct(2*p+1:3*p);
s4 = multStruct(3*p+1:4*p);
s5 = multStruct(4*p+1:5*p);
s6 = multStruct(5*p+1:6*p);
s7 = multStruct(6*p+1:7*p);
s8 = multStruct(7*p+1:8*p);
s9 = multStruct(8*p+1:9*p);
s10 = multStruct(9*p+1:10*p);

%print results to screen
if sim.expar
    for i = 1:length(multStruct)
        multStruct(i).output.results
    end
end
multStruct = reshape(multStruct,[n p]);
disp([num2str(n*p) ' simulations complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes. '])
    
end

