function [Pw_error,Pw_zero] = calcSimError(FM_P,mdp,f)
P_a = FM_P(1,f,2); %actual power
%find timestamps where real data matches forecast data
Tpts = find(FM_P(1,f,1) == FM_P(2:end,:,1));
intervals = 1:24:length(Tpts); %space out timestamps in terms of hours
P_a_f = zeros(ceil((mdp.T-1)/24),1); %initialize forecasted power
%compute forecasted power time series
for j = 1:length(P_a_f)
    if j <= length(intervals) %there are forecasted comparisons available
        P_a_f(j) = FM_P(intervals(j)+1,f-intervals(j),2);
    else %there are not forecasted comparisons available
        P_a_f(j) = nan;
    end
end
%P_a_f(P_a_f==0) = nan; %remove days that weren't forecasted
Pw_error = P_a_f - P_a; %[W] find error, positive = overestimate
if P_a == 0
    Pw_zero = P_a_f;
    id_zero = P_a_f == 0; %find zero forecasts in P_a_f
    Pw_zero(id_zero) = 1; %set zero forecasts to on
    Pw_zero(~id_zero) = nan; %set nonzero forecasts to nan
else
    Pw_zero = nan(size(P_a_f));
end
    
    
end

