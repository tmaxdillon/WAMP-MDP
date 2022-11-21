
clearvars -except mdpsim pbosim slosim sl2sim
%close all

%% vis
set(0,'defaulttextinterpreter','tex')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
output_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
    'output_data/11_22/'];

slcomp = false; %comparing simple logic, false means baseline comparison
printfig = false; %print figure

if ~exist('mdpsim','var') || ~exist('pbosim','var') || ...
        ~exist('sl2sim','var') || ~exist('sl3sim','var')
    load([ output_path 'mdpsim']);
    load([ output_path 'pbosim']);
    %load([ output_path 'slosim']);
    load([ output_path 'sl2sim']);
    load([ output_path 'sl3sim']);
    mdpsim = mdpsim(2:end,:);
    pbosim = pbosim(2:end,:);
    %slosim = slosim(2:end,:);
    sl2sim = sl2sim(2:end,:);
    sl3sim = sl3sim(2:end,:);
end

x = mdpsim(1,1).sim.tuning_array1./1000;
B = mdpsim(1,1).sim.tuning_array2(2:end);
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
            [power_avg(e,w,1)] = getPower(mdpsim(w,e));
            [power_avg(e,w,2)] = getPower(pbosim(w,e));
        end
        kW(w) = mdpsim(w,e).output.wec.rp; %rated power
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [power_avg(e,w,3)] = getPower(sl2sim(w,e));
                [power_avg(e,w,4)] = getPower(sl3sim(w,e));
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
if ~exist('i_mx','var') || ~exist('i_av','var')
    i_mx = zeros(size(mdpsim,2),size(mdpsim,1),4);
    for w = 1:size(mdpsim,1) %across all wcd
        for e = 1:size(mdpsim,2) %across all emx
            [i_av(e,w,1),~,~,~,~,~,i_mx(e,w,1)] =  ...
                calcIntermit(mdpsim(w,e).output.a_act_sim,99,1);
            [i_av(e,w,2),~,~,~,~,~,i_mx(e,w,2)] =  ...
                calcIntermit(pbosim(w,e).output.a_act_sim,99,1);
        end
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [i_av(e,w,3),~,~,~,~,~,i_mx(e,w,3)] =  ...
                    calcIntermit(sl2sim(w,e).output.a_act_sim,99,1);
                [i_av(e,w,4),~,~,~,~,~,i_mx(e,w,4)] =  ...
                    calcIntermit(sl3sim(w,e).output.a_act_sim,99,1);
            end
        end
    else %baseline comparisons
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [i_av(e,w,4),~,~,~,~,~,i_mx(e,w,4)] =  ...
                    calcIntermit(mpnf_struct(w,e).output.a_sim,99,1);
                [i_av(e,w,3),~,~,~,~,~,i_mx(e,w,3)] =  ...
                    calcIntermit(apfl_3_struct(w,e).output.a_sim,99,1);
                [i_av(e,w,2),~,~,~,~,~,i_mx(e,w,2)] =  ...
                    calcIntermit(apfl_4_struct(w,e).output.a_sim,99,1);
            end
        end
    end
end
%load degradation
if ~exist('L','var')
    L = zeros(size(mdpsim,2),size(mdpsim,1),4);
    y = 10; %[years] of operation
    for w = 1:size(mdpsim,1) %across all wcd
        for e = 1:size(mdpsim,2) %across all emx
            [L(e,w,1)] = calcBatDeg(mdpsim(w,e),y,x(e)*1000)*100;
            [L(e,w,2)] = calcBatDeg(pbosim(w,e),y,x(e)*1000)*100;
        end
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [L(e,w,3)] = calcBatDeg(sl2sim(w,e),y,x(e)*1000)*100;
                [L(e,w,4)] = calcBatDeg(sl3sim(w,e),y,x(e)*1000)*100;
            end
        end
    else %baseline comparisons
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                %disp(['w = ' num2str(w) ' e = ' num2str(e)])
                [L(e,w,4)] = calcBatDeg(mpnf_struct(w,e),y,x(e)*1000)*100;
                [L(e,w,3)] = ...
                    calcBatDeg(apfl_3_struct(w,e),y,x(e)*1000)*100;
                [L(e,w,2)] = ...
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
            [t_r(e,w,1)] = calcThetaRate(mdpsim(w,e).output.a_act_sim, ...
                mdpsim(w,e).output.FM_P(1,:,1),mdpsim(w,e).mdp.tp)*100;
            [t_r(e,w,2)] = calcThetaRate(pbosim(w,e).output.a_act_sim, ...
                pbosim(w,e).output.FM_P(1,:,1),pbosim(w,e).mdp.tp)*100;
        end
    end
    if slcomp %simple logic comparison
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                [t_r(e,w,3)] =  ...
                    calcThetaRate(sl2sim(w,e).output.a_act_sim, ...
                    sl2sim(w,e).output.FM_P(1,:,1),mdpsim(w,e).mdp.tp)*100;
                [t_r(e,w,4)] = ...
                    calcThetaRate(sl3sim(w,e).output.a_act_sim, ...
                    sl3sim(w,e).output.FM_P(1,:,1),mdpsim(w,e).mdp.tp)*100;
            end
        end
    else %baseline comparisons
        for w = 1:size(mdpsim,1) %across all wcd
            for e = 1:size(mdpsim,2) %across all emx
                %disp(['w = ' num2str(w) ' e = ' num2str(e)])
                [t_r(e,w,4)] = ... 
                    calcThetaRate(mpnf_struct(w,e).output.a_sim, ...
                    mpnf_struct(w,e).output.FM_mod(1,:,1), ...
                    mdpsim(w,e).mdp.tp)*100;
                [t_r(e,w,3)] = ...
                    calcThetaRate(apfl_3_struct(w,e).output.a_sim, ...
                    apfl_3_struct(w,e).output.FM_mod(1,:,1), ...
                    mdpsim(w,e).mdp.tp)*100;
                [t_r(e,w,2)] = ...
                    calcThetaRate(apfl_4_struct(w,e).output.a_sim, ...
                    apfl_4_struct(w,e).output.FM_mod(1,:,1), ...
                    mdpsim(w,e).mdp.tp)*100;
            end
        end
    end
end

mt = {'-*',':o','--sq','-.d'};
mc = [255 0 143]/256;
mpc = [0,180,123]/256;
a3c = [0, 100, 220]/256;
a4c = [0,47,108]/256;
ms = 8;
ms2 = 5;
fs = 10;
fs2 = 8; %legend font size
lw = 1.2;
lw2 = 1;
xoff = 1.75; %[in]
yoff = .75; %[in]
xdist = 1.25; %[in]
ydist = 1.05; %[in]
xmarg = .35; %[in]
ymarg = 0.25; %[in]

results_pa = figure;
set(gcf,'Units','inches','Color','w')
set(gcf, 'Position', [0, 4, 6.5, 7.5])
%AVG POWER
for w = 1:nw
    ax(w) = subplot(5,3,w);
    hold on
    s2p(w) = plot(x,power_avg(:,w,2),'d-','MarkerEdgeColor',a4c, ...
        'MarkerFaceColor',a4c, ...
        'Color',a4c,'MarkerSize',ms2,'LineWidth',lw);
    s4p(w) = plot(x,power_avg(:,w,3),'*-','MarkerEdgeColor',a3c, ...
        'MarkerFaceColor',a3c, ...
        'Color',a3c,'MarkerSize',ms2,'LineWidth',lw);
    s3p(w) = plot(x,power_avg(:,w,4),'o-','MarkerEdgeColor',mpc, ...
        'Color',mpc,'MarkerSize',ms2,'LineWidth',lw);
    s1p(w) = plot(x,power_avg(:,w,1),'.-','MarkerEdgeColor',mc, ...
        'Color',mc,'MarkerSize',ms,'LineWidth',lw);
    set(gca,'FontSize',fs2)
    xticks([0 10 20 30 40])
    if w == 1
        title({'3 m WEC',''},'Fontweight','normal', ...
            'FontSize',fs);
        s1p(w).DisplayName = 'MDP';
        if slcomp
            s2p(w).DisplayName = 'Posterior Bound';
            s3p(w).DisplayName = 'Greedy';
            s4p(w).DisplayName = 'Duration Based';
        else
            s4p(w).DisplayName = 'APDC450';
            s3p(w).DisplayName = 'MPNF';
            s2p(w).DisplayName = 'APDC600';
        end
        %add ylabel
        ylabdim = [-.75 .5];
        ylab = {'Average','Power','Consumed','[W]'};
        yl = text(0,0,ylab);
        set(yl,'Units','normalized','Position',ylabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'VerticalAlignment','middle','Rotation',00);
        lg = legend([s1p(1) s3p(1) s4p(1) s2p(1)], ...
            'box','off','fontsize',fs2,'units','inches', ...
            'position',[.5 (ymarg+ydist)*5-ymarg+yoff .5 .5]);
%         ylim([410 490])
%         yticks([410 430 450 470 490])
    elseif w == 2
        title({'4 m WEC',''},'Fontweight','normal', ...
            'FontSize',fs);
%         ylim([530 590])
%         yticks([530 545 560 575 590])
    elseif w == 3
        title({'5 m WEC',''},'Fontweight','normal', ...
            'FontSize',fs);
        yline(600,'--k','Maximum Draw', ...
            'LabelHorizontalAlignment','left',...
            'LabelVerticalAlignment','top','FontSize',fs2, ...
            'LineWidth',lw2,'FontName','cmr10');
%         ylim([575 605])
%         yticks([575 585 595 605])
    end
    grid on
end
for w = 1:nw
    set(ax(w),'Units','inches','position',...
        [xoff+(w-1)*(xdist+xmarg) yoff+4*(ydist+ymarg) xdist ydist])
end

%THETA RATE
a = 3;
for w = 1:nw
    ax(w+a) = subplot(5,3,w+a);
    hold on
    s2p(w+a) = plot(x,t_r(:,w,2),'d-','MarkerEdgeColor',a4c, ...
        'MarkerFaceColor',a4c, ...
        'Color',a4c,'MarkerSize',ms2,'LineWidth',lw);
    s4p(w+a) = plot(x,t_r(:,w,3),'*-','MarkerEdgeColor',a3c, ...
        'MarkerFaceColor',a3c, ...
        'Color',a3c,'MarkerSize',ms2,'LineWidth',lw);
    s3p(w+a) = plot(x,t_r(:,w,4),'o-','MarkerEdgeColor',mpc, ...
        'Color',mpc,'MarkerSize',ms2,'LineWidth',lw);
    s1p(w+a) = plot(x,t_r(:,w,1),'.-','MarkerEdgeColor',mc, ...
        'Color',mc,'MarkerSize',ms,'LineWidth',lw);
    set(gca,'FontSize',fs2)
    xticks([0 10 20 30 40])
    if w == 1
        %add ylabel
        ylabdim = [-.75 .5];
        ylab = {'Theta','Rate','[%]'};
        yl = text(0,0,ylab);
        set(yl,'Units','normalized','Position',ylabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'VerticalAlignment','middle','Rotation',00);
%         ylim([410 490])
%         yticks([410 430 450 470 490])
    elseif w == 2
%         ylim([530 590])
%         yticks([530 545 560 575 590])
    elseif w == 3
%         ylim([97 100])
%         yticks([97 98 99 100])
    end
    grid on
end
for w = 1:nw
    set(ax(w+a),'Units','inches','position',...
        [xoff+(w-1)*(xdist+xmarg) yoff+3*(ydist+ymarg) xdist ydist])
end

%AVG INT
a = 6;
for w = 1:nw
    ax(w+a) = subplot(5,3,w+a);
    hold on
    s2p(w+a) = plot(x,i_av(:,w,2),'d-','MarkerEdgeColor',a4c, ...
        'MarkerFaceColor',a4c, ...
        'Color',a4c,'MarkerSize',ms2,'LineWidth',lw);
    s4p(w+a) = plot(x,i_av(:,w,3),'*-','MarkerEdgeColor',a3c, ...
        'MarkerFaceColor',a3c, ...
        'Color',a3c,'MarkerSize',ms2,'LineWidth',lw);
    s3p(w+a) = plot(x,i_av(:,w,4),'o-','MarkerEdgeColor',mpc, ...
        'Color',mpc,'MarkerSize',ms2,'LineWidth',lw);
    s1p(w+a) = plot(x,i_av(:,w,1),'.-','MarkerEdgeColor',mc, ...
        'Color',mc,'MarkerSize',ms,'LineWidth',lw);
    set(gca,'FontSize',fs2)
    xticks([0 10 20 30 40])
    if w == 1
        %add ylabel
        ylabdim = [-.75 .5];
        ylab = {'Mean','Duration','in Low or', 'Survival Mode','[hours]'};
        yl = text(0,0,ylab);
        set(yl,'Units','normalized','Position',ylabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'VerticalAlignment','middle','Rotation',00);
%         ylim([410 490])
%         yticks([410 430 450 470 490])
    elseif w == 2
%         ylim([530 590])
%         yticks([530 545 560 575 590])
    elseif w == 3
%         ylim([97 100])
%         yticks([97 98 99 100])
    end
    grid on
end
for w = 1:nw
    set(ax(w+a),'Units','inches','position',...
        [xoff+(w-1)*(xdist+xmarg) yoff+2*(ydist+ymarg) xdist ydist])
end

%MAX INT
a = 9;
for w = 1:nw
    ax(w+a) = subplot(5,3,w+a);
    hold on
    s2p(w+a) = plot(x,i_mx(:,w,2),'d-','MarkerEdgeColor',a4c, ...
        'MarkerFaceColor',a4c, ...
        'Color',a4c,'MarkerSize',ms2,'LineWidth',lw);
    s4p(w+a) = plot(x,i_mx(:,w,3),'*-','MarkerEdgeColor',a3c, ...
        'MarkerFaceColor',a3c, ...
        'Color',a3c,'MarkerSize',ms2,'LineWidth',lw);
    s3p(w+a) = plot(x,i_mx(:,w,4),'o-','MarkerEdgeColor',mpc, ...
        'Color',mpc,'MarkerSize',ms2,'LineWidth',lw);
    s1p(w+a) = plot(x,i_mx(:,w,1),'.-','MarkerEdgeColor',mc, ...
        'Color',mc,'MarkerSize',ms,'LineWidth',lw);
    set(gca,'FontSize',fs2)
    xticks([0 10 20 30 40])
    if w == 1
        %add ylabel
        ylabdim = [-.75 .5];
        ylab = {'Longest','Duration','in Low or','Survival Mode','[hours]'};
        yl = text(0,0,ylab);
        set(yl,'Units','normalized','Position',ylabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'VerticalAlignment','middle','Rotation',00);
%         ylim([410 490])
%         yticks([410 430 450 470 490])
    elseif w == 2
%         ylim([530 590])
%         yticks([530 545 560 575 590])
    elseif w == 3
%         ylim([97 100])
%         yticks([97 98 99 100])
    end
    grid on
end
for w = 1:nw
    set(ax(w+a),'Units','inches','position',...
        [xoff+(w-1)*(xdist+xmarg) yoff+(ydist+ymarg) xdist ydist])
end

%BATT DEG
a = 12;
for w = 1:nw
    ax(w+a) = subplot(5,3,w+a);
    hold on
    s2p(w+a) = plot(x,L(:,w,2),'d-','MarkerEdgeColor',a4c, ...
        'MarkerFaceColor',a4c, ...
        'Color',a4c,'MarkerSize',ms2,'LineWidth',lw);
    s4p(w+a) = plot(x,L(:,w,3),'*-','MarkerEdgeColor',a3c, ...
        'MarkerFaceColor',a3c, ...
        'Color',a3c,'MarkerSize',ms2,'LineWidth',lw);
    s3p(w+a) = plot(x,L(:,w,4),'o-','MarkerEdgeColor',mpc, ...
        'Color',mpc,'MarkerSize',ms2,'LineWidth',lw);
    s1p(w+a) = plot(x,L(:,w,1),'.-','MarkerEdgeColor',mc, ...
        'Color',mc,'MarkerSize',ms,'LineWidth',lw);
    yline(20,'--k',{'Estimated battery','end of life'}, ...
    'LabelHorizontalAlignment','left', ...
    'LabelVerticalAlignment','bottom','FontSize',fs2, ...
    'LineWidth',lw2,'FontName','cmr10');
    set(gca,'FontSize',fs2)
    %add xlabel
    xlabdim = [0.5 -.4];
    xlab = {'Battery Storage','Capacity [kWh]'};
    xl = text(0,0,xlab);
    set(xl,'Units','normalized','Position',xlabdim, ...
        'HorizontalAlignment','center','FontSize',fs, ...
        'Rotation',0);
    xticks([0 10 20 30 40])
    if w == 1
        %add ylabel
        ylabdim = [-.75 .5];
        ylab = {'Battery','Capacity','Fade','[%]'};
        yl = text(0,0,ylab);
        set(yl,'Units','normalized','Position',ylabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'VerticalAlignment','middle','Rotation',00);
        ylim([10 20])
%         yticks([410 430 450 470 490])
    elseif w == 2
        ylim([10 20])
%         yticks([530 545 560 575 590])
    elseif w == 3
        ylim([10 20])
%         yticks([97 98 99 100])
    end
    grid on
end
for w = 1:nw
    set(ax(w+a),'Units','inches','position',...
        [xoff+(w-1)*(xdist+xmarg) yoff xdist ydist])
end



