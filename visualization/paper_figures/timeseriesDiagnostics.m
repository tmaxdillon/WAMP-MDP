%close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
output_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
    'output_data/12_22/'];

printfig = true; %print figure

if ~exist('simStruct','var')
    load([output_path 'mdpsim']);
    simStruct = mdpsim;
end
w = 2; %wec index 
b = 3; %battery index

%unpack data structure
FM_P_1 = squeeze(simStruct(w,b).output.FM_P(1,:,:));
FM_mod_1 = squeeze(simStruct(w,b).output.FM_mod(1,:,:));
output = simStruct(w,b).output;
if output.abridged %find forecast time steps being used
    f_pts = 1:find(output.E_sim > 0,1,'last');
else
    f_pts = 1:length(output.E_sim(1:end-1));
end

%plot settings
xoff = 1.05;
xlength = 4.65;
ylength = .625;
yoff = .275;
ymarg = 0.075;
ylhpos = -0.125; %ylabel horizonal position (normalized)
fs = 8; %axis font size
fs2 = 7; %tick font size
cHs = [4 74 116]/255;
cHs2 = [4 74 125]/255; 
cTp = [9 141 223]/255;
cTp2 = [0 130 210]/255;
ccw = [4 200 180]/255;
ccw2 = [0 150 130]/255;
ckW = [72 54 116]/255;
cmo(4,:) = [102 0 57]/225;
cmo(3,:) = [178 0 100]/255;
cmo(2,:) = [255 0 143]/255;
cmo(1,:) = [255 76 176]/255;
% cmo(4,:) = [41 31 66]/225;
% cmo(3,:) = [72 54 116]/255;
% cmo(2,:) = [103 78 167]/255;
% cmo(1,:) = [133 113 184]/255;
cJS = [178 55 0]/225;
addpath(genpath('~/Dropbox (MREL)/MATLAB/Helper/'))
cSC = AdvancedColormap('kr ryy yl lg ggk',1000);


tsdiag = figure;
set(gcf,'Units','inches','Color','w')
set(gcf, 'Position', [1, 1, 6.5, 4.5])
%RESOURCE TIME SERIES
ax(1) = subaxis(6,1,1,'SpacingVert',0.02);
hold(ax(1),'on')
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    -10.*ones(size(FM_mod_1(f_pts,2)))); %dummy plot to set x axis
%draw right axis gridlines on bottom because matlab doesn't do this
gl1 = 5; %[s] grid line 1
gl2 = 10; %[s] grid line 2
hs = FM_mod_1(f_pts,2);
tp = FM_mod_1(f_pts,3);
lHs = plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_mod_1(f_pts,2),'Color',cHs,'LineWidth',.8);
lHs.Color(4) = 1;
set(gca,'ylim',[0 2.14],'ycolor',cHs2,'FontSize',fs)
yll = ylabel({'Significant','Wave','Height','[m]'},'Color',cHs2, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yll,'Position');
set(yll,'Position',[ylhpos ylpos(2) ylpos(3)])
ytl = get(gca,'YTick');
yyaxis right
lTp = plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_mod_1(f_pts,3),'Color',cTp,'LineWidth',.8);
lTp.Color(4) = .6;
set(gca,'ylim',[0 inf],'ycolor',cTp2,'FontSize',fs)
yl = ylabel({'Peak','Wave','Period','[s]'},'Color',cTp2, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[1.09 ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
grid on
yyaxis left
hl(1) = yline(max(hs)*(gl1/max(tp)));
set(hl(1),'LineStyle','-','Color',[.8 .8 .8], ...
    'Alpha',1)
hl(2) = yline(max(hs)*(gl2/max(tp)));
set(hl(2),'LineStyle','-','Color',[.8 .8 .8], ...
    'Alpha',1)
% Set yline to 'back'
% Temporarily disable the warning that appears when accessing 
% the undocumented properties.
warnState = warning('off','MATLAB:structOnObject');
cleanupObj = onCleanup(@()warning(warnState)); 
Sxh = struct(hl(1));% Get undocumented properties (you'll get a warning)
clear('cleanupObj')      % Trigger warning reset
Sxh.Edge.Layer = 'back'; % Set ConstantLine uistack
warnState = warning('off','MATLAB:structOnObject');
cleanupObj = onCleanup(@()warning(warnState)); 
Sxh = struct(hl(2));% Get undocumented properties (you'll get a warning)
clear('cleanupObj')      % Trigger warning reset
Sxh.Edge.Layer = 'back'; % Set ConstantLine uistack
xlim([datetime(FM_mod_1(f_pts(1),1),'ConvertFrom','datenum') ...
    datetime(FM_mod_1(f_pts(end),1),'ConvertFrom','datenum')]);
xl = xlim;
xt = xticks;
text(.965,.125,'(a)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
set(gca,'ycolor',cHs2)
yll.Color = cHs2;
%CWR TIME SERIES
ax(2) = subaxis(6,1,2);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ... 
    FM_P_1(f_pts,4),'Color',ccw);
yticks([0 .05 .1 .15])
yl = ylabel({'Capture','Width','Ratio'}','Color',ccw2, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
xlim(xl)
set(gca,'FontSize',fs)
grid on
text(1.025,.5,'(b)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
%POWER TIME SERIES
ax(3) = subaxis(6,1,3);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_P_1(f_pts,2)/1000,'k');
ylim([0 output.wec.rp*1.1/1000])
yticks([0 .25 .5 round(output.wec.rp/1000,2) ])
yl = ylabel({'WEC','Power','Output','[kW]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
xlim(xl)
set(gca,'FontSize',fs)
grid on
text(1.025,.5,'(c)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
%OPERATIONAL STATE TIME SERIES
ax(4) = subaxis(6,1,4);
set(gca,'YAxisLocation','right')
for i = 1:max(output.a_sim)
    scatter(datetime(FM_P_1((output.a_sim==i),1),'ConvertFrom', ...
        'datenum'),output.a_sim(output.a_sim==i),'.', ...
        'MarkerEdgeColor',cmo(i,:))
    hold on
    scatter(datetime(FM_P_1((output.a_act_sim==i),1),'ConvertFrom', ...
        'datenum'),output.a_sim(output.a_act_sim==i),'.', ...
        'MarkerEdgeColor',cmo(i,:))
end
set(gca,'YAxisLocation','right')
grid on
xlim(xl)
xticks(xt)
ylim([0.5 4.5])
yl = ylabel({'Operational','Mode'},'Color',cmo(4,:), ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
yticks(1:max(output.a_sim));
set(gca,'YTickLabel',[])
tx = (fliplr({'Full Power','Medium Power','Low Power', ... 
    'Survival Mode'}));
dy_tx = 0.253;
for i = 1:max(output.a_sim)
    text(1.0075,-.13+dy_tx*i,tx(i),'Units','Normalized', ...
        'HorizontalAlignment','left','FontSize',fs2, ...
        'Color',cmo(i,:))
end
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
box on
text(.955,.125,'(d)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
%STATE OF CHARGE TIME SERIES
ax(5) = subaxis(6,1,5);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    output.E_sim(f_pts)/1000,20,output.E_sim(f_pts)/1000,'Filled')
colormap(ax(5),cSC)
caxis([0 output.wec.E_max/1000])
hold on
dvp = plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    output.E_true(f_pts)/1000,'-m','LineWidth',.9);
ylim([0 output.wec.E_max/1000*1.1])
yticks(linspace(0,output.wec.E_max/1000,5))
yl = ylabel({'State','of','Charge','[kWh]'},'Color',cSC(end,:)*.8, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
dv_dn = {'Discretization Validation'};
dvl = legend(dvp,dv_dn,'Units','normalized', ...
    'Position',[.36 .209 .1 .03],'FontSize',fs2,'NumColumns',1);
xlim(xl)
xticks(xt)
grid on
box on
text(1.025,.5,'(e)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);
%J STAR TIME SERIES
ax(6) = subplot(6,1,6);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    output.J_recon(f_pts),'Color',cJS,'LineWidth',.25);
delta = max(output.val_Jstar(f_pts))*.1;
%ylim([0-delta max(output.val_Jstar(f_pts))+delta])
ylim([0 1.4])
ovh = find(output.J_recon > 1.4);
hold on
scatter(datetime(FM_mod_1(ovh,1),'ConvertFrom','datenum'),1.4,'ko')
yticks([0 .2 .8 1])
yl = ylabel({'Reconstructed','Optimization','Value'},'Color',cJS, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'FontSize',fs)
xlim(xl)
xticks(xt)
grid on
text(1.025,.5,'(f)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs);

xticks(xt)

for i = 1:length(ax)
    set(ax(i),'Units','Inches','Position',[xoff ...
        (length(ax)-i)*(ylength+ymarg)+yoff xlength ylength])
end

if printfig
    print(tsdiag,['~/Dropbox (MREL)/Research/WAMP-MDP/' ...
        'paper_figures/tsdiag'],'-dpng','-r600')
end

