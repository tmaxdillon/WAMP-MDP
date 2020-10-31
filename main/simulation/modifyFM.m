function [FM_P,FM] = modifyFM(FM,frc,wec)
%tMod = tic;
if frc.stagelimit
    %disp('Modifying forecast matrix.')
    %apply stage limit value
    if frc.stagelimit
        FM = FM(1:1+frc.stagelimitval,:,:);
    end
end
%interpolate
if frc.sub > 0
    for f = 1:size(FM,2)
        Fext = find(isnan(FM(:,f,2)) == 0,1,'last');
        excl = Fext - (size(FM,1) - frc.sub); %number of forecasts to exclude
        if excl >= 1 %must interpolate if one or more excluded value
            %draw out the interpolation/indexing and it will all make sense...
            FM(2:excl+1,f,2) = interp1([1 excl+3],[FM(1,f,2) ...
                FM(excl+2,f,2)],3:excl+2); %Hs
            FM(2:excl+1,f,3) = interp1([1 excl+3],[FM(1,f,3) ...
            FM(excl+2,f,3)],3:excl+2); %Tp
        end
    end
end
%disp(['Forecast matrix modified after ' num2str(round(toc(tMod)/60,2)) ...
%' minutes.'])
%tPow = tic;
%disp('Power-ifying forecast matrix.')
FM_P = zeros(size(FM,1),size(FM,2),2); %preallocate
FM_P(:,:,1) = FM(:,:,1); %time stays the same, it is a flat circle
for f = 1:size(FM,2)
    for t = 1:size(FM,1)
        FM_P(t,f,2) = powerFromWEC_mdp(FM(t,f,2),FM(t,f,3),wec);
    end
end
%disp(['Forecast matrix converted to power matrix after ' ...
%num2str(round(toc(tMod)/60,2)) ' minutes.'])
end

