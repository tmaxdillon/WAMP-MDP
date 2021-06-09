function [apct,power_avg,beta_avg,E_sim_ind,E_recon,J_recon] = ...
    calcPerfMetrics(amp,mdp,wec,output)

%percent of each operational state and average output power
power_avg = 0; %preallocate
apct = zeros(1,mdp.m); %preallocate
for i = 1:mdp.m
    apct(i) = length(output.a_sim(output.a_sim == i))./ ...
        length(output.a_sim(output.a_sim > 0));
    power_avg = power_avg + apct(i)*amp.Ps(i);
end
%average beta value
beta_avg = mean(output.beta);
%battery indicies
E_sim_ind = zeros(1,length(output.E_sim));
for i = 1:length(output.E_sim)
    [~,E_sim_ind(i)] =  min(abs(amp.E - output.E_sim(i)));
end
%find f extent based on action timeseries
f_ext = find(output.a_sim > 0,1,'last');
%reconstructed E timeseries and J timesries
E_recon = zeros(length(output.E_sim),1);
J_recon = zeros(length(output.E_sim),1);
E_recon(1) = amp.E_start;
disp(['length f_ext = ' num2str(f_ext)])
disp(['WEC B = ' num2str(wec.B) ' and E_max = ' num2str(amp.E_max)])
for f = 1:f_ext
    [~,E_recon(f+1)] = powerToBattery(output.Pw_sim(f), ...
        E_recon(f),amp.Ps(output.a_sim(f)), ...
        amp.sdr,amp.E_max,mdp.dt,wec.FO);
    J_recon(f) = ...
        beta(output.E_sim(f),amp.E,amp.E_max,mdp.b,mdp.beta_lb) + ...
        mdp.mu(output.a_sim(f));
end

