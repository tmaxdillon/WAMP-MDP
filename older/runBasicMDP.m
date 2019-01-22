%created by Trent Dillon on June 13th 2018
%code simulates Markov Decision Process algorithm of WAMP system

%last updated Thursday July 25th by Trent Dillon

clear all close all clc
%% load data

load('WETSForecastMatrix')

FM = WETSForecastMatrix.FM_subset;
%Right now I am only using a 2 month subset because the full forecast
%matrix (WETSForecastMatrix.FM) has outages and data gaps (see included
%figure of outages/gaps).

% Data configuration:
% [forecast extent, forecast, parameter]
%
% Parameter = 1: time
% Parameter = 2: Hs
% Parameter = 3: Tp

clear WETSForecastMatrix

%% set input parameters

%VISUALIZATION SETTINGS:
visualize = 1; %toggle for immediate visualization

%STATE: amount of charge in bank
mdp.n = 20;
amp.E = linspace(0,50000,mdp.n); %[Wh], discretized battery state
amp.E_start = amp.E(round(mdp.n/2)); % initial state for simulation of sequential MDPs

%ACTION: number of operational states for AMP
mdp.m = 4;

%FUNCTIONAL PENALTY: penaltiy for each action (or operational state)
% [low, medium, full, power dump]
mdp.mu = [3000 1000 0 0]; %values need/needed to be tuned or "optimized"

%POWER CONSUMPTION: amount of power consumed by amp for each action
% [low, medium, full, power dump]
amp.Ps = [50 1000 1500 7500]; %values may need to be adjusted for Fred.Olsen

%POWER PRODUCTION: gaussian surface based on the following paramters
%see powerFromWEC.m
wec.Hsc = 4;    %height center
wec.Tpc = 9;    %period center
wec.w = 15;     %width of normal dist
wec.r = 15000;   %rated (max) power of device
wec.cw = 1;     %capture width at peak
wec.eta_ct = 0.6; %conversion efficiency


%STAGE: extent of forecasts for backward recursion in hours
mdp.T = size(FM,1)-1; %currently using longest possible forecast (first row of
                  %the forecast matrix is real data
mdp.dt = 1; %[hours]

%SIMULATION EXTENT: number of sequential forecasts
mdp.F = size(FM,2); %approximately 2 months of forecasts
%F = 10; %sometimes easier to set F to a smaller value for debugging

%SIMULATION TYPE:
mdp.pb = 1; %posterior bound
mdp.abridged = 0;
%add skip duration-limited forecasts (not fully devloped)

%% run backward recursion 
% -- takes about 1 minute for the full simulation extent

%preallocate outputs
output.E_sim = zeros(mdp.F,1); %initialize battery time series
output.E_sim(1) = amp.E_start; %set initial value of battery time series
output.a_sim = zeros(mdp.F,1); %initialize action time series
output.Pw_sim = zeros(mdp.F,1);
output.val_Jstar = zeros(mdp.F,1);
output.val_all = zeros(mdp.F,length(mdp.mu));
output.Pw_error = zeros(ceil(mdp.T/24),mdp.F);

% %for debugging, quickly set placements in the for loop to evaluate
% %individual quantities
% f = 2; %forecast
% pts = find(isnan(FM(:,f,2)) == 0);t = max(pts)-1; %stage
% s = 1; %state
% a = 3; %action
% clear pts
tic
for f=1:mdp.F %over each forecast
    %cut out early if using posterior bound to full duration
    if f > size(FM,2) - mdp.T && mdp.pb == 1
        mdp.abridged = 1;
        break
    end
    
    %preallocate backward recursion matrices
    Jstar = zeros(mdp.n,mdp.T+1);   %optimal values to go for each state and stage
    policy = zeros(mdp.n,mdp.T);    %optimaly policy (action) for each state and stage
    
    %find extent of forecast, Tf (which depends on how recent the forecast
    %is) by searching for start of NaN values
    pts = find(isnan(FM(:,f,2)) == 0);
    Tf = max(pts)-1;
    
    for t=Tf:-1:1 %over all stages, starting backward (backward recursion)
        compare = zeros(mdp.n,mdp.m); %array to compare the value of each action
        for s=1:mdp.n %over all states
            for a=1:mdp.m %all possible actions
                
                %1: compute evolution of battery:
                    % current charge - time*(power consumed - power produced)
                if mdp.pb == 0                    
                    E_evolved = amp.E(s) - mdp.dt*(amp.Ps(a) - ...
                        powerFromWEC(FM(t+1,f,2),FM(t+1,f,3),wec.Hsc, ... 
                        wec.Tpc,wec.w,wec.r,wec.cw,wec.eta_ct));
                elseif mdp.pb == 1
                    %[~,fptc] = find(FM(1,:,1) == FM(t+1,f,1));
                    %more robust, but slower ^                  
                    E_evolved = amp.E(s) - mdp.dt*(amp.Ps(a) - ...
                        powerFromWEC(FM(1,f+t,2),FM(1,f+t,3),wec.Hsc, ... 
                        wec.Tpc,wec.w,wec.r,wec.cw,wec.eta_ct));                
                end
                
                %2: find the state index of the evolved battery
                [~,ind_E] = min(abs(amp.E - E_evolved));
                
                %3: compute the 'value' of this action
                % (keep in mind larger values are undesireable)
                compare(s,a) = beta(amp.E(s)) + mdp.mu(a) + Jstar(ind_E,t+1);
                
            end
            
            %compare the value of the three actions, finding the optimal
            %value to go and the optimal policy
            [Jstar(s,t),policy(s,t)] = min(compare(s,:)); 
        end
    end
    
    %EVOLVE SIMULATION:
     [~,ind_E_sim] = min(abs(amp.E-output.E_sim(f))); %find index of current state
     output.a_sim(f) = policy(ind_E_sim,1); %find action given current state
     %find power produced by WEC
     output.Pw_sim(f) = powerFromWEC(FM(1,f,2),FM(1,f,3),... 
         wec.Hsc,wec.Tpc,wec.w,wec.r,wec.cw,wec.eta_ct);
     %find energy in next state
     output.E_sim(f+1) = output.E_sim(f) -  ... 
         mdp.dt*(amp.Ps(output.a_sim(f)) - output.Pw_sim(f));
     
    %COMPUTE ERROR IN FORECAST
    if f > 1
        %find timestamps where real data matches forecast data
        pts = find(FM(1,f,1) == FM(2:end,:,1));
        Hs_a = FM(1,f,2); %actuals
        Tp_a = FM(1,f,3); %actuals
        P_a = powerFromWEC(Hs_a,Tp_a,wec.Hsc,wec.Tpc,wec.w,wec.r,wec.cw, ... 
            wec.eta_ct); %actuals
        intervals = 1:24:length(pts); %space out timestamps in terms of hours
        P_a_f = zeros(ceil(mdp.T/24),1); %initialize
        for j = 1:length(intervals)
            Hs_a_f = FM(intervals(j)+1,f-intervals(j),2);
            Tp_a_f = FM(intervals(j)+1,f-intervals(j),3);
            P_a_f(j) = powerFromWEC(Hs_a_f,Tp_a_f, ...
                wec.Hsc,wec.Tpc,wec.w,wec.r,wec.cw,wec.eta_ct);
        end
        P_a_f(P_a_f==0) = nan;
        output.Pw_error(:,f) = P_a_f - P_a;
    end
    clear Hs_a Hs_a_f Tp_a Tp_a_f P_a P_a_f j 
     
    %DOCUMENT BELLMANS VALUES
     %all values
     output.val_all(f,:) = compare(ind_E_sim,:);
     %value to go
     output.val_Jstar(f,:) = Jstar(ind_E_sim,1);
end
toc

clear Tf name compare ind_E ind_E_sim pts policy Jstar a t s f ... 
    E_evolved 

% save MDP outputs
name = ['sim_n' num2str(mdp.n) 'F' num2str(mdp.F) 'fp' num2str(amp.Ps(3))];
if mdp.pb == 1
    name = [name 'pb'];
end
stru.(name).amp = amp;
stru.(name).wec = wec;
stru.(name).mdp = mdp;
stru.(name).output = output;
stru.(name).FM = FM;
save( ... 
    [name '.mat'],'-struct','stru','-v7.3');

if visualize == 1
    vizMDPSim(stru.(name))
end

clear stru name

