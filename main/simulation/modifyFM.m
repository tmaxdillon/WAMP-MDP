function [FM_P,FM] = modifyFM(FM,frc,mdp,wec)
%interpolate for spin up buffer
if frc.sub > 0
    for f = 1:size(FM,2)
        Fext = find(~isnan(FM(:,f,2)),1,'last');
        excl = Fext - (size(FM,1) - frc.sub); %num of forecasts to exclude
        if excl >= 1 %must interpolate if one or more excluded value
            %draw out the interpolation/indexing and it will all make sense
            FM(2:excl+1,f,2) = interp1([1 excl+2],[FM(1,f,2) ...
            FM(excl+2,f,2)],2:excl+1); %Hs
            FM(2:excl+1,f,3) = interp1([1 excl+2],[FM(1,f,3) ...
            FM(excl+2,f,3)],2:excl+1); %Tp
        end
    end
end
%apply time between forecasts and downselect FM
if mdp.dt > 1
    FM = FM(1:mdp.dt:end,:,:);
end
if frc.stagelimit
    FM = FM(1:1+frc.stagelimitval,:,:);
end
%Tp and Hs to power in power matrix
FM_P = zeros(size(FM,1),size(FM,2),4); %preallocate
FM_P(:,:,1) = FM(:,:,1); %time stays the same, it is a flat circle
rp = (wec.B*wec.F(wec.Tp_ra,wec.Hs_ra,wec.B)*wec.eta_ct*(1/(16*4*pi)) ...
    *wec.rho*wec.g^2*wec.Hs_ra^2*wec.Tp_ra)/(1+wec.h); %rated power
Bmat = wec.B*ones(size(FM,[1 2])); %[m] B matrix for interpolation
FM_P(:,:,2) = wec.B.*wec.F(FM(:,:,3),FM(:,:,2),Bmat).* ...
    wec.eta_ct.*(1/(16*4*pi)).*wec.rho.*wec.g^2.* ...
    FM(:,:,2).^2.*FM(:,:,3) - rp*wec.h; %[W] power output
FM_P(:,:,3) = wec.B*wec.F(FM(:,:,3),FM(:,:,2),Bmat); %[m] cw
FM_P(:,:,4) = wec.F(FM(:,:,3),FM(:,:,2),Bmat); %[~] cwr
P = FM_P(:,:,2);
P(P<0) = 0; %remove negative power generation
P(P>rp) = rp; %capped at rated power
FM_P(:,:,2) = P;

end

