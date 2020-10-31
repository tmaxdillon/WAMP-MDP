%created by Trent Dillon on June 14th 2018
%function outputs the power produced by a fictional wave energy converater
%based on an idealized gaussian surface as a power matrix

%for use in MDP codeset

function [power,cw] = powerFromWEC_mdp(Hs,Tp,wec)

rho = 1020;
g = 9.81;

hs_eff = exp(-1.*((Hs - wec.hs_res*wec.Hsm).^2) ...
    ./wec.w); %Hs efficiency
tp_eff = skewedGaussian_mdp(Tp,wec.tp_c(1),wec.tp_c(2), ...
    wec.tp_eff_max); %Tp efficiency
wavepower = (1/(16*4*pi))*rho*g^2*Hs^2*Tp; %[W], wavepower
power = wec.eta_ct*wec.width*hs_eff*tp_eff*wavepower - ...
    wec.r*wec.house*1000; %[W]
power(power<0) = 0; %remove negative power

%compute capture width (removing house load and ct effiency)
cw = ((power + wec.r*wec.house*1000)/(wec.eta_ct))/wavepower;

%scale to rated power
power(power>wec.r*1000) = wec.r; %[W]

% H/L > 0.14 then waves break (deep water assumption)
L = g*Tp^2/(2*pi);
if Hs/L > .14
    power = 0; %is this correct? probably not...
end

end

