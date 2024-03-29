function [] = avgPowerFunction(sim1,sim2,sim3,sim4,flexcomp)

%close all
set(0,'defaulttextinterpreter','none')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'calibri')
set(0,'DefaultAxesFontName', 'calibri')

pbodelta = true;

B = sim1(1,1).sim.tuning_array2;
nw = length(B);

power_avg = zeros(size(sim1,2),size(sim1,1),4);
% i_25 = zeros(size(mdpsim,2),size(mdpsim,1),3);
% i_75 = zeros(size(mdpsim,2),size(mdpsim,1),3);
% sd = zeros(size(mdpsim,2),size(mdpsim,1),3);

for w = 1:size(sim1,1) %across all wcd
    for e = 1:size(sim1,2) %across all emx   
        [power_avg(e,w,1),i_25(e,w,1),i_75(e,w,1),sd(e,w,1)] = ...
            getPower(sim1(w,e));
        [power_avg(e,w,2),i_25(e,w,2),i_75(e,w,2),sd(e,w,2)] = ...
            getPower(sim2(w,e));
        [power_avg(e,w,3),i_25(e,w,3),i_75(e,w,3),sd(e,w,3)] = ...
            getPower(sim3(w,e));
        [power_avg(e,w,4),i_25(e,w,4),i_75(e,w,4),sd(e,w,4)] = ...
            getPower(sim4(w,e));
    end
    kW(w) = sim1(w,e).output.wec.rp; %rated power
end

%x axis info
x = sim1(1,1).sim.tuning_array1./1000;
%xlab = 'Battery Size [kWh]';

%colors
%c = 10;
% mc = brewermap(c,'reds'); mc = mc(c-nw:end,:);
% pc = brewermap(c,'greens'); pc = pc(c-nw:end,:);
% sc = brewermap(c,'purples'); sc = sc(c-nw:end-1,:);
s1c = [205 0 0]/256;
s2c = [0 110 78]/256;
s3c = [64, 32, 96]/256;
s4c = [147, 112, 219]/256;
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
ylims = flipud([110 650; 80 590; 60 480 ; 20 140]);
%ylims = flipud([1 2 ;3 4 ;5 6;7 8 ]);

% %find max range
% for w = 1:size(sim1,1)
%     maxdist(w) = max(max(power_avg(:,w,:))) - min(min(power_avg(:,w,:)));
% end
% maxdist = max(round(ceil(maxdist.*1.2),-1));

%find maximum power no flexibility
if flexcomp
    mpnf_struct = maxPowerNoFlex(B,x.*1000);
    for e = 1:size(mpnf_struct,2)
        for w = 1:size(mpnf_struct,1)            
            mpnf(w,e) = mpnf_struct(w,e).p_avg;
        end
    end
    apfl_3 = avgPowerFixedLoad(B,x.*1000,450);
    apfl_4 = avgPowerFixedLoad(B,x.*1000,600);
end

if pbodelta
    adj = power_avg(:,:,2);
else
    adj = zeros(size(power_avg(:,:,2)));
end
    
%average power
results_pa = figure;
set(gcf,'Units','inches')
set(gcf, 'Position', [1, 1, 6.5, 3.75])
for w = 1:size(sim1,1) %across all wcd
    ax(w) = subplot(1,4,w);
    hold on
    s1p(w) = plot(x,power_avg(:,w,1)-adj(:,w) ...
        ,'-*','MarkerEdgeColor',s1c, ...
        'Color',s1c,'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName',inputname(1));
    s2p(w) = plot(x,power_avg(:,w,2)-adj(:,w), ...
        '-*','MarkerEdgeColor',s2c, ...
        'Color',s2c,'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName',inputname(2));
    s3p(w) = plot(x,power_avg(:,w,3)-adj(:,w), ...
        '-*','MarkerEdgeColor',s3c, ...
        'Color',s3c,'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName',inputname(3));
    s4p(w) = plot(x,power_avg(:,w,4)-adj(:,w), ...
        '-*','MarkerEdgeColor',s4c, ...
        'Color',s4c,'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName',inputname(4));
    if flexcomp
        s5p(w) = plot(x,mpnf(w,:)'-adj(:,w), ...
            'k','LineWidth',lw,'DisplayName','MPNF');
        s6p(w) = plot(x,apfl_3(w,:)'-adj(:,w) ...
            ,'m','LineWidth',lw,'DisplayName', ...
            'APFL450');
        s7p(w) = plot(x,apfl_4(w,:)'-adj(:,w) ...
            ,'c','LineWidth',lw,'DisplayName', ...
            'APFL600');
    end
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
    %ylim(ylims(w,:))
    if w == 4 && ~pbodelta
        yline(600,'--k','Max Draw', ...
            'LabelHorizontalAlignment','left','FontSize',fs, ...
            'LineWidth',lw2,'FontName','cmr10');
    end
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

if flexcomp
    hL = legend([s1p(2) s2p(2) s3p(2) s4p(2) s5p(2) s6p(2) s7p(2)], ...
        'location','northoutside','Box','on','NumColumns',4, ...
        'Orientation','horizontal');
    newPosition = [0.325 .95 0.5 0];
    set(hL,'Position', newPosition,'Units', 'normalized');
else
    hL = legend([s1p(2) s2p(2) s3p(2) s4p(2)], ...
        'location','northoutside','Box','on','NumColumns',4, ...
        'Orientation','horizontal');
    newPosition = [0.325 .95 0.5 0];
    set(hL,'Position', newPosition,'Units', 'normalized');
end

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

for w = 1:size(sim1,1)
    axes(ax(w))
    set(gca,'Units','Inches','Position', ...
        [xoff+(xmarg+xdist)*(w-1) yoff xdist ydist])
end

end

