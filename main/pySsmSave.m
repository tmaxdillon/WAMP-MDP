function [] = pySsmSave(prepath,tp,ta_i,batchlims)

%inputs:
%tp - tp is the tuned parameter in string form (e.g. 'eta'), it is passed
%into the 'sim' structure and used to identify the tuned parameter in
%doPySsm.m
%ta_i - ta_i is the tuning array index (between 1 and 10) and it is passed
%in to the 'sim' structure and used to identify the value of the tuned
%parameter in doPySsm.m

batchtype = 'pySsm'; %set batch inputs to pySsm
mdpScript

if isequal(tp,'bbb') %set baseline output filename without index
    name = tp;
else
    name = [tp '_' num2str(ta_i)];
end
stru.(name) = pySsmStruct;
save([prepath name '.mat'],'-struct','stru','-v7.3')

end

