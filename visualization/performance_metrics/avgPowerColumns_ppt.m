clearvars -except mdpsim pbosim slosim
close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'calibri')
set(0,'DefaultAxesFontName', 'calibri')

if ~exist('mdpsim','var') || ~exist('pbosim','var') || ...
        ~exist('slosim','var')
    load('mdpsim');
    load('pbosim');
    load('slosim');
end

B = mdpsim(1).sim.tuning_array2;
nw = length(B);

for w = 1:size(mdpsim,1) %across all wcd
    for e = 1:size(mdpsim,2) %across all emx       
        power_avg(e,w,1) = mdpsim(w,e).output.power_avg;
        power_avg(e,w,2) = pbosim(w,e).output.power_avg;
        power_avg(e,w,3) = slosim(w,e).output.power_avg;
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
fs1 = 13;
fs2 = 11;
lw = 1.2;
lw2 = 1;

%spacing
xoff = 1.5; %[in]
yoff = .85; %[in]
xdist = 1.5; %[in]
ydist = 3; %[in]
xmarg = 0.5; %[in]
ylims = flipud([570 620; 540 590; 430 480 ; 90 140]);

%find max range
for w = 1:size(mdpsim,1)
    maxdist(w) = max(max(power_avg(:,w,:))) - min(min(power_avg(:,w,:)));
end
maxdist = max(round(ceil(maxdist.*1.2),-1));

%average power
results_pa = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 10, 5])
for w = 1:size(mdpsim,1) %across all wcd
    ax(w) = subplot(1,4,w);
    hold on
    sp(w) = plot(x,power_avg(:,w,3),'-s','MarkerEdgeColor',sc(w,:), ...
        'Color',sc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','Simple Logic');   
    mp(w) = plot(x,power_avg(:,w,1),'-o','MarkerEdgeColor',mc(w,:), ...
        'Color',mc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','MDP');
    pp(w) = plot(x,power_avg(:,w,2),'-*','MarkerEdgeColor',pc(w,:), ...
        'Color',pc(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','Posterior Bound');
    tt(w) = title({[num2str(B(w)) ' m WEC'], ...
        ['(\sim' num2str(round(kW(w)/1000,2)) 'kW)']}, ...
        'FontWeight','normal','Units','Normalized', ...
        'interpreter','tex');
    set(gca,'FontSize',fs2)
    tt(w).Position(2) = tt(w).Position(2)*1.025;
    ylim(ylims(w,:))
    xlim([0 30])
    yline(600,'--k','Max Draw', ...
        'LabelHorizontalAlignment','left','FontSize',fs2, ...
        'LineWidth',lw2,'FontName','calibri'); 
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
    grid on
    %set(gca,'Units','Inches','Position',[xoff yoff xdist ydist])
end

hL = legend([mp(2) pp(2) sp(2)],'location','northoutside','Box','on', ...
    'Orientation','horizontal','FontSize',fs1,'Color',[255 255 245]/256);
newPosition = [0.375 .94 0.3 0];
set(hL,'Position', newPosition,'Units', 'normalized');

%add labels
axes(ax(2))
xlabdim = [1.7 -0.33*xoff];
xlab = 'Battery Storage Capacity [kWh]';
xl = text(0,0,xlab);
set(xl,'Units','inches','Position',xlabdim, ...
    'HorizontalAlignment','center','FontSize',fs1, ... 
    'Rotation',0);
axes(ax(1))
ylabdim = [-0.6*xoff ydist/2];
ylab = {'Average','Power','Consumed','for','Sensing','[W]'};
yl = text(0,0,ylab);
set(yl,'Units','inches','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs1, ... 
    'VerticalAlignment','middle','Rotation',00);

for w = 1:size(mdpsim,1)
    axes(ax(w))
    set(gca,'Units','Inches','Position', ...
        [xoff+(xmarg+xdist)*(w-1) yoff xdist ydist])
end

set(gcf, 'Color',[255 255 245]/256,'InvertHardCopy','off')
set(ax,'Color',[255 255 245]/256)
print(results_pa,'~/Dropbox (MREL)/Research/General Exam/pf/mdpresults_1',  ...
    '-dpng','-r600')

