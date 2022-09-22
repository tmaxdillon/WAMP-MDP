close all
clearvars -except mdpsim slosim sl2sim
%% 

set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
output_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
    'output_data/'];

printfig = true; %print figure

if ~exist('mdpsim','var') || ~exist('slosim','var') || ...
        ~exist('sl2sim','var')
    load([output_path 'mdpsim']);
    load([output_path 'pbosim']);
    load([output_path 'slosim']);
    load([output_path 'sl2sim']);    
    %simStruct = mdpsim;
end
w = 2; %wec index
b = 2; %battery index

%unpack data structure
FM_P_1 = squeeze(mdpsim(w,b).output.FM_P(1,:,:));
FM_mod_1 = squeeze(mdpsim(w,b).output.FM_mod(1,:,:));
mdpo = mdpsim(w,b).output;
pboo = pbosim(w,b).output;
sloo = slosim(w,b).output;
sl2o = sl2sim(w,b).output;
if mdpo.abridged %find forecast time steps being used
    f_pts = 1:find(mdpo.E_sim > 0,1,'last');
else
    f_pts = 1:length(mdpo.E_sim(1:end-1));
end

%plot settings
xoff = 1;
xlength = 4.65;
ylength = .625;
yoff = .35;
ymarg = 0.075;
ylhpos = -0.115; %ylabel horizonal position (normalized)
fs = 8; %axis font size
fs2 = 6.5; %tick font size
cmdp(4,:) = [41 31 66]/225;
cmdp(3,:) = [72 54 116]/255;
cmdp(2,:) = [103 78 167]/255;
cmdp(1,:) = [133 113 184]/255;
cpbo(4,:) = [97 35 53]/225;
cpbo(3,:) = [139 50 77]/255;
cpbo(2,:) = [162 90 112]/255;
cpbo(1,:) = [185 132 148]/255;
cslo(4,:) = [127 0 0]/225;
cslo(3,:) = [204 0 0]/255;
cslo(2,:) = [255 50 50]/255;
cslo(1,:) = [255 102 102]/255;
csl2(4,:) = [127 72 10]/225;
csl2(3,:) = [203 116 16]/255;
csl2(2,:) = [254 145 20]/255;
csl2(1,:) = [254 167 66]/255;
%more vibrant orange
csl2(4,:) = [178 55 0]/225;
csl2(3,:) = [255 79 0]/255;
csl2(2,:) = [255 114 50]/255;
csl2(1,:) = [255 131 76]/255;
cSC = AdvancedColormap('kr ryy yl lg ggk',1000);

tscomp = figure;
set(gcf,'Units','inches','Color','w')
set(gcf, 'Position', [1, 1, 6.5, 6.75])
%POWER TIME SERIES
ax(1) = subaxis(9,1,1);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_P_1(f_pts,2)/1000,'k');
ylim([0 ceil(mdpo.wec.rp*1.1/1000)])
yticks([0:0.25:ceil(mdpo.wec.rp*1.1/1000)])
yl = ylabel({'WEC','Power','Output','[kW]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
xlim([datetime(FM_mod_1(f_pts(1),1),'ConvertFrom','datenum') ...
    datetime(FM_mod_1(f_pts(end),1),'ConvertFrom','datenum')]);
xl = xlim;
xt = xticks;
set(gca,'FontSize',fs)
grid on
%MDP: OPERATIONAL STATE TIME SERIES
ax(2) = subaxis(9,1,2);
set(gca,'YAxisLocation','right')
for i = 1:max(mdpo.a_sim)
    scatter(datetime(FM_P_1((mdpo.a_sim==i),1),'ConvertFrom', ...
        'datenum'),mdpo.a_sim(mdpo.a_sim==i),'.', ...
        'MarkerEdgeColor',cmdp(i,:))
    hold on
    scatter(datetime(FM_P_1((mdpo.a_act_sim==i),1),'ConvertFrom', ...
        'datenum'),mdpo.a_sim(mdpo.a_act_sim==i),'.', ...
        'MarkerEdgeColor',cmdp(i,:))
end
set(gca,'YAxisLocation','right')
grid on
xlim(xl)
xticks(xt)
ylim([0.5 4.5])
yl = ylabel({'MDP','Operational','Mode'},'Color',cmdp(3,:), ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
yticks(1:max(mdpo.a_sim));
set(gca,'YTickLabel',[])
tx = (fliplr({'Full Power','Medium Power','Low Power', ...
    'Survival Mode'}));
dy_tx = 0.253;
for i = 1:max(mdpo.a_sim)
    text(1.0075,-.13+dy_tx*i,tx(i),'Units','Normalized', ...
        'HorizontalAlignment','left','FontSize',fs2, ...
        'Color',cmdp(i,:))
end
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
apl = {['Avg Power = ' num2str(round(mdpo.power_avg,1)) ' W']};
aptx = text(.12,.1,apl,'Units','Normalized','FontSize',fs2, ...
    'Color',cmdp(3,:),'BackgroundColor','w','EdgeColor','k');
box on
%MDP: STATE OF CHARGE TIME SERIES
ax(3) = subaxis(9,1,3);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    mdpo.E_sim(f_pts)/1000,20,mdpo.E_sim(f_pts)/1000,'Filled')
colormap(ax(3),cSC)
caxis([0 mdpo.wec.E_max/1000])
hold on
dvp = plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    mdpo.E_true(f_pts)/1000,'-m','LineWidth',.9);
ylim([0 mdpo.wec.E_max/1000*1.1])
yticks(linspace(0,mdpo.wec.E_max/1000,3))
yl = ylabel({'MDP','SoC Profile','[kWh]'},'Color',cmdp(3,:), ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
% dv_dn = {'Discretization Validation'};
% dvl = legend(dvp,dv_dn, ...
%     'location','southwest','FontSize',fs2,'NumColumns',1);
xlim(xl)
xticks(xt)
grid on
box on
%PBO: OPERATIONAL STATE TIME SERIES
ax(4) = subaxis(9,1,4);
set(gca,'YAxisLocation','right')
for i = 1:max(pboo.a_sim)
    scatter(datetime(FM_P_1((pboo.a_sim==i),1),'ConvertFrom', ...
        'datenum'),pboo.a_sim(pboo.a_sim==i),'.', ...
        'MarkerEdgeColor',cpbo(i,:))
    hold on
    scatter(datetime(FM_P_1((pboo.a_act_sim==i),1),'ConvertFrom', ...
        'datenum'),pboo.a_sim(pboo.a_act_sim==i),'.', ...
        'MarkerEdgeColor',cpbo(i,:))
end
set(gca,'YAxisLocation','right')
grid on
xlim(xl)
xticks(xt)
ylim([0.5 4.5])
yl = ylabel({'Posterior','Bound','Operational','Mode'},'Color',cpbo(3,:), ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
yticks(1:max(pboo.a_sim));
set(gca,'YTickLabel',[])
tx = (fliplr({'Full Power','Medium Power','Low Power', ...
    'Survival Mode'}));
dy_tx = 0.253;
for i = 1:max(pboo.a_sim)
    text(1.0075,-.13+dy_tx*i,tx(i),'Units','Normalized', ...
        'HorizontalAlignment','left','FontSize',fs2, ...
        'Color',cpbo(i,:))
end
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
apl = {['Avg Power = ' num2str(round(pboo.power_avg,1)) ' W']};
aptx = text(.12,.1,apl,'Units','Normalized','FontSize',fs2, ...
    'Color',cpbo(3,:),'BackgroundColor','w','EdgeColor','k');
box on
%PBO: STATE OF CHARGE TIME SERIES
ax(5) = subaxis(9,1,5);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    pboo.E_sim(f_pts)/1000,20,pboo.E_sim(f_pts)/1000,'Filled')
colormap(ax(5),cSC)
caxis([0 pboo.wec.E_max/1000])
hold on
dvp = plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    pboo.E_true(f_pts)/1000,'-m','LineWidth',.9);
ylim([0 pboo.wec.E_max/1000*1.1])
yticks(linspace(0,pboo.wec.E_max/1000,3))
yl = ylabel({'Posterior','Bound','SoC Profile','[kWh]'},'Color',cpbo(3,:), ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
% dv_dn = {'Discretization Validation'};
% dvl = legend(dvp,dv_dn, ...
%     'location','southwest','FontSize',fs2,'NumColumns',1);
xlim(xl)
xticks(xt)
grid on
box on
%SoC BASED: OPERATIONAL STATE TIME SERIES
ax(6) = subaxis(9,1,6);
set(gca,'YAxisLocation','right')
for i = 1:max(sloo.a_sim)
    scatter(datetime(FM_P_1((sloo.a_sim==i),1),'ConvertFrom', ...
        'datenum'),sloo.a_sim(sloo.a_sim==i),'.', ...
        'MarkerEdgeColor',cslo(i,:))
    hold on
    scatter(datetime(FM_P_1((sloo.a_act_sim==i),1),'ConvertFrom', ...
        'datenum'),sloo.a_sim(sloo.a_act_sim==i),'.', ...
        'MarkerEdgeColor',cslo(i,:))
end
set(gca,'YAxisLocation','right')
grid on
xlim(xl)
xticks(xt)
ylim([0.5 4.5])
yl = ylabel({'SoC','Based','Operational','Mode'},'Color',cslo(3,:), ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
yticks(1:max(sloo.a_sim));
set(gca,'YTickLabel',[])
tx = (fliplr({'Full Power','Medium Power','Low Power', ...
    'Survival Mode'}));
dy_tx = 0.253;
for i = 1:max(sloo.a_sim)
    text(1.0075,-.13+dy_tx*i,tx(i),'Units','Normalized', ...
        'HorizontalAlignment','left','FontSize',fs2, ...
        'Color',cslo(i,:))
end
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
apl = {['Avg Power = ' num2str(round(sloo.power_avg,1)) ' W']};
aptx = text(.12,.1,apl,'Units','Normalized','FontSize',fs2, ...
    'Color',cslo(3,:),'BackgroundColor','w','EdgeColor','k');
box on
%SoC BASED: STATE OF CHARGE TIME SERIES
ax(7) = subaxis(9,1,7);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    sloo.E_sim(f_pts)/1000,20,sloo.E_sim(f_pts)/1000,'Filled')
colormap(ax(7),cSC)
caxis([0 sloo.wec.E_max/1000])
hold on
dvp = plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    sloo.E_true(f_pts)/1000,'-m','LineWidth',.9);
ylim([0 sloo.wec.E_max/1000*1.1])
yticks(linspace(0,sloo.wec.E_max/1000,3))
yl = ylabel({'SoC','Based','SoC Profile','[kWh]'},'Color',cslo(3,:), ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
% dv_dn = {'Discretization Validation'};
% dvl = legend(dvp,dv_dn, ...
%     'location','southwest','FontSize',fs2,'NumColumns',1);
xlim(xl)
xticks(xt)
grid on
box on
%DURATION BASED: OPERATIONAL STATE TIME SERIES
ax(8) = subaxis(9,1,8);
set(gca,'YAxisLocation','right')
for i = 1:max(sl2o.a_sim)
    scatter(datetime(FM_P_1((sl2o.a_sim==i),1),'ConvertFrom', ...
        'datenum'),sl2o.a_sim(sl2o.a_sim==i),'.', ...
        'MarkerEdgeColor',csl2(i,:))
    hold on
    scatter(datetime(FM_P_1((sl2o.a_act_sim==i),1),'ConvertFrom', ...
        'datenum'),sl2o.a_sim(sl2o.a_act_sim==i),'.', ...
        'MarkerEdgeColor',csl2(i,:))
end
set(gca,'YAxisLocation','right')
grid on
xlim(xl)
xticks(xt)
ylim([0.5 4.5])
yl = ylabel({'Duration','Based','Operational','Mode'},'Color',csl2(3,:), ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
yticks(1:max(sl2o.a_sim));
set(gca,'YTickLabel',[])
tx = (fliplr({'Full Power','Medium Power','Low Power', ...
    'Survival Mode'}));
dy_tx = 0.253;
for i = 1:max(sl2o.a_sim)
    text(1.0075,-.13+dy_tx*i,tx(i),'Units','Normalized', ...
        'HorizontalAlignment','left','FontSize',fs2, ...
        'Color',csl2(i,:))
end
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
apl = {['Avg Power = ' num2str(round(sl2o.power_avg,1)) ' W']};
aptx = text(.12,.1,apl,'Units','Normalized','FontSize',fs2, ...
    'Color',csl2(3,:),'BackgroundColor','w','EdgeColor','k');
box on
%DURATION BASED: STATE OF CHARGE TIME SERIES
ax(9) = subaxis(9,1,9);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    sl2o.E_sim(f_pts)/1000,20,sl2o.E_sim(f_pts)/1000,'Filled')
colormap(ax(9),cSC)
caxis([0 sl2o.wec.E_max/1000])
hold on
dvp = plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    sl2o.E_true(f_pts)/1000,'-m','LineWidth',.9);
ylim([0 sl2o.wec.E_max/1000*1.1])
yticks(linspace(0,sl2o.wec.E_max/1000,3))
yl = ylabel({'Duration','Based','SoC Profile','[kWh]'},'Color',csl2(3,:), ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'FontSize',fs)
dv_dn = {'Discretization Validation'};
% dvl = legend(dvp,dv_dn, ...
%     'location','southwest','FontSize',fs2,'NumColumns',1);
xlim(xl)
xticks(xt)
grid on
box on

for i = 1:length(ax)
    set(ax(i),'Units','Inches','Position',[xoff ...
        (length(ax)-i)*(ylength+ymarg)+yoff xlength ylength])
end

if printfig
    print(tscomp,['~/Dropbox (MREL)/Research/WAMP-MDP/' ...
        'paper_figures/tscomp'],'-dpng','-r600')
end
