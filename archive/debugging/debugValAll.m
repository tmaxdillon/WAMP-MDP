
clear all, close all, clc

%% recreate E_sim_ind and Jstar

val_all = output.val_all;
state_evol_all = output.state_evol_all;
state_evolved = zeros(length(state_evol_all),1);
Jstar = output.val_Jstar;
E_sim_ind = output.E_sim_ind;
policy_all = output.policy_all;
J_star = zeros(length(Jstar),1);

for f = 1:length(Jstar)
    state = E_sim_ind(f);
    action = policy_all(state,1,f);
    if state > 0 && action > 0
        state_evolved(f) = state_evol_all(state,action,1,f);
        J_star(f) = val_all(state,action,1,f);
    else
        state_evolved(f) = nan;
        J_star(f) = nan;
    end
end

state_evolved = [E_sim_ind(1) ; state_evolved(1:end-1)];

diff.E = state_evolved - E_sim_ind';
diff.J = J_star - Jstar;

clear state_evol_all state_evolved action state E_sim_ind f Jstar policy_all ... 
    J_star

%% plot everything

infpts = find(output.val_Jstar == inf);

ax(1) = subplot(2,1,1);
plot(datetime(FM(1,:,1),'ConvertFrom','datenum'),diff.J,'k','LineWidth',1.2)
hold on
plot(datetime(FM(1,infpts,1),'ConvertFrom','datenum'),zeros(length(infpts),1), ... 
    'ro')
ylabel('J-Value Overestimate')
xlabel('Time')
grid on
%DIFFERENCE BETWEEN WHAT IT IS AND WHAT IT THINKS IT WILL EVOLVE TO
ax(2) = subplot(2,1,2);
plot(datetime(FM(1,:,1),'ConvertFrom','datenum'),diff.E,'LineWidth',1.2)
hold on
plot(datetime(FM(1,infpts,1),'ConvertFrom','datenum'),zeros(length(infpts),1), ... 
    'ro')
ylabel('State Overestimate')
xlabel('Time')
grid on
% ax(3) = subplot(2,1,3);
% plot(datetime(FM(1,:,1),'ConvertFrom','datenum'),diff.Hs,'r','LineWidth',1.2)
% hold on
% plot(datetime(FM(1,:,1),'ConvertFrom','datenum'),diff.Tp,'m','LineWidth',1.2)
% ylabel('Wave Parameter Difference')
% xlabel('Time')
% grid on

linkaxes(ax,'x')





