s = simStruct(1,1);
y = 2017;
d = 08;
m = 07;
h = 12;

dn = datenum(y,m,d,h,0,0);
if isfield(s.output,'FM_P')
    pt = find(s.output.FM_P(1,:,1) == dn);
else %sensitivity analysis, unpack appropraitely
    pt = find(s.output.FM_P_1(:,1) == dn);
    s.amp = bbb.amp; %baseline amp structure
end

[~,~,~,E_next] = powerBalance(s.output.Pw_sim(pt),s.output.E_recon(pt), ...
        s.output.a_act_sim(pt),s.amp.sdr,s.amp.E_max,s.amp.Ps,1,true);
    
disp(['E_now = ' num2str(s.output.E_recon(pt)) ' Wh'])
disp(['Pw = ' num2str(s.output.Pw_sim(pt)) ' kW'])
disp(['A = ' num2str(s.output.a_act_sim(pt)) ])
disp(['E_next = ' num2str(E_next) ' Wh'])



   
