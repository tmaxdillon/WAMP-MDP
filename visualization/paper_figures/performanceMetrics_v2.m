
clearvars -except mdpsim pbosim sl2sim sl3sim
%close all

%% vis
%close all
set(0,'defaulttextinterpreter','tex')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
output_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
    'output_data/11_22/'];

slcomp = false; %comparing simple logic, false means baseline comparison
printfig = true; %print figure
close all

if ~exist('mdpsim','var') || ~exist('pbosim','var') || ...
        ~exist('sl2sim','var') || ~exist('sl3sim','var')
    load([ output_path 'mdpsim']);
    load([ output_path 'pbosim']);
    %load([ output_path 'slosim']);
    load([ output_path 'sl4sim']);
    load([ output_path 'sl3sim']);
    mdpsim = mdpsim(2:end,:);
    pbosim = pbosim(2:end,:);
    %slosim = slosim(2:end,:);
    sl2sim = sl4sim(2:end,:);
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
            [power_avg(e,w,4)] = getPower(mdpsim(w,e));
            [power_avg(e,w,1)] = getPower(pbosim(w,e));
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

if slcomp
    c1 = [72 54 116]/255; %pbo
    c2 = [60,130,60]/256; %dbl
    c3 = [0 240 0]/256; %gre
else
    c1 = [0,47,108]/256; %apdc600
    c2 = [0, 100, 220]/256; %apdc450
    c3 = [0,180,123]/256; %mpnf
end
c4 = [255 0 143]/256; %mdp
mt{1} = 'd-';
mt{2} = '*-';
mt{3} = 'o-';
mt{4} = '.-';
sccol(1,:) = [170 170 170]/256;
sccol(2,:) = [110 110 110]/256;
sccol(3,:) = [50 50 50]/256;
ms = 8;
ms2 = 5;
ms3 = 4;
ms4 = 3;
fs = 10;
fs2 = 8; %legend font size
lw = 1.2;
lw2 = 1;
xoff = 1.1; %[in]
yoff = .95; %[in]
xdist = 1.15; %[in]
xscdist = .65; %[in]
ydist = 1; %[in]
xmarg = .35; %[in]
ymarg = 0.25; %[in]
ylabx = -.575;

if slcomp
    pmsim = figure;
else
    pmilc = figure;
end
set(gcf,'Units','inches','Color','w')
set(gcf, 'Position', [0, 4, 6.5, 7.4])
%AVG POWER
sca = 4;
for w = 1:nw
    ax(w) = subplot(5,4,w);
    hold on
    s1p(w) = plot(x,power_avg(:,w,1),mt{1},'MarkerEdgeColor',c1, ...
        'MarkerFaceColor',c1, ...
        'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
    s2p(w) = plot(x,power_avg(:,w,2),mt{2},'MarkerEdgeColor',c2, ...
        'MarkerFaceColor',c2, ...
        'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
    s3p(w) = plot(x,power_avg(:,w,3),'o-','MarkerEdgeColor',c3, ...
        'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
    s4p(w) = plot(x,power_avg(:,w,4),mt{4},'MarkerEdgeColor',c4, ...
        'Color',c4,'MarkerSize',ms,'LineWidth',lw);
    set(gca,'FontSize',fs2)
    xticks([0 10 20 30 40])
    if w == 1
        title({'3 m WEC',''},'Fontweight','normal', ...
            'FontSize',fs);
        s4p(w).DisplayName = 'MDP';
        if slcomp
            s1p(w).DisplayName = 'Posterior Bound';
            s2p(w).DisplayName = 'Duration-Based';
            s3p(w).DisplayName = 'Greedy';
        else
            s3p(w).DisplayName = 'MPNF';
            s2p(w).DisplayName = 'APDC450';
            s1p(w).DisplayName = 'APDC600';
        end
        %add ylabel
        ylabdim = [ylabx .5];
        ylab = {'Mean','Power','Consumption','[W]'};
        yl = text(0,0,ylab);
        set(yl,'Units','normalized','Position',ylabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'VerticalAlignment','middle','Rotation',00);
        if slcomp
            %ylim([410 490])
            %yticks([410 430 450 470 490])
            lg = legend([s4p(1) s1p(1) s3p(1) s2p(1)], ...
            'NumColumns',1,'box','off','fontsize',fs2, ...
            'units','normalized','position',[-.075 .025 .4 .03]);
        else
            lg = legend([s4p(1) s3p(1) s2p(1) s1p(1)], ...
            'NumColumns',1,'box','off','fontsize',fs2, ...
            'units','normalized','position',[-.1 .025 .4 .03]);
        end
        text(.85,.1,'(a)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    elseif w == 2
        title({'4 m WEC',''},'Fontweight','normal', ...
            'FontSize',fs);
        if slcomp
             ylim([540 585])
             yticks([540 550 560 570 580])
        end
        text(.85,.1,'(b)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    elseif w == 3
        title({'5 m WEC',''},'Fontweight','normal', ...
            'FontSize',fs);
        yline(600,'--k','Maximum Draw', ...
            'LabelHorizontalAlignment','left',...
            'LabelVerticalAlignment','top','FontSize',fs2, ...
            'LineWidth',lw2,'FontName','cmr10');
        if slcomp
%             ylim([575 605])
%             yticks([580 590 600])
        end
        text(.85,.1,'(c)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    end
    grid on
    %plot scale comparison
    ax(sca) = subplot(5,4,sca);
    xticks([0 10 20 30 40])
    title({'Y-Axis Scale','Comparison',''}, ...
        'Fontweight','normal','FontSize',fs2);
    hold on
    plot(x,power_avg(:,w,1),mt{1},'MarkerEdgeColor', ...
        sccol(w,:),'MarkerFaceColor',sccol(w,:), ...
        'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,power_avg(:,w,2),mt{2},'MarkerEdgeColor', ...
        sccol(w,:),'MarkerFaceColor',sccol(w,:), ...
        'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,power_avg(:,w,3),mt{3},'MarkerEdgeColor', ...
        sccol(w,:),'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    sc1p(w) = plot(x,power_avg(:,w,4),mt{4},'MarkerEdgeColor', ...
        sccol(w,:),'Color',sccol(w,:),'MarkerSize',ms3,'LineWidth',lw2);
    set(gca,'FontSize',fs2)
    grid on
    if w == 3
        sc1p(1).DisplayName = '3 m WEC';
        sc1p(2).DisplayName = '4 m WEC';
        sc1p(3).DisplayName = '5 m WEC';
        lg = legend([sc1p(3) sc1p(2) sc1p(1)], ...
            'box','off','fontsize',fs2, ...
            'units','inches','position',[xoff+3*(xdist+xmarg)+xscdist/2 ...
            ymarg .05 .05]);
    end
end
text(.75,.1,'(d)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs2);
for w = 1:nw
    set(ax(w),'Units','inches','position',...
        [xoff+(w-1)*(xdist+xmarg) yoff+4*(ydist+ymarg) xdist ydist])
end
set(ax(sca),'Units','inches','position', ...
        [xoff+(w)*(xdist+xmarg) yoff+4*(ydist+ymarg) xscdist ydist])
    

%THETA RATE
a = 4;
sca = 8;
for w = 1:nw
    ax(w+a) = subplot(5,4,w+a);
    hold on
    plot(x,t_r(:,w,1),mt{1},'MarkerEdgeColor',c1, ...
        'MarkerFaceColor',c1, ...
        'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,t_r(:,w,2),mt{2},'MarkerEdgeColor',c2, ...
        'MarkerFaceColor',c2, ...
        'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,t_r(:,w,3),mt{3},'MarkerEdgeColor',c3, ...
        'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,t_r(:,w,4),mt{4},'MarkerEdgeColor',c4, ...
        'Color',c4,'MarkerSize',ms,'LineWidth',lw);
    set(gca,'FontSize',fs2)
    xticks([0 10 20 30 40])
    if w == 1
        %add ylabel
        ylabdim = [ylabx .5];
        ylab = {'Theta','Rate','[%]','\fontsize{1} ', ...
            '\fontsize{7.5} (percentage of', ...
            '\fontsize{7.5} \thetah time steps', ...
            '\fontsize{7.5} in medium or', ...
            '\fontsize{7.5} full power)'};
        yl = text(0,0,ylab);
        set(yl,'Units','normalized','Position',ylabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'VerticalAlignment','middle','Rotation',00);
%         ylim([410 490])
%         yticks([410 430 450 470 490])
        text(.85,.1,'(e)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    elseif w == 2
%         ylim([530 590])
%         yticks([530 545 560 575 590])
        text(.85,.1,'(f)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    elseif w == 3
        if slcomp
            ylim([97 100])
            yticks([97 98 99 100])
        end
        text(.85,.1,'(g)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    end
    grid on
    %plot scale comparison
    ax(sca) = subplot(5,4,sca);
    xticks([0 10 20 30 40])
    hold on
    plot(x,t_r(:,w,1),mt{1},'MarkerEdgeColor', ...
        sccol(w,:),'MarkerFaceColor',sccol(w,:), ...
        'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,t_r(:,w,2),mt{2},'MarkerEdgeColor', ...
        sccol(w,:),'MarkerFaceColor',sccol(w,:), ...
        'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,t_r(:,w,3),mt{3},'MarkerEdgeColor', ...
        sccol(w,:),'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,t_r(:,w,4),mt{4},'MarkerEdgeColor', ...
        sccol(w,:),'Color',sccol(w,:),'MarkerSize',ms3,'LineWidth',lw2);
    set(gca,'FontSize',fs2)
    grid on
end
text(.75,.1,'(h)','Units','Normalized', ...
    'VerticalAlignment','middle','FontWeight','normal', ...
    'FontSize',fs2);
for w = 1:nw
    set(ax(w+a),'Units','inches','position',...
        [xoff+(w-1)*(xdist+xmarg) yoff+3*(ydist+ymarg) xdist ydist])
end
set(ax(sca),'Units','inches','position', ...
        [xoff+(w)*(xdist+xmarg) yoff+3*(ydist+ymarg) xscdist ydist])

%AVG INT
a = 8;
sca = 12;
for w = 1:nw
    ax(w+a) = subplot(5,4,w+a);
    hold on
    plot(x,i_av(:,w,1),mt{1},'MarkerEdgeColor',c1, ...
        'MarkerFaceColor',c1, ...
        'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,i_av(:,w,2),mt{2},'MarkerEdgeColor',c2, ...
        'MarkerFaceColor',c2, ...
        'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,i_av(:,w,3),mt{3},'MarkerEdgeColor',c3, ...
        'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,i_av(:,w,4),mt{4},'MarkerEdgeColor',c4, ...
        'Color',c4,'MarkerSize',ms,'LineWidth',lw);
    set(gca,'FontSize',fs2)
    xticks([0 10 20 30 40])
    if w == 1
        %add ylabel
        ylabdim = [ylabx .5];
        ylab = {'Mean','Duration','in Low or','Survival','Mode','[hours]'};
        yl = text(0,0,ylab);
        set(yl,'Units','normalized','Position',ylabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'VerticalAlignment','middle','Rotation',00);
%         ylim([410 490])
%         yticks([410 430 450 470 490])
        text(.85,.9,'(i)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    elseif w == 2
%         ylim([530 590])
%         yticks([530 545 560 575 590])
        text(.85,.9,'(j)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    elseif w == 3
%         ylim([97 100])
%         yticks([97 98 99 100])
        text(.85,.9,'(k)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    end
    grid on
    %plot scale comparison
    ax(sca) = subplot(5,4,sca);
    xticks([0 10 20 30 40])
    hold on
    plot(x,i_av(:,w,1),mt{1},'MarkerEdgeColor', ...
        sccol(w,:),'MarkerFaceColor',sccol(w,:), ...
        'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,i_av(:,w,2),mt{2},'MarkerEdgeColor', ...
        sccol(w,:),'MarkerFaceColor',sccol(w,:), ...
        'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,i_av(:,w,3),mt{3},'MarkerEdgeColor', ...
        sccol(w,:),'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,i_av(:,w,4),mt{4},'MarkerEdgeColor', ...
        sccol(w,:),'Color',sccol(w,:),'MarkerSize',ms3,'LineWidth',lw2);
    set(gca,'FontSize',fs2)
    grid on
end
text(.75,.9,'(l)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
for w = 1:nw
    set(ax(w+a),'Units','inches','position',...
        [xoff+(w-1)*(xdist+xmarg) yoff+2*(ydist+ymarg) xdist ydist])
end
set(ax(sca),'Units','inches','position', ...
        [xoff+(w)*(xdist+xmarg) yoff+2*(ydist+ymarg) xscdist ydist])

%MAX INT
a = 12;
sca = 16;
for w = 1:nw
    ax(w+a) = subplot(5,4,w+a);
    hold on
    plot(x,i_mx(:,w,1),mt{1},'MarkerEdgeColor',c1, ...
        'MarkerFaceColor',c1, ...
        'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,i_mx(:,w,2),mt{2},'MarkerEdgeColor',c2, ...
        'MarkerFaceColor',c2, ...
        'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,i_mx(:,w,3),mt{3},'MarkerEdgeColor',c3, ...
        'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,i_mx(:,w,4),mt{4},'MarkerEdgeColor',c4, ...
        'Color',c4,'MarkerSize',ms,'LineWidth',lw);
    set(gca,'FontSize',fs2)
    xticks([0 10 20 30 40])
    if w == 1
        %add ylabel
        ylabdim = [ylabx .5];
        ylab = {'Longest','Duration','in Low or','Survival','Mode', ...
            '[hours]'};
        yl = text(0,0,ylab);
        set(yl,'Units','normalized','Position',ylabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'VerticalAlignment','middle','Rotation',00);
        %ylim([0 95])
%         yticks([410 430 450 470 490])
        text(.8,.35,'(m)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    elseif w == 2
%         ylim([530 590])
%         yticks([530 545 560 575 590])
        text(.85,.9,'(n)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    elseif w == 3
%         ylim([97 100])
%         yticks([97 98 99 100])
        text(.85,.9,'(o)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    end
    grid on
    %plot scale comparison
    ax(sca) = subplot(5,4,sca);
    xticks([0 10 20 30 40])
    hold on
    plot(x,i_mx(:,w,1),mt{1},'MarkerEdgeColor', ...
        sccol(w,:),'MarkerFaceColor',sccol(w,:), ...
        'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,i_mx(:,w,2),mt{2},'MarkerEdgeColor', ...
        sccol(w,:),'MarkerFaceColor',sccol(w,:), ...
        'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,i_mx(:,w,3),mt{3},'MarkerEdgeColor', ...
        sccol(w,:),'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,i_mx(:,w,4),mt{4},'MarkerEdgeColor', ...
        sccol(w,:),'Color',sccol(w,:),'MarkerSize',ms3,'LineWidth',lw2);
    set(gca,'FontSize',fs2)
    grid on
end
text(.75,.25,'(p)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
for w = 1:nw
    set(ax(w+a),'Units','inches','position',...
        [xoff+(w-1)*(xdist+xmarg) yoff+(ydist+ymarg) xdist ydist])
end
set(ax(sca),'Units','inches','position', ...
        [xoff+(w)*(xdist+xmarg) yoff+(ydist+ymarg) xscdist ydist])

%BATT DEG
a = 16;
sca = 20;
for w = 1:nw
    ax(w+a) = subplot(5,4,w+a);
    hold on
    plot(x,L(:,w,1),mt{1},'MarkerEdgeColor',c1, ...
        'MarkerFaceColor',c1, ...
        'Color',c1,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,L(:,w,2),mt{2},'MarkerEdgeColor',c2, ...
        'MarkerFaceColor',c2, ...
        'Color',c2,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,L(:,w,3),mt{3},'MarkerEdgeColor',c3, ...
        'Color',c3,'MarkerSize',ms2,'LineWidth',lw);
    plot(x,L(:,w,4),mt{4},'MarkerEdgeColor',c4, ...
        'Color',c4,'MarkerSize',ms,'LineWidth',lw);
    yline(20,'--k',{'Estimated','battery','end of life'}, ...
        'LabelHorizontalAlignment','left', ...
        'LabelVerticalAlignment','bottom','FontSize',fs2, ...
        'LineWidth',lw2,'FontName','cmr10');
    set(gca,'FontSize',fs2)
    %add xlabel
    xlabdim = [0.5 -.35];
    xlab = {'Battery Storage','Capacity [kWh]'};
    xl = text(0,0,xlab);
    set(xl,'Units','normalized','Position',xlabdim, ...
        'HorizontalAlignment','center','FontSize',fs, ...
        'Rotation',0);
    xticks([0 10 20 30 40])
    if w == 1
        %add ylabel
        ylabdim = [ylabx .5];
        ylab = {'Battery','Capacity','Fade','Over Five','Years','[%]'};
        yl = text(0,0,ylab);
        set(yl,'Units','normalized','Position',ylabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'VerticalAlignment','middle','Rotation',00);
%         ylim([410 490])
%         yticks([410 430 450 470 490])
        text(.85,.85,'(q)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    elseif w == 2
%         ylim([530 590])
%         yticks([530 545 560 575 590])
        text(.85,.85,'(r)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    elseif w == 3
%         ylim([97 100])
%         yticks([97 98 99 100])
        text(.85,.85,'(s)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
    end
    grid on
    %plot scale comparison
    ax(sca) = subplot(5,4,sca);
    xticks([0 10 20 30 40])
    hold on
    plot(x,L(:,w,1),mt{1},'MarkerEdgeColor', ...
        sccol(w,:),'MarkerFaceColor',sccol(w,:), ...
        'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,L(:,w,2),mt{2},'MarkerEdgeColor', ...
        sccol(w,:),'MarkerFaceColor',sccol(w,:), ...
        'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,L(:,w,3),mt{3},'MarkerEdgeColor', ...
        sccol(w,:),'Color',sccol(w,:),'MarkerSize',ms4,'LineWidth',lw2);
    plot(x,L(:,w,4),mt{4},'MarkerEdgeColor', ...
        sccol(w,:),'Color',sccol(w,:),'MarkerSize',ms3,'LineWidth',lw2);
    set(gca,'FontSize',fs2)
    grid on
end
text(.75,.85,'(t)','Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'FontSize',fs2);
yline(20,'--k',{''}, ...
    'LabelHorizontalAlignment','left', ...
    'LabelVerticalAlignment','bottom','FontSize',fs2, ...
    'LineWidth',lw2,'FontName','cmr10');
%add xlabel
xlabdim = [0.5 -.3];
xlab = {'Battery Storage','Capacity [kWh]'};
xl = text(0,0,xlab);
set(xl,'Units','normalized','Position',xlabdim, ...
    'HorizontalAlignment','center','FontSize',fs2, ...
    'Rotation',0);
for w = 1:nw
    set(ax(w+a),'Units','inches','position',...
        [xoff+(w-1)*(xdist+xmarg) yoff xdist ydist])
end
set(ax(sca),'Units','inches','position', ...
        [xoff+(w)*(xdist+xmarg) yoff xscdist ydist])
    
if printfig
    if slcomp
        print(pmsim,['~/Dropbox (MREL)/Research/WAMP-MDP/' ...
            'paper_figures/pmsim'],'-dpng','-r600')
    else
        print(pmilc,['~/Dropbox (MREL)/Research/WAMP-MDP/' ...
            'paper_figures/pmilc'],'-dpng','-r600')
    end
end


