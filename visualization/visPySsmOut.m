function [] = visPySsmOut(var)

addpath(genpath('~/Dropbox (MREL)/MATLAB/Helper'))
w = 4;
b = 9;
O = zeros(w,b,10);
for i = 1:10
    temp = load(['~/Dropbox (MREL)/MATLAB/WAMP-MDP/output_data/pyssm_out/' ...
        var '_' num2str(i) '.mat']);
    for j = 1:w
        for k = 1:b
            O(j,k,i) = temp.([var '_' num2str(i)])(j,k).output.power_avg;
        end
    end
end
ta = temp.([var '_' num2str(i)])(j,k).output.tuning_array;
batts = [2500 5000:5000:40000]; %[Wh]
wecs = [2 3 4 5]; %[m]

%POWER SYSTEM PARAMETERS
if isequal(var,'eta') %conversion and transmission efficiency
    xlab = 'POW: C&T Efficiency';
elseif isequal(var,'whl') %wec hotel load
    xlab = 'POW: Hotel Load [%]';
elseif isequal(var,'rhs') %rated significant wave height
    xlab = 'POW: Rated Hs [m]';
elseif isequal(var,'rtp') %rated peak period
    xlab = 'POW: Rated Tp [s]';
elseif isequal(var,'sdr') %self discharge rate
    xlab = 'POW: Self Discharge [%]';
elseif isequal(var,'est') %battery starting fraction
    xlab = 'POW: Battery Start Soc [%]';
%MARKOV DECISION PROCESS PARAMETERS
elseif isequal(var,'slt') %stage limit
    xlab = 'MDP: Stage Limit [h]';
elseif isequal(var,'tbs') %time between stages
    xlab = 'MDP: Time Between Stages [h]';
elseif isequal(var,'ebs') %energy between states
    xlab = 'MDP: Energy Between States [Wh]';
elseif isequal(var,'dfr') %discount factor
    xlab = 'MDP: Discount Factor';
elseif isequal(var,'sub') %spin up buffer
    xlab = 'MDP: Spin Up Buffer';
end

%set colors
c(1,:,:) = brewermap(b*2,'reds');
c(2,:,:) = brewermap(b*2,'greens');
c(3,:,:) = brewermap(b*2,'blues');
c(4,:,:) = brewermap(b*2,'purples');

sensfig = figure;
set(gcf,'Units','inches','Position',[0 5 3 9],'Color','w')
for j = 1:w
    for k = 1:b
        p(j,k) = plot(ta,squeeze(O(j,k,:))','LineWidth',1.5);
        p(j,k).DisplayName = [num2str(wecs(j)) ...
            ' m WEC, ' num2str(round(batts(k)/1000,0)) ' kWh batt'];
        p(j,k).Color = c(j,b+k,:);
        hold on
    end
end
legend(reshape(p',[1 36]),'Location','southoutside','NumColumns',1)
set(gca,'Units','inches','Position',[0.75 7 2 1.8])
xlabel(xlab)
ylabel('Average Power [W]')
grid on
ylim([0 625])


