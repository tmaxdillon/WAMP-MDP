function [sensfig] = visPySsm(var,met,n,s)

%var - sensitivity variable
%met - performance metric
%n - normalization toggle
%s - intermittency statistic 1: maximum, 2: mean

addpath(genpath('~/Dropbox (MREL)/MATLAB/Helper'))
data_path = ['~/Dropbox (MREL)/MATLAB/WAMP-MDP/output_data/pyssm_out/'];
bbb = load([data_path 'bbb.mat']);
w = 3;
b = 9;
p = zeros(w,b,10);
i_mx = zeros(w,b,10);
i_av = zeros(w,b,10);
f_mx = zeros(w,b,10);
f_av = zeros(w,b,10);
t_r = zeros(w,b,10);
b_p = zeros(w,b);
b_i_mx = zeros(w,b);
b_i_av = zeros(w,b);
b_f_av = zeros(w,b);
b_f_mx = zeros(w,b);
b_t_r = zeros(w,b,10);
if isequal(var,'tpe')
    temp = load([data_path var '_1.mat']);
    tp = temp.([var '_1'])(1,1).output.tuning_array;
else
    tp = ones(1,10).*bbb.bbb(1,1).mdp.tp;
end
for i = 1:10
    temp = load([data_path var '_' num2str(i) '.mat']);    
    for j = 1:w
        for k = 1:b
            temp_output = temp.([var '_' num2str(i)])(j+1,k).output;
%             p(j,k,i) = temp.([var '_' num2str(i)])(j+1,k).output.power_avg;
%             p(j,k,i) = 
%             [i_av(j,k,i),~,~,~,~,~,i_mx(j,k,i)] =  ...
%                 calcIntermit(temp.([var '_' ...
%                 num2str(i)])(j+1,k).output.a_act_sim,99,1);
            p(j,k,i) = temp_output.power_avg;
            [i_av(j,k,i),~,~,~,~,~,i_mx(j,k,i)] =  ...
                calcIntermit(temp_output.a_act_sim,99,1);
            f_av(j,k,i) = p(j,k,i)/i_av(j,k,i);
            f_mx(j,k,i) = p(j,k,i)/i_mx(j,k,i);
            t_r(j,k,i) = calcThetaRate(temp_output.a_act_sim, ...
                temp_output.FM_P_1(:,1),tp(i));
            if i == 1 %populate baseline matrix
                bbb_output = bbb.bbb(j+1,k).output;
%                 b_p(j,k) = bbb.bbb(j+1,k).output.power_avg;
%                 [b_i_av(j,k),~,~,~,~,~,b_i_mx(j,k)] =  ...
%                     calcIntermit(bbb.bbb(j+1,k).output.a_act_sim,99,1);
                b_p(j,k) = bbb_output.power_avg;
                [b_i_av(j,k),~,~,~,~,~,b_i_mx(j,k)] =  ...
                    calcIntermit(bbb_output.a_act_sim,99,1);
                b_f_av(j,k) = b_p(j,k)/b_i_av(j,k,i);
                b_f_mx(j,k) = b_p(j,k)/b_i_mx(j,k,i);
                b_t_r(j,k,i) = calcThetaRate(bbb_output.a_act_sim, ...
                    bbb_output.FM_P_1(:,1),bbb.bbb(j+1,k).mdp.tp);
                ta = temp.([var '_' num2str(i)])(j,k).output.tuning_array;
            end
        end
    end
end
ta = temp.([var '_' num2str(i)])(j,k).output.tuning_array;
batts = [2500 5000:5000:40000]; %[Wh]
wecs = [2 3 4 5]; %[m]

%set metric
if isequal(met,'pow')
    V = p;
    B = b_p;
    if n
        ylab = {'Change in P_{avg} [%]'};
        %ylim([-inf inf])
    else
        ylab = {'Average Power [W]'};
        %ylim([0 625])
    end
elseif isequal(met,'int')
    if s == 1 %maximum
        V = i_mx;
        B = b_i_mx;
    elseif s == 2 %average
        V = i_av;
        B = b_i_av;
    end
    if n
        if s == 1
            ylab = {'Change in I_{max} [%]'};
        elseif s == 2
            ylab = {'Change in I_{avg} [%]'};
        end
    else
        if s == 1
            ylab = {'I_{max} [h]'};
        elseif s == 2
            ylab = {'I_{avg} [h]'};
        end
    end
elseif isequal(met,'com')
    if s == 1 %maximum
        V = f_mx;
        B = b_f_mx;
    elseif s == 2 %average
        V = f_av;
        B = b_f_av;
    end
    if n %normalized
        if s == 1
            ylab = {'Change in F_{max} [%]'};
        elseif s == 2
            ylab = {'Change in F_{avg} [%]'};
        end
    else
        if s == 1
            ylab = {'F_{max} [W/h]'};
        elseif s == 2
            ylab = {'F_{avg} [W/h]'};
        end
    end
elseif isequal(met,'tra')
    V = t_r;
    B = b_t_r;
    if n %normalized
        ylab = {'Change in Theta Rate [%]'};
    else
        ylab = {'Theta Rate [~]'};
    end
end

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
elseif isequal(var,'tam') %theta amplitude
    xlab = 'MDP: Theta Amplitude';
elseif isequal(var,'tpe') %theta period
    xlab = 'MDP: Theta Period [h]';
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
        if n
            pl(j,k) = plot(ta,100.*(squeeze(V(j,k,:))./B(j,k))', ...
                'LineWidth',1.5);
        else
            pl(j,k) = plot(ta,squeeze(V(j,k,:))','LineWidth',1.5);
        end
        pl(j,k).DisplayName = [num2str(wecs(j)) ...
            ' m WEC, ' num2str(round(batts(k)/1000,0)) ' kWh batt'];
        pl(j,k).Color = c(j,b+k,:);
        hold on
    end
end
legend(reshape(pl',[1 w*b]),'Location','southoutside','NumColumns',1)
set(gca,'Units','inches','Position',[0.75 7 2 1.8])
xlabel(xlab)
ylabel(ylab)
grid on



