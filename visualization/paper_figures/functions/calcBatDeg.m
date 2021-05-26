function [L] = calcBatDeg(struct,y,E_max)

struct.output.E_sim(struct.output.a_sim == 0) = [];

S = extendToLifetime(struct.output.E_sim, ...
    struct.output.FM_mod(1,1:length(struct.output.E_sim),1)',y);
L = batDegModel(S/E_max,15,3600*8760*y,true,[]);

end

