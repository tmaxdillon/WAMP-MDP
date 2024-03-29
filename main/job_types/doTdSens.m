function [multStruct] = doTdSens(FM,amp,frc,mdp,sim,wec,tTot)

%assemble array
m = length(sim.tuning_array1);
n = length(sim.tuning_array2);
[S1,S2] = meshgrid(sim.tuning_array1,sim.tuning_array2);
sim.S1 = reshape(S1,[m*n 1]);
sim.S2 = reshape(S2,[m*n 1]);
%set number of cores
if isempty(gcp('nocreate')) && sim.hpc
    cores = feature('numcores'); %find number of cores
    if cores > sim.corelim %only start if using HPC
        parpool(cores);
    end
end

%preallocate and print simulation combinations
clear multStruct
multStruct(m*n) = struct();
if sim.pb
    sim_type = ' [Posterior Bound] ';
elseif sim.sl
    sim_type = ' [Simple Logic] ';
elseif sim.slv2
    sim_type = ' [Simple Logic 2] ';
elseif sim.slv3
    sim_type = ' [Simple Logic 3] ';
else
    sim_type = ' [Markov Decision Process] ';
end
disp(['Beginning sensitivity analysis using' sim_type 'between ' ...
    sim.tuned_parameter{1} ' and ' sim.tuned_parameter{2} ...
    ' of ' num2str(m*n) ' combinations:'])
DT = table(sim.S1,sim.S2,'VariableNames', ...
    {sim.tuned_parameter{1},sim.tuned_parameter{2}});
disp(DT)

%this block of code can (probably) eventually be commented out
%set non expar (backward recursion par) settings
if ~sim.expar
    sim.mw = 0; %max number of workers
end
% %set battery discretization externally for multiple simulations, not
% %default because sim.use_d_n is default
% if isequal(sim.tuned_parameter{1},'emx') && sim.exdist && ~sim.use_d_n
%     E_temp = 0:amp.Ps(2)-5:max(sim.S1); %[Wh] discretized battery state
%     mdp.n = length(E_temp);
%     disp(['n = ' num2str(mdp.n) ' max E = ' num2str(max(sim.S1))])
% elseif isequal(sim.tuned_parameter{2},'emx') && sim.exdist && ~sim.use_d_n
%     E_temp = 0:amp.Ps(2)-5:max(sim.S2); %[Wh] discretized battery state
%     mdp.n = length(E_temp);
%     disp(['n = ' num2str(mdp.n) ' max E = ' num2str(max(sim.S2))])
% end

%parallization loop
parfor (i = 1:m*n,sim.mw)
    output = simulateWAMP(FM,amp,frc,mdp,sim,wec,tTot,i);
    multStruct(i).amp = amp;
    multStruct(i).frc = frc;
    multStruct(i).mdp = mdp;
    multStruct(i).output = output;
    multStruct(i).sim = sim;
    multStruct(i).wec = wec;
end

%print results to screen
for i = 1:length(multStruct)
    multStruct(i).output.results
end
multStruct = reshape(multStruct,[n m]);
disp([num2str(m*n) ' simulations complete after ' ...
        num2str(round(toc(tTot)/60,2)) ' minutes. '])

end

