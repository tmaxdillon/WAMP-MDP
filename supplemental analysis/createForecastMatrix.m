% created by Trent Dillon on May 30th 2018
% code loads data from cdip buoy and synthesizes with historical forecasts
% to create a 'forecast matrix'
 
clear all, close all, clc

%% set up data path

localpath = '/Users/tmd1502/Dropbox/'; %laptop
%localpath = '\Users\Trent Dillon\Dropbox\'; %sahale
%localpath = 'E:\Users\Trent Dillon\Dropbox\'; %MRElab
datapath = '/Research/Unconfigured Data/WETS/';

%% load data

%forecast
rawforecast = [];
files = dir([localpath datapath 'buoy.51210 forecast/*.table']);
for i=1:length(files)
    file = load([localpath datapath 'buoy.51210 forecast/' files(i).name]);
    forecast_header(i) = file(1,1);
    file = file(2:end,:); %first forecast often seems corrupted/wrong, remove it
    sizes(i) = length(file);
    rawforecast = [rawforecast ; forecast_header(i)*ones(length(file),1) file];
    clear file
end

%wave data
delimiterIn = ' ';
headerlinesIn = 3;
rawdata = importdata([localpath datapath '225 buoy all/data'], ...
    delimiterIn,headerlinesIn);

clear i headerlinesIn delimiterIn sizes localpath datapath files forecast_header

%% reformat data

formatIn_f = 'yyyymmddHH';

tic
%forecast
%[FORECAST,TIME,Hs,Tp]
for i=1:length(rawforecast)
   forecast(i,1) = datenum(num2str(rawforecast(i,1)*100),formatIn_f); %forecast
   forecast(i,2) = datenum(num2str(rawforecast(i,2)*100),formatIn_f); %time
   forecast(i,3) = rawforecast(i,4); %Hs
   forecast(i,4) = rawforecast(i,7); %Tp
end
toc

tic
%wavedata
%[TIME,Hs,Tp]
for i=1:length(rawdata.data)/2
    Y = rawdata.data(i*2,1);
    M = rawdata.data(i*2,2);
    D = rawdata.data(i*2,3);
    H = rawdata.data(i*2,4);
    wavedata(i,1) = datenum(Y,M,D,H,00,00);
    wavedata(i,2) = rawdata.data(i*2,6); %Hs
    wavedata(i,3) = rawdata.data(i*2,7); %Tp
end
toc
      
clear Y M D H formatIn_f i rawforecast rawdata

%% create forecast matrix -- set time

fe = 7.5*24; %forecast extent
nr = 365*24-fe; %number of runs

%initialize forecast matrix
FM = zeros(fe+1,nr,3);
%[STAGE,RUN,PARAMETER]
%[:,:,1] = time
%[:,:,2] = Hs
%[:,:,3] = Tp

%set time
yearStart = 2017;
monthStart = 01;
dayStart = 01;
hourStart = 21;
for i=1:size(FM,1)
    for j=1:size(FM,2)
        FM(i,j,1) = datenum(yearStart,monthStart,dayStart,hourStart+i+j-1,00,00);
    end
end

tester_t = FM(:,:,1); %for deugging

clear yearStart monthStart dayStart hourStart i j fe nr pt

%% create forecast matrix -- set parameters

%set Hs and Tp
tic
for j=1:size(FM,2)
     for i = 1:size(FM,1)
        %use real data
        if i == 1
            pt = find(FM(i,j,1) == wavedata(:,1));
            if isempty(pt)
                FM(i,j,2) = nan; %Hs
                FM(i,j,3) = nan; %Tp
            else
                FM(i,j,2) = wavedata(pt,2); %Hs
                FM(i,j,3) = wavedata(pt,3); %Tp
            end
        %use forecasted data
        elseif i == 2
            array = forecast(:,1)-FM(i,j,1); %array for finding forecast
            array(array>=0) = nan; %set future forecasts to nan
            array = abs(array); %abs to find closest forecast
            mindiff = nanmin(array);
            fpts = find(array == mindiff);
            %[~,fpts] = nanmin(array); %forecast point is smallest diff
            spf = forecast(fpts,:); %specific forecast
            dpt = find(FM(i,j,1) == spf(:,2)); %find matching forecast time
            %outage in dataset or missing value
            if isempty(dpt)
                FM(i,j,2) = nan; %Hs
                FM(i,j,3) = nan; %Tp
            %no outage
            else
                FM(i,j,2) = spf(dpt,3); %Hs
                FM(i,j,3) = spf(dpt,4); %Tp
            end
        else
            dpt = find(FM(i,j,1) == spf(:,2)); %find matching forecast time
            %outage in dataset or missing value
            if isempty(dpt)
                FM(i,j,2) = nan; %Hs
                FM(i,j,3) = nan; %Tp
            %no outage
            else
                FM(i,j,2) = spf(dpt,3); %Hs
                FM(i,j,3) = spf(dpt,4); %Tp
            end
        end
     end
end
toc

tester_hs = FM(:,:,2); %for debugging
tester_tp = FM(:,:,3); %for debugging

clear array fpts spf dpt pt i j mindiff ans

%% plot outages

close all
offline_b = zeros(size(FM,2),1);
offline_f = zeros(size(FM,2),1);
notnanpts_b = find(~isnan(FM(1,:,2)));
notnanpts_f = find(~isnan(FM(158,:,2)));
offline_b(notnanpts_b) = nan;
offline_f(notnanpts_f) = nan;
subplot(2,1,1)
p1 = plot(datetime(FM(1,:,1),'ConvertFrom','datenum'),FM(1,:,2),'k','LineWidth',2.5);
hold on
p2 = plot(datetime(FM(1,:,1),'ConvertFrom','datenum'),offline_b,'ro');
% s=0;
% for i=1:length(offline_b)
%     if s == 0 && ~isnan(offline_b(i))
%         istart = i;
%         s = 1;
%     elseif s == 1 && isnan(offline_b(i))
%         iend = i;
%         s = 0;
%         x = [datetime(FM(1,istart,1),'ConvertFrom','datenum') datetime(FM(1,iend,1), ... 
%'ConvertFrom','datenum')];
%         patch(x, [-20 20], [0.6 0.4 0.9], 'FaceAlpha', 0.3, 'EdgeColor','none')
%         hold on
%     end
% end
grid on
ylabel('Hs [m]')
xlabel('Time')

subplot(2,1,2)
p3 = plot(datetime(FM(158,:,1),'ConvertFrom','datenum'),FM(158,:,2),'k','LineWidth',2.5);
hold on
p4 = plot(datetime(FM(158,:,1),'ConvertFrom','datenum'),offline_f,'go');
%legend([p2 p3],'buoy offline','forecast offline')
grid on
ylabel('Hs [m]')
xlabel('Time')

clear notnanpts_b notnanpts_f p1 p2 p3 p4

%% find largest continuous subset

counting = 0;
j = 1;
count = [];
for i = 1:length(offline_b)
    if counting == 0
        if isnan(offline_b(i)) && isnan(offline_f(i))
            counting = 1;
            count(j,1) = i;
        end
    else
        if ~isnan(offline_b(i)) || ~isnan(offline_f(i))
            counting = 0;
            count(j,2) = i-1;
            j = j+1;
        end
    end
    if counting == 1 && i == length(offline_b)
        count(j,2) = i;
    end
end

clear i j 

extents = count(:,2) - count(:,1);
[~,subset_id] = max(extents);
subset_pts = count(subset_id,1):count(subset_id,2);

%% plot subset comparison

subplot(2,1,1)
p1 = plot(datetime(FM(1,:,1),'ConvertFrom','datenum'),FM(1,:,2),'k','LineWidth',2.5);
hold on
p2 = plot(datetime(FM(1,:,1),'ConvertFrom','datenum'),offline_b,'ro');
hold on
plot(datetime(FM(1,subset_pts,1),'ConvertFrom','datenum'),FM(1,subset_pts,2),'m','LineWidth',2.5);
grid on
ylabel('Hs [m]')
xlabel('Time')
title('Buoy Data')
legend('Online','Offline','Subset')

subplot(2,1,2)
p3 = plot(datetime(FM(158,:,1),'ConvertFrom','datenum'),FM(158,:,2),'k','LineWidth',2.5);
hold on
p4 = plot(datetime(FM(158,:,1),'ConvertFrom','datenum'),offline_f,'ro');
hold on
plot(datetime(FM(158,subset_pts,1),'ConvertFrom','datenum'),FM(158,subset_pts,2),'m','LineWidth',2.5);
grid on
ylabel('Hs [m]')
xlabel('Time')
title('Forecast Data')
legend('Online','Offline','Subset')

clear p1 p2 p3 p4

%% save/return

s.WETSForecastMatrix.FM = FM;
s.WETSForecastMatrix.FM_subset = FM(:,subset_pts,:);
save('WETSForecastMatrix.mat','-struct','s','-v7.3');
