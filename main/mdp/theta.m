function [theta_a] = theta(t,FM,f,mu,tp,tA)

dv = datevec(FM(t,f,1)); %get matlab serial into datevec
h = dv(4); %hour of day

%piecewise function
theta_a(1:2) = (tA/2)*cos(2*pi*h*(1/tp)) + tA/2; %varying error
theta_a(3:4) = 0; %no penalty if in medium or high power mode
% disp(num2str(theta_a))
% pause

end

