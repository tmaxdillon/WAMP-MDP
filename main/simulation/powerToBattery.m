function [power_batt_net,E_evolved] = ...
    powerToBattery(power_wec,E,draw,sdr, ...
    E_max,dt,FO)

if FO
    %never more than a third of the power
    power_amp = power_wec*(1/3);
    
    %never more than 960 watts
    if power_amp > 960
        power_amp = 960;
    end
else
    power_amp = power_wec;
end

sd = E*(sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
E_evolved = dt*(power_amp - draw) + E - sd;
%power_batt_gross = (E_evolved - E + sd)/dt; %gross power to battery bank
if E_evolved > E_max %dump power
    E_evolved = E_max;
elseif E_evolved <= 0 %bottom out
    E_evolved = 0;
end
power_batt_net = (E_evolved - E + sd)/dt; %net power sent to battery bank
    
end

