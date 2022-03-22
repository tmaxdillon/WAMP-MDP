function [apfl] = avgPowerFixedLoad(wecs,batts,draw)

mdpInputs
ld = load('WETSForecastMatrix');
FM = ld.WETSForecastMatrix.FM_subset;
clear WETSForecastMatrix
apfl = zeros(length(wecs),length(batts));
for w = 1:length(wecs)
    wec.B = wecs(w);
    %unpack data
    [FM_P,~] = modifyFM(FM,frc,mdp,wec);
    for b = 1:length(batts)
        amp.E_max = batts(b);
        E = zeros(size(FM_P,2),1);
        L = ones(size(FM_P,2),1)*draw;
        E(1) = batts(b)/2;
        for i = 1:size(FM_P,2)-1
            sd = E(i)*(amp.sdr/100)*(1/(30*24))*mdp.dt; %[Wh] self disc
            E(i+1) = mdp.dt*(FM_P(1,i,2) - L(i)) + E(i) - sd;
            if E(i+1) > amp.E_max %topped out, discard power
                E(i+1) = amp.E_max;
            elseif E(i+1) < 0 %bottomed out
                L(i) = 0;
                E(i+1) = E(i);
            end
        end
        apfl(w,b) = mean(L);
    end
end

end

