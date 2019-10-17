function [y_norm,y_val] = skewedGaussian_mdp(x,alpha,width,ymax)

% https://www.mathworks.com/matlabcentral/answers/250321-apply-a-skew-
%normal-distribution-to-a-normal-distribution
y_val = 2*(1/sqrt((2*pi))*exp(-x^2/width))*normcdf(alpha*x);
y_norm = y_val/ymax;

end
% 
% function [eta_Tp_norm,eta_Tp_val] = skewedGaussian(Tp_t,c1,c2,Tp_eff_max)
% 
% %description:
% %   returns the peak period component of hydrodynamic efficiency, assuming
% %   this distribution follows a skewed normal distribution with
% %   coeffieients c1 and c2, found through linear regression
% %inputs:
% %   Tp_t - peak wave period
% %   c1 - distribution skew coefficient (usually around 0.5)
% %   c2 - distribution width coeffieient (suually around 60)
% %   Tp_eff_max - efficency at resonance (~1)
% %outputs:
% %   eta_Tp_val - probability value determined from distribution
% %   eta_Tp_norm - normalized peak period efficiency
% eta_Tp_val = 2*(1/sqrt((2*pi))*exp(-Tp_t^2/c2))*normcdf(c1*Tp_t);
% eta_Tp_norm = eta_Tp_val/Tp_eff_max; %normalize between 0 and 1
% 
% end

