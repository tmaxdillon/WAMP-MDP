%created by Trent Dillon on June 13th
%function outputs the battery cost for the WAMP MDP using a polynomial
%utility function, given an input of amount of charge in battery

function [beta] = beta(E,amp,mdp)
%polynomial coefficients found using trial and error on 
%https://mycurvefit.com/ and createBetaUtilityPiecewise.m

%beta coefficient
b = mdp.b;

E(E<0)=0; %negative battery capacity not possible

%DISCRETIZE CHARGE (posterior bound may reach infinity otherwise)
[~,E_ind] = min(abs(amp.E-E)); %find index of current state
E_disc = amp.E(E_ind); %find discretized state

%LOWER BOUND
%lower bound is percentage of starting charge
lb = mdp.beta_lb*amp.E_start;

%COMPUTE BETA
if E_disc < lb
    beta = b*(lb/E_disc - 1);
else
    beta = 0;
end


end

