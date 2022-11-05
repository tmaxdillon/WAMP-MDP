function [FM,amp,frc,mdp,sim,wec] = ...
    updateSensitivity(FM,amp,frc,mdp,sim,wec,i)

if sim.tdsens && ~sim.senssm && ~sim.pyssm %two dimensional sensitivity
    if isequal(sim.tuned_parameter{1},'emx') && ...
            isequal(sim.tuned_parameter{2},'wcd') && sim.tdsens
        amp.E_max = sim.S1(i);
        wec.B = sim.S2(i);
    end
    if isequal(sim.tuned_parameter{1},'ebs') && ...
            isequal(sim.tuned_parameter{2},'wcd') && sim.tdsens
        mdp.d_n = sim.S1(i);
        wec.B = sim.S2(i);
    end
    if isequal(sim.tuned_parameter{1},'rhs') && ...
            isequal(sim.tuned_parameter{2},'rtp') && sim.tdsens
        wec.Hs_ra = sim.S1(i);
        wec.Tp_ra = sim.S2(i);
    end
%     %only do this block of code if rhs or rtp becomes a tds parameter
%     without the other one also in the tds
%     %update rated conditions based on WEC size change
%     if ~isequal(sim.S1{2}(i),'rhs') %not rated Hs sensitivity
%         wec.Hs_ra = interp1([2 3 4 5],wec.Hs_ra_a,wec.B);
%     end
%     if ~isequal(sim.S1{2}(i),'rtp') %not rated Tp sensitivity
%         wec.Tp_ra = interp1([2 3 4 5],wec.Tp_ra_a,wec.B);
%     end
elseif ~sim.tdsens && sim.senssm && ~sim.pyssm %old ssm
%     if isequal(sim.S1{2}(i),'eta') %c/t efficiency
%         wec.eta_ct = sim.S1{1}(i);
%     elseif isequal(sim.S1{2}(i),'whl') %hotel load
%         wec.h = sim.S1{1}(i);
%     elseif isequal(sim.S1{2}(i),'rhs') %rated Hs
%         wec.Hs_ra = sim.S1{1}(i);
%     elseif isequal(sim.S1{2}(i),'rtp') %rated Tp
%         wec.Tp_ra = sim.S1{1}(i);
%     elseif isequal(sim.S1{2}(i),'sdr') %self dischg rate
%         amp.sdr = sim.S1{1}(i);
%     elseif isequal(sim.S1{2}(i),'est') %battery start fraction
%         amp.est = sim.S1{1}(i);
%     elseif isequal(sim.S1{2}(i),'slt') %stage limit
%         frc.stagelimit = true; frc.stagelimitval = sim.S1{1}(i);
%     elseif isequal(sim.S1{2}(i),'tbs') %time btwn stages
%         mdp.dt = sim.S1{1}(i);
%     elseif isequal(sim.S1{2}(i),'ebs') %energy btwn stages
%         mdp.d_n = sim.S1{1}(i);
%     elseif isequal(sim.S1{2}(i),'dfr') %discount factor
%         mdp.alpha = sim.S1{1}(i);
%     elseif isequal(sim.S1{2}(i),'sub') %spin up buffer
%         frc.sub = sim.S1{1}(i);
%     end
%     %update WEC and battery capacities
%     wec.B = sim.S1{3}(i);
%     amp.E_max = sim.S1{4}(i);
%     %update rated conditions based on WEC size change
%     if ~isequal(sim.S1{2}(i),'rhs') %not rated Hs sensitivity
%         wec.Hs_ra = interp1([2 3 4 5],wec.Hs_ra_a,wec.B);
%     end
%     if ~isequal(sim.S1{2}(i),'rtp') %not rated Tp sensitivity
%         wec.Tp_ra = interp1([2 3 4 5],wec.Tp_ra_a,wec.B);
%     end
elseif ~sim.tdsens && ~sim.senssm && sim.pyssm %python (new) ssm
    amp.E_max = sim.S1(i);
    wec.B = sim.S2(i);
    %update rated conditions based on WEC size change
    if ~isequal(sim.tp,'rhs') %not rated Hs sensitivity
        wec.Hs_ra = interp1([2 3 4 5],wec.Hs_ra_a,wec.B);
    end
    if ~isequal(sim.tp,'rtp') %not rated Tp sensitivity
        wec.Tp_ra = interp1([2 3 4 5],wec.Tp_ra_a,wec.B);
    end
end

end

