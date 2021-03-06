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

for e = 1:size(mdpsim,2) %across all emx
    for w = 1:size(mdpsim,1) %across all wcd
        beta_avg(e,w,1) = mdpsim(w,e).output.beta_avg;
        power_avg(e,w,1) = mdpsim(w,e).output.power_avg;
        beta_avg(e,w,2) = pbosim(w,e).output.beta_avg;
        power_avg(e,w,2) = pbosim(w,e).output.power_avg;
        beta_avg(e,w,3) = slosim(w,e).output.beta_avg;
        power_avg(e,w,3) = slosim(w,e).output.power_avg;
    end
end

%x axis info
x = mdpsim(1).sim.tuning_array1./1000;
xlab = 'Battery Size [kWh]';

%colors
mc = brewermap(size(mdpsim,1),'reds');
pc = brewermap(size(pbosim,1),'purples');
sc = brewermap(size(slosim,1),'blues');
cc = brewermap(size(slosim,1),'spectral');
c = 7;
col1 = brewermap(8,'reds'); %col(1,:) = col1(c,:);
% col2 = brewermap(10,'oranges'); col(2,:) = col2(c,:);
% col3 = brewermap(10,'YlOrBr'); col(3,:) = col3(4,:);
% col4 = brewermap(10,'greens'); col(4,:) = col4(c,:);
% col5 = brewermap(10,'blues'); col(5,:) = col5(c,:);
% col6 = brewermap(10,'purples'); col(6,:) = col6(c,:);
col = col1(3:end,:);

%sizes
ms = 5;
fs = 10;
lw = 1;

%spacing
xoff = 1.25; %[in]
yoff = 0.5; %[in]
xdist = 4.75; %[in]
ydist = 4; %[in]

%average power
results_pa = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 6.5, 5])
for w = 1:size(mdpsim,1) %across all wcd
    hold on
    if ~isequal(w,4)
        plot(x,power_avg(:,w,1),'-o','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw)
        plot(x,power_avg(:,w,2),'-*','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw)
        plot(x,power_avg(:,w,3),'-s','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw)
    else
        mp = plot(x,power_avg(:,w,1),'-o','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','MDP');
        pp = plot(x,power_avg(:,w,2),'-*','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','Posterior Bound');
        sp = plot(x,power_avg(:,w,3),'-s','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','Simple Logic');
    end
%     cp(w,:) = plot([],'Color',col(w,:),'DisplayName',['WEC B = ' ...
%         num2str(mdpsim(1).sim.tuning_array2(w))]);
end
%lg1 = legend([cp],'Location','westoutside','orientation','vertical');
lg2 = legend([mp pp sp],'Location','northoutside', ...
    'orientation','horizontal');
ylabel({'Mean','Power','Consumed','[W]'})
ylh = get(gca,'ylabel');
set(ylh, 'Rotation',0,'Units','Inches', ...
    'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Position',[-yoff*1.5 ydist/2 0])
xlabel(xlab)
grid on
set(gca,'FontSize',10)
set(gca,'Units','Inches','Position',[xoff yoff xdist ydist])

%beta
results_bt = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 6.5, 5])
for w = 1:size(mdpsim,1) %across all wcd
    hold on
    if ~isequal(w,4)
        plot(x,beta_avg(:,w,1),'-o','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw)
        plot(x,beta_avg(:,w,2),'-*','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw)
        plot(x,beta_avg(:,w,3),'-s','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw)
    else
        mp = plot(x,beta_avg(:,w,1),'-o','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','MDP');
        pp = plot(x,beta_avg(:,w,2),'-*','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','Posterior Bound');
        sp = plot(x,beta_avg(:,w,3),'-s','MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
            'DisplayName','Simple Logic');
    end
end
lg2 = legend([mp pp sp],'Location','northoutside', ...
    'orientation','horizontal');
ylabel('Beta')
ylh = get(gca,'ylabel');
set(ylh, 'Rotation',0,'Units','Inches', ...
    'VerticalAlignment','middle', ...
    'HorizontalAlignment','center','Position',[-yoff*1.5 ydist/2 0])
xlabel(xlab)
grid on
set(gca,'FontSize',10)
set(gca,'Units','Inches','Position',[xoff yoff xdist ydist])

