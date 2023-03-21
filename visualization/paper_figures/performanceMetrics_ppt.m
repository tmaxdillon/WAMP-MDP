
clearvars -except mdpsim pbosim sl2sim sl3sim mgrmod
%close all

%% vis
%close all
set(0,'defaulttextinterpreter','tex')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'calibri')
set(0,'DefaultAxesFontName', 'calibri')
addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
output_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
    'output_data/12_22/'];

printfig = true; %print figure
slcomp = true;
close all

if ~exist('mdpsim','var') || ~exist('pbosim','var') || ...
        ~exist('sl2sim','var') || ~exist('sl3sim','var')
    load([ output_path 'mdpsim']);
    load([ output_path 'pbosim']);
    %load([ output_path 'slosim']);
    load([ output_path 'sl4sim']);
    load([ output_path 'sl3sim']);
    load([ output_path 'mgrmod']);
    mdpsim = mdpsim([2 4],:);
    pbosim = pbosim([2 4],:);
    %slosim = slosim(2:end,:);
    sl2sim = sl4sim([2 4],:);
    sl3sim = sl3sim([2 4],:);
    mgrmod = mgrmod([2 4],:);
end

x = mdpsim(1,1).sim.tuning_array1./1000;
B = [3 5];
nw = length(B);

%run baseline analysis
if ~exist('mpnf_struct','var') || ~exist('apfl_3_struct','var') || ...
        ~exist('apfl_4_struct','var')
    mpnf_struct = maxPowerNoFlex(B,x.*1000,mdpsim);
    apfl_3_struct = avgPowerFixedLoad(B,x.*1000,450,mdpsim);
    apfl_4_struct = avgPowerFixedLoad(B,x.*1000,600,mdpsim);
    %MAKE SURE FM_P IS APPROPRIATELY ABRIDGED
end

%load average power
if ~exist('power_avg','var')
    power_avg = zeros(size(mdpsim,2),size(mdpsim,1),4);
    for w = 1:size(mdpsim,1) %across all wcd
        for e = 1:size(mdpsim,2) %across all emx
            [power_avg(e,w,4)] = getPower(mdpsim(w,e));
            [power_avg(e,w,1)] = getPower(pbosim(w,e));
            [power_avg(e,w,5)] = getPower(mgrmod(w,e));
        end
        kW(w) = mdpsim(w,e).output.wec.rp; %rated power
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [power_avg(e,w,2)] = getPower(sl2sim(w,e));
                [power_avg(e,w,3)] = getPower(sl3sim(w,e));
            end
        end
    else %baseline comparisons
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [power_avg(e,w,3)] = mpnf_struct(w,e).p_avg;
                [power_avg(e,w,2)] = apfl_3_struct(w,e).p_avg;
                [power_avg(e,w,1)] = apfl_4_struct(w,e).p_avg;
            end
        end
    end
end
%load intermittency
if ~exist('i_mx','var') || ~exist('i_av','var')
    i_mx = zeros(size(mdpsim,2),size(mdpsim,1),4);
    for w = 1:size(mdpsim,1) %across all wcd
        for e = 1:size(mdpsim,2) %across all emx
            [i_av(e,w,4),~,~,~,~,~,i_mx(e,w,4)] =  ...
                calcIntermit(mdpsim(w,e).output.a_act_sim,99,1);
            [i_av(e,w,1),~,~,~,~,~,i_mx(e,w,1)] =  ...
                calcIntermit(pbosim(w,e).output.a_act_sim,99,1);
            [i_av(e,w,5),~,~,~,~,~,i_mx(e,w,1)] =  ...
                calcIntermit(mgrmod(w,e).output.a_act_sim,99,1);
        end
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [i_av(e,w,2),~,~,~,~,~,i_mx(e,w,2)] =  ...
                    calcIntermit(sl2sim(w,e).output.a_act_sim,99,1);
                [i_av(e,w,3),~,~,~,~,~,i_mx(e,w,3)] =  ...
                    calcIntermit(sl3sim(w,e).output.a_act_sim,99,1);
            end
        end
    else %baseline comparisons
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [i_av(e,w,3),~,~,~,~,~,i_mx(e,w,3)] =  ...
                    calcIntermit(mpnf_struct(w,e).output.a_sim,99,1);
                [i_av(e,w,2),~,~,~,~,~,i_mx(e,w,2)] =  ...
                    calcIntermit(apfl_3_struct(w,e).output.a_sim,99,1);
                [i_av(e,w,1),~,~,~,~,~,i_mx(e,w,1)] =  ...
                    calcIntermit(apfl_4_struct(w,e).output.a_sim,99,1);
            end
        end
    end
end
%load degradation
if ~exist('L','var')
    L = zeros(size(mdpsim,2),size(mdpsim,1),4);
    y = 5; %[years] of operation
    for w = 1:size(mdpsim,1) %across all wcd
        for e = 1:size(mdpsim,2) %across all emx
            [L(e,w,4)] = calcBatDeg(mdpsim(w,e),y,x(e)*1000)*100;
            [L(e,w,1)] = calcBatDeg(pbosim(w,e),y,x(e)*1000)*100;
            [L(e,w,5)] = calcBatDeg(mgrmod(w,e),y,x(e)*1000)*100;
        end
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [L(e,w,2)] = calcBatDeg(sl2sim(w,e),y,x(e)*1000)*100;
                [L(e,w,3)] = calcBatDeg(sl3sim(w,e),y,x(e)*1000)*100;
            end
        end
    else %baseline comparisons
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                %disp(['w = ' num2str(w) ' e = ' num2str(e)])
                [L(e,w,3)] = calcBatDeg(mpnf_struct(w,e),y,x(e)*1000)*100;
                [L(e,w,2)] = ...
                    calcBatDeg(apfl_3_struct(w,e),y,x(e)*1000)*100;
                [L(e,w,1)] = ...
                    calcBatDeg(apfl_4_struct(w,e),y,x(e)*1000)*100;
            end
        end
    end
end
%load theta rate
if ~exist('t_r','var')
    t_r = zeros(size(mdpsim,2),size(mdpsim,1),4);
    for w = 1:size(mdpsim,1) %across all wcd
        for e = 1:size(mdpsim,2) %across all emx
            [t_r(e,w,4)] = calcThetaRate(mdpsim(w,e).output.a_act_sim, ...
                mdpsim(w,e).output.FM_P(1,:,1),mdpsim(w,e).mdp.tp)*100;
            [t_r(e,w,1)] = calcThetaRate(pbosim(w,e).output.a_act_sim, ...
                pbosim(w,e).output.FM_P(1,:,1),pbosim(w,e).mdp.tp)*100;
            [t_r(e,w,5)] = calcThetaRate(mgrmod(w,e).output.a_act_sim, ...
                mgrmod(w,e).output.FM_P(1,:,1),mgrmod(w,e).mdp.tp)*100;
        end
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [t_r(e,w,2)] =  ...
                    calcThetaRate(sl2sim(w,e).output.a_act_sim, ...
                    sl2sim(w,e).output.FM_P(1,:,1),mdpsim(w,e).mdp.tp)*100;
                [t_r(e,w,3)] = ...
                    calcThetaRate(sl3sim(w,e).output.a_act_sim, ...
                    sl3sim(w,e).output.FM_P(1,:,1),mdpsim(w,e).mdp.tp)*100;
            end
        end
    else %baseline comparisons
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                %disp(['w = ' num2str(w) ' e = ' num2str(e)])
                [t_r(e,w,3)] = ... 
                    calcThetaRate(mpnf_struct(w,e).output.a_sim, ...
                    mpnf_struct(w,e).output.FM_mod(1,:,1), ...
                    mdpsim(w,e).mdp.tp)*100;
                [t_r(e,w,2)] = ...
                    calcThetaRate(apfl_3_struct(w,e).output.a_sim, ...
                    apfl_3_struct(w,e).output.FM_mod(1,:,1), ...
                    mdpsim(w,e).mdp.tp)*100;
                [t_r(e,w,1)] = ...
                    calcThetaRate(apfl_4_struct(w,e).output.a_sim, ...
                    apfl_4_struct(w,e).output.FM_mod(1,:,1), ...
                    mdpsim(w,e).mdp.tp)*100;
            end
        end
    end
end

% if slcomp
    c1 = [72 54 116]/255; %pbo
    c2 = [60,130,60]/256; %dbl
    c3 = [0 240 0]/256; %gre
% else
%     c1 = [0,47,108]/256; %apdc600
%     c2 = [0, 100, 220]/256; %apdc450
%     c3 = [0,180,123]/256; %mpnf
% end
c4 = [255 0 143]/256; %mdp
c5 = [159,0,0]/256; %mgrmod
mt{1} = 'd-';
mt{2} = '*-';
mt{3} = 'o-';
mt{4} = '.-';
mt{5} = '.-';
sccol(1,:) = [170 170 170]/256;
sccol(2,:) = [110 110 110]/256;
sccol(3,:) = [50 50 50]/256;
ms = 8;
ms2 = 5;
ms3 = 4;
ms4 = 3;
fs = 10;
fs2 = 10; %legend font size
fs3 = 8; %annotation fs
lw = 1.2;
lw2 = 1;
xoff = 1.75; %[in]
yoff = .75; %[in]
xlength = 1.2; %[in]
ylength = 1; %[in]
xmarg = .75; %[in]
ymarg = 0.3; %[in]
ylabx = -.35;

% if slcomp
%     pmsim = figure;
% else
%     pmilc = figure;
% end
pmsim = figure;
set(gcf,'Units','inches','Color','w')
set(gcf,'Position',[0, 4, 7, 4.25])
%AVERAGE POWER - 5 M
ax(1) = subplot(2,3,1);
hold on
s1p = plot(x,power_avg(:,2,1),mt{1},'MarkerEdgeColor',c1, ...
    'MarkerFaceColor',c1, ...
    'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
s2p = plot(x,power_avg(:,2,2),mt{2},'MarkerEdgeColor',c2, ...
    'MarkerFaceColor',c2, ...
    'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
s3p = plot(x,power_avg(:,2,3),'o-','MarkerEdgeColor',c3, ...
    'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
s4p = plot(x,power_avg(:,2,4),mt{4},'MarkerEdgeColor',c4, ...
    'Color',c4,'MarkerSize',ms,'LineWidth',lw);
s5p = plot(x,power_avg(:,2,5),mt{5},'MarkerEdgeColor',c5, ...
    'Color',c5,'MarkerSize',ms,'LineWidth',lw);
set(gca,'FontSize',fs2)
xticks([0 10 20 30 40])
set(gca,'XTickLabels',[])
title({'Mean Power','Consumption',''},'Fontweight','normal', ...
    'FontSize',fs);
s4p.DisplayName = 'MDP';
s1p.DisplayName = 'Posterior Bound';
s2p.DisplayName = 'Duration-Based';
s3p.DisplayName = 'Greedy';
s5p.DisplayName = 'Modified MDP';
ylabdim = [ylabx .5];
ylab = {'[W]'};
yl = text(0,0,ylab);
set(yl,'Units','normalized','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ...
    'VerticalAlignment','middle','Rotation',00);
yline(600,'--k',{'Maximum','Draw'}, ...
    'LabelHorizontalAlignment','left',...
    'LabelVerticalAlignment','bottom','FontSize',fs3, ...
    'LineWidth',lw2,'FontName','calibri');
lg = legend([s4p s1p s3p s2p s5p], ...
    'NumColumns',1,'box','off','fontsize',9, ...
    'units','normalized','position',[-.11 .1 .4 .03]);
ylv = get(gca,'YLim');
ylim(ylv);
grid on
%AVERAGE POWER - 3 M
ax(4) = subplot(2,3,4);
hold on
plot(x,power_avg(:,1,1),mt{1},'MarkerEdgeColor',c1, ...
    'MarkerFaceColor',c1, ...
    'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
plot(x,power_avg(:,1,2),mt{2},'MarkerEdgeColor',c2, ...
    'MarkerFaceColor',c2, ...
    'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
plot(x,power_avg(:,1,3),'o-','MarkerEdgeColor',c3, ...
    'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
plot(x,power_avg(:,1,4),mt{4},'MarkerEdgeColor',c4, ...
    'Color',c4,'MarkerSize',ms,'LineWidth',lw);
plot(x,power_avg(:,1,5),mt{5},'MarkerEdgeColor',c5, ...
    'Color',c5,'MarkerSize',ms,'LineWidth',lw);
set(gca,'FontSize',fs2)
xticks([0 10 20 30 40])
ylabdim = [ylabx .5];
ylab = {'[W]'};
yl = text(0,0,ylab);
set(yl,'Units','normalized','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ...
    'VerticalAlignment','middle','Rotation',00);
xlabdim = [0.5 -.4];
xlab = {'Battery Storage','Capacity [kWh]'};
xl = text(0,0,xlab);
set(xl,'Units','normalized','Position',xlabdim, ...
    'HorizontalAlignment','center','FontSize',fs2, ...
    'Rotation',0);
ylv = get(gca,'YLim');
ylim(ylv);
grid on
%PERSISTENCE TARGET RATE - 5 M
ax(2) = subplot(2,3,2);
hold on
plot(x,t_r(:,2,1),mt{1},'MarkerEdgeColor',c1, ...
    'MarkerFaceColor',c1, ...
    'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
plot(x,t_r(:,2,2),mt{2},'MarkerEdgeColor',c2, ...
    'MarkerFaceColor',c2, ...
    'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
plot(x,t_r(:,2,3),mt{3},'MarkerEdgeColor',c3, ...
    'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
plot(x,t_r(:,2,4),mt{4},'MarkerEdgeColor',c4, ...
    'Color',c4,'MarkerSize',ms,'LineWidth',lw);
plot(x,t_r(:,2,5),mt{5},'MarkerEdgeColor',c5, ...
    'Color',c5,'MarkerSize',ms,'LineWidth',lw);
set(gca,'FontSize',fs2)
xticks([0 10 20 30 40])
set(gca,'XTickLabels',[])
title({'Persistence','Target Success Rate',''},'Fontweight','normal', ...
    'FontSize',fs);
ylabdim = [ylabx .5];
ylab = {'[%]'};
yl = text(0,0,ylab);
set(yl,'Units','normalized','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ...
    'VerticalAlignment','middle','Rotation',00);
ylv = get(gca,'YLim');
ylim(ylv);
grid on
%PERSISTENCE TARGET RATE - 3 M
ax(5) = subplot(2,3,5);
hold on
plot(x,t_r(:,1,1),mt{1},'MarkerEdgeColor',c1, ...
    'MarkerFaceColor',c1, ...
    'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
plot(x,t_r(:,1,2),mt{2},'MarkerEdgeColor',c2, ...
    'MarkerFaceColor',c2, ...
    'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
plot(x,t_r(:,1,3),mt{3},'MarkerEdgeColor',c3, ...
    'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
plot(x,t_r(:,1,4),mt{4},'MarkerEdgeColor',c4, ...
    'Color',c4,'MarkerSize',ms,'LineWidth',lw);
plot(x,t_r(:,1,5),mt{5},'MarkerEdgeColor',c5, ...
    'Color',c5,'MarkerSize',ms,'LineWidth',lw);
set(gca,'FontSize',fs2)
xticks([0 10 20 30 40])
ylabdim = [ylabx .5];
ylab = {'[%]'};
yl = text(0,0,ylab);
set(yl,'Units','normalized','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ...
    'VerticalAlignment','middle','Rotation',00);
xlabdim = [0.5 -.4];
xlab = {'Battery Storage','Capacity [kWh]'};
xl = text(0,0,xlab);
set(xl,'Units','normalized','Position',xlabdim, ...
    'HorizontalAlignment','center','FontSize',fs2, ...
    'Rotation',0);
ylv = get(gca,'YLim');
ylim(ylv);
grid on
%MEAN INTERMITTENCY DURATION - 5 M
ax(3) = subplot(2,3,3);
hold on
plot(x,i_av(:,2,1),mt{1},'MarkerEdgeColor',c1, ...
    'MarkerFaceColor',c1, ...
    'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
plot(x,i_av(:,2,2),mt{2},'MarkerEdgeColor',c2, ...
    'MarkerFaceColor',c2, ...
    'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
plot(x,i_av(:,2,3),mt{3},'MarkerEdgeColor',c3, ...
    'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
plot(x,i_av(:,2,4),mt{4},'MarkerEdgeColor',c4, ...
    'Color',c4,'MarkerSize',ms,'LineWidth',lw);
plot(x,i_av(:,2,5),mt{5},'MarkerEdgeColor',c5, ...
    'Color',c5,'MarkerSize',ms,'LineWidth',lw);
set(gca,'FontSize',fs2)
xticks([0 10 20 30 40])
set(gca,'XTickLabels',[])
title({'Mean Intermittency','Duration',''},'Fontweight','normal', ...
    'FontSize',fs);
ylabdim = [ylabx .5];
ylab = {'[h]'};
yl = text(0,0,ylab);
set(yl,'Units','normalized','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ...
    'VerticalAlignment','middle','Rotation',00);
ylv = get(gca,'YLim');
ylim(ylv);
grid on
%MEAN INTERMITTENCY DURATION - 3 M
ax(6) = subplot(2,3,6);
hold on
plot(x,i_av(:,1,1),mt{1},'MarkerEdgeColor',c1, ...
    'MarkerFaceColor',c1, ...
    'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
plot(x,i_av(:,1,2),mt{2},'MarkerEdgeColor',c2, ...
    'MarkerFaceColor',c2, ...
    'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
plot(x,i_av(:,1,3),mt{3},'MarkerEdgeColor',c3, ...
    'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
plot(x,i_av(:,1,4),mt{4},'MarkerEdgeColor',c4, ...
    'Color',c4,'MarkerSize',ms,'LineWidth',lw);
plot(x,i_av(:,1,5),mt{5},'MarkerEdgeColor',c5, ...
    'Color',c5,'MarkerSize',ms,'LineWidth',lw);
set(gca,'FontSize',fs2)
xticks([0 10 20 30 40])
ylabdim = [ylabx .5];
ylab = {'[h]'};
yl = text(0,0,ylab);
set(yl,'Units','normalized','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ...
    'VerticalAlignment','middle','Rotation',00);
xlabdim = [0.5 -.4];
xlab = {'Battery Storage','Capacity [kWh]'};
xl = text(0,0,xlab);
set(xl,'Units','normalized','Position',xlabdim, ...
    'HorizontalAlignment','center','FontSize',fs2, ...
    'Rotation',0);
ylv = get(gca,'YLim');
ylim(ylv);
grid on

for i = 1:length(ax)
    set(ax(i),'Units','Inches','Position', ...
        [xoff+(rem(i-1,3)*(xlength+xmarg)) ...
        yoff+floor((length(ax)-i)/3)*(ymarg+ylength) xlength ylength])
end

set(gcf, 'Color',[255 255 241]/256,'InvertHardCopy','off')
set(ax,'Color',[255 255 241]/256)
if printfig
    if slcomp
        print(pmsim,['~/Dropbox (MREL)/Research/Defense/' ...
            'presentation_figures/pmsim_1'],'-dpng','-r600')
    else
        print(pmilc,['~/Dropbox (MREL)/Research/WAMP-MDP/' ...
            'paper_figures/pmilc'],'-dpng','-r600')
    end
end


