function [] = visAllPySsm(var)

sd = 3.5; %shift down

fig1 = visPySsm(var,'pow',1,[]); %power, normalized
title(gca,'Power, Normalized')
set(fig1,'Units','Inches');
drawnow
pos = get(fig1,'Position');
fig2 = visPySsm(var,'pow',0,[]); %power, raw
title('Power, Raw')
set(fig2,'Units','Inches');
drawnow
set(fig2,'Units','Inches','Position',[pos(1) pos(2)-sd pos(3) pos(4)]) 
fig3 = visPySsm(var,'int',1,2); %avg intermittency, normalized
title(gca,'Avg Intermittency, Normalized')
set(fig3,'Units','Inches');
drawnow
set(fig3,'Units','Inches','Position',[pos(1)+pos(3) pos(2) pos(3) pos(4)])
fig4 = visPySsm(var,'int',0,2); %avg intermittency, raw
title(gca,'Avg Intermittency, Raw')
set(fig4,'Units','Inches');
drawnow
set(fig4,'Units','Inches','Position',[pos(1)+pos(3) pos(2)-sd pos(3) pos(4)])
fig5 = visPySsm(var,'int',1,1); %max intermittency, normalized
title(gca,'Max Intermittency, Normalized')
set(fig5,'Units','Inches');
drawnow
set(fig5,'Position',[pos(1)+2*pos(3) pos(2) pos(3) pos(4)]) 
fig6 = visPySsm(var,'int',0,1); %max intermittency, raw
title(gca,'Max Intermittency, Raw')
set(fig6,'Units','Inches');
drawnow
set(fig6,'Position',[pos(1)+2*pos(3) pos(2)-sd pos(3) pos(4)]) 
fig7 = visPySsm(var,'tra',1,[]); %theta rate, normalized
title(gca,'Theta Rate, Normalized')
drawnow
set(fig7,'Units','Inches');
set(fig7,'Position',[pos(1)+3*pos(3) pos(2) pos(3) pos(4)]) 
fig8 = visPySsm(var,'tra',0,[]); %theta rate, raw
title(gca,'Theta Rate, Raw')
drawnow
set(fig8,'Units','Inches');
set(fig8,'Position',[pos(1)+3*pos(3) pos(2)-sd pos(3) pos(4)]) 


end

