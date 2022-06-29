close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

if ~exist('simStruct','var')
    load('mdpsim');
    simStruct = mdpsim;
end
w = 3; %wec index 
b = 7; %battery index

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
xoff = 1;
xlength = 4.65;
ylength = .625;
yoff = .275;
ymarg = 0.075;
ylhpos = -0.115; %ylabel horizonal position (normalized)
fs = 8; %axis font size
fs2 = 6.5; %tick font size
cHs = [4 74 116]/255;
cTp = [9 141 223]/255;
ccw = [4 200 180]/255;
cmo(4,:) = [41 31 66]/225;
cmo(3,:) = [72 54 116]/255;
cmo(2,:) = [103 78 167]/255;
cmo(1,:) = [133 113 184]/255;
cJS = [128 0 64]/255;
addpath(genpath('~/Dropbox (MREL)/MATLAB/Helper/'))
cSC = AdvancedColormap('kr ryy yl lg ggk',1000);

mdp_ts = figure;
set(gcf,'Units','inches','Color','w')
set(gcf, 'Position', [1, 1, 6.5, 4.5])
%RESOURCE TIME SERIES
ax(1) = subaxis(6,1,1,'SpacingVert',0.02);
yyaxis left
lHs = plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_mod_1(f_pts,2),'Color',cHs,'LineWidth',.8);
lHs.Color(4) = 1;
set(gca,'ylim',[0 inf],'ycolor',cHs,'FontSize',fs)
yl = ylabel({'Significant','Wave','Height','[m]'},'Color',cHs, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
grid on
yyaxis right
lTp = plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_mod_1(f_pts,3),'Color',cTp,'LineWidth',.8);
lTp.Color(4) = .6;
set(gca,'ylim',[0 inf],'ycolor',cTp,'FontSize',fs)
yl = ylabel({'Peak','Wave','Period','[s]'},'Color',cTp, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[1.1 ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
grid on
xlim([datetime(FM_mod_1(f_pts(1),1),'ConvertFrom','datenum') ...
    datetime(FM_mod_1(f_pts(end),1),'ConvertFrom','datenum')]);
xl = xlim;
xt = xticks;
%CWR TIME SERIES
ax(2) = subaxis(6,1,2);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ... 
    FM_P_1(f_pts,4),'Color',ccw);
yticks([0:.05:ceil(max(FM_P_1(f_pts,4)))])
yl = ylabel({'Capture','Width','Ratio'}','Color',ccw, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
xlim(xl)
set(gca,'FontSize',fs)
grid on
%POWER TIME SERIES
ax(3) = subaxis(6,1,3);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    FM_P_1(f_pts,2)/1000,'k');
ylim([0 output.wec.rp*1.1/1000])
yticks([0:1:ceil(output.wec.rp*1.1/1000)])
yl = ylabel({'Power','Produced','[kW]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
xlim(xl)
set(gca,'FontSize',fs)
grid on
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
yl = ylabel({'Operational','Mode'},'Color',cmo(3,:), ...
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
%STATE OF CHARGE TIME SERIES
ax(5) = subaxis(6,1,5);
scatter(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    output.E_sim(f_pts)/1000,20,output.E_sim(f_pts)/1000,'Filled')
colormap(ax(5),cSC)
caxis([0 output.wec.E_max/1000])
hold on
dvp = plot(datetime(FM_P_1(f_pts,1),'ConvertFrom','datenum'), ...
    output.E_recon(f_pts)/1000,'-m','LineWidth',.9);
ylim([0 output.wec.E_max/1000*1.1])
yticks(linspace(0,output.wec.E_max/1000,5))
yl = ylabel({'State','of','Charge','[kWh]'},'Color',cSC(end,:), ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'XTickLabel',[]);
set(gca,'FontSize',fs)
dv_dn = {'Discretization Validation'};
dvl = legend(dvp,dv_dn, ...
    'location','southwest','FontSize',fs2,'NumColumns',1);
xlim(xl)
xticks(xt)
grid on
box on
%J STAR TIME SERIES
ax(6) = subplot(6,1,6);
plot(datetime(FM_mod_1(f_pts,1),'ConvertFrom','datenum'), ...
    output.val_Jstar(f_pts),'Color',cJS,'LineWidth',1);
delta = max(output.val_Jstar(f_pts))*.1;
ylim([0-delta max(output.val_Jstar(f_pts))+delta])
%yticks(linspace(0,output.wec.rp/1000,3))
yl = ylabel({'Backward','Recursion','Value'},'Color',cJS, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(yl,'Position');
set(yl,'Position',[ylhpos ylpos(2) ylpos(3)])
set(gca,'FontSize',fs)
xlim(xl)
xticks(xt)
grid on


xticks(xt)


for i = 1:length(ax)
    set(ax(i),'Units','Inches','Position',[xoff ...
        (length(ax)-i)*(ylength+ymarg)+yoff xlength ylength])
end


