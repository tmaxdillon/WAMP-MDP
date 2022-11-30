%close all
clearvars -except P D T P_b D_b T_b ta

set(0,'defaulttextinterpreter','tex')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
data_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
    'output_data/pyssm_out/'];

printfig = false; %print figure
var = 'slt';
logp = false; %log scale

w = 3;
b = 8;
if ~exist('P','var') || ~exist('D','var') || ~exist('T','var') || ...
        ~exist('P_b','var') || ~exist('D_b','var') || ...
        ~exist('T_b','var') || ~exist('ta','var')
    P = zeros(w,b,10);
    D = zeros(w,b,10);
    T = zeros(w,b,10);
    P_b = zeros(w,b);
    D_b = zeros(w,b);
    T_b = zeros(w,b);
    bbb = load([data_path 'bbb.mat']);    
    for i = 1:10
        temp = load([data_path var '_' num2str(i) '.mat']);
        %set theta period
        if ~isequal(var,'tpe')
            tp = 4; %[h] default
        else
            tp = temp.([var '_' num2str(i)])(1,1).output.tuning_array(i);
        end
        for j = 1:w
            for k = 1:b
                temp_output = temp.([var '_' num2str(i)])(j+1,k).output;
                P(j,k,i) = temp_output.power_avg;
                [D(j,k,i),~,~,~,~,~,~] = calcIntermit( ...
                    temp_output.a_act_sim,99,1);
                T(j,k,i) = calcThetaRate(temp_output.a_act_sim, ...
                    temp_output.FM_P_1(:,1),tp)*100;                
                if i == 1 %populate baseline matrix & tuning array
                    bbb_output = bbb.bbb(j+1,k).output;                    
                    P_b(j,k) = bbb_output.power_avg;
                    [D_b(j,k,i),~,~,~,~,~,~] = calcIntermit( ...
                        bbb_output.a_act_sim,99,1);
                    T_b(j,k,i) = calcThetaRate( ...
                        bbb_output.a_act_sim,bbb_output.FM_P_1(:,1),4)*100;
                    ta = temp_output.tuning_array;                   
                end
            end
        end
    end
end
batts = [2500 5000:5000:35000]; %[Wh]
wecs = [3 4 5]; %[m]

%xlabel
%POWER SYSTEM PARAMETERS
if isequal(var,'eta') %conversion and transmission efficiency
    xlab = 'Conversion and Transmission Efficiency';
elseif isequal(var,'whl') %wec hotel load
    xlab = 'WEC Hotel Load [% of rated power]';
elseif isequal(var,'rhs') %rated significant wave height
    xlab = 'Rated Significant Wave Height [m]';
elseif isequal(var,'rtp') %rated peak period
    xlab = 'Rated Peak Period [s]';
elseif isequal(var,'sdr') %self discharge rate
    xlab = 'Battery Self Discharge Rate [%/month]';
elseif isequal(var,'est') %battery starting fraction
    xlab = 'Battery Starting State of Charge [%]';
%MARKOV DECISION PROCESS PARAMETERS
elseif isequal(var,'slt') %stage limit
    xlab = 'Forecast Extent (Stage Limit) [h]';
elseif isequal(var,'tbs') %time between stages
    xlab = 'Duration of Decisions (Time Between Stages) [h]';
elseif isequal(var,'ebs') %energy between states
    xlab = 'Energy Between States (State Discretization) [Wh]';
elseif isequal(var,'dfr') %discount factor
    xlab = 'Discount Factor Applied to Bellman''s Equation';
elseif isequal(var,'sub') %spin up buffer
    xlab = 'Spin Up Buffer Applied to Fresh Forecast [h]';
elseif isequal(var,'tam') %theta amplitude
    xlab = 'Magnitude of Theta Penalty (\theta_A)';
    if ~logp
        %xlims = [0 10];
    end
elseif isequal(var,'tam_z') %theta amplitude
    xlab = 'Magnitude of Theta Penalty (\theta_A)';
elseif isequal(var,'tam_l') %theta amplitude
    xlab = 'Magnitude of Theta Penalty (\theta_A)';
elseif isequal(var,'tpe') %theta period
    xlab = 'Interval of Theta Penalty (\theta_h) [h]';
end

%set colors
c(1,:,:) = brewermap(ceil(b*1.5),'blues');
c(2,:,:) = brewermap(ceil(b*1.5),'purples');
c(3,:,:) = brewermap(ceil(b*1.5),'reds');

%figure settings
xoff = 1.25;
yoff = .5;
xmarg = .575;
ymarg = 0.1;
xlength = .75;
ylength = .75;
ylhpos = -.45;
fs = 9;
fs2 = 9;
fs_tick = 7;
fs_leg = 6;
lgxs = 5.35;
lgdx = .35;
lgys = .7;
lgdy = .75;
lgits1 = 22;
lgits2 = 1;
lgfs = 6.75;

sensfig = figure;
set(gcf,'Units','inches','Position',[1 1 6.5 2.8],'Color','w')
%AVG P: ABSOLUTE
ax(1) = subplot(2,3,1);
for j = 1:w
    for k = 1:b
        if logp %theta amplitude
            semilogx(ta,squeeze(P(j,k,:))','LineWidth',1.5, ...
            'Color',c(j,end-b+k,:));
        else
            plot(ta,squeeze(P(j,k,:))','LineWidth',1.5, ...
                'Color',c(j,end-b+k,:));
        end
        hold on
    end
end
set(gca,'FontSize',fs_tick)
lab(1) = ylabel({'[W]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(lab(1),'Position');
set(lab(1),'Position',[ylhpos ylpos(2) ylpos(3)])
if exist('xlims','var')
    xlim(xlims)
else
    xlim([min(ta) max(ta)])
end
set(gca,'XTickLabel',[])
title({'Average','Power','Consumed',''},'FontWeight','normal', ...
    'FontSize',fs)
grid on
text(-.7,.5,{'Absolute','Value'},'Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'HorizontalAlignment','right','FontSize',fs2);
%THETA RATE: ABSOLUTE
ax(2) = subplot(2,3,2);
for j = 1:w
    for k = 1:b
        if logp
            semilogx(ta,squeeze(T(j,k,:))','LineWidth',1.5, ...
            'Color',c(j,end-b+k,:));
        else
            plot(ta,squeeze(T(j,k,:))','LineWidth',1.5, ...
                'Color',c(j,end-b+k,:));
        end
        hold on
    end
end
set(gca,'FontSize',fs_tick)
lab(1) = ylabel({'[%]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(lab(1),'Position');
set(lab(1),'Position',[ylhpos ylpos(2) ylpos(3)])
if exist('xlims','var')
    xlim(xlims)
else
    xlim([min(ta) max(ta)])
end
set(gca,'XTickLabel',[])
title({'\fontsize{9} Theta Rate', ...
            '\fontsize{6} (percentage of', ...
            '\fontsize{6} \thetah time steps', ...
            '\fontsize{6} in medium or', ...
            '\fontsize{6} full power)', ...
            '\fontsize{1} '}, ...
    'FontWeight','normal')
grid on
%AVG DUR: ABSOLUTE
ax(3) = subplot(2,3,3);
for j = 1:w
    for k = 1:b
        if logp
            semilogx(ta,squeeze(D(j,k,:))','LineWidth',1.5, ...
            'Color',c(j,end-b+k,:));
        else
            plot(ta,squeeze(D(j,k,:))','LineWidth',1.5, ...
                'Color',c(j,end-b+k,:));
        end
        hold on
    end
end
set(gca,'FontSize',fs_tick)
lab(1) = ylabel({'[h]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(lab(1),'Position');
set(lab(1),'Position',[ylhpos ylpos(2) ylpos(3)])
if exist('xlims','var')
    xlim(xlims)
else
    xlim([min(ta) max(ta)])
end
set(gca,'XTickLabel',[])
title({'Mean Duration','in Low or','Survival Mode',''}, ...
    'FontWeight','normal','FontSize',fs)
grid on
%AVG P: NORMALIZED
ax(4) = subplot(2,3,4);
for j = 1:w
    for k = 1:b
        if logp
            lgvar(j,k) = semilogx(ta,100*squeeze(P(j,k,:)./P_b(j,k))', ...
                'LineWidth',1.5,'Color',c(j,end-b+k,:));
        else
            lgvar(j,k) = plot(ta,100*squeeze(P(j,k,:)./P_b(j,k))', ...
            'LineWidth',1.5,'Color',c(j,end-b+k,:));
        end
        lgvar(j,k).DisplayName = '';
        hold on
    end
end
set(gca,'FontSize',fs_tick)
lab(1) = ylabel({'[%]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(lab(1),'Position');
set(lab(1),'Position',[ylhpos ylpos(2) ylpos(3)])
if exist('xlims','var')
    xlim(xlims)
else
    xlim([min(ta) max(ta)])
end
grid on
hL1 = legend(reshape(lgvar(1,:),[1 b]),'location','eastoutside', ...
    'box','off','NumColumns',1,'Units','Inches', ...
    'Position',[lgxs lgys lgdx lgdy],'FontSize',lgfs);
hL1.ItemTokenSize = [lgits1,lgits2];
text(-.7,.5,{'Normalized','by Default','Value'},'Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'HorizontalAlignment','right','FontSize',fs2);
%THETA RATE: NORMALIZED
ax(5) = subplot(2,3,5);
for j = 1:w
    for k = 1:b
        if logp
            lgvar(j,k) = semilogx(ta,100*squeeze(T(j,k,:)./T_b(j,k))', ...
                'LineWidth',1.5,'Color',c(j,end-b+k,:));
        else
            lgvar(j,k) = plot(ta,100*squeeze(T(j,k,:)./T_b(j,k))', ...
            'LineWidth',1.5,'Color',c(j,end-b+k,:));
        end
        lgvar(j,k).DisplayName = '';
        hold on
    end
end
set(gca,'FontSize',fs_tick)
lab(1) = ylabel({'[%]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(lab(1),'Position');
set(lab(1),'Position',[ylhpos ylpos(2) ylpos(3)])
if exist('xlims','var')
    xlim(xlims)
else
    xlim([min(ta) max(ta)])
end
xlabel({'',xlab},'FontSize',fs)
grid on
hL2 = legend(reshape(lgvar(2,:),[1 b]),'location','eastoutside', ...
    'box','off','NumColumns',1,'Units','Inches', ...
    'Position',[lgxs+lgdx lgys lgdx lgdy],'FontSize',lgfs);
hL2.ItemTokenSize = [lgits1,lgits2];
%AVG DUR: NORMALIZED
ax(6) = subplot(2,3,6);
for j = w:-1:1 %hopefully this results in the 5m WEC plotting first
    for k = 1:b
        if logp
            lgvar(j,k) = semilogx(ta,100*squeeze(D(j,k,:)./D_b(j,k))', ...
                'LineWidth',1.5,'Color',c(j,end-b+k,:));
        else
            lgvar(j,k) = plot(ta,100*squeeze(D(j,k,:)./D_b(j,k))', ...
            'LineWidth',1.5,'Color',c(j,end-b+k,:));
        end
        lgvar(j,k).DisplayName = '';
        hold on
    end
end
set(gca,'FontSize',fs_tick)
lab(1) = ylabel({'[%]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(lab(1),'Position');
set(lab(1),'Position',[ylhpos ylpos(2) ylpos(3)])
if exist('xlims','var')
    xlim(xlims)
else
    xlim([min(ta) max(ta)])
end
grid on
hL3 = legend(reshape(lgvar(3,:),[1 b]),'location','eastoutside', ...
    'box','off','NumColumns',1,'Units','Inches', ...
    'Position',[lgxs+2*lgdx lgys lgdx lgdy],'FontSize',lgfs);
hL3.ItemTokenSize = [lgits1,lgits2];
% hL = legend(reshape(lgvar',[1 w*b]),'location','eastoutside', ...
%     'box','off','NumColumns',3,'Units','Inches', ...
%     'Position',[5.75 1 .25 .5],'FontSize',lgfs);
% hL.ItemTokenSize = [10,1];
dy = .1;
xadj = 4.05;
yadj = .225;
text(lgxs-xadj,lgys+yadj,'2.5 kWh','Units','Inches','FontSize',fs_leg, ...
    'HorizontalAlignment','right')
text(lgxs-xadj,lgys+yadj-1*dy,'5 kWh','Units','Inches', ...
    'FontSize',fs_leg,'HorizontalAlignment','right')
text(lgxs-xadj,lgys+yadj-2*dy,'10 kWh','Units','Inches', ...
    'FontSize',fs_leg,'HorizontalAlignment','right')
text(lgxs-xadj,lgys+yadj-3*dy,'15 kWh','Units','Inches', ...
    'FontSize',fs_leg,'HorizontalAlignment','right')
text(lgxs-xadj,lgys+yadj-4*dy,'20 kWh','Units','Inches', ...
    'FontSize',fs_leg,'HorizontalAlignment','right')
text(lgxs-xadj,lgys+yadj-5*dy,'25 kWh','Units','Inches', ...
    'FontSize',fs_leg,'HorizontalAlignment','right')
text(lgxs-xadj,lgys+yadj-6*dy,'30 kWh','Units','Inches', ...
    'FontSize',fs_leg,'HorizontalAlignment','right')
text(lgxs-xadj,lgys+yadj-6.5*dy,{'35 kWh','Battery'},'Units','Inches', ...
    'FontSize',fs_leg,'HorizontalAlignment','right', ...
    'VerticalAlignment','top')
dx = lgdx;
xadj2 = 3.825;
yadj = .375;
text(lgxs-xadj2,lgys+yadj,{'3 m','WEC'},'Units','Inches', ...
    'FontSize',fs_leg,'HorizontalAlignment','center')
text(lgxs-xadj2+dx,lgys+yadj,{'4 m','WEC'},'Units','Inches', ...
    'FontSize',fs_leg,'HorizontalAlignment','center')
text(lgxs-xadj2+2*dx,lgys+yadj,{'5 m','WEC'},'Units','Inches', ...
    'FontSize',fs_leg,'HorizontalAlignment','center')
text(lgxs-3.6,lgys+.7,{'Color Indicates','Energy System Size'}, ...
    'Units','Inches','FontSize',fs,'HorizontalAlignment','center')

%set(lab,'FontSize',fs_lab)

for i = 1:length(ax)
    set(ax(i),'Units','Inches','Position', ...
        [xoff+(rem(i-1,3)*(xlength+xmarg)) ...
        yoff+floor((length(ax)-i)/3)*(ymarg+ylength) xlength ylength])
end

if printfig
    print(sensfig,['~/Dropbox (MREL)/Research/WAMP-MDP/' ...
        'paper_figures/sens_' var],'-dpng','-r600')
end




