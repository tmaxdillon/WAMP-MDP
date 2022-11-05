function [] = visPySsmComp(var,n,s)

addpath(genpath('~/Dropbox (MREL)/MATLAB/Helper'))
data_path = ['~/Dropbox (MREL)/MATLAB/WAMP-MDP/output_data/'];
bbb = load([data_path 'bbb.mat']);
w = 3;
b = 9;
f_mx = zeros(w,b,10);
f_av = zeros(w,b,10);
b_av = zeros(w,b);
b_mx = zeros(w,b);
for i = 1:10
    temp = load([data_path var '_' num2str(i) '.mat']);
    for j = 1:w
        for k = 1:b
            p = temp.([var '_' num2str(i)])(j,k).output.power_avg;
            [i_av,~,~,~,~,~,i_mx] =  ...
                calcIntermit(temp.([var '_' ...
                num2str(i)])(j+1,k).output.a_act_sim,99,1);
            f_av(j,k,i) = p/i_av;
            f_mx(j,k,i) = p/i_mx;
            if i == 1 %populate baseline matrix
                p = bbb.bbb(j,k).output.power_avg;
                [i_av,~,~,~,~,~,i_mx] =  ...
                    calcIntermit(bbb.bbb(j+1,k).output.a_act_sim,99,1);
                b_av(j,k) = p/i_av;
                b_mx(j,k) = p/i_mx;
                ta = temp.([var '_' num2str(i)])(j,k).output.tuning_array;
            end
        end
    end
end
%ta = temp.([var '_' num2str(i)])(j,k).output.tuning_array;
batts = [2500 5000:5000:40000]; %[Wh]
wecs = [2 3 4 5]; %[m]

if s == 1 %maximum
    F = f_mx;
    B = b_mx;
elseif s == 2 %average
    F = f_av;
    B = b_av;
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
            pl(j,k) = plot(ta,100.*(squeeze(F(j,k,:))./B(j,k))', ...
                'LineWidth',1.5);
        else
            pl(j,k) = plot(ta,squeeze(F(j,k,:))','LineWidth',1.5);
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
if n %normalized
    if s == 1
        ylabel('Change in F_{max} [%]')
    elseif s == 2
        ylabel('Change in F_{avg} [%]')
    end
else
    if s == 1
        ylabel('F_{max} [W/h]')
    elseif s == 2
        ylabel('F_{avg} [W/h]')
    end
end
grid on



