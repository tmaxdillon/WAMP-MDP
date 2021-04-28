function [] = visMDPSim(simStruct)

close all
yoff = 2.9;

FM_P = simStruct.output.FM_P;
FM_mod = simStruct.output.FM_mod;
output = simStruct.output;
amp = simStruct.amp;

if output.abridged
    f_pts = 1:find(output.E_sim > 0,1,'last');
else
    f_pts = 1:length(output.E_sim(1:end-1));
end

% %find J_actions
% for f = 1:length(output.val_Jstar)
%     state = output.E_sim_ind(f);
%     if state > 0
%         J_actions(:,f) = output.val_all(state,:,1,f);
%     else
%         J_actions(:,f) = nan;
%     end
% end

xoff = 1.5;
xlength = 7;
ylength = .75;
yoff = .5;
ymarg = 0.3;

%plotting setup
mdp_ts = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 10, 7])
fs = 9; %annotation font size
fs2 = 11; %axis font size%RESOURCE TIME SERIES
ax(1) = subaxis(6,1,1,'SpacingVert',0.02);
% plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'), ... 
%     FM_mod(1,f_pts,2),datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'), ... 
%     FM_mod(1,f_pts,3),datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'), ... 
%     FM_P(1,f_pts,4),'LineWidth',2);
yyaxis left
plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'),FM_mod(1,f_pts,2));
ylim([0 inf])
ylabel({'Significant','Wave','Height','[m]'})
yyaxis right
plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'),FM_mod(1,f_pts,3));
ylim([0 inf])
ylabel({'Peak','Wave','Period','[s]'})
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs2)
grid on
title({['Average Power ' num2str(round(output.power_avg,2)) ...
    ', Average Beta = ' num2str(round(output.beta_avg,4))],''})
xl = xlim;
xt = xticks;
%CWR TIME SERIES
ax(2) = subaxis(6,1,2);
plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'),FM_P(1,f_pts,4),'c');
ylabel('CWR')
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs2)
grid on
%POWER TIME SERIES
ax(3) = subaxis(6,1,3);
plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'),FM_mod(1,f_pts,2),'k');
% hold on
% plot(datetime(FM_P(1,f_pts,1),'ConvertFrom','datenum'),output.Pb_sim(f_pts)/1000, ...
%     'g','LineWidth',2)
%ylim([-inf output.wec.rp+0.5])
%yticks(0:0.5:5)
ylabel({'Power','Produced','[kW]'},'FontSize',fs2)
% ylh = get(gca,'ylabel');
% ylp = get(ylh, 'Position');
% ylp(1) = ylp(1)-yoff;
% set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
%     'HorizontalAlignment','center')
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs2)
%legend('WEC Power','Net Power to Battery','Location','Northwest')
grid on
%OPERATIONAL STATE TIME SERIES
ax(4) = subaxis(6,1,4);
for i = 1:max(output.a_sim)
    scatter(datetime(FM_P(1,(output.a_sim==i),1),'ConvertFrom', ...
        'datenum'),output.a_sim(output.a_sim==i),'.','MarkerEdgeColor', ... 
        [255 51 51]/256)
    hold on
end
xlim(xl)
xticks(xt)
ylim([0.5 max(output.a_sim) + 0.5])
yticks(1:max(output.a_sim))
yticklabels({'Full Power','Medium Power','Low Power','Suvival Mode'})
ylabel({'Sensing','Mode'},'FontSize',fs2)
% ylh = get(gca,'ylabel');
% ylp = get(ylh,'Position');
% ylp(1) = ylp(1)-yoff;
% set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
%     'HorizontalAlignment','center')
% set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs2)
grid on
%BATTERY CAPACITY TIME SERIES
ax(5) = subaxis(6,1,5);
scatter(datetime(FM_P(1,f_pts,1),'ConvertFrom','datenum'), ...
    output.E_sim(f_pts)/1000,20,output.beta(f_pts),'Filled')
colormap(gca,flipud(brewermap(50,'PiYG')))
caxis([0 1])
%ylim([0 amp.E_max/1000+.25])
%yticks(1:11)
ylabel({'Battery','[kWh]'})
% ylh = get(gca,'ylabel');
% ylp = get(ylh, 'Position');
% ylp(1) = ylp(1)-yoff;
% set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
%     'HorizontalAlignment','center')
%set(gca,'XTick',[]);
set(gca,'FontSize',fs2)
%xlabel('Time','FontSize',fs2)
grid on
%J VALUES
% ax(4) = subplot(6,1,6);
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
ax(6) = subplot(6,1,6);
time_surf = repmat(FM_P(1,1:(size(output.Pw_error,2)),1) ...
    ,[size(output.Pw_error,1),1]);
extent_surf = repmat(1:size(output.Pw_error,1),[size(output.Pw_error,2),1])';
s1 = surf(datetime(time_surf,'ConvertFrom','datenum'),extent_surf, ...
    output.Pw_error/1000);
view(2)
set(s1, 'edgecolor','none')
colormap(gca,redblue(11))
c = colorbar('Location','east');
c.Label.String = 'Overestimate [kW]';
caxis([-max(abs(output.Pw_error(:)/1000)) max(abs(output.Pw_error(:)/1000))])
% ylabel({'Forecast','Extent [days]'},'FontSize',20)
% ylh = get(gca,'ylabel');
% ylp = get(ylh, 'Position');
% ylp(1) = ylp(1)-4;
% set(ylh, 'Rotation',0, 'Position',ylp,'VerticalAlignment','middle', ...
%     'HorizontalAlignment','center')
% set(gca,'FontSize',16)
xlabel('Time')
zlabel('Overestimate [W]')
set(gca,'FontSize',fs2)
grid on

for i = 1:length(ax)
    set(ax(i),'Units','Inches','Position',[xoff ...
        (length(ax)-i)*(ylength+ymarg)+yoff xlength ylength])
end

set(gcf, 'Color',[255 255 245]/256,'InvertHardCopy','off')
set(ax,'Color',[255 255 245]/256)
print(mdp_ts,'~/Dropbox (MREL)/Research/General Exam/pf/slo_ts_4m',  ...
    '-dpng','-r600')
linkaxes(ax,'x')
end
