function [mpnf] = maxPowerNoFlex(wecs,batts)

mdpInputs
load('WETSForecastMatrix')
FM = WETSForecastMatrix.FM_subset;
clear WETSForecastMatrix
mpnf = zeros(length(wecs),length(batts));
for w = 1:length(wecs)
    wec.B = wecs(w);
    %unpack data
    [FM_P,~] = modifyFM(FM,frc,mdp,wec);
    for b = 1:length(batts)
        amp.E_max = batts(b);
        consump = 1; %[W]
        searching = true;
        while searching
            E = zeros(size(FM_P,2),1);
            E(1) = batts(b)/2;
            for i = 1:size(FM_P,2)-1
                sd = E(i)*(amp.sdr/100)*(1/(30*24))*mdp.dt; %[Wh] self disc
                E(i+1) = mdp.dt*(FM_P(1,i,2) - consump) + E(i) - sd;
                if E(i+1) > amp.E_max %topped out, discard power
                    E(i+1) = amp.E_max;
                elseif E(i+1) < 0 %bottomed out
                    mpnf(w,b) = consump-1; %[W] this is maximum power
                    searching = false;
                end
            end
            consump = consump+1; %[W]
            if consump > 600
                mpnf(w,b) = 600;
                searching = false;
            end
        end
    end
end

end

