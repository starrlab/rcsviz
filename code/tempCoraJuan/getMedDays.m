function [out,locs] = getMedDays(eventData, var)
%% gets different days where medication was taken

if var==0   % for all types of medicaiton
    locs = find(diff(eventData.sessionTime.Day)~=0);    
    if locs(1)~=0    % add first day
        locs = [1;locs+1];
    end
    out = eventData.sessionTime(locs);

end

end
