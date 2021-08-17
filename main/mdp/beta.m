%created by Trent Dillon on June 13th 2018
%function outputs the battery cost for the WAMP MDP using a polynomial
%utility function, given an input of amount of charge in battery

function [beta] = beta(E_val,E,E_max,b,beta_lb)
%polynomial coefficients found using trial and error on 
%https://mycurvefit.com/ and createBetaUtilityPiecewise.m

E_val(E_val<0)=0; %negative battery capacity not possible

%DISCRETIZE CHARGE (posterior bound may reach infinity otherwise)
[~,E_ind] = min(abs(E-E_val)); %find index of current state
E_disc = E(E_ind); %find discretized state

%LOWER BOUND
%lower bound is percentage of starting charge
lb = beta_lb*E_max;

%COMPUTE BETA
if E_disc < lb
    beta = b*(lb/E_disc - 1);
    if isnan(beta) && b == 0
        beta = 0;
    end
else
    beta = 0;
end


end

