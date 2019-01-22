function [power_amp] = powerToAMP(power_wec,E,amp,mdp,sim)
%never more than a third of the power
power_amp = power_wec*(1/3);

%never more than 960 watts
if power_amp > 960
    power_amp = 960;
end

%never more than upper limit capacity if constrained in simulation
if power_amp*mdp.dt > (amp.E_max - E)
    power_amp = (amp.E_max - E)/mdp.dt;
end

end

