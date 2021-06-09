clearvars -except mdpsim pbosim slosim
close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

medmode = 3; %set median mode (1) versus mean mode
plotmode = 1; %1: line, 2: shade, 3: errorbar

if ~exist('mdpsim','var') || ~exist('pbosim','var') || ...
        ~exist('slosim','var')
    load('mdpsim');
    load('pbosim');
    load('slosim');
end

B = mdpsim(1).sim.tuning_array2;
nw = length(B);

i_av = zeros(size(mdpsim,2),size(mdpsim,1),3);
i_hh = zeros(size(mdpsim,2),size(mdpsim,1),3);
i_ll = zeros(size(mdpsim,2),size(mdpsim,1),3);
i_me = zeros(size(mdpsim,2),size(mdpsim,1),3);
i_25 = zeros(size(mdpsim,2),size(mdpsim,1),3);
i_75 = zeros(size(mdpsim,2),size(mdpsim,1),3);
i_mx = zeros(size(mdpsim,2),size(mdpsim,1),3);
hh = 99;
ll = 1;

for w = 1:size(mdpsim,1) %across all wcd
    for e = 1:size(mdpsim,2) %across all emx  
        [i_av(e,w,1),i_hh(e,w,1),i_ll(e,w,1), ...
            i_me(e,w,1),i_25(e,w,1),i_75(e,w,1),i_mx(e,w,1)] =  ...
            calcIntermit(mdpsim(w,e).output.a_sim,hh,ll);
        [i_av(e,w,2),i_hh(e,w,2),i_ll(e,w,2), ...
            i_me(e,w,2),i_25(e,w,2),i_75(e,w,2),i_mx(e,w,2)] =  ...
            calcIntermit(pbosim(w,e).output.a_sim,hh,ll);
        [i_av(e,w,3),i_hh(e,w,3),i_ll(e,w,3), ...
            i_me(e,w,3),i_25(e,w,3),i_75(e,w,3),i_mx(e,w,3)] =  ...
            calcIntermit(slosim(w,e).output.a_sim,hh,ll);
    end
    kW(w) = mdpsim(w,e).output.wec.rp; %rated power
end

%x axis info
x = mdpsim(1).sim.tuning_array1./1000;
%xlab = 'Battery Size [kWh]';

%colors
c = 10;
mc = brewermap(c,'reds'); mc = mc(c-nw:end,:);
pc = brewermap(c,'greens'); pc = pc(c-nw:end,:);
sc = brewermap(c,'purples'); sc = sc(c-nw:end-1,:);
col1 = flipud(brewermap(8,'reds')); %col(1,:) = col1(c,:);
% col2 = brewermap(10,'oranges'); col(2,:) = col2(c,:);
% col3 = brewermap(10,'YlOrBr'); col(3,:) = col3(4,:);
% col4 = brewermap(10,'greens'); col(4,:) = col4(c,:);
% col5 = brewermap(10,'blues'); col(5,:) = col5(c,:);
% col6 = brewermap(10,'purples'); col(6,:) = col6(c,:);
col = col1(1:size(mdpsim,1),:);
c1 = [220,20,60]/256;
c2 = [0,0,205]/256;
c3 = [123,104,238]/256;

%sizes
ms = 6;
fs = 10;
lw = 1.2;
lw2 = 1;

%spacing
xoff = 1.25; %[in]
yoff = .55; %[in]
xdist = .95; %[in]
ydist = 2.4; %[in]
xmarg = 0.4; %[in]
ylims = flipud([570 620; 540 590; 430 480 ; 90 140]);

%find max range
% for w = 1:size(mdpsim,1)
%     maxdist(w) = max(max(i_mx(:,w,:))) - min(min(i_mx(:,w,:)));
% end
% maxdist = max(round(ceil(maxdist.*1.2),-1));

%set median or mean
if medmode == 1
    i = i_me;
    i_low = i_hh;
    i_high = i_ll;
    avglab = 'Median';
elseif medmode == 2
    i = i_av;
    i_low = i_hh;
    i_high = i_ll;
    avglab = 'Mean';
elseif medmode == 3
    i = i_mx;
    i_low = [];
    i_high = [];
    avglab = 'Max';
end

%average power
results_pa = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 6.5, 3.75])
for w = 1:size(mdpsim,1) %across all wcd
    ax(w) = subplot(1,4,w);
    hold on
    %POSTERIOR BOUND
    if plotmode == 1 || plotmode == 2
        pp(w) = plot(x,i(:,w,2),'-','MarkerEdgeColor',pc(w,:), ...
            'Color',pc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','Posterior Bound');
        mp(w) = plot(x,i(:,w,1),'-','MarkerEdgeColor',mc(w,:), ...
            'Color',mc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','MDP');
        sp(w) = plot(x,i(:,w,3),'-','MarkerEdgeColor',sc(w,:), ...
            'Color',sc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','Simple Logic');
        if plotmode == 2
            fill([x,flip(x)],[i_low(:,w,2)',flip(i_high(:,w,2)')], ...
                pc(w,:),'FaceAlpha',0.3,'EdgeColor','none', ...
                'HandleVisibility','off');
            fill([x,flip(x)],[i_low(:,w,1)',flip(i_high(:,w,1)')], ...
                mc(w,:),'FaceAlpha',0.3,'EdgeColor','none', ...
                'HandleVisibility','off');
            fill([x,flip(x)],[i_low(:,w,3)',flip(i_high(:,w,3)')], ...
                sc(w,:),'FaceAlpha',0.3,'EdgeColor','none', ...
                'HandleVisibility','off');
        end
    elseif plotmode == 3
        pp(w) = errorbar(x,i(:,w,2),i(:,w,2)-i_low(:,w,2), ...
            i_high(:,w,2)-i(:,w,2),'-o','MarkerEdgeColor',pc(w,:), ...
            'Color',pc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','Posterior Bound');
        mp(w) = errorbar(x,i(:,w,1),i(:,w,1)-i_low(:,w,1), ...
            i_high(:,w,1)-i(:,w,1),'-o','MarkerEdgeColor',mc(w,:), ...
            'Color',pc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','Posterior Bound');
        sp(w) = errorbar(x,i(:,w,3),i(:,w,3)-i_low(:,w,3), ...
            i_high(:,w,3)-i(:,w,3),'-o','MarkerEdgeColor',sc(w,:), ...
            'Color',pc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','Posterior Bound');
    end
    tt(w) = title({[num2str(B(w)) ' m WEC'], ...
        ['(\sim' num2str(round(kW(w)/1000,2)) 'kW)']}, ...
        'FontWeight','normal','Units','Normalized', ...
        'interpreter','tex');
    tt(w).Position(2) = tt(w).Position(2)*1.025;
    ylim([0 inf])
    %ylim(ylims(w,:))
%     yline(600,'--k','Max Draw', ...
%         'LabelHorizontalAlignment','left','FontSize',fs, ...
%         'LineWidth',lw2,'FontName','cmr10'); 
    %     ylim([ceil(max(max(power_avg(:,w,:))))-maxdist-1 ...
%         ceil(max(max(power_avg(:,w,:)+1)))])
%     if w == 1
%         lg2 = legend([mp pp sp],'Location','northoutside', ...
%             'orientation','horizontal');
%     end
%     ylabel({'Mean','Power','Consumed','[W]'})
%     ylh = get(gca,'ylabel');
%     set(ylh, 'Rotation',0,'Units','Inches', ...
%         'VerticalAlignment','middle', ...
%         'HorizontalAlignment','center','Position',[-yoff*1.5 ydist/2 0])
%     if w == 1
%         xlabel(xlab)
%     end
%     grid on
    set(gca,'FontSize',10)
    grid on
    %set(gca,'Units','Inches','Position',[xoff yoff xdist ydist])
end

hL = legend([mp(2) pp(2) sp(2)],'location','northoutside','Box','on', ...
    'Orientation','horizontal');
newPosition = [0.325 .95 0.5 0];
set(hL,'Position', newPosition,'Units', 'normalized');

%add labels
axes(ax(2))
xlabdim = [1.1 -0.29*xoff];
xlab = 'Battery Storage Capacity [kWh]';
xl = text(0,0,xlab);
set(xl,'Units','inches','Position',xlabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'Rotation',0);
axes(ax(1))
ylabdim = [-0.6*xoff ydist/2];
ylab = {avglab,'Intermittency','Duration','[h]'};
yl = text(0,0,ylab);
set(yl,'Units','inches','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'VerticalAlignment','middle','Rotation',00);

for w = 1:size(mdpsim,1)
    axes(ax(w))
    set(gca,'Units','Inches','Position', ...
        [xoff+(xmarg+xdist)*(w-1) yoff xdist ydist])
end



