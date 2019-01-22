function [] = visMDPSim(simStruct)

FM = simStruct.FM;
output = simStruct.output;

if output.abridged
    f_pts = 1:find(output.E_sim > 0,1,'last');
else
    f_pts = 1:length(output.E_sim(1:end-1));
end

%find J_actions
for f = 1:length(output.val_Jstar)
    state = output.E_sim_ind(f);
    if state > 0
        J_actions(:,f) = output.val_all(state,:,1,f);
    else
        J_actions(:,f) = nan;
    end
end


figure
%POWER TIME SERIES
ax(1) = subplot(4,1,1);
plot(datetime(FM(1,f_pts,1),'ConvertFrom','datenum'), ...
    output.Pw_sim(f_pts)/1000,'Color', ...
    [204 255 204]/256,'LineWidth',2)
hold on
plot(datetime(FM(1,f_pts,1),'ConvertFrom','datenum'),output.Pa_sim(f_pts)/1000, ...
    'g','LineWidth',2)
ylim([0 inf])
yticks(0:2:12)
ylabel('Power [kW]','FontSize',20)
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
ylp(1) = ylp(1)-4;
set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
    'HorizontalAlignment','center')
set(gca,'XTickLabel',[]);
set(gca,'FontSize',16)
legend('WEC Power','Power to AMP','Location','Northwest')
grid on
title({['Average Power ' num2str(round(output.power_avg,2)) ...
    ', Average Beta = ' num2str(round(output.beta_avg,4))],''})
xl = xlim;
xt = xticks;
%OPERATIONAL STATE TIME SERIES
ax(2) = subplot(4,1,2);
for i = 1:max(output.a_sim)
    scatter(datetime(FM(1,(output.a_sim==i),1),'ConvertFrom', ...
        'datenum'),output.a_sim(output.a_sim==i),'.','MarkerEdgeColor','m')
    hold on
end
xlim(xl)
xticks(xt)
ylim([0.5 max(output.a_sim) + 0.5])
yticks(1:max(output.a_sim))
ylabel({'Operational','Mode'},'FontSize',20)
ylh = get(gca,'ylabel');
ylp = get(ylh,'Position');
ylp(1) = ylp(1)-4;
set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
    'HorizontalAlignment','center')
set(gca,'XTickLabel',[]);
set(gca,'FontSize',16)
grid on
%BATTERY CAPACITY TIME SERIES
ax(3) = subplot(4,1,3);
scatter(datetime(FM(1,f_pts,1),'ConvertFrom','datenum'), ...
    output.E_sim(f_pts)/1000,20,output.beta(f_pts),'Filled')
colormap(gca,flipud(brewermap(50,'RdYlGn')))
caxis([0 1])
ylim([0 inf])
yticks(1:6)
ylabel({'Battery','State [kWh]'},'FontSize',20)
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
ylp(1) = ylp(1)-4;
set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
    'HorizontalAlignment','center')
%set(gca,'XTick',[]);
set(gca,'FontSize',16)
xlabel('Time','FontSize',16)
grid on
%J VALUES
% ax(4) = subplot(5,1,4);
% for i = 1:size(J_actions,1)
%     plot(datetime(FM(1,f_pts,1),'ConvertFrom','datenum'), ...
%         J_actions(i,f_pts),'LineWidth',2)
%     legendStrings{i} = ['Mode: ' num2str(i)];
%     hold on
% end
% plot(datetime(FM(1,f_pts,1),'ConvertFrom','datenum'),output.val_Jstar(f_pts), ...
%     'k','LineWidth',2)
% ylabel('Bellmans Values')
% xlabel('Time')
% ylim([0 inf])
% grid on
% legend(legendStrings)
%ERROR
ax(5) = subplot(4,1,4);
time_surf = repmat(FM(1,1:(size(output.Pw_error,2)),1) ...
    ,[size(output.Pw_error,1),1]);
extent_surf = repmat(1:size(output.Pw_error,1),[size(output.Pw_error,2),1])';
s1 = surf(datetime(time_surf,'ConvertFrom','datenum'),extent_surf, ...
    output.Pw_error/1000);
view(2)
set(s1, 'edgecolor','none')
colormap(gca,redblue(11))
c = colorbar('Location','west');
c.Label.String = 'Overestimate [kW]';
caxis([-max(abs(output.Pw_error(:)/1000)) max(abs(output.Pw_error(:)/1000))])
ylabel({'Forecast','Extent [days]'},'FontSize',20)
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
ylp(1) = ylp(1)-4;
set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
    'HorizontalAlignment','center')
set(gca,'FontSize',16)
xlabel('Time')
zlabel('Overestimate [W]')
grid on

set(gcf, 'Position', [100, 100, 1400, 650])

%linkaxes(ax,'x')
end

