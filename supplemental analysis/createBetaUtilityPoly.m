%created by Trent Dillon in May
%defines battery cost function

clear all close all clc

%% set range of probable battery capacities

E = linspace(0,20,30); %kWh

%% set polynomial coefficients

a = 74;
b = -24;
c = 2;
asym = 0;

%% compute beta

beta = (a+b.*E+c.*E.^2)./(E-asym);

%% exponential method

d = 1.1;
c = 5;
asym = 0;

beta = d.^(E-c)-1;


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

