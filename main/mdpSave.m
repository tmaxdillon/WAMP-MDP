function [] = mdpSave(prepath,name,batchtype,batchsim, ...
    batchpar1,batchpar2)

%clearvars -except name prepath batchtype scen loc c
mdpScript

if exist('multStruct','var')
    stru.(name) = multStruct;
    %what is any of this doing?
%     if exist('multStruct_pb','var')
%         stru.([name '_pb']) = multStruct_pb;
%     end
%     if exist('multStruct_sl','var')
%         stru.([name '_sl']) = multStruct_sl;
%     end
%     if exist('multScruct_s2','var')
%         stru.([name '_s2']) = multStruct_s2;
%     end
else
    stru.(name) = simStruct;
end
save([prepath name '.mat'], '-struct','stru','-v7.3')

end

