%clearvars -except mdpsim pbosim slosim sl2sim
close all
set(0,'defaulttextinterpreter','tex')
%set(0,'defaulttextinterpreter','latex')
set(0,'DefaultTextFontname', 'cmr10')
set(0,'DefaultAxesFontName', 'cmr10')
addpath(genpath('~/MREL Dropbox/Trent Dillon/MATLAB/Helper'))
output_path = ['~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/' ...
    'output_data/'];

if ~exist('mdpsim','var') || ~exist('pbosim','var')
    load([ output_path 'mdpsim']);
    load([ output_path 'pbosim']);
    mdpsim = mdpsim(2:end,2:end);
    pbosim = pbosim(2:end,2:end);
end

x = mdpsim(1,1).sim.tuning_array1(2:end)./1000;
B = mdpsim(1,1).sim.tuning_array2(2:end);
nw = length(B);
y = 10; %[years] of operation for bat deg

%find deltas
if ~exist('deltas','var')
    deltas = zeros(size(mdpsim,2),size(mdpsim,1),3);
    for w = 1:size(mdpsim,1) %across all wcd
        for e = 1:size(mdpsim,2) %across all emx
            [deltas(e,w,1)] = getPower(mdpsim(w,e)) - ...
                getPower(pbosim(w,e)); %power delta
            [~,~,~,~,~,~,i_m] = ...
                calcIntermit(mdpsim(w,e).output.a_sim,99,1); %mdp int
            [~,~,~,~,~,~,i_p] = ...
                calcIntermit(pbosim(w,e).output.a_sim,99,1); %pbo int
            deltas(e,w,2) = i_m - i_p;
            [deltas(e,w,3)] = calcBatDeg(mdpsim(w,e),y,x(e)*1000)*100 ...
                -calcBatDeg(pbosim(w,e),y,x(e)*1000)*100;
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
fs = 10;
fsl = 8; %legend font size
ms = 4;
lw = .8;
xoff = 1.85; %[in]
yoff = .6; %[in]
xdist = 4.5; %[in]
ydist = .9; %[in]
ymarg = 0.25; %[in]

ylab{1} = {'Average','Power','Delta','','P_{mdp} - P_{pbo} [W]'};
ylab{2} = {'Longest','Intermittency','Delta','','I_{mdp} - I_{pbo} [h]'};
    ylab{3} = {'Capacity','Fade','Delta','','CF_{mdp} - CF_{pbo} [%]'};

post_comp = figure;
set(gcf,'Units','inches','Color','w')
set(gcf, 'Position', [1, 1, 6.5, 4])
ax = zeros(3,1);
%AVG POWER DELTA
for m = 1:3 %across all performance metrics
    ax(m) = subplot(3,1,m);
    for w = 1:nw %accross all wec sizes
        hold on
        s1p(w) = plot(x,deltas(:,w,m),'-o','MarkerFaceColor',col(w,:), ...
            'MarkerSize',ms,'MarkerEdgeColor',col(w,:), ...
            'Color',col(w,:),'LineWidth',lw,'DisplayName', ...
            [num2str(B(w)) ' m WEC']);
    end
    set(gca,'FontSize',10)
    ylabdim = [-.25 .5];
    yl = text(0,0,ylab{m});
    set(yl,'Units','normalized','Position',ylabdim, ...
        'HorizontalAlignment','center','FontSize',fs, ...
        'VerticalAlignment','middle','Rotation',00);
    if m == 1
        legend('show','box','off','location','southeast')
    end
    if m == 3
        xlabdim = [0.5 -.5];
        xlab = 'Battery Storage Capacity [kWh]';
        xl = text(0,0,xlab);
        set(xl,'Units','normalized','Position',xlabdim, ...
            'HorizontalAlignment','center','FontSize',fs, ...
            'Rotation',0);
    end
    hold on
    grid on
end

for m = 1:3
    set(ax(m),'Units','Inches','Position',[xoff ...
        (3-m)*(ydist+ymarg)+yoff xdist ydist])
end
    


