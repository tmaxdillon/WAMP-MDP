function [apct,power_avg,beta_avg,E_sim_ind] = ...
    calcPerfMetrics(amp,mdp,output)

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

end

