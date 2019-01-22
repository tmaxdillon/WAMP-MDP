function [Pw_error] = calcSimError(FM,mdp,wec,f)
%find timestamps where real data matches forecast data
pts = find(FM(1,f,1) == FM(2:end,:,1));
Hs_a = FM(1,f,2); %actual height
Tp_a = FM(1,f,3); %actual time
P_a = powerFromWEC(Hs_a,Tp_a,wec); %actual power
intervals = 1:24:length(pts); %space out timestamps in terms of hours
P_a_f = zeros(ceil(mdp.T/24),1); %initialize forecasted power
%compute forecasted power time series
for j = 1:length(intervals)
    Hs_a_f = FM(intervals(j)+1,f-intervals(j),2);
    Tp_a_f = FM(intervals(j)+1,f-intervals(j),3);
    Fpts = find(isnan(FM(:,f-1,2)) == 0); %number of forecasts
    %find diffference between number of forecasts and durlim
    diff = length(Fpts)-1-mdp.T+mdp.sub;
    if diff > 0
        Hs_a_f = FM(intervals(j)+1+diff, ...
            f-(intervals(j)),2);
        Tp_a_f = FM(intervals(j)+1+diff, ...
            f-(intervals(j)),3);
    end
    P_a_f(j) = powerFromWEC(Hs_a_f,Tp_a_f,wec);
    P_a_f(P_a_f==0) = nan;
    Pw_error = P_a_f - P_a; %find error
end
end

