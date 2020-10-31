function [] = visPowerMatrix_mdp(Hsm,Tpm,rated,wec)

ymin = 0;
xmin = 0;
rho = 1020;
g = 9.81;

% set axes
y = ymin:.01:4*Hsm; %wave height
x = xmin:.01:1.3*Tpm; %peak period
N = 1000; %discretization for finding skewed gaussian

% preallocate
power = zeros(ymin+length(y),xmin+length(x));
wavepower = zeros(ymin+length(y),xmin+length(x));
efficiency = zeros(ymin+length(y),xmin+length(x));

% x = linspace(y(1),y(end),N);
% gaussian = @(x,b) (1/sqrt((2*pi))*exp(-x.^2/b))
% skewedgaussian = @(x,alpha,b) 2*gaussian(x,b).*normcdf(alpha*x)

%find skewed gaussian fit
c0 = [0.5 60];
fun = @(c)findSkewedSS_mdp(linspace(0,2*Tpm,N),c,wec,Tpm);
options = optimset('MaxFunEvals',10000,'MaxIter',10000, ...
    'TolFun',.0001,'TolX',.0001);
tic
c = fminsearch(fun,c0,options);
% debug/visualize efficiency curve
% [~,y_,Y] = findSkewedSS_mdp(linspace(0,2*Tpm,N),c,wave,Tpm);
% figure, plot(y_,Y)
toc

[~,prob_max] = skewedGaussian_mdp(Tpm*wec.tp_res, ... 
    c(1),c(2),1); %maximum Tp efficiency

%find width through rated conditions
wavepower_r = (1/(16*4*pi))*rho*g^2*(wec.hs_rated*Hsm)^2 ...
    *(wec.tp_rated*Tpm); %[W], wave power at resonance
hs_eff_r = exp(-1.*((wec.hs_rated*Hsm- ... 
    wec.hs_res*Hsm).^2)./wec.w); %Hs eff (rated)
tp_eff_r = ...
    skewedGaussian_mdp(wec.tp_rated*Tpm,c(1),c(2),prob_max); %Tp eff (rated)
width = 1000*rated*(1-wec.house)/ ... 
    (wec.eta_ct*hs_eff_r*tp_eff_r*wavepower_r); %[m]

for i = 1:length(x) %Tp
    for j = 1:length(y) %Hs
        hs_eff = exp(-1.*((y(j)-wec.hs_res*Hsm).^2)./wec.w); %Hs efficiency
        tp_eff = skewedGaussian_mdp(x(i),c(1),c(2),prob_max); %Tp efficiency
        efficiency(j+ymin,i+xmin) = hs_eff*tp_eff;
        wavepower(j+ymin,i+xmin) = ...
            (1/(16*4*pi))*rho*g^2*y(j)^2*x(i)/1000; %[kW]
        power(j+ymin,i+xmin) = wec.eta_ct*width*efficiency(j+ymin,i+xmin)* ...
            wavepower(j+ymin,i+xmin) - rated*wec.house; %[kW]
        %cut out
        if wavepower(j+ymin,i+xmin)*width > wec.cutout*rated
            power(j+ymin,i+xmin) = 0;
        end
        % H/L > 0.14 then waves break (deep water assumption)
        L = g*x(i)^2/(2*pi);
        if y(j)/L > .14
            power(j+ymin,i+xmin) = 0; %is this correct? probably not...
        end        
    end
end

% %scale to rated power and revmove negative power
power(power<0) = 0;
power(power>rated) = rated; %[kW]

% visualize
figure
pc = pcolor([1:xmin x],[1:ymin y],wavepower);
shading interp;
colormap(brewermap(50,'purples'))
set(pc, 'EdgeColor', 'none'); %remove edges to better visualize
cb = colorbar;
ylabel(cb,'[kW/m]','Fontsize',14)
axis equal
axis tight
title('Wave Energy Flux','Fontsize',20)
ylabel({'Significant', 'Wave Height [m]'},'Fontsize',20)
xlabel('Peak Period [s]','Fontsize',20)
set(gca,'Fontsize',14)

figure
pc = pcolor([1:xmin x],[1:ymin y],efficiency);
shading interp;
colormap(brewermap(50,'purples'))
set(pc, 'EdgeColor', 'none'); %remove edges to better visualize
cb = colorbar;
ylabel(cb,'Efficiency [~]','Fontsize',14)
axis equal
axis tight
title('Efficiency','Fontsize',20)
ylabel({'Significant', 'Wave Height [m]'},'Fontsize',20)
xlabel('Peak Period [s]','Fontsize',20)
set(gca,'Fontsize',14)

figure
pc = pcolor([1:xmin x],[1:ymin y],power);
shading interp;
colormap(brewermap(50,'purples'))
set(pc, 'EdgeColor', 'none'); %remove edges to better visualize
cb = colorbar;
ylabel(cb,'Power [kW]','Fontsize',14)
%axis equal
%axis tight
title('Power Matrix','Fontsize',20)
ylabel({'Significant', 'Wave Height [m]'},'Fontsize',20)
xlabel('Peak Period [s]','Fontsize',20)
set(gca,'Fontsize',14)

end

