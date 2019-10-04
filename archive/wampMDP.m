% created by Trent Dillon on May 30th 2018
% code simulates performance of the "WAMP" under a markov decision process
% using forecast-based control

clear all, close all, clc
%% STEP 1: Load Data

load('WETSwaves_2017.mat'); %wave data
wavedata = WETSwaves_2017;
%load(WETSforecasts_2017) %wave forecasts 
load('powermatrix_normaldist.mat'); %power matrix
PM = powermatrix;

clear WETSwaves_2017

%% STEP 2: Create Forecast Matrix

fe = 7.5*48; %forecast extent in n (number of forecasts available)
FM = zeros(fe,length(wavedata)-fe,3); %initialize forecast matrix

for i=1:length(FM)
    FM(:,i,1) = wavedata(i:fe+i-1,1); %time
    FM(:,i,2) = wavedata(i:fe+i-1,2); %Hs
    FM(:,i,3) = wavedata(i:fe+i-1,3); %Te
end

clear i

%% STEP 3: Add Artificial Forecast Error

FM_artificial = FM; %initialize
vm = 1; %variance multiplier (applied linearly toward furthest forecast)

tic
for k=1:fe:length(FM)  %over each forecast
    var_Hs = std(FM(:,k,2));
    var_Te = std(FM(:,k,3));
    for i=1:fe %over each stage
%         mean_Hs = mean(FM_artificial(1:i,k,2));
%         mean_Te = mean(FM_artificial(1:i,k,3));
        FM_artificial(i,k,2) = normrnd(FM(i,k,2),(i/fe)*vm*var_Hs); %Hs
        FM_artificial(i,k,3) = normrnd(FM(i,k,3),(i/fe)*vm*var_Te); %Te
    end
end
toc

%% STEP 4: Plot Sample "Forecast" versus Real Data

k = 503; %forecast number


figure
subplot(2,1,1)
plot(datetime(FM_artificial(:,k,1),'ConvertFrom','datenum'), ... 
    FM_artificial(:,k,2),'m','LineWidth',1.8)
grid on
hold on
plot(datetime(FM(:,k,1),'ConvertFrom','datenum'), ... 
    FM(:,k,2),'r','LineWidth',1.8)
xtickformat('MM-dd, HH:mm')
ylabel('Hs [m]','Fontsize',14)
legend('Artificial Forecast','Real Data')

subplot(2,1,2)
plot(datetime(FM_artificial(:,k,1),'ConvertFrom','datenum'), ... 
    FM_artificial(:,k,3),'c','LineWidth',1.8)
grid on
hold on
plot(datetime(FM(:,k,1),'ConvertFrom','datenum'), ... 
    FM(:,k,3),'b','LineWidth',1.8)
xtickformat('MM-dd, HH:mm')
ylabel('Te [m]','Fontsize',14)
legend('Artificial Forecast','Real Data')


    
    
    
    
    