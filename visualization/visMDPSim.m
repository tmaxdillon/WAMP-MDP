function [] = visMDPSim(simStruct)

FM_P = simStruct.output.FM_P;
FM_mod = simStruct.output.FM_mod;
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
set(gcf, 'Position', [1, 1, 10, 12])
fs2 = 11; %axis font size

%RESOURCE TIME SERIES
ax(1) = subaxis(8,1,1,'SpacingVert',0.02);
yyaxis left
plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'), ...
    FM_mod(1,f_pts,2));
ylim([0 inf])
ylabel({'Significant','Wave','Height','[m]'})
yyaxis right
plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'), ...
    FM_mod(1,f_pts,3));
ylim([0 inf])
ylabel({'Peak','Wave','Period','[s]'})
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs2)
grid on
title({['Average Power ' num2str(round(output.power_avg,2)) ...
    ', Average Beta = ' num2str(round(output.beta_avg,4)) ...
    ', WEC Rated Power = ' num2str(round(output.wec.rp,3)) ' W' ...
    ', Battery Capacity = ' num2str(round(output.wec.E_max/1000,3)) ...
    ' kWh'],''})
xl = xlim;
xt = xticks;
%CWR TIME SERIES
ax(2) = subaxis(8,1,2);
plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'), ... 
    FM_P(1,f_pts,4),'c');
ylabel('CWR')
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs2)
grid on
%POWER TIME SERIES
ax(3) = subaxis(8,1,3);
plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'), ...
    FM_P(1,f_pts,2)/1000,'k');
ylim([0 output.wec.rp*1.1/1000])
yticks(linspace(0,output.wec.rp/1000,3))
ylabel({'Power','Produced','[kW]'},'FontSize',fs2)
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs2)
grid on
%OPERATIONAL STATE TIME SERIES
ax(4) = subaxis(8,1,4);
for i = 1:max(output.a_sim)
    scatter(datetime(FM_P(1,(output.a_sim==i),1),'ConvertFrom', ...
        'datenum'),output.a_sim(output.a_sim==i),'.','MarkerEdgeColor', ... 
        [255 51 51]/256)
    hold on
end
xlim(xl)
xticks(xt)
ylim([0.5 4.5])
yticks(1:max(output.a_sim))
yticklabels(fliplr({'Full Power','Medium Power','Low Power', ... 
    'Suvival Mode'}))
ylabel({'Sensing','Mode'},'FontSize',fs2)
set(gca,'FontSize',fs2)
grid on
%BATTERY CAPACITY TIME SERIES
ax(5) = subaxis(8,1,5);
scatter(datetime(FM_P(1,f_pts,1),'ConvertFrom','datenum'), ...
    output.E_sim(f_pts)/1000,20,output.beta(f_pts),'Filled')
colormap(gca,flipud(brewermap(50,'PiYG')))
caxis([0 1])
hold on
plot(datetime(FM_P(1,f_pts,1),'ConvertFrom','datenum'), ...
    output.E_recon(f_pts)/1000,'-r','LineWidth',.7)
ylim([0 output.wec.E_max/1000*1.1])
yticks(linspace(0,output.wec.E_max/1000,3))
ylabel({'Battery','[kWh]'})
%set(gca,'XTick',[]);
set(gca,'FontSize',fs2)
%xlabel('Time','FontSize',fs2)
grid on
%ERROR
ax(6) = subplot(8,1,6);
time_surf = repmat(FM_P(1,1:(size(output.Pw_error,2)),1) ...
    ,[size(output.Pw_error,1),1]);
extent_surf = repmat(1:size(output.Pw_error,1), ...
    [size(output.Pw_error,2),1])';
s1 = surf(datetime(time_surf,'ConvertFrom','datenum'),extent_surf, ...
    output.Pw_error/1000);
view(2)
set(s1, 'edgecolor','none')
colormap(gca,redblue(11))
c = colorbar('Location','east');
c.Label.String = 'Overestimate [kW]';
caxis([-max(abs(output.Pw_error(:)/1000)) ...
    max(abs(output.Pw_error(:)/1000))])
ylabel({'Forecast','Extent [days]'})
ylim([1 inf])
xlabel('Time')
zlabel('Overestimate [W]')
set(gca,'FontSize',fs2)
grid on
%J Star Values
ax(7) = subplot(8,1,7);
plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'), ...
    output.val_Jstar(f_pts),'m');
%ylim([0 output.wec.rp*1.1/1000])
%yticks(linspace(0,output.wec.rp/1000,3))
ylabel({'J Star','[~]'},'FontSize',fs2)
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs2)
grid on
%J Recon Values
ax(8) = subplot(8,1,8);
plot(datetime(FM_mod(1,f_pts,1),'ConvertFrom','datenum'), ...
    output.J_recon(f_pts),'g');
%ylim([0 output.wec.rp*1.1/1000])
%yticks(linspace(0,output.wec.rp/1000,3))
ylabel({'J Recon','[~]'},'FontSize',fs2)
%set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs2)
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

