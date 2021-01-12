%created by Trent Dillon on June 13th 2018
%code analyzes the inherent forecast error in the WETS Forecast Matrix

%last updated July 10 th by Trent Dillon

clear all close all clc
%% load data

load('WETSForecastMatrix')

FM = WETSForecastMatrix.FM_subset;
%Right now I am only using a 2 month subset because the full forecast
%matrix (WETSForecastMatrix.FM) has outages and data gaps (see included
%figure of outages/gaps).

% Data configuration:
% [forecast extent, forecast, parameter]
%
% Parameter = 1: time
% Parameter = 2: Hs
% Parameter = 3: Tp

tester_hs = FM(:,:,2); %for debugging
tester_tp = FM(:,:,3); %for debugging

clear WETSForecastMatrix

%% set wec parameters

%POWER PRODUCTION: gaussian surface based on the following paramters
%see powerFromWEC.m
Hsc = .6;  %height center
Tpc = 8;    %period center
w = 200;    %width of normal dist
r = 2500;   %rated (max) power of device
cw = .2;     %capture width

%% find forecasted arrays

P_a_f = zeros(8,1970);
P_a = zeros(1,1970);
Tp_a_f = zeros(8,1970);
Tp_a = zeros(1,1970);
Hs_a_f = zeros(8,1970);
Hs_a = zeros(1,1970);

for i = 2:size(FM,2)
    %find timestamps where real data matches forecast data at each time
    %step i 
    pts = find(FM(1,i,1) == FM(2:end,:,1));
    Hs_a(i) = FM(1,i,2); %actuals
    Tp_a(i) = FM(1,i,3); %actuals
    P_a(i) = powerFromWEC(Hs_a(i),Tp_a(i),Hsc,Tpc,w,r,cw); %actuals
    intervals = 1:24:length(pts); %space out timestamps in terms of hours
    for j = 1:length(intervals)
        Hs_a_f(j,i) = FM(intervals(j)+1,i-intervals(j),2);
        Tp_a_f(j,i) = FM(intervals(j)+1,i-intervals(j),3);
        P_a_f(j,i) = powerFromWEC(Hs_a_f(j,i),Tp_a_f(j,i), ...
            Hsc,Tpc,w,r,cw);
    end
end

P_a_f(P_a_f==0) = nan;
Hs_a_f(Hs_a_f==0) = nan;
Tp_a_f(Tp_a_f==0) = nan;
P_errormatrix = P_a_f - P_a;
Tp_errormatrix = Tp_a_f - Tp_a;
Hs_errormatrix = Hs_a_f - Hs_a;

clear i intervals j pts

%% plot

time_surf = repmat(FM(1,:,1),[size(P_errormatrix,1),1]);
extent_surf = repmat(1:size(P_errormatrix,1),[size(P_errormatrix,2),1])';

figure
%datetime(time_surf,'ConvertFrom','datenum')
s1 = surf(datetime(time_surf,'ConvertFrom','datenum'),extent_surf,P_errormatrix);
set(s1, 'edgecolor','none')
colormap parula
title('Power Error')
ylabel('Forecast Extent [days]')
xlabel('Forecast Time')
zlabel('Overestimate [W]')
grid on

figure
%datetime(time_surf,'ConvertFrom','datenum')
s2 = surf(datetime(time_surf,'ConvertFrom','datenum'),extent_surf,Hs_errormatrix);
set(s2, 'edgecolor','none')
colormap parula
title('Hs Error')
ylabel('Forecast Extent [days]')
xlabel('Forecast Time')
zlabel('Overestimate [m]')
grid on

figure
%datetime(time_surf,'ConvertFrom','datenum')
s3 = surf(datetime(time_surf,'ConvertFrom','datenum'),extent_surf,Tp_errormatrix);
set(s3, 'edgecolor','none')
colormap parula
title('Tp Error')
ylabel('Forecast Extent [days]')
xlabel('Forecast Time')
zlabel('Overestimate [s]')
grid on

clear s1 s2 s3

%% integrate energy: "how accurate was this actual value?"

count = zeros(1,size(P_a_f,2)-1);
E_a_f = zeros(1,size(P_a_f,2)-8);
E_a   = zeros(1,size(P_a_f,2)-8);

%find extent of available forecast information
for i = 1:size(P_a_f,2)-1
    %find how many forecasts there are for each time step in the FM
    %(starting at 2 because t = 1 has zero forecasts)
    count(i) = nnz(~isnan(P_a_f(:,i+1)));
end
%integrate forecasted power to find forecasted energy
for i = 8:size(P_a_f,2)-1
    E_a_f(i) = trapz(1:24:24*(count(i)+1),[P_a(i+1) ; P_a_f(1:count(i),i+1)]);
    E_a(i) = trapz(1:24:24*(count(i)+1),P_a(i+1-count(i):i+1));
end

E_error = E_a_f - E_a;

clear i j count

%% plot

figure
subplot(2,1,1)
plot(datetime(FM(1,8:end-1,1),'ConvertFrom','datenum'),E_a(8:end)/1000, ...
    'g','LineWidth',2.5)
hold on
plot(datetime(FM(1,8:end-1,1),'ConvertFrom','datenum'),E_a_f(8:end)/1000, ...
    'b','LineWidth',2.5)
xlabel('Time')
ylabel('Overestimate [kWh]')
title('Energy Production')
legend('Actual','Forecasted')
grid on
subplot(2,1,2)
plot(datetime(FM(1,8:end-1,1),'ConvertFrom','datenum'),E_error(8:end)/1000, ... 
    'k','LineWidth',2.5)
xlabel('Time')
ylabel('Overestimate [kWh]')
grid on

%% integrate energy: "how accurate is this forecast going to actually 
%end up being?"

intervals = 1:24:(size(FM,2)-(size(FM,1)-1));
E_a_2 = zeros(1,length(intervals));
E_a_f_2 = zeros(1,length(intervals));

for i = 1:length(intervals)
    pf = zeros(1,length(FM(:,intervals(i),2))-1);
    pa = zeros(1,length(FM(:,intervals(i),2))-1);
    for j = 1:length(pf)
        pf(j) = powerFromWEC(FM(j,intervals(i),2),FM(j,intervals(i),3) ... 
            ,Hsc,Tpc,w,r,cw);
        pa(j) = powerFromWEC(FM(1,intervals(i)+j,2), ... 
            FM(1,intervals(i)+j,3),Hsc,Tpc,w,r,cw);
    end
    E_a_f_2(i) = trapz(1:length(pf),pf);
    E_a_2(i) = trapz(1:length(pa),pa);
end
    
E_error_2 = E_a_f_2 - E_a_2;

clear i j pf pa

%% plot

figure
subplot(2,1,1)
plot(datetime(FM(1,intervals,1),'ConvertFrom','datenum'),E_a_2/1000, ...
    'g','LineWidth',2.5)
hold on
plot(datetime(FM(1,intervals,1),'ConvertFrom','datenum'),E_a_f_2/1000, ...
    'b','LineWidth',2.5)
xlabel('Time')
ylabel('7.5 Day Energy [kWh]')
title('Energy Production')
legend('Actual','Forecasted')
ylim([0 max([E_a_2 E_a_f_2])/1000+100])
grid on
subplot(2,1,2)
plot(datetime(FM(1,intervals,1),'ConvertFrom','datenum'),E_error_2/1000, ... 
    'k','LineWidth',2.5)
xlabel('Time')
ylabel('Overestimate [kWh]')
grid on
    