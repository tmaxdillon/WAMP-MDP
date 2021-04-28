function [i_av,i_hh,i_ll,i_me,i_25,i_75] = calcIntermit(a_sim,hh,ll)

a_sim_orig = a_sim;
a_sim(a_sim == 0) = [];
a_sim(a_sim ~= 4) = 0;
a_sim(a_sim == 4) = 1;
ind = find(a_sim == 1);
I = diff(ind);
i_av = mean(I);
% i_mx = max(I);
% i_mi = min(I);
i_me = median(I);
i_25 = prctile(I,25);
i_75 = prctile(I,75);
i_hh = prctile(I,hh);
i_ll = prctile(I,ll);

end

