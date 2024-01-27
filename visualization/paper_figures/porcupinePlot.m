clc, close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
addpath(genpath('~/MATLAB/Helper'))

if ~exist('FM','var')
    load('WETSForecastMatrix')
    FM = WETSForecastMatrix.FM_subset;
    clear WETSForecastMatrix
end
mdpInputs

%extract data and organize
%add for spin up buffer
FM_orig = FM;
sub = 5; %spin up buffer
for f = 1:size(FM,2) %apply spin up buffer
    Fext = find(~isnan(FM(:,f,2)),1,'last');
    excl = Fext - (size(FM,1) - sub); %num of forecasts to exclude
    if excl >= 1 %must interpolate if one or more excluded value
        %draw out the interpolation/indexing and it will all make sense
        FM(2:excl+1,f,2) = interp1([1 excl+2],[FM_orig(1,f,2) ...
            FM_orig(excl+2,f,2)],2:excl+1); %Hs
        FM(2:excl+1,f,3) = interp1([1 excl+2],[FM_orig(1,f,3) ...
            FM_orig(excl+2,f,3)],2:excl+1); %Tp
    end
end
P = (1/(16*4*pi)).*wec.rho.*wec.g^2.*FM(:,:,2).^2.*FM(:,:,3); %[W/m]
%find error of forecasts
Err = zeros(1,size(P,2));
temp_err = zeros(1,size(P,1)-1);
for f = 1:24:size(P,2) %compute error across all forecasts
    for t = 1:size(P,1)-1
        if t+f <= size(P,2)
            temp_err(t) = abs(P(1+t,f) - P(1,f+t));           
        else
            temp_err(t) = NaN;
        end 
    end
    Err(f) = nanmean(temp_err);
end
Err = round((Err./max(Err)).*100);
mmv = 1; %moving mean value
%find deltas
D = zeros(size(P,2),7)*nan;
ind_err = D; %index error, for debugging
nfa = 1:24:size(P,2); %new forecast array
for f = 25:size(P,2)
    days_avail = ceil((f-1)/24); %forecast days available for comparison
    if days_avail > 7 %limited to seven day horizon
        days_avail = 7;
    end
    f_ind = nfa(nfa < f); %look for forecasts prior to f
    f_ind = f_ind(end-days_avail+1:end); %filter available forecasts
    for d = 1:days_avail
        %just need to fix the indexing on the second term in line 55
        D(f,d) = P(f-f_ind(end+1-d)+1,f_ind(end+1-d)) - P(1,f); %[W/m]
        ind_err(f,d) = FM(1,f,1) - FM(f-f_ind(end+1-d)+1,f_ind(end+1-d),1);
    end
end
D = D'; %transpose for consistency

%plot settings
fs = 8;
f = 1; %position size factor increase
yls = -.1;
%cM = [21, 0, 128]/256; %color of measured
cM = 'k';
%cF = [137, 198, 240]/256; %color of forecast
%cF = brewermap(7,'YlOrRd');
cF = AdvancedColormap('sr',100); %color of forecasts
cD = AdvancedColormap('kkkg kg r',7); %color of deltas
%icF = 1;
cB = [0.75 0.75 0.75]; %color of background
%cF = [240, 137, 147]/256; 
aF = 0.4; %alpha of forecasts
aD = 0.4; %alpha of deltas
aB = 0.225; %alpha of background;
aM = 1; %alpha of measured
xB = 500; %background x dir buffer
lwM = 1.5; %linewidth of measured
lwF = .8; %linewidth of forecast
%lwB = .85; %linewidth of bounding box
lwB = 1.1; %linewidth of bounding box
cblpos = [-0.8 1.05]; %colorbar label position
ll = 250; %left limit (grey area)
rl = 700; %right limit (grey area)
ann_pos = [0.02 0.75]; %position for annotations

porcupine = figure;
set(gcf,'Units','inches')
set(gcf,'Position', [0, 0, 6.5*f, 4*f])
%set(gca,'FontName','cmr10')
%PORCUPINE
a = 1; ax(a) = subplot(4,1,1);
aL = area([datetime(FM(1,1,1)-xB,'ConvertFrom','datenum'), ...
    datetime(FM(1,ll,1),'ConvertFrom','datenum')], ...
    [max(P(:)./1000)*2 max(P(:)./1000)*2],'FaceAlpha',aB, ...
    'FaceColor',cB,'EdgeColor','k','LineWidth',lwB);
hold on
aR = area([datetime(FM(1,rl,1),'ConvertFrom','datenum'), ...
    datetime(FM(1,end,1)+xB,'ConvertFrom','datenum')], ...
    [max(P(:)./1000)*2 max(P(:)./1000)*2],'FaceAlpha',aB, ...
    'FaceColor',cB,'EdgeColor','k','LineWidth',lwB);
hold on
pM = plot(datetime(FM(1,:,1),'ConvertFrom','datenum'), ...
    movmean(P(1,:)/1000,mmv),'LineWidth',lwM,'Color',cM);
hold on
pM.Color(4) = aM;
for i = 1:24:size(P,2)
    pF(i) = plot(datetime(FM(:,i,1),'ConvertFrom','datenum'), ...
        movmean(P(:,i)/1000,mmv),'LineWidth',lwF,'Color', ...
        cF(round(Err(i)),:));
    pF(i).Color(4) = aF;
end
ymax = max(P(:)./1000)*1.1; %maximum for ylim
set(ax(a),'YLim',[0 ymax]);
line([datetime(FM(1,ll,1),'ConvertFrom','datenum') ...
    datetime(FM(1,rl,1),'ConvertFrom','datenum')],[ymax ymax], ...
    'LineWidth',lwB,'Color','k');
hold on
line([datetime(FM(1,ll,1),'ConvertFrom','datenum') ...
    datetime(FM(1,rl,1),'ConvertFrom','datenum')],[0 0], ...
    'LineWidth',lwB,'Color','k');
hold on
line([datetime(FM(1,ll,1),'ConvertFrom','datenum') ...
    datetime(FM(1,ll,1),'ConvertFrom','datenum')],[0 ymax], ...
    'LineWidth',lwB,'Color','k');
hold on
line([datetime(FM(1,rl,1),'ConvertFrom','datenum') ...
    datetime(FM(1,rl,1),'ConvertFrom','datenum')],[0 ymax], ...
    'LineWidth',lwB,'Color','k');
% rectangle('Position',[FM(1,1,1)-xB ...
%     0 FM(1,end,1)+xB ymax],'EdgeColor','r')
set(ax(a),'XLim',[datetime(min(min(FM(:,:,1))),'ConvertFrom','datenum') ...
    datetime(max(max(FM(:,:,1))),'ConvertFrom','datenum')])
xt = get(ax(a),'XTick');
set(ax(a).YLabel,'interpreter','tex','String', ...
    {'Wave','Power','Flux','[kWm^{-1}]'})
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
set(ylh,'Rotation',0,'Position',ylp,'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Units','Normalized')
ylabpos = get(ylh,'Position');
ylabpos(1) = yls;
set(ylh,'Position',ylabpos)
set(ax(a),'XTick',xt,'XTickLabel',{});
colormap(ax(a),cF)
cb(a) = colorbar('east');
set(cb(a),'Box','off','TickLength',0.05,'Units','Normalized')
set(cb(a).Label,'String',{'Normalized','Error'},'Rotation',0, ...
    'HorizontalAlignment','right','Units','Normalized')
text(ann_pos(1),ann_pos(2),'(a)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal','FontSize',fs);
set(gca,'FontSize',fs)
grid on
%DELTAS
a = 2; ax(a) = subplot(4,1,2);
aL = area([datetime(FM(1,1,1)-xB,'ConvertFrom','datenum'), ...
    datetime(FM(1,ll,1),'ConvertFrom','datenum')], ...
    [max(P(:)./1000)*2 max(P(:)./1000)*2],'FaceAlpha',aB, ...
    'FaceColor',cB,'EdgeColor','k','LineWidth',lwB);
hold on
aR = area([datetime(FM(1,rl,1),'ConvertFrom','datenum'), ...
    datetime(FM(1,end,1)+xB,'ConvertFrom','datenum')], ...
    [max(P(:)./1000)*2 max(P(:)./1000)*2],-100,'FaceAlpha',aB, ...
    'FaceColor',cB,'EdgeColor','k','LineWidth',lwB);
for i = 1:size(D,1)
    pD(i) = plot(datetime(FM(1,:,1),'ConvertFrom','datenum'), ...
        movmean(D(i,:)/1000,mmv),'LineWidth',lwF,'Color',cD(i,:));
    pD(i).Color(4) = aD;
end
ymax = max(D(:)./1000)*1.1; %maximum for ylim
ymin = min(D(:)./1000)*1.1; %minimum for ylim
set(ax(a),'YLim',[0 ymax]);
line([datetime(FM(1,ll,1),'ConvertFrom','datenum') ...
    datetime(FM(1,rl,1),'ConvertFrom','datenum')],[ymax ymax], ...
    'LineWidth',lwB,'Color','k');
line([datetime(FM(1,ll,1),'ConvertFrom','datenum') ...
    datetime(FM(1,rl,1),'ConvertFrom','datenum')],[ymin ymin], ...
    'LineWidth',lwB,'Color','k');
hold on
line([datetime(FM(1,ll,1),'ConvertFrom','datenum') ...
    datetime(FM(1,ll,1),'ConvertFrom','datenum')],[ymin ymax], ...
    'LineWidth',lwB,'Color','k');
hold on
line([datetime(FM(1,rl,1),'ConvertFrom','datenum') ...
    datetime(FM(1,rl,1),'ConvertFrom','datenum')],[ymin ymax], ...
    'LineWidth',lwB,'Color','k');
set(ax(a),'YLim',[ymin ymax]);
set(ax(a),'XLim',[datetime(min(min(FM(:,:,1))),'ConvertFrom','datenum') ...
    datetime(max(max(FM(:,:,1))),'ConvertFrom','datenum')])
xt = get(ax(a),'XTick');
set(ax(a).YLabel,'interpreter','tex','String', ...
    {'P_{w,f} - P_{w,m}','[kWm^{-1}]'})
set(ax(a).YLabel,'Units','Normalized','Rotation',0,'Position', ...
    ylabpos,'VerticalAlignment','middle', ...
    'HorizontalAlignment','center')
set(ax(a),'XTick',xt);
colormap(gca,cD)
cb(a) = colorbar('east');
set(cb(a),'Box','off','TickLength',0.05,'Units','Normalized', ...
    'Ticks',(1:2:7)./7,'TickLabels',{'1','3','5','7'})
set(cb(a).Label,'String',{'Days','Out'},'Rotation',0, ...
    'HorizontalAlignment','right','Units','Normalized')
text(ann_pos(1),ann_pos(2),'(b)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal','FontSize',fs);
set(gca,'FontSize',fs)
grid on
%PORCUPINE ZOOM
a = 3; ax(a) = subplot(4,1,3);
pM = plot(datetime(FM(1,:,1),'ConvertFrom','datenum'), ...
    movmean(P(1,:)/1000,mmv),'LineWidth',lwM,'Color',cM);
pM.Color(4) = aM;
hold on
for i = 1:24:size(P,2)
    pFz(i) = plot(datetime(FM(:,i,1),'ConvertFrom','datenum'), ...
        movmean(P(:,i)/1000,mmv),'LineWidth',lwF,'Color', ...
        cF(round(Err(i)),:));
    pFz(i).Color(4) = aF;
end
set(ax(a),'XLim',[datetime(FM(1,ll,1),'ConvertFrom','datenum') ...
    datetime(FM(1,rl,1),'ConvertFrom','datenum')])
%set(ax(a),'YLim',[0 max(P(:)./1000)*1.1]);
xt = get(ax(a),'XTick');
set(ax(a).YLabel,'interpreter','tex','String', ...
    {'Wave','Power','Flux','[kWm^{-1}]'})
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
set(ylh,'Rotation',0,'Position',ylp,'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Units','Normalized')
ylabpos = get(ylh,'Position');
ylabpos(1) = yls;
set(ylh,'Position',ylabpos)
set(ax(a),'XTick',xt,'XTickLabels',{});
colormap(gca,cF)
cb(a) = colorbar('east');
set(cb(a),'Box','off','TickLength',0.05,'Units','Normalized')
set(cb(a).Label,'String',{'Normalized','Error'},'Rotation',0, ...
    'HorizontalAlignment','right','Units','Normalized')
set(gca,'FontSize',fs,'LineWidth',lwB)
text(ann_pos(1),ann_pos(2),'(c)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal','FontSize',fs);
grid on
%DELTA ZOOM
a = 4; ax(a) = subplot(4,1,4);
hold on
for i = 1:size(D,1)
    pFz(i) = plot(datetime(FM(1,:,1),'ConvertFrom','datenum'), ...
        movmean(D(i,:)/1000,mmv),'LineWidth',lwF,'Color',cD(i,:));
    pFz(i).Color(4) = aD;
end
set(ax(a),'XLim',[datetime(FM(1,ll,1),'ConvertFrom','datenum') ...
    datetime(FM(1,rl,1),'ConvertFrom','datenum')])
% yl = get(ax(a),'YLim');
% yl(2) = yl(2)*1.25;
% set(ax(a),'YLim',yl);
set(ax(a),'YLim',[-15 40]);
xt = get(ax(a),'XTick');
set(ax(a).YLabel,'interpreter','tex','String', ...
    {'P_{w,f} - P_{w,m}','[kWm^{-1}]'})
ylh = get(gca,'ylabel');
ylp = get(ylh, 'Position');
set(ylh,'Rotation',0,'Position',ylp,'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Units','Normalized')
ylabpos = get(ylh,'Position');
ylabpos(1) = yls;
set(ylh,'Position',ylabpos)
set(ax(a),'XTick',xt);
colormap(gca,cD)
cb(a) = colorbar('east');
set(cb(a),'Box','off','TickLength',0.05,'Units','Normalized', ...
    'Ticks',(1:2:7)./7,'TickLabels',{'1','3','5','7'})
set(cb(a).Label,'String',{'Days','Out'},'Rotation',0, ...
    'HorizontalAlignment','right','Units','Normalized')
set(gca,'FontSize',fs,'LineWidth',lwB)
text(ann_pos(1),ann_pos(2),'(d)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal','FontSize',fs);
grid on
box on

Xwidth = 5.25;
Yheight = .75; 
XmargW = 0.3;
YmargW = 0.15;
Yoff = .3;
Xoff = .9;
cbyh = [0.85 0.62 0.355 0.145];

for a=1:4
    j = [4 3 2 1];
    if a < 3
        extra = 1;
    else
        extra = 0;
    end
    set(ax(a),'Units','Inches','Position',[Xoff ...
        Yoff+(j(a)-1)*(Yheight+YmargW)+extra*YmargW Xwidth Yheight])
    cbh = findobj(gcf,'tag','Colorbar');
    set(cbh, 'YAxisLocation','right');
    set(cb(a),'Position',[.90 cbyh(a) .008 0.1])
    set(cb(a).Label,'Position',cblpos)
end

set(gcf,'Color','w')
% print(porcupine, ...
%     '~/Dropbox (MREL)/Research/WAMP-MDP/paper_figures/porcupine',  ...
%     '-dpng','-r600')
print(porcupine, ...
    '~/Documents/WAMP-MDP/paper_figures/porcupine',  ...
    '-dpng','-r600')


