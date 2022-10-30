%load forecast matrix
if ~exist('FM','var')
    load('WETSForecastMatrix')
    FM = WETSForecastMatrix.FM_subset;
    clear WETSForecastMatrix
end
mdpInputs

f = 1;

for t = 1:50
    theta_a(:,t) = theta(t,FM,f,mdp.mu,mdp.tp,mdp.tA,mdp.tsl,2);
end

figure
for a = 1:4
    plot(datetime(FM(f,1:size(theta_a,2),1),'ConvertFrom','datenum'), ...
        theta_a(a,:),'DisplayName',['a = ' num2str(a)])
    hold on
end
xlabel('time')
ylabel('penalty')
legend('show')