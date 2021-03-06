function [Pw_error] = calcSimError(FM_P,mdp,f)
P_a = FM_P(1,f,2); %actual power
%find timestamps where real data matches forecast data
Tpts = find(FM_P(1,f,1) == FM_P(2:end,:,1));
intervals = 1:24:length(Tpts); %space out timestamps in terms of hours
P_a_f = zeros(ceil((mdp.T-1)/24),1); %initialize forecasted power
%compute forecasted power time series
for j = 1:length(intervals)
    P_a_f(j) = FM_P(intervals(j)+1,f-intervals(j),2);
end
P_a_f(P_a_f==0) = nan; %remove days that weren't forecasted
Pw_error = P_a_f - P_a; %[W] find error, positive = overestimate
end

