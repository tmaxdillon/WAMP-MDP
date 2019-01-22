%created by Trent Dillon on June 14th
%function outputs the power produced by a fictional wave energy converater
%based on an idealized gaussian surface as a power matrix

function [power] = powerFromWEC(Hs,Tp,wec)
rho = 1020;
g = 9.81;
%normal distribution based around given apex, width and rated power
gausseff = wec.cw*exp(-1*((Tp-wec.Tpc)^2+(Hs-wec.Hsc)^2)/wec.w);
wavepower = (1/(16*4*pi))*rho*g^2*Hs^2*Tp;

power = wec.eta_ct*gausseff*wavepower;

%scale to rated power
power(power>wec.r) = wec.r;

end

