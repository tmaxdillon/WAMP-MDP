%created by Trent Dillon on June 12 2018 to analyze forecast matrix

clear all close all clc
%% load forecast matrix

load('WETSForecastMatrix.mat')

FM = WETSForecastMatrix.FM;

clear WETSForecastMatrix

tester_hs = FM(:,:,2); %for debugging
tester_tp = FM(:,:,3); %for debugging

%% compute errors

for i = 1:180
    for j = 1:size(FM,2)-i
        per_diff_Hs(i,j) = abs(FM(i+1,j,2)-FM(1,j+1,2))/FM(1,j+1,2);
        per_diff_Tp(i,j) = abs(FM(i+1,j,3)-FM(1,j+1,3))/FM(1,j+1,3);
        % forecasted data - actual data
        diff_Hs(i,j) = (FM(i+1,j,2)-FM(1,j+1,2)); 
        diff_Tp(i,j) = (FM(i+1,j,3)-FM(1,j+1,3));
    end
end

clear i j

mean_per_error_Hs = nanmean(per_diff_Hs,2);
mean_per_error_Tp = nanmean(per_diff_Tp,2);
med_abs_error_Hs = nanmedian(per_diff_Hs,2);
med_abs_error_Tp = nanmedian(per_diff_Tp,2);

%clear per_diff_Tp per_diff_Hs

%% plot mean percent error

time = 1:size(mean_per_error_Hs);

figure
subplot(2,1,1)
plot(time,mean_per_error_Hs*100,'-r','LineWidth',3)
xlabel('Forecast Extent [hr]')
ylabel('Significant Wave Height Error [%]')
ylim([0 inf])
title('Mean Percent Error')
grid on
subplot(2,1,2)
plot(time,mean_per_error_Tp*100,'-r','LineWidth',3)
xlabel('Forecast Extent [hr]')
ylabel('Peak Period Error [%]')
ylim([0 inf])
grid on

clear time

%% find distributions

Tp_binWidth = 1;
Hs_binWidth = 0.05;

%bin edges
Hs_max = nanmax(diff_Hs(:));
Hs_min = nanmin(diff_Hs(:));
Tp_max = nanmax(diff_Tp(:));
Tp_min = nanmin(diff_Tp(:));
hbc = floor(Hs_min):Hs_binWidth:round(Hs_max,1);
bin_edges_Hs = [hbc - Hs_binWidth/2,  ...
    hbc(end)+Hs_binWidth/2];
tbc = floor(Tp_min):Tp_binWidth:round(Tp_max,1);
bin_edges_Tp = [tbc - Tp_binWidth/2,  ...
    tbc(end)+Tp_binWidth/2];

clear Hs_max Hs_min Hs_bin_centers Tp_max Tp_min Tp_bin_centers ...
    Tp_binWidth Hs_binWidth

scatter_Hs = [];
scatter_Tp = [];

for i=1:size(diff_Hs,1)
    
    %find histogram for each forecast stage
    ho_Hs = histogram(diff_Hs(i,:),bin_edges_Hs,'Normalization' ...
        ,'probability');
    scatter_Hs(i,:) = ho_Hs.Values;
    ho_Tp = histogram(diff_Tp(i,:),bin_edges_Tp,'Normalization' ...
        ,'probability');
    scatter_Tp(i,:) = ho_Tp.Values;
   
    clear ho_Hs ho_Tp
end
   
clear i

%% visualize probability over time

hbc_surf = repmat(hbc,[size(scatter_Hs,1),1]);
tbc_surf = repmat(tbc,[size(scatter_Tp,1),1]);
time = 1:size(mean_abs_error_Hs);
timeHs_surf = repmat(time,[size(scatter_Hs,2),1])';
timeTp_surf = repmat(time,[size(scatter_Tp,2),1])';

figure(1)
s1 = surf(hbc_surf,timeHs_surf,scatter_Hs);
set(s1, 'edgecolor','none')
zlim([0 0.15])
xlim([-2 2])
colormap jet
title('Significant Wave Height Probability Distribution')
ylabel('Forecast Stage [hours]')
xlabel('Forecast Error [m]')
zlabel('Probability')
grid on

figure(2)
s2 = surf(tbc_surf,timeTp_surf,scatter_Tp);
set(s2, 'edgecolor','none')
zlim([0 0.4])
xlim([-8 8])
colormap jet
title('Peak Period Probability Distribution')
ylabel('Forecast Stage [hours]')
xlabel('Forecast Error [s]')
zlabel('Probability')
grid on

%% analyze outages

%find times offline
offline_b = zeros(size(FM,2),1);
offline_f = zeros(size(FM,2),1);
notnanpts_b = find(~isnan(FM(1,:,2)));
notnanpts_f = find(~isnan(FM(158,:,2)));
offline_b(notnanpts_b) = nan;
offline_f(notnanpts_f) = nan;

%find longest mutually online stretch
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

%plot subset comparison
figure(3)
subplot(2,1,1)
p1 = plot(datetime(FM(1,:,1),'ConvertFrom','datenum'),FM(1,:,2),'k',  ... 
    'LineWidth',1.7);
hold on
p2 = plot(datetime(FM(1,:,1),'ConvertFrom','datenum'),offline_b,'ro');
hold on
plot(datetime(FM(1,subset_pts,1),'ConvertFrom','datenum'),FM(1,subset_pts,2), ... 
    'g','LineWidth',1.7);
grid on
ylabel('Hs [m]')
xlabel('Time')
title('Buoy Data')
legend('Online','Offline','Subset')
ylim([0 6])

subplot(2,1,2)
p3 = plot(datetime(FM(158,:,1),'ConvertFrom','datenum'),FM(158,:,2),'k', ... 
    'LineWidth',1.7);
hold on
p4 = plot(datetime(FM(158,:,1),'ConvertFrom','datenum'),offline_f,'ro');
hold on
plot(datetime(FM(158,subset_pts,1),'ConvertFrom','datenum'), ... 
    FM(158,subset_pts,2),'g','LineWidth',1.7);
grid on
ylabel('Hs [m]')
xlabel('Time')
title('6.5 Day Forecast')
legend('Online','Offline','Subset')
ylim([0 6])

clear p1 p2 p3 p4




