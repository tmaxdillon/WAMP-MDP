clearvars -except mdpsim pbosim slosim sl2sim
%close all

%% vis
set(0,'defaulttextinterpreter','tex')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
output_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
    'output_data/'];

slcomp = false; %comparing simple logic, false means baseline comparison

if ~exist('mdpsim','var') || ~exist('pbosim','var') || ...
        ~exist('slosim','var') || ~exist('sl2sim','var')
    load([ output_path 'mdpsim']); %reds
    load([ output_path 'pbosim']); %purples
    load([ output_path 'slosim']); %greens
    load([ output_path 'sl2sim']); %blues
    mdpsim = mdpsim(2:end,:);
    pbosim = pbosim(2:end,:);
    slosim = slosim(2:end,:);
    sl2sim = sl2sim(2:end,:);
end

x = mdpsim(1,1).sim.tuning_array1./1000;
B = mdpsim(1,1).sim.tuning_array2(2:end);
nw = length(B);

%run baseline analysis
if ~exist('mpnf','var') || ~exist('apfl_3','var') || ...
        ~exist('apfl_4','var')
    mpnf_struct = maxPowerNoFlex(B,x.*1000,mdpsim);
    apfl_3_struct = avgPowerFixedLoad(B,x.*1000,450,mdpsim);
    apfl_4_struct = avgPowerFixedLoad(B,x.*1000,600,mdpsim);
    %MAKE SURE FM_P IS APPROPRIATELY ABRIDGED
end

%load average power
if ~exist('power_avg','var')
    power_avg = zeros(size(mdpsim,2),size(mdpsim,1),3);
    for w = 1:size(mdpsim,1) %across all wcd
        for e = 1:size(mdpsim,2) %across all emx
            [power_avg(e,w,1)] = getPower(mdpsim(w,e));
        end
        kW(w) = mdpsim(w,e).output.wec.rp; %rated power
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [power_avg(e,w,2)] = getPower(slosim(w,e));
                [power_avg(e,w,3)] = getPower(sl2sim(w,e));
            end
        end
    else %baseline comparisons
       for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [power_avg(e,w,4)] = mpnf_struct(w,e).p_avg;
                [power_avg(e,w,3)] = apfl_3_struct(w,e).p_avg;
                [power_avg(e,w,2)] = apfl_4_struct(w,e).p_avg;
            end
        end
    end
end
%load intermittency
if ~exist('i_mx','var')
    i_mx = zeros(size(mdpsim,2),size(mdpsim,1),3);
    for w = 1:size(mdpsim,1) %across all wcd
        for e = 1:size(mdpsim,2) %across all emx
            [~,~,~,~,~,~,i_mx(e,w,1)] =  ...
                calcIntermit(mdpsim(w,e).output.a_sim,99,1);
        end
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [~,~,~,~,~,~,i_mx(e,w,2)] =  ...
                    calcIntermit(slosim(w,e).output.a_sim,99,1);
                [~,~,~,~,~,~,i_mx(e,w,3)] =  ...
                    calcIntermit(sl2sim(w,e).output.a_sim,99,1);
            end
        end
    else %baseline comparisons
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [~,~,~,~,~,~,i_mx(e,w,4)] =  ...
                    calcIntermit(mpnf_struct(w,e).output.a_sim,99,1);
                [~,~,~,~,~,~,i_mx(e,w,3)] =  ...
                    calcIntermit(apfl_3_struct(w,e).output.a_sim,99,1);
                [~,~,~,~,~,~,i_mx(e,w,2)] =  ...
                    calcIntermit(apfl_3_struct(w,e).output.a_sim,99,1);
            end
        end
    end
end
%load degradation
if ~exist('L','var')
    L = zeros(size(mdpsim,2),size(mdpsim,1),3);
    y = 10; %[years] of operation
    for w = 1:size(mdpsim,1) %across all wcd
        for e = 1:size(mdpsim,2) %across all emx
            [L(e,w,1)] = calcBatDeg(mdpsim(w,e),y,x(e)*1000)*100;
        end
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [L(e,w,2)] = calcBatDeg(slosim(w,e),y,x(e)*1000)*100;
                [L(e,w,3)] = calcBatDeg(sl2sim(w,e),y,x(e)*1000)*100;
            end
        end
    else %baseline comparisons
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [L(e,w,4)] = calcBatDeg(mpnf_struct(w,e),y,x(e)*1000)*100;
                [L(e,w,3)] = ...
                    calcBatDeg(apfl_3_struct(w,e),y,x(e)*1000)*100;
                [L(e,w,2)] = ...
                    calcBatDeg(apfl_4_struct(w,e),y,x(e)*1000)*100;
            end
        end
    end
end

c = 10;
mc = brewermap(c,'reds'); mc = mc(c-nw:end,:);
pc = brewermap(c,'purples'); pc = pc(c-nw:end,:);
sc = brewermap(c,'greens'); sc = sc(c-nw:end-1,:);
dc = brewermap(c,'blues'); dc = dc(c-nw:end-1,:); %duration based
fc = AdvancedColormap('pink',c); fc = fc(c-nw:end-1,:);  %apfl
nc = AdvancedColormap('wwc c ck',c); nc = nc(c-nw:end-1,:); %mpnf
col(1,:) = [205 0 0]/256;
col(2,:) = [0 110 78]/256;
col(3,:) = [147, 112, 219]/256;
if slcomp
    cf = [255,223,255]/256; %fill
else
    cf = [223,255,0]/256; %fill
end
mt = {'-*',':o','--sq','-.d'};
ms = 5;
fs = 10;
fsl = 8; %legend font size
lw = 1.2;
lw2 = 1;
xoff = 1.75; %[in]
yoff = .5; %[in]
xdist = 1.5; %[in]
ydist = 2; %[in]
xmarg = 1.25; %[in]
ymarg = 0.25; %[in]

results_pa = figure;
set(gcf,'Units','inches','Color','w')
set(gcf, 'Position', [1, 1, 6.5, 5])
%AVG POWER
ax(1) = subplot(2,2,[1 3]);
for w = 1:nw %across all wcd
    hold on
    s1p(w) = plot(x,power_avg(:,w,1), ...
        mt{1},'MarkerEdgeColor',col(w,:), ...
        'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw);
    s2p(w) = plot(x,power_avg(:,w,2), ...
        mt{2},'MarkerEdgeColor',col(w,:), ...
        'MarkerFaceColor',cf, ...
        'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw);
    s3p(w) = plot(x,power_avg(:,w,3), ...
        mt{3},'MarkerEdgeColor',col(w,:), ...
        'MarkerFaceColor',cf, ...
        'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw);
    if ~slcomp
        s4p(w) = plot(x,power_avg(:,w,4), ...
            mt{4},'MarkerEdgeColor',col(w,:), ...
            'MarkerFaceColor',cf, ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw);
    end
    lp(w) = plot(x,zeros(length(x),1),'Color',col(w,:), ...
        'LineWidth',lw);
    if w == 1
        lp(w).DisplayName = '2 m WEC';
        s1p(w).DisplayName = 'MDP';
        if slcomp
            s2p(w).DisplayName = 'SoC Based';
            s3p(w).DisplayName = 'Duration Based';
        else
            s4p(w).DisplayName = 'MPNF';
            s3p(w).DisplayName = 'APDC450';
            s2p(w).DisplayName = 'APDC600';
        end
    elseif w == 2
        lp(w).DisplayName = '3 m WEC';
    elseif w == 3
        lp(w).DisplayName = '4 m WEC';
    end
end
yline(600,'--k','Maximum Draw', ...
    'LabelHorizontalAlignment','left',...
    'LabelVerticalAlignment','bottom','FontSize',fs, ...
    'LineWidth',lw2,'FontName','cmr10');
set(gca,'FontSize',10)
if slcomp
    ylim([370 600])
else
    ylim([50 600])
end
%add labels
axes(ax(1))
xlabdim = [0.5 -.075];
xlab = 'Battery Storage Capacity [kWh]';
xl = text(0,0,xlab);
set(xl,'Units','normalized','Position',xlabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'Rotation',0);
ylabdim = [-.6 .5];
ylab = {'Average','Power','Consumed','[W]'};
yl = text(0,0,ylab);
set(yl,'Units','normalized','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'VerticalAlignment','middle','Rotation',00);
%legend
if slcomp
    legend([s1p(1) s2p(1) s3p(1) lp(1) lp(2) lp(3)],'location', ...
        'northwestoutside','box','off','fontsize',fsl)
else
    legend([s1p(1) s2p(1) s3p(1) s4p(1) lp(1) lp(2) lp(3)],'location', ...
        'northwestoutside','box','off','fontsize',fsl)
end
set(gca,'Units','inches','position',...
    [xoff yoff xdist 2*ydist+ymarg])
grid on

%MAX INTERMITTENCY
ax(2) = subplot(2,2,2);
for w = 1:nw %across all wcd
    hold on
    s1p(w) = plot(x,i_mx(:,w,1), ...
        mt{1},'MarkerEdgeColor',col(w,:), ...
        'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','Markov Decision Process');
    s2p(w) = plot(x,i_mx(:,w,2), ...
        mt{2},'MarkerEdgeColor',col(w,:), ...
        'MarkerFaceColor',cf, ...
        'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','SoC Based Logic');
    s3p(w) = plot(x,i_mx(:,w,3), ...
        mt{3},'MarkerEdgeColor',col(w,:), ...
        'MarkerFaceColor',cf, ...
        'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','Duration Based Logic');
    if ~slcomp
        s4p(w) = plot(x,i_mx(:,w,4), ...
            mt{4},'MarkerEdgeColor',col(w,:), ...
            'MarkerFaceColor',cf, ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw);
    end
end
set(gca,'FontSize',10)
axes(ax(2))
ylabdim = [-.5 .5];
ylab = {'Longest','Full','Power','Intermitency','[h]'};
yl = text(0,0,ylab);
set(yl,'Units','normalized','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'VerticalAlignment','middle','Rotation',00);
set(gca,'Units','inches','position',...
    [xoff+xmarg+xdist yoff+ydist+ymarg xdist ydist])
grid on

%BATTERY DEGRADATION
ax(3) = subplot(2,2,4);
for w = 1:nw %across all wcd
    hold on
    s1p(w) = plot(x,L(:,w,1), ...
        mt{1},'MarkerEdgeColor',col(w,:), ...
        'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','Markov Decision Process');
    s2p(w) = plot(x,L(:,w,2), ...
        mt{2},'MarkerEdgeColor',col(w,:), ...
        'MarkerFaceColor',cf, ...
        'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','SoC Based Logic');
    s3p(w) = plot(x,L(:,w,3), ...
        mt{3},'MarkerEdgeColor',col(w,:), ...
        'MarkerFaceColor',cf, ...
        'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw, ...
        'DisplayName','Duration Based Logic');
    if ~slcomp
        s4p(w) = plot(x,L(:,w,4), ...
            mt{4},'MarkerEdgeColor',col(w,:), ...
            'MarkerFaceColor',cf, ...
            'Color',col(w,:),'MarkerSize',ms,'LineWidth',lw);
    end
end
yline(20,'--k',{'Estimated battery','end of life'}, ...
        'LabelHorizontalAlignment','left', ...
        'LabelVerticalAlignment','bottom','FontSize',fs, ...
        'LineWidth',lw2,'FontName','cmr10'); 
set(gca,'FontSize',10)
ylim([8 20])
axes(ax(3))
xlabdim = [0.5 -.155];
xlab = 'Battery Storage Capacity [kWh]';
xl = text(0,0,xlab);
set(xl,'Units','normalized','Position',xlabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'Rotation',0);
ylabdim = [-.5 .5];
ylab = {'Battery','Capacity','Fade','[%]'};
yl = text(0,0,ylab);
set(yl,'Units','normalized','Position',ylabdim, ...
    'HorizontalAlignment','center','FontSize',fs, ... 
    'VerticalAlignment','middle','Rotation',00);
set(ax(3),'Units','inches','position',...
    [xoff+xmarg+xdist yoff xdist ydist])
grid on




