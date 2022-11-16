function [] = visAllPySsm(var)

% visPySsm(var,'com',1,2)
% visPySsm(var,'com',1,1)
% visPySsm(var,'com',0,2)
% visPySsm(var,'com',0,1)
visPySsm(var,'tra',0,[])
pos = get(gcf,'Position','Units','Inches');
visPySsm(var,'tra',1,[])
set(gcf,'Units','Inches','Position',[pos(1)
visPySsm(var,'int',1,2)
visPySsm(var,'int',1,1)
visPySsm(var,'int',0,2)
visPySsm(var,'int',0,1)
visPySsm(var,'pow',1,[])
visPySsm(var,'pow',0,[])

end

