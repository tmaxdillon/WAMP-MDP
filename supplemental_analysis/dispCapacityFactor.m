function [CF] = dispCapacityFactor(struct)

for w = 1:size(struct,1)
    for b = 1:size(struct,2)
        CF(w,b) = struct(w,b).output.wec.CF;
    end
end

disp(['max = ' num2str(max(CF(:))) ' min = ' num2str(min(CF(:)))])

end

