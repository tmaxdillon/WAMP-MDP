clearvars -except mdpsim pbosim slosim mbzsim pbzsim sl2sim
%close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

if ~exist('mdpsim','var') || ~exist('pbosim','var') || ...
        ~exist('slosim','var') || ~exist('mbzsim','var') || ...
        ~exist('pbzsim','var') || ~exist('sl2sim','var')
    load('mdpsim');
    load('pbosim');
    load('slosim');
    load('mbzsim');
    load('pbzsim');
    load('sl2sim');
end

B = mdpsim(1).sim.tuning_array2;
nw = length(B);

power_avg = zeros(size(mdpsim,2),size(mdpsim,1),3);
% i_25 = zeros(size(mdpsim,2),size(mdpsim,1),3);
% i_75 = zeros(size(mdpsim,2),size(mdpsim,1),3);
% sd = zeros(size(mdpsim,2),size(mdpsim,1),3);

for w = 1:size(mdpsim,1) %across all wcd
    for e = 1:size(mdpsim,2) %across all emx   
        [power_avg(e,w,1),i_25(e,w,1),i_75(e,w,1),sd(e,w,1)] = ...
            getPower(mdpsim(w,e));
        [power_avg(e,w,2),i_25(e,w,2),i_75(e,w,2),sd(e,w,2)] = ...
            getPower(pbosim(w,e));
        [power_avg(e,w,3),i_25(e,w,3),i_75(e,w,3),sd(e,w,3)] = ...
            getPower(slosim(w,e));
        [power_avg(e,w,4),i_25(e,w,4),i_75(e,w,4),sd(e,w,4)] = ...
            getPower(mbzsim(w,e));
        [power_avg(e,w,5),i_25(e,w,5),i_75(e,w,5),sd(e,w,5)] = ...
            getPower(pbzsim(w,e));
        [power_avg(e,w,6),i_25(e,w,6),i_75(e,w,6),sd(e,w,6)] = ...
            getPower(sl2sim(w,e));
%         power_avg(e,w,1) = mdpsim(w,e).output.power_avg;
%         power_avg(e,w,2) = pbosim(w,e).output.power_avg;
%         power_avg(e,w,3) = slosim(w,e).output.power_avg;
    end
    kW(w) = mdpsim(w,e).output.wec.rp; %rated power
end

%x axis info
x = mdpsim(1).sim.tuning_array1./1000;
%xlab = 'Battery Size [kWh]';

%colors
%c = 10;
% mc = brewermap(c,'reds'); mc = mc(c-nw:end,:);
% pc = brewermap(c,'greens'); pc = pc(c-nw:end,:);
% sc = brewermap(c,'purples'); sc = sc(c-nw:end-1,:);
mdpc = [205 0 0]/256;
mbzc = [255	49 83]/256;
pboc = [0 110 78]/256;
pbzc = [105, 255, 105]/256;
sloc = [64, 32, 96]/256;
sl2c = [147, 112, 219]/256;
%col1 = flipud(brewermap(8,'reds')); %col(1,:) = col1(c,:);
% col2 = brewermap(10,'oranges'); col(2,:) = col2(c,:);
% col3 = brewermap(10,'YlOrBr'); col(3,:) = col3(4,:);
% col4 = brewermap(10,'greens'); col(4,:) = col4(c,:);
% col5 = brewermap(10,'blues'); col(5,:) = col5(c,:);
% col6 = brewermap(10,'purples'); col(6,:) = col6(c,:);
% col = col1(1:size(mdpsim,1),:);
%c1 = [220,20,60]/256;
%c2 = [0,0,205]/256;
%c3 = [123,104,238]/256;

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
for w = 1:size(mdpsim,1)
    maxdist(w) = max(max(power_avg(:,w,:))) - min(min(power_avg(:,w,:)));
end
maxdist = max(round(ceil(maxdist.*1.2),-1));

%average power
results_pa = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 6.5, 3.75])
for w = 1:size(mdpsim,1) %across all wcd
    ax(w) = subplot(1,4,w);
    hold on
    pbop(w) = plot(x,power_avg(:,w,2),'-*','MarkerEdgeColor',pboc, ...
        'Color',pboc,'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','PB');
    mdpp(w) = plot(x,power_avg(:,w,1),'-o','MarkerEdgeColor',mdpc, ...
        'Color',mdpc,'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','MDP');
    slop(w) = plot(x,power_avg(:,w,3),'-s','MarkerEdgeColor',sloc, ...
        'Color',sloc,'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','Simple Logic');
    pbzp(w) = plot(x,power_avg(:,w,5),'-*','MarkerEdgeColor',pbzc, ...
        'Color',pbzc,'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','PB (no beta)');
    mbzp(w) = plot(x,power_avg(:,w,4),'-o','MarkerEdgeColor',mbzc, ...
        'Color',mbzc,'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','MDP (no beta)');
    sl2p(w) = plot(x,power_avg(:,w,6),'-s','MarkerEdgeColor',sl2c, ...
        'Color',sl2c,'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','Simple Logic 2');
%     fill([x,flip(x)],[i_25(:,w,2)',flip(i_75(:,w,2)')], ...
%         pc(w,:),'FaceAlpha',0.3,'EdgeColor','none', ...
%         'HandleVisibility','off');
%     fill([x,flip(x)],[i_25(:,w,1)',flip(i_75(:,w,1)')], ...
%         mc(w,:),'FaceAlpha',0.3,'EdgeColor','none', ...
%         'HandleVisibility','off');
%     fill([x,flip(x)],[i_25(:,w,3)',flip(i_75(:,w,3)')], ...
%         sc(w,:),'FaceAlpha',0.3,'EdgeColor','none', ...
%         'HandleVisibility','off');
%     fill([x,flip(x)],[power_avg(:,w,2)'-sd(:,w,2)', ...
%         flip(power_avg(:,w,2)'+sd(:,w,2)')], ...
%         pc(w,:),'FaceAlpha',0.1,'EdgeColor','none', ...
%         'HandleVisibility','off');
%     fill([x,flip(x)],[power_avg(:,w,1)'-sd(:,w,1)', ...
%         flip(power_avg(:,w,1)'+sd(:,w,1)')], ...
%         mc(w,:),'FaceAlpha',0.1,'EdgeColor','none', ...
%         'HandleVisibility','off');
%     fill([x,flip(x)],[power_avg(:,w,3)'-sd(:,w,3)', ...
%         flip(power_avg(:,w,3)'+sd(:,w,3)')], ...
%         sc(w,:),'FaceAlpha',0.1,'EdgeColor','none', ...
%         'HandleVisibility','off');
    tt(w) = title({[num2str(B(w)) ' m WEC'], ...
        ['(\sim' num2str(round(kW(w)/1000,2)) 'kW)']}, ...
        'FontWeight','normal','Units','Normalized', ...
        'interpreter','tex');
    tt(w).Position(2) = tt(w).Position(2)*1.025;
    ylim(ylims(w,:))
    yline(600,'--k','Max Draw', ...
        'LabelHorizontalAlignment','left','FontSize',fs, ...
        'LineWidth',lw2,'FontName','cmr10'); 
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

hL = legend([mdpp(2) pbop(2) slop(2) mbzp(2) pbzp(2) sl2p(2)], ...
    'location','northoutside','Box','on','NumColumns',3, ...
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
ylab = {'Average','Power','Consumed','[W]'};
yl = text(0,0,ylab);
set(yl,'Units','inches','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'VerticalAlignment','middle','Rotation',00);

for w = 1:size(mdpsim,1)
    axes(ax(w))
    set(gca,'Units','Inches','Position', ...
        [xoff+(xmarg+xdist)*(w-1) yoff xdist ydist])
end


