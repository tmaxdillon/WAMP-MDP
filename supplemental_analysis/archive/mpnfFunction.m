function [] = mpnfFunction(Hs,Tp,t,wec,amp)
%MPNFFUNCTION Summary of this function goes here

E = zeros(length(Hs),1);
E(1) = amp.E_start;

consump = 1; %[W]

for j = 0:1000
    % find battery charge if power production only occurs
    for i = 1:length(Hs)-1
        E(i+1) = E(i) + powerToAMP(powerFromWEC(Hs(i),Tp(i),wec), ...
            E(i),amp,mdp,sim) - (consump+j)*mdp.dt;
    end
    if ~isempty(find(E<0))
        break
    end
end

