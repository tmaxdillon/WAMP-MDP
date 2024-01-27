if ~allon
    close all
    clearvars -except mdpsim pbosim sl4sim sl3sim
    w = 2; %wec index
    b = 3; %battery index
end
%% 

close all
disp('plotting...')
set(0,'defaulttextinterpreter','tex')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
%addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
addpath(genpath('~/MATLAB/Helper'))
% output_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
%     'output_data/12_22/'];
output_path = ['~/Documents/WAMP-MDP/output_data/12_22/'];


printfig = true; %print figure

if ~exist('mdpsim','var') || ~exist('sl4sim','var') || ...
        ~exist('sl3sim','var') || ~exist('pbosim','var')
    load([output_path 'mdpsim']);
    load([output_path 'pbosim']);
    load([output_path 'sl4sim']);
    load([output_path 'sl3sim']);    
    %simStruct = mdpsim;
end

%unpack data structure
FM_P_1 = squeeze(mdpsim(w,b).output.FM_P(1,:,:));
FM_mod_1 = squeeze(mdpsim(w,b).output.FM_mod(1,:,:));
mdpo = mdpsim(w,b).output;
pboo = pbosim(w,b).output;
greo = sl3sim(w,b).output;
dblo = sl4sim(w,b).output;
if mdpo.abridged %find forecast time steps being used
    f_pts = 1:find(mdpo.E_sim > 0,1,'last');
else
    f_pts = 1:length(mdpo.E_sim(1:end-1));
end

%compute theta rate
[t_r_mdp] = calcThetaRate(mdpo.a_act_sim,mdpo.FM_mod(1,:,1), ...
    mdpsim(w,b).mdp.tp)*100;
[t_r_pbo] = calcThetaRate(pboo.a_act_sim,pboo.FM_mod(1,:,1), ...
    pbosim(w,b).mdp.tp)*100;
[t_r_gre] = calcThetaRate(greo.a_act_sim,greo.FM_mod(1,:,1), ...
    sl3sim(w,b).mdp.tp)*100;
[t_r_dbl] = calcThetaRate(dblo.a_act_sim,dblo.FM_mod(1,:,1), ...
    sl4sim(w,b).mdp.tp)*100;

%old colors
% cmdp(4,:) = [41 31 66]/225;
% cmdp(3,:) = [72 54 116]/255;
% cmdp(2,:) = [103 78 167]/255;
% cmdp(1,:) = [133 113 184]/255;
% cpbo(4,:) = [97 35 53]/225;
% cpbo(3,:) = [139 50 77]/255;
% cpbo(2,:) = [162 90 112]/255;
% cpbo(1,:) = [185 132 148]/255;
% cgre(4,:) = [127 0 0]/225;
% cgre(3,:) = [204 0 0]/255;
% cgre(2,:) = [255 50 50]/255;
% cgre(1,:) = [255 102 102]/255;
% cdbl(4,:) = [127 72 10]/225;
% cdbl(3,:) = [203 116 16]/255;
% cdbl(2,:) = [254 145 20]/255;
% cdbl(1,:) = [254 167 66]/255;
% %more vibrant orange
% cdbl(4,:) = [178 55 0]/225;
% cdbl(3,:) = [255 79 0]/255;
% cdbl(2,:) = [255 114 50]/255;
% cdbl(1,:) = [255 131 76]/255;

%plot settings
xoff = 1;
xlength = 4.65;
ylength = .625;
yoff = .35;
ymarg = 0.075;
ylhpos = -0.115; %ylabel horizonal position (normalized)
fs = 8; %axis font size
fs2 = 7; %tick font size
fs3 = 6; %text box font
ann_x = 1.132;
cmdp(4,:) = [102 0 57]/225;
cmdp(3,:) = [178 0 100]/255;
cmdp(2,:) = [255 0 143]/255;
cmdp(1,:) = [255 76 176]/255;
cpbo(4,:) = [41 31 66]/225;
cpbo(3,:) = [72 54 116]/255;
cpbo(2,:) = [103 78 167]/255;
cpbo(1,:) = [133 113 184]/255;
cgre(4,:) = [0 96 0]/256;
cgre(3,:) = [0 168 0]/256;
cgre(2,:) = [20 240 20]/256;
cgre(1,:) = [127 247 127]/256;
cdbl(4,:) = [36,78,36]/256;
cdbl(3,:) = [60,130,60]/256;
cdbl(2,:) = [98,155,98]/256;
cdbl(1,:) = [157,192,157]/256;
cSC = AdvancedColormap('kr ryy yl lg ggk',1000);
reddots = false;

tscomp = figure;
set(gcf,'Units','inches','Color','w')
set(gcf, 'Position', [1, 1, 6.5, 6.75])
%POWER TIME SERIES
ax(1) = subaxis(9,1,1);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_P_1(f_pts,2)/1000,'k');
ylim([0 ceil(mdpo.wec.rp/1000)])
if w == 2
    yticks([0 .25 .5 round(mdpo.wec.rp/1000,2) ])
elseif w == 3
    yticks([0 .5 1 round(mdpo.wec.rp/1000,2) ])
elseif w == 4
    yticks([0 1 2 round(mdpo.wec.rp/1000,2) ])
end
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
text(1.025,.5,'(a)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
grid on
%MDP: OPERATIONAL STATE TIME SERIES
ax(2) = subaxis(9,1,2);
set(gca,'YAxisLocation','right')
for i = 1:max(mdpo.a_sim)
    if reddots
        scatter(datetime(FM_P_1((mdpo.a_sim==i),1),'ConvertFrom', ...
            'datenum'),mdpo.a_sim(mdpo.a_sim==i),'.', ...
            'MarkerEdgeColor','r')
    end
    hold on
    scatter(datetime(FM_P_1((mdpo.a_act_sim==i),1),'ConvertFrom', ...
        'datenum'),mdpo.a_act_sim(mdpo.a_act_sim==i),'.', ...
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
apl = {['P_{mean} = ' num2str(round(mdpo.power_avg,1)) ' W, ' ...
    '\theta_{rate} = ' num2str(round(t_r_mdp,1)) ' %']};
text(.03,.1,apl,'Units','Normalized','FontSize',fs3, ...
    'Color','k','BackgroundColor','w','EdgeColor','k');
text(ann_x,.4,'(b)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
box on
%MDP: STATE OF CHARGE TIME SERIES
ax(3) = subaxis(9,1,3);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    mdpo.E_sim(f_pts)/1000,20,mdpo.E_sim(f_pts)/1000,'Filled')
colormap(ax(3),cSC)
caxis([0 mdpo.wec.E_max/1000])
hold on
plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
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
text(1.025,.5,'(c)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
box on
%PBO: OPERATIONAL STATE TIME SERIES
ax(4) = subaxis(9,1,4);
set(gca,'YAxisLocation','right')
for i = 1:max(pboo.a_sim)
    if reddots
        scatter(datetime(FM_P_1((pboo.a_sim==i),1),'ConvertFrom', ...
            'datenum'),pboo.a_sim(pboo.a_sim==i),'.', ...
            'MarkerEdgeColor','r')
    end
    hold on
    scatter(datetime(FM_P_1((pboo.a_act_sim==i),1),'ConvertFrom', ...
        'datenum'),pboo.a_act_sim(pboo.a_act_sim==i),'.', ...
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
        'Color',cpbo(i,:)*.75)
end
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
apl = {['P_{mean} = ' num2str(round(pboo.power_avg,1)) ' W, ' ...
    '\theta_{rate} = ' num2str(round(t_r_pbo,1)) ' %']};
text(.03,.1,apl,'Units','Normalized','FontSize',fs3, ...
    'Color','k','BackgroundColor','w','EdgeColor','k');
text(ann_x,.4,'(d)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
box on
%PBO: STATE OF CHARGE TIME SERIES
ax(5) = subaxis(9,1,5);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    pboo.E_sim(f_pts)/1000,20,pboo.E_sim(f_pts)/1000,'Filled')
colormap(ax(5),cSC)
caxis([0 pboo.wec.E_max/1000])
hold on
plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
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
text(1.025,.5,'(e)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
box on
%GREEDY LOGIC: OPERATIONAL STATE TIME SERIES
ax(6) = subaxis(9,1,6);
set(gca,'YAxisLocation','right')
for i = 1:max(greo.a_sim)
    if reddots
        scatter(datetime(FM_P_1((greo.a_sim==i),1),'ConvertFrom', ...
            'datenum'),greo.a_sim(greo.a_sim==i),'.', ...
            'MarkerEdgeColor','r')
    end
    hold on
    scatter(datetime(FM_P_1((greo.a_act_sim==i),1),'ConvertFrom', ...
        'datenum'),greo.a_act_sim(greo.a_act_sim==i),'.', ...
        'MarkerEdgeColor',cgre(i,:))
end
set(gca,'YAxisLocation','right')
grid on
xlim(xl)
xticks(xt)
ylim([0.5 4.5])
yl = ylabel({'Greedy','Logic','Operational','Mode'}, ...
    'Color',cgre(3,:)*.85, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
yticks(1:max(greo.a_sim));
set(gca,'YTickLabel',[])
tx = (fliplr({'Full Power','Medium Power','Low Power', ...
    'Survival Mode'}));
dy_tx = 0.253;
for i = 1:max(greo.a_sim)
    text(1.0075,-.13+dy_tx*i,tx(i),'Units','Normalized', ...
        'HorizontalAlignment','left','FontSize',fs2, ...
        'Color',cgre(i,:)*.85)
end
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
apl = {['P_{mean} = ' num2str(round(greo.power_avg,1)) ' W, ' ...
    '\theta_{rate} = ' num2str(round(t_r_gre,1)) ' %']};
text(.03,.1,apl,'Units','Normalized','FontSize',fs3, ...
    'Color','k','BackgroundColor','w','EdgeColor','k');
text(ann_x,.4,'(f)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
box on
%GREEDY LOGIC: STATE OF CHARGE TIME SERIES
ax(7) = subaxis(9,1,7);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    greo.E_sim(f_pts)/1000,20,greo.E_sim(f_pts)/1000,'Filled')
colormap(ax(7),cSC)
caxis([0 greo.wec.E_max/1000])
hold on
plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    greo.E_true(f_pts)/1000,'-m','LineWidth',.9);
ylim([0 greo.wec.E_max/1000*1.1])
yticks(linspace(0,greo.wec.E_max/1000,3))
yl = ylabel({'Greedy','Logic','SoC Profile','[kWh]'}, ...
    'Color',cgre(3,:)*.85, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
xlim(xl)
xticks(xt)
grid on
text(1.025,.5,'(g)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
box on
%DURATION BASED: OPERATIONAL STATE TIME SERIES
ax(8) = subaxis(9,1,8);
set(gca,'YAxisLocation','right')
for i = 1:max(dblo.a_sim)
    if reddots
        scatter(datetime(FM_P_1((dblo.a_sim==i),1),'ConvertFrom', ...
            'datenum'),dblo.a_sim(dblo.a_sim==i),'.', ...
            'MarkerEdgeColor','r')
    end
    hold on
    scatter(datetime(FM_P_1((dblo.a_act_sim==i),1),'ConvertFrom', ...
        'datenum'),dblo.a_act_sim(dblo.a_act_sim==i),'.', ...
        'MarkerEdgeColor',cdbl(i,:))
end
set(gca,'YAxisLocation','right')
grid on
xlim(xl)
xticks(xt)
ylim([0.5 4.5])
yl = ylabel({'Duration','Based','Operational','Mode'}, ...
    'Color',cdbl(3,:)*.85, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
yticks(1:max(dblo.a_sim));
set(gca,'YTickLabel',[])
tx = (fliplr({'Full Power','Medium Power','Low Power', ...
    'Survival Mode'}));
dy_tx = 0.253;
for i = 1:max(dblo.a_sim)
    text(1.0075,-.13+dy_tx*i,tx(i),'Units','Normalized', ...
        'HorizontalAlignment','left','FontSize',fs2, ...
        'Color',cdbl(i,:)*.75)
end
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
apl = {['P_{mean} = ' num2str(round(dblo.power_avg,1)) ' W, ' ...
    '\theta_{rate} = ' num2str(round(t_r_dbl,1)) ' %']};
text(.03,.1,apl,'Units','Normalized','FontSize',fs3, ...
    'Color','k','BackgroundColor','w','EdgeColor','k');
text(ann_x,.4,'(h)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
box on
%DURATION BASED: STATE OF CHARGE TIME SERIES
ax(9) = subaxis(9,1,9);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    dblo.E_sim(f_pts)/1000,20,dblo.E_sim(f_pts)/1000,'Filled')
colormap(ax(9),cSC)
caxis([0 dblo.wec.E_max/1000])
hold on
plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    dblo.E_true(f_pts)/1000,'-m','LineWidth',.9);
ylim([0 dblo.wec.E_max/1000*1.1])
yticks(linspace(0,dblo.wec.E_max/1000,3))
yl = ylabel({'Duration','Based','SoC Profile','[kWh]'}, ...
    'Color',cdbl(3,:)*.85, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'FontSize',fs)
dv_dn = {'Discretization Validation'};
xlim(xl)
xticks(xt)
grid on
text(1.025,.5,'(i)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
box on

for i = 1:length(ax)
    set(ax(i),'Units','Inches','Position',[xoff ...
        (length(ax)-i)*(ylength+ymarg)+yoff xlength ylength])
end

if printfig
    print(tscomp,['~/Documents/WAMP-MDP/' ...
        'paper_figures/tscomp_w' num2str(w) 'b' ...
        num2str(b) ],'-dpng','-r600')
end
