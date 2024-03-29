function [apct,power_avg,E_sim_ind,E_recon,J_recon] = ...
    calcPerfMetrics(amp,mdp,sim,wec,output,j,FM_P)

%percent of each operational state and average output power
power_avg = 0; %preallocate
apct = zeros(1,mdp.m); %preallocate
for i = 1:mdp.m
    apct(i) = length(output.a_act_sim(output.a_act_sim == i))./ ...
        length(output.a_act_sim(output.a_act_sim > 0));
    power_avg = power_avg + apct(i)*amp.Ps(i);
end
%check to see if there is average power discrepancy
power_avg2 = mean(output.P_sim(output.P_sim > 0));
if abs(power_avg2 - power_avg) > 1 && sim.senssm
    if sim.senssm
    warning(['power averages not within 1 W. parameter = ' ...
        sim.tp{ceil(j/sim.n)} ' and value = ' num2str(sim.S1(j))])
    elseif sim.tdsens
        warning(['power averages not within 1 W. B = ' ...
            num2str(sim.tuning_array2) ' m and Smax = ' ...
            num2str(sim.tuning_array1) ' kWh.'])
    end
end
%average beta value
% beta_avg = mean(output.beta);
%battery indicies
E_sim_ind = zeros(1,length(output.E_sim));
for i = 1:length(output.E_sim)
    [~,E_sim_ind(i)] =  min(abs(amp.E - output.E_sim(i)));
end
%find f extent based on action timeseries
f_ext = find(output.a_act_sim > 0,1,'last');
%reconstructed E timeseries and J timesries
E_recon = zeros(length(output.E_sim),1);
J_recon = zeros(length(output.E_sim),1);
tau = 0;
% E_sim = output.E_sim;
% E_recon(1) = amp.E_start;
% dE(1) = E_recon(1) - E_sim(1);
% disp(['length f_ext = ' num2str(f_ext)])
% disp(['power averages not equal. parameter = ' ...
%         sim.tp{ceil(j/sim.n)} ' and value = ' num2str(sim.S1(j))])
for f = 1:f_ext
    %     [~,E_recon(f+1)] = powerToBattery(output.Pw_sim(f), ...
    %         E_recon(f),amp.Ps(output.a_sim(f)), ...
    %         amp.sdr,amp.E_max,mdp.dt,wec.FO);
    %     [~,~,~,E_recon(f+1)] = powerBalance(output.Pw_sim(f),E_recon(f), ...
    %         output.a_act_sim(f),amp.sdr,amp.E_max,amp.Ps,1,true);
    %     disp(['sim = ' num2str(E_sim(f+1))])
    %     disp(['rc = ' num2str(E_recon(f+1))])
    %     dE(f+1) = E_recon(f+1) - E_sim(f+1);
    %     disp(['dE = ' num2str(dE(f+1))])
    if mdp.tau
        if output.a_act_sim(f) >= 3
            tau = 0;
        else
            tau = tau + 1;
        end
    else
        tau = 0;
    end
    theta_a = theta(1,FM_P,f, ...
        mdp.mu,mdp.tp,mdp.tA,mdp.tsl,mdp.theta); %phase penalty    
    J_recon(f) = mdp.mu(output.a_act_sim(f)) + (mdp.tau_x^tau-1) ...
        + theta_a(output.a_act_sim(f));
end

