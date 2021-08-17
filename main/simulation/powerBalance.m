function [draw_act,a_act_ind,power_disc,E_evolved] = ...
    powerBalance(power_wec,E,a_ind,sdr,E_max,Ps,dt)

sd = E*(sdr/100)*(1/(30*24))*dt; %[Wh] self discharge
draw_att = Ps(a_ind); %attempted draw
%default values
draw_act = draw_att; %actual draw matches attempted draw
a_act_ind = a_ind; %actual action matches attempted action
power_disc = 0;
E_evolved = dt*(power_wec - draw_att) + E - sd; %next battery state
%updates based on battery capacity limits
if E_evolved > E_max %topped out, discard power
    power_disc = E_evolved - E_max; %[Wh], power discarded
    E_evolved = E_max;
elseif E_evolved <= 0 %bottomed out, find actual draw
    draw_exact = (E - sd)/dt + power_wec; %[W], exact draw possible
    Ps_temp = Ps - draw_exact;
    if sum(Ps_temp(:) < 0) == 0 %Ps_temp is all positive
        a_act_ind = 1; %enter lowest power state
    else %negative values in Ps_temp, consumption possible
        [~,a_act_ind] = max(Ps_temp(Ps_temp<0)); %largest possible
    end
    draw_act = Ps(a_act_ind); 
    E_evolved = dt*(power_wec - draw_act) + E - sd;
end

end

