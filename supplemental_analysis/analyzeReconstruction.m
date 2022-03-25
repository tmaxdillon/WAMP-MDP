s = mdpdn5(1,3);
y = 2017;
d = 21;
m = 07;
h = 15;

dn = datenum(y,m,d,h,0,0);
pt = find(s.output.FM_P(1,:,1) == dn);

[~,~,~,E_next] = powerBalance(s.output.Pw_sim(pt),s.output.E_recon(pt), ...
        s.output.a_act_sim(pt),s.amp.sdr,s.amp.E_max,s.amp.Ps,1,true);
    
disp(['E_now = ' num2str(s.output.E_recon(pt)) ' Wh'])
disp(['Pw = ' num2str(s.output.Pw_sim(pt)) ' kW'])
disp(['A = ' num2str(s.output.a_act_sim(pt)) ])
disp(['E_next = ' num2str(E_next) ' Wh'])

   
