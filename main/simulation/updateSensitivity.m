function [FM,amp,frc,mdp,sim,wec] = ...
    updateSensitivity(FM,amp,frc,mdp,sim,wec,i)

if sim.tdsens && ~sim.senssm %two dimensional sensitivity
    if isequal(sim.tuned_parameter{1},'emx') && ...
            isequal(sim.tuned_parameter{2},'wcd') && sim.tdsens
        amp.E_max = sim.S1(i);
        wec.B = sim.S2(i);
    %NEED TO TRY THIS
    elseif isequal(sim.tuned_parameter{1},'eps') && ...
            isequal(sim.tuned_parameter{2},'nll') && sim.tdsens
        f_eps = sim.S1(i)/mdp.eps; %epsilon factor for mu calc
        mdp.eps = sim.S1(i);
        mdp.mu = mdp.mu.*f_eps;
    end
elseif ~sim.tdsens && sim.senssm %sensitivity small multiple
    if isequal(sim.tp{floor(i/sim.n)},'eta') %c/t efficiency
        wec.eta_ct = sim.ta(i);
    elseif isequal(sim.tp{floor(i/sim.n)},'whl') %hotel load
        wec.h = sim.ta(i);
    elseif isequal(sim.tp{floor(i/sim.n)},'rhs') %rated Hs
        wec.Hs_ra = sim.ta(i);
    elseif isequal(sim.tp{floor(i/sim.n)},'rtp') %rated Tp
        wec.Tp_ra = sim.ta(i);
    elseif isequal(sim.tp{floor(i/sim.n)},'sdr') %self discharge rate
        amp.sdr = sim.ta(i);
    elseif isequal(sim.tp{floor(i/sim.n)},'slt') %stage limit
        frc.stagelimit = true; frc.stagelimiit = sim.ta(i);
    elseif isequal(sim.tp{floor(i/sim.n)},'tbs') %time between stages
        mdp.dt = sim.ta(i);
    elseif isequal(sim.tp{floor(i/sim.n)},'ebs') %energy between stages
        mdp.d_n = sim.ta(i);
    elseif isequal(sim.tp{floor(i/sim.n)},'dfr') %discount factor
        mdp.alpha = sim.ta(i);
    elseif isequal(sim.tp{floor(i/sim.n)},'sub') %spin up buffer
        frc.sub = sim.ta(i);
    end
end

