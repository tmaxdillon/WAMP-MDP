%% beta discretized

figure
plot(1:length(unique(output.beta)),unique(output.beta))


%% timeseries beta comparison

if output.abridged
    f_pts = 1:find(output.E_sim > 0,1,'last');
else
    f_pts = 1:length(output.E_sim(1:end-1));
end

figure
plot(datetime(FM(1,f_pts,1),'ConvertFrom','datenum'),output.beta)
hold on
plot(datetime(FM(1,f_pts,1),'ConvertFrom','datenum'),beta(output.E_sim,amp,mdp,sim))