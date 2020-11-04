function [power_batt,E_evolved] = powerToBattery(power_wec,E,draw,amp, ...
    mdp,wec)

if wec.FO
    %never more than a third of the power
    power_amp = power_wec*(1/3);
    
    %never more than 960 watts
    if power_amp > 960
        power_amp = 960;
    end
else
    power_amp = power_wec;
end

sd = E*(amp.sdr/100)*(1/(30*24))*mdp.dt; %[Wh] self discharge
E_evolved = mdp.dt*(power_amp - draw) + E - sd;
if E_evolved > amp.E_max %dump power
    E_evolved = amp.E_max;
elseif E_evolved <= 0 %bottom out
    E_evolved = 0;
end
power_batt = (E_evolved - E + sd)/mdp.dt; %net power sent to battery bank
    
end

