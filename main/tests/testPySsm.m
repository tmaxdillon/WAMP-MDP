vars = {'eta','whl','rhs','rtp','sdr','est','slt', ...
    'tbs','ebs','dfr','sub','tam','tpe','bbb'};

for i = 1:length(vars)
    pySsmSave('~/MREL Dropbox/Trent Dillon/MATLAB/WAMP-MDP/main/tests/' ...
        ,vars{i},1,true)
end