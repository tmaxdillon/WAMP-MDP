%created by Trent Dillon in July
%defines battery cost function via polynomial

clear all close all clc

%% set range of probable battery capacities

uc = 5000;
n = 2000;
lb = 0.75;
ub = 1.75;

E = linspace(0,uc,n); %Wh
Emid = E(round(n/2));

%% run piecewise

a = 50;
b = 1.01;

beta = zeros(size(E));
for i = 1:length(E)
    if E(i) < lb*Emid
        beta(i) = a*((lb*Emid)/E(i) - 1);
    elseif E(i) > ub*Emid
        beta(i) = b^(E(i) - (ub*Emid)) - 1;
    else
        beta(i) = 0;
    end
end


%% plot

figure
plot(E,beta,'--ro',...
    'LineWidth',2.5,...
    'MarkerSize',15,...
    'MarkerEdgeColor','g',...
    'MarkerFaceColor',[0,0,0])
ylim([0,inf])
grid on
set(gca,'FontSize',20)
xlabel('Energy In Battery Bank: E [Wh]','Fontsize',20)
ylabel('Battery Cost: Beta [~]','Fontsize',20)
legend('Discretized Values')

