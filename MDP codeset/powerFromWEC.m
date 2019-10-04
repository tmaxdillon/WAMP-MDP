%created by Trent Dillon on June 14th 2018
%function outputs the power produced by a fictional wave energy converater
%based on an idealized gaussian surface as a power matrix

%for use in MDP codeset

function [power] = powerFromWEC(Hs,Tp,wec)

rho = 1020;
g = 9.81;

rho = 1020;
g = 9.81;
hs_eff = exp(-1.*((Hs - wec.hs_res*wec.Hsm).^2) ...
    ./wec.w); %Hs efficiency
tp_eff = skewedGaussian(Tp,wec.tp_c(1),wec.tp_c(2))/ ...
    skewedGaussian(wec.Tpm*wave.tp_res, ...
    wec.tp_c(1),wec.tp_c(2)); %Tp efficiency
wavepower = (1/(16*4*pi))*rho*g^2* ...
    (wec.hs_rated*wec.Hsm)^2 *(wec.tp_rated*wec.Tpm); %[W], wavepower
power = wave.eta_ct*wec.width*hs_eff*tp_eff*wavepower - ...
    wec.r*wec.house; %[kW]

%scale to rated power
power(power>wec.r) = wec.r; %[kW]
power(power<0) = 0;

end

