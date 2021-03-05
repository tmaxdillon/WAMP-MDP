clearvars -except mdpsim pbosim slosim
close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')

if ~exist('mdpsim','var') || ~exist('pbosim','var') || ...
        ~exist('slosim','var')
    load('mdpsim');
    load('pbosim');
    load('slosim');
end

B = mdpsim(1).sim.tuning_array2;
nw = length(B);

fixer = [1 2 3 4];
for e = 1:size(mdpsim,2) %across all emx
    for w = 1:size(mdpsim,1) %across all wcd
        power_avg(e,fixer(w),1) = mdpsim(w,e).output.power_avg;
        power_avg(e,fixer(w),2) = pbosim(w,e).output.power_avg;
        power_avg(e,fixer(w),3) = slosim(w,e).output.power_avg;
    end
end

%x axis info
x = mdpsim(1).sim.tuning_array1./1000;
%xlab = 'Battery Size [kWh]';


%colors
mc = brewermap(nw*2,'reds'); mc = mc(nw:end-1,:);
pc = brewermap(nw*2,'greens'); pc = pc(nw:end-1,:);
sc = brewermap(nw*2,'purples'); sc = sc(nw:end-1,:);
c = 7;
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
yoff = .625; %[in]
xdist = .95; %[in]
ydist = 2.5; %[in]
xmarg = 0.4; %[in]
ylims = flipud([560 620; 530 590; 420 480 ; 80 140]);

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
    mp(w) = plot(x,power_avg(:,w,1),'-o','MarkerEdgeColor',mc(w,:), ...
        'Color',mc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','MDP');
    pp(w) = plot(x,power_avg(:,w,2),'-*','MarkerEdgeColor',pc(w,:), ...
        'Color',pc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','Posterior Bound');
    sp(w) = plot(x,power_avg(:,w,3),'-s','MarkerEdgeColor',sc(w,:), ...
        'Color',sc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','Simple Logic');   
    tt(w) = title([num2str(B(w)) ' m WEC'],'FontWeight','normal', ...
        'Units','Normalized');
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

print(results_pa,['~/Dropbox (MREL)/Research/WAMP-MDP/' ...
    'paper_figures/results_pa'],'-dpng','-r600')

