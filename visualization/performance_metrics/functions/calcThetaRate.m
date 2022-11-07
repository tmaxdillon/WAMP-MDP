function [t_r] = calcThetaRate(a_sim,t_sim,tp)

t_sim(a_sim == 0) = [];
a_sim(a_sim == 0) = [];
a_sim(a_sim < 3) = 0;
a_sim(a_sim >= 3) = 1;

dv = datevec(t_sim); %datevec
h = dv(:,4); %hour of day

rems = rem(h,tp); %remainders
thetas = a_sim(rems == 0);
t_r = sum(thetas)./length(thetas);

end

