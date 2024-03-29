close all
clearvars -except O_eta O_whl O_slt O_tbs ta_eta ta_whl ta_slt ta_tbs B

%% 

set(0,'defaulttextinterpreter','tex')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
data_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
    'output_data/pyssm_out/'];

printfig = true; %print figure

%ITALICIZE DELTA T

bbb = load([data_path 'bbb.mat']);
w = 4;
b = 9;
if ~exist('O_eta','var') || ~exist('O_whl','var') || ...
        ~exist('O_slt','var') || ~exist('O_tbs','var') || ...
        ~exist('ta_eta','var') || ~exist('ta_whl','var') || ...
        ~exist('ta_slt','var') || ~exist('ta_tbs','var') || ...
        ~exist('B','var')
    O_eta = zeros(w,b,10);
    O_whl = zeros(w,b,10);
    O_slt = zeros(w,b,10);
    O_tbs = zeros(w,b,10);
    B = zeros(w,b);
    for i = 1:10
        temp_eta = load([data_path 'eta_' num2str(i) '.mat']);
        temp_whl = load([data_path 'whl_' num2str(i) '.mat']);
        temp_slt = load([data_path 'slt_' num2str(i) '.mat']);
        temp_tbs = load([data_path 'tbs_' num2str(i) '.mat']);
        for j = 1:w
            for k = 1:b
                O_eta(j,k,i) = temp_eta.(['eta_' ...
                    num2str(i)])(j,k).output.power_avg;
                O_whl(j,k,i) = temp_whl.(['whl_' ...
                    num2str(i)])(j,k).output.power_avg;
                O_slt(j,k,i) = temp_slt.(['slt_' ...
                    num2str(i)])(j,k).output.power_avg;
                O_tbs(j,k,i) = temp_tbs.(['tbs_' ...
                    num2str(i)])(j,k).output.power_avg;
                if i == 1 %populate baseline matrix
                    B(j,k) = bbb.bbb(j,k).output.power_avg;
                end
            end
        end
    end
    ta_eta = temp_eta.(['eta_' num2str(i)])(j,k).output.tuning_array;
    ta_whl = 100.*temp_whl.(['whl_' num2str(i)])(j,k).output.tuning_array;
    ta_slt = temp_slt.(['slt_' num2str(i)])(j,k).output.tuning_array;
    ta_tbs = temp_tbs.(['tbs_' num2str(i)])(j,k).output.tuning_array;
end
batts = [2500 5000:5000:40000]; %[Wh]
wecs = [2 3 4 5]; %[m]

%set colors
csm(1,:,:) = brewermap(b*2,'blues');
csm(2,:,:) = brewermap(b*2,'reds');
csm(3,:,:) = brewermap(b*2,'greens');
csm(4,:,:) = brewermap(b*2,'purples');

%figure settings
xoff = 1.1;
yoff = 1.4;
xmarg = .4;
ymarg = 0.05;
xlength = 1;
ylength = .9;
ylhpos = -.65;
fs_tick = 8;
fs_lab = 10;

sensfig = figure;
set(gcf,'Units','inches','Position',[1 1 6.5 3.75],'Color','w')
%ETA: average power
ax(1) = subaxis(2,4,1);
for j = 1:w
    for k = 1:b
        p_eta(j,k) = plot(ta_eta,squeeze(O_eta(j,k,:))','LineWidth',1.5);
        p_eta(j,k).DisplayName = [num2str(wecs(j)) ...
            ' m WEC, ' num2str(round(batts(k)/1000,1)) ' kWh batt'];
        p_eta(j,k).Color = csm(j,b+k,:);
        hold on
    end
end
lab(1) = ylabel({'Average','Power','[W]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(lab(1),'Position');
set(lab(1),'Position',[ylhpos ylpos(2) ylpos(3)])
xlim([min(ta_eta) max(ta_eta)])
set(gca,'XTickLabel',[])
title({'Electrical','Efficiency (\eta)',''},'FontWeight','normal')
grid on
%ETA: normalized
ax(5) = subaxis(2,4,5);
for j = 1:w
    for k = 1:b
        pn_eta(j,k) = plot(ta_eta,100.*(squeeze(O_eta(j,k,:))./B(j,k))', ...
                'LineWidth',1.5);
        pn_eta(j,k).Color = csm(j,b+k,:);
        hold on
    end
end
lab(2) = ylabel({'Change','in Average','Power','from','Baseline','[%]'}, ...
    'Rotation',0,'Units','normalized','VerticalAlignment','middle');
ylpos = get(lab(2),'Position');
set(lab(2),'Position',[ylhpos ylpos(2) ylpos(3)])
yticks([75 100 125 150])
xlabel('[\sim]')
ylim([70 165])
xlim([min(ta_eta) max(ta_eta)])
grid on
%WHL: average power
ax(2) = subaxis(2,4,2);
for j = 1:w
    for k = 1:b
        p_whl(j,k) = plot(ta_whl,squeeze(O_whl(j,k,:))','LineWidth',1.5);
        p_whl(j,k).Color = csm(j,b+k,:);
        hold on
    end
end
xlim([min(ta_whl) max(ta_whl)])
xticks([min(ta_whl) 5 10 max(ta_whl)]);
xt_whl = get(gca,'XTick');
set(gca,'XTickLabel',[])
title({'Hotel','Load ({\ith})',''},'FontWeight','normal')
grid on
%WHL: normalized
ax(6) = subaxis(2,4,6);
for j = 1:w
    for k = 1:b
        pn_whl(j,k) = plot(ta_whl,100.*(squeeze(O_whl(j,k,:))./B(j,k))', ...
                'LineWidth',1.5);
        pn_whl(j,k).Color = csm(j,b+k,:);
        hold on
    end
end
ylim([83 125])
yticks([90 100 110 120])
xlabel('[%]')
xlim([min(ta_whl) max(ta_whl)])
xticks(xt_whl)
grid on
%SLT: average power
ax(3) = subaxis(2,4,3);
for j = 1:w
    for k = 1:b
        p_slt(j,k) = plot(ta_slt,squeeze(O_slt(j,k,:))','LineWidth',1.5);
        p_slt(j,k).Color = csm(j,b+k,:);
        hold on
    end
end
xlim([min(ta_slt) max(ta_slt)])
xticks([min(ta_slt) 50 100 max(ta_slt)]);
xt_slt = get(gca,'XTick');
set(gca,'XTickLabel',[])
title({'Stage','Limit (\itT)',''},'FontWeight','normal')
grid on
%SLT: normalized
ax(7) = subaxis(2,4,7);
for j = 1:w
    for k = 1:b
        pn_slt(j,k) = plot(ta_slt,100.*(squeeze(O_slt(j,k,:))./B(j,k))', ...
                'LineWidth',1.5);
        pn_slt(j,k).Color = csm(j,b+k,:);
        hold on
    end
end
ylim([-inf 100.09])
yticks([99.95 100 100.05])
xlabel('[hours]')
xlim([min(ta_slt) max(ta_slt)])
xticks(xt_slt)
grid on
%TBS: average power
ax(4) = subaxis(2,4,4);
for j = 1:w
    for k = 1:b
        p_tbs(j,k) = plot(ta_tbs,squeeze(O_tbs(j,k,:))','LineWidth',1.5);
        p_tbs(j,k).Color = csm(j,b+k,:);
        hold on
    end
end
xlim([min(ta_tbs) max(ta_tbs)])
xticks([min(ta_tbs) 10 20 max(ta_tbs)]);
xt_tbs = get(gca,'XTick');
set(gca,'XTickLabel',[])
title({'Time Between','Stages (\Delta\itt)',''},'FontWeight','normal')
grid on
%TBS: normalized
ax(8) = subaxis(2,4,8);
for j = 1:w
    for k = 1:b
        pn_tbs(j,k) = plot(ta_tbs,100.*(squeeze(O_tbs(j,k,:))./B(j,k))', ...
                'LineWidth',1.5);
        pn_tbs(j,k).Color = csm(j,b+k,:);
        hold on
    end
end
ylim([35 105])
xlabel('[hours]')
xlim([min(ta_tbs) max(ta_tbs)])
xticks(xt_tbs)
grid on

set(ax,'FontSize',fs_tick)
set(lab,'FontSize',fs_lab)

for i = 1:length(ax)
    set(ax(i),'Units','Inches','Position', ...
        [xoff+(rem(i-1,4)*(xlength+xmarg)) ...
        yoff+floor((length(ax)-i)/4)*(ymarg+ylength) xlength ylength])
end

lg = legend(reshape(p_eta',[1 36]),'NumColumns',4,'Units','Inches', ...
    'Position',[.65 .125 4*(xlength+xmarg)-xmarg ylength], ...
    'box','off','FontSize',7);

if printfig
    print(sensfig,['~/Dropbox (MREL)/Research/WAMP-MDP/' ...
        'paper_figures/sensfig'],'-dpng','-r600')
end




