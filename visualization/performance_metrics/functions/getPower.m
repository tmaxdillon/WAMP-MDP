function [avg,i_25,i_75,sd] = getPower(S)

avg = S.output.power_avg;
a_sim = S.output.a_sim;
a_sim(a_sim == 0) = [];
P = S.amp.Ps(a_sim);
i_25 = prctile(P,25);
i_75 = prctile(P,75);
sd = std(P);

end

