function [] = pySsmSave(prepath,tp,ta_i,batchlims)

batchtype = pyssm; %set batch inputs to pySsm
mdpScript

name = [tp '_' num2str(ta_i)];
stru.(name) = pySsmStruct;
save([prepath name '.mat'],'-struct','stru','s0','-v7.3')

end

