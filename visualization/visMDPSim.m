function [] = visMDPSim(simStruct)

if isfield(simStruct.output,'FM_P') %not pyssm
    FM_P_1 = squeeze(simStruct.output.FM_P(1,:,:));
    FM_mod_1 = squeeze(simStruct.output.FM_mod(1,:,:));
else %pyssm (smaller output files)
    FM_P_1 = simStruct.output.FM_P_1;
    FM_mod_1 = simStruct.output.FM_mod_1;
end
output = simStruct.output;
if output.abridged
    f_pts = 1:find(output.E_sim > 0,1,'last');
else
    f_pts = 1:length(output.E_sim(1:end-1));
end

xoff = 1.75;
xlength = 7;
ylength = .9;
yoff = .75;
ymarg = 0.3;

%plotting setup
mdp_ts = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 10, 10])
fs = 11; %axis font size

%RESOURCE TIME SERIES
ax(1) = subaxis(7,1,1,'SpacingVert',0.02);
yyaxis left
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_mod_1(f_pts,2));
ylim([0 inf])
ylabel({'Significant','Wave','Height','[m]'})
yyaxis right
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_mod_1(f_pts,3));
ylim([0 inf])
ylabel({'Peak','Wave','Period','[s]'})
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
grid on
title({['Average Power ' num2str(round(output.power_avg,2)) ...
    ', WEC Rated Power = ' num2str(round(output.wec.rp,3)) ' W' ...
    ', Battery Capacity = ' num2str(round(output.wec.E_max/1000,3)) ...
    ' kWh'],''})
xl = xlim;
xt = xticks;
%CWR TIME SERIES
ax(2) = subaxis(7,1,2);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ... 
    FM_P_1(f_pts,4),'c');
ylabel('CWR')
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
grid on
%POWER TIME SERIES
ax(3) = subaxis(7,1,3);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_P_1(f_pts,2)/1000,'k');
ylim([0 output.wec.rp*1.1/1000])
yticks(linspace(0,output.wec.rp/1000,3))
ylabel({'Power','Produced','[kW]'},'FontSize',fs)
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
grid on
%OPERATIONAL STATE TIME SERIES
ax(4) = subaxis(7,1,4);
for i = 1:max(output.a_sim)
    scatter(datetime(FM_P_1((output.a_sim==i),1),'ConvertFrom', ...
        'datenum'),output.a_sim(output.a_sim==i),'.', ...
        'MarkerEdgeColor',[255 51 51]/256)
    hold on
    scatter(datetime(FM_P_1((output.a_act_sim==i),1),'ConvertFrom', ...
        'datenum'),output.a_sim(output.a_act_sim==i),'.', ...
        'MarkerEdgeColor',[51 255 51]/256)
end
xlim(xl)
xticks(xt)
ylim([0.5 4.5])
yticks(1:max(output.a_sim))
yticklabels(fliplr({'Full Power','Medium Power','Low Power', ... 
    'Suvival Mode'}))
ylabel({'Sensing','Mode'},'FontSize',fs)
set(gca,'FontSize',fs)
grid on
%BATTERY CAPACITY TIME SERIES
ax(5) = subaxis(7,1,5);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    output.E_sim(f_pts)/1000,20,output.E_sim(f_pts)/1000,'Filled')
colormap(gca,brewermap(50,'PiYG'))
caxis([0 output.wec.E_max/1000])
hold on
plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    output.E_recon(f_pts)/1000,'-r','LineWidth',.7)
ylim([0 output.wec.E_max/1000*1.1])
yticks(linspace(0,output.wec.E_max/1000,3))
ylabel({'Battery','[kWh]'})
%set(gca,'XTick',[]);
set(gca,'FontSize',fs)
%xlabel('Time','FontSize',fs2)
grid on
drawnow
% %ERROR - holding for discussion
% ax(6) = subplot(7,1,6);
% time_surf = repmat(FM_P_1(1:(size(output.error.val,2)),1) ...
%     ,[size(output.error.val,1),1]);
% extent_surf = repmat(1:size(output.error.val,1), ...
%     [size(output.error.val,2),1])';
% s1 = surf(datetime(time_surf,'ConvertFrom','datenum'),extent_surf, ...
%     output.error.val/1000);
% view(2)
% set(s1, 'edgecolor','none')
% colormap(ax(6),redblue(11))
% c = colorbar('Location','east');
% c.Label.String = 'Overestimate [kW]';
% caxis([-max(abs(output.error.val(:)/1000)) ...
%     max(abs(output.error.val(:)/1000))]);
% % freezeColors
% % cbfreeze(c)
% hold on
% colordata = permute(repmat([1 1 1]'./256, ...
%     [1,size(time_surf,2),size(time_surf,1)]),[3 2 1]);
% s2 = surf(datetime(time_surf,'ConvertFrom','datenum'),extent_surf, ...
%     output.error.zero,colordata);
% set(s2, 'edgecolor','none')
% %colormap(gca,[0 0 0])
% ylabel({'Forecast','Extent [days]'})
% ylim([1 inf])
% xlabel('Time')
% zlabel('Overestimate [W]')
% set(gca,'FontSize',fs2)
% grid on
%J Star Values
ax(6) = subplot(7,1,6);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    output.val_Jstar(f_pts),'m');
%ylim([0 output.wec.rp*1.1/1000])
%yticks(linspace(0,output.wec.rp/1000,3))
ylabel({'J Star','[~]'},'FontSize',fs)
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
grid on
%J Recon Values
ax(7) = subplot(7,1,7);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    output.J_recon(f_pts),'g');
%ylim([0 output.wec.rp*1.1/1000])
%yticks(linspace(0,output.wec.rp/1000,3))
ylabel({'J Recon','[~]'},'FontSize',fs)
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
grid on

for i = 1:length(ax)
    set(ax(i),'Units','Inches','Position',[xoff ...
        (length(ax)-i)*(ylength+ymarg)+yoff xlength ylength])
end

% set(gcf, 'Color',[255 255 245]/256,'InvertHardCopy','off')
% set(ax,'Color',[255 255 245]/256)
% print(mdp_ts,'~/Dropbox (MREL)/Research/General Exam/pf/slo_ts_4m',  ...
%     '-dpng','-r600')
linkaxes(ax,'x')
end

