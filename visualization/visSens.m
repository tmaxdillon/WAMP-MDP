function [] = visSens(sensStruct,par)

n = length(sensStruct);
ta = zeros(n,1);
power_avg = zeros(n,1);
%set figure parameters

%POWER SYSTEM PARAMETERS
if isequal(par,'eta') %conversion and transmission efficiency
    ta = linspace(0.4,1,n);
    xlab = 'C/T Efficiency';
elseif isequal(par,'whl') %wec hotel load
    ta = linspace(0,.18,n);
    xlab = 'Hotel Load [%]';
elseif isequal(par,'rhs') %rated significant wave height
    ta = linspace(0.5,5,n);
    xlab = 'Rated Hs [m]';
elseif isequal(par,'rtp') %rated peak period
    ta = linspace(5,14,n);
    xlab = 'Rated Tp [s]';
elseif isequal(par,'sdr') %self discharge rate
    ta = linspace(0,9,n);
    xlab = 'Self Discharge [%]';
    %MARKOV DECISION PROCESS PARAMETERS
elseif isequal(par,'slt') %stage limit
    ta = linspace(18,180,n);
    xlab = 'Stage Limit [h]';
elseif isequal(par,'tbs') %time between stages
    ta = linspace(1,19,n);
    xlab = 'Time Between Stages [h]';
elseif isequal(par,'ebs') %energy between states
    ta = linspace(17.5,40,n);
    xlab = 'Energy Between States [Wh]';
elseif isequal(par,'dfr') %discount factor
    ta = linspace(.5,.99,n);
    xlab = 'Discount Factor';
elseif isequal(par,'sub') %spin up buffer
    ta = linspace(0,9,n);
    xlab = 'Spin Up Buffer';
end

for i = 1:n
    power_avg(i) = sensStruct(i).output.power_avg; 
end

figure
set(gcf,'Units','inches','Position',[0, 5, 3, 2])
plot(ta,power_avg,'r')
hold on
%yline(600,'--k','Max Draw','LabelHorizontalAlignment','left'); 
xlabel(xlab)
ylabel('Average Power [W]')
%ylim([0 625])
grid on

end

