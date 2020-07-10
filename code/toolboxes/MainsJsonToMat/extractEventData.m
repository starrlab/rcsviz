function out = extractEventData(fn)

%% function that extracts montage data based on difference event inputs
% input fn: input directory where all seession files live (end with Slash dir/)


%% creates a table with all event data in the folder
fsDir = dir(fn);

for ii=1:length(fsDir)
    if strcmp(fsDir(ii).name,'allEvents.mat')
        break
    elseif ii==length(fsDir)
        concantenate_event_data(fn);
    end
end

out = load(strcat(fn,'allEvents.mat'));

%% 
