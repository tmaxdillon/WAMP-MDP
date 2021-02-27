function [] = mdpSave(prepath,name)

%clearvars -except name prepath batchtype scen loc c
mdpScript

if exist('multStruct','var')
    stru.(name) = multStruct;
    if exist('multStruct_pb','var')
        stru.([name '_pb']) = multStruct_pb;
    end
    if exist('multStruct_sl','var')
        stru.([name '_sl']) = multStruct_sl;
    end
else
    stru.(name) = simStruct;
end
save([prepath name '.mat'], '-struct','stru','-v7.3')

end

