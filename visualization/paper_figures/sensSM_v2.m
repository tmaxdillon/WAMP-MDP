close all
clearvars -except P D T P_b D_b T_b ta

set(0,'defaulttextinterpreter','tex')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
data_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
    'output_data/pyssm_out/'];

printfig = false; %print figure
var = 'tpe';

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
    xlims = [0 5];
elseif isequal(var,'tpe') %theta period
    xlab = 'Interval of Theta Penalty (\theta_h) [h]';
end

%set colors
c(1,:,:) = brewermap(b*2,'blues');
c(2,:,:) = brewermap(b*2,'purples');
c(3,:,:) = brewermap(b*2,'reds');

%figure settings
xoff = 1.45;
yoff = .5;
xmarg = .65;
ymarg = 0.1;
xlength = .75;
ylength = .75;
ylhpos = -.45;
fs_tick = 8;
fs_lab = 10;

sensfig = figure;
set(gcf,'Units','inches','Position',[1 1 6.5 2.8],'Color','w')
%AVG P: ABSOLUTE
ax(1) = subplot(2,3,1);
for j = 1:w
    for k = 1:b
        if isequal(var,'tm') %theta amplitude
            semilogx(ta,squeeze(P(j,k,:))','LineWidth',1.5, ...
            'Color',c(j,b+k,:));
        else
            plot(ta,squeeze(P(j,k,:))','LineWidth',1.5, ...
                'Color',c(j,b+k,:));
        end
        hold on
    end
end
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
title({'Average','Power','Consumed',''},'FontWeight','normal')
grid on
text(-.9,.5,{'Absolute','Value'},'Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'HorizontalAlignment','right','FontSize',fs_lab);
%THETA RATE: ABSOLUTE
ax(2) = subplot(2,3,2);
for j = 1:w
    for k = 1:b
        if isequal(var,'ta') %theta amplitude
            semilogx(ta,squeeze(T(j,k,:))','LineWidth',1.5, ...
            'Color',c(j,b+k,:));
        else
            plot(ta,squeeze(T(j,k,:))','LineWidth',1.5, ...
                'Color',c(j,b+k,:));
        end
        hold on
    end
end
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
title({'Theta Rate', ...
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
        if isequal(var,'tm') %theta amplitude
            semilogx(ta,squeeze(D(j,k,:))','LineWidth',1.5, ...
            'Color',c(j,b+k,:));
        else
            plot(ta,squeeze(D(j,k,:))','LineWidth',1.5, ...
                'Color',c(j,b+k,:));
        end
        hold on
    end
end
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
    'FontWeight','normal')
grid on
%AVG P: NORMALIZED
ax(4) = subplot(2,3,4);
for j = 1:w
    for k = 1:b
        if isequal(var,'tm') %theta amplitude
            semilogx(ta,100*squeeze(P(j,k,:)./P_b(j,k))', ...
                'LineWidth',1.5,'Color',c(j,b+k,:));
        else
            plot(ta,100*squeeze(P(j,k,:)./P_b(j,k))', ...
            'LineWidth',1.5,'Color',c(j,b+k,:));
        end
        hold on
    end
end
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
text(-.9,.5,{'Normalized','by Default','Value'},'Units','Normalized', ...
            'VerticalAlignment','middle','FontWeight','normal', ...
            'HorizontalAlignment','right','FontSize',fs_lab);
%THETA RATE: NORMALIZED
ax(5) = subplot(2,3,5);
for j = 1:w
    for k = 1:b
        if isequal(var,'tm') %theta amplitude
            semilogx(ta,100*squeeze(T(j,k,:)./T_b(j,k))', ...
                'LineWidth',1.5,'Color',c(j,b+k,:));
        else
            plot(ta,100*squeeze(T(j,k,:)./T_b(j,k))', ...
            'LineWidth',1.5,'Color',c(j,b+k,:));
        end
        hold on
    end
end
lab(1) = ylabel({'[%]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(lab(1),'Position');
set(lab(1),'Position',[ylhpos ylpos(2) ylpos(3)])
if exist('xlims','var')
    xlim(xlims)
else
    xlim([min(ta) max(ta)])
end
xlabel({'',xlab})
grid on
%AVG DUR: NORMALIZED
ax(6) = subplot(2,3,6);
for j = 1:w
    for k = 1:b
        if isequal(var,'tm') %theta amplitude
            lgvar(j,k) = semilogx(ta,100*squeeze(D(j,k,:)./D_b(j,k))', ...
                'LineWidth',1.5,'Color',c(j,b+k,:));
        else
            lgvar(j,k) = plot(ta,100*squeeze(D(j,k,:)./D_b(j,k))', ...
            'LineWidth',1.5,'Color',c(j,b+k,:));
        end
        lgvar(j,k).DisplayName = '';
        hold on
    end
end
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
hL = legend(reshape(lgvar',[1 w*b]),'location','eastoutside', ...
    'box','off','NumColumns',3,'Units','Inches', ...
    'Position',[5.75 1 .25 .5],'FontSize',1);
hL.ItemTokenSize = [10,20];


set(ax,'FontSize',fs_tick)
set(lab,'FontSize',fs_lab)

for i = 1:length(ax)
    set(ax(i),'Units','Inches','Position', ...
        [xoff+(rem(i-1,3)*(xlength+xmarg)) ...
        yoff+floor((length(ax)-i)/3)*(ymarg+ylength) xlength ylength])
end

if printfig
    print(sensfig,['~/Dropbox (MREL)/Research/WAMP-MDP/' ...
        'paper_figures/sensfig'],'-dpng','-r600')
end
        
        
        
% %ETA: average power
% ax(1) = subaxis(2,4,1);
% for j = 1:w
%     for k = 1:b
%         p_eta(j,k) = plot(ta_eta,squeeze(O_eta(j,k,:))','LineWidth',1.5);
%         p_eta(j,k).DisplayName = [num2str(wecs(j)) ...
%             ' m WEC, ' num2str(round(batts(k)/1000,1)) ' kWh batt'];
%         p_eta(j,k).Color = csm(j,b+k,:);
%         hold on
%     end
% end
% lab(1) = ylabel({'Average','Power','[W]'}, ...
%     'Rotation',0,'Units','normalized','VerticalAlignment','middle');
% ylpos = get(lab(1),'Position');
% set(lab(1),'Position',[ylhpos ylpos(2) ylpos(3)])
% xlim([min(ta_eta) max(ta_eta)])
% set(gca,'XTickLabel',[])
% title({'Electrical','Efficiency (\eta)',''},'FontWeight','normal')
% grid on
% %ETA: normalized
% ax(5) = subaxis(2,4,5);
% for j = 1:w
%     for k = 1:b
%         pn_eta(j,k) = plot(ta_eta,100.*(squeeze(O_eta(j,k,:))./B(j,k))', ...
%                 'LineWidth',1.5);
%         pn_eta(j,k).Color = csm(j,b+k,:);
%         hold on
%     end
% end
% lab(2) = ylabel({'Change','in Average','Power','from','Baseline','[%]'}, ...
%     'Rotation',0,'Units','normalized','VerticalAlignment','middle');
% ylpos = get(lab(2),'Position');
% set(lab(2),'Position',[ylhpos ylpos(2) ylpos(3)])
% yticks([75 100 125 150])
% xlabel('[\sim]')
% ylim([70 165])
% xlim([min(ta_eta) max(ta_eta)])
% grid on
% %WHL: average power
% ax(2) = subaxis(2,4,2);
% for j = 1:w
%     for k = 1:b
%         p_whl(j,k) = plot(ta_whl,squeeze(O_whl(j,k,:))','LineWidth',1.5);
%         p_whl(j,k).Color = csm(j,b+k,:);
%         hold on
%     end
% end
% xlim([min(ta_whl) max(ta_whl)])
% xticks([min(ta_whl) 5 10 max(ta_whl)]);
% xt_whl = get(gca,'XTick');
% set(gca,'XTickLabel',[])
% title({'Hotel','Load ({\ith})',''},'FontWeight','normal')
% grid on
% %WHL: normalized
% ax(6) = subaxis(2,4,6);
% for j = 1:w
%     for k = 1:b
%         pn_whl(j,k) = plot(ta_whl,100.*(squeeze(O_whl(j,k,:))./B(j,k))', ...
%                 'LineWidth',1.5);
%         pn_whl(j,k).Color = csm(j,b+k,:);
%         hold on
%     end
% end
% ylim([83 125])
% yticks([90 100 110 120])
% xlabel('[%]')
% xlim([min(ta_whl) max(ta_whl)])
% xticks(xt_whl)
% grid on
% %SLT: average power
% ax(3) = subaxis(2,4,3);
% for j = 1:w
%     for k = 1:b
%         p_slt(j,k) = plot(ta_slt,squeeze(O_slt(j,k,:))','LineWidth',1.5);
%         p_slt(j,k).Color = csm(j,b+k,:);
%         hold on
%     end
% end
% xlim([min(ta_slt) max(ta_slt)])
% xticks([min(ta_slt) 50 100 max(ta_slt)]);
% xt_slt = get(gca,'XTick');
% set(gca,'XTickLabel',[])
% title({'Stage','Limit (\itT)',''},'FontWeight','normal')
% grid on
% %SLT: normalized
% ax(7) = subaxis(2,4,7);
% for j = 1:w
%     for k = 1:b
%         pn_slt(j,k) = plot(ta_slt,100.*(squeeze(O_slt(j,k,:))./B(j,k))', ...
%                 'LineWidth',1.5);
%         pn_slt(j,k).Color = csm(j,b+k,:);
%         hold on
%     end
% end
% ylim([-inf 100.09])
% yticks([99.95 100 100.05])
% xlabel('[hours]')
% xlim([min(ta_slt) max(ta_slt)])
% xticks(xt_slt)
% grid on
% %TBS: average power
% ax(4) = subaxis(2,4,4);
% for j = 1:w
%     for k = 1:b
%         p_tbs(j,k) = plot(ta_tbs,squeeze(O_tbs(j,k,:))','LineWidth',1.5);
%         p_tbs(j,k).Color = csm(j,b+k,:);
%         hold on
%     end
% end
% xlim([min(ta_tbs) max(ta_tbs)])
% xticks([min(ta_tbs) 10 20 max(ta_tbs)]);
% xt_tbs = get(gca,'XTick');
% set(gca,'XTickLabel',[])
% title({'Time Between','Stages (\Delta\itt)',''},'FontWeight','normal')
% grid on
% %TBS: normalized
% ax(8) = subaxis(2,4,8);
% for j = 1:w
%     for k = 1:b
%         pn_tbs(j,k) = plot(ta_tbs,100.*(squeeze(O_tbs(j,k,:))./B(j,k))', ...
%                 'LineWidth',1.5);
%         pn_tbs(j,k).Color = csm(j,b+k,:);
%         hold on
%     end
% end
% ylim([35 105])
% xlabel('[hours]')
% xlim([min(ta_tbs) max(ta_tbs)])
% xticks(xt_tbs)
% grid on





