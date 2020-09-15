close all, clear all, clc
fontSize = 22;
patsgp = {'RCS03','RCS09','RCS10'};
dirname = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database/';
savedir = '/Users/juananso/Box Sync/RCS_GP_data_analysis_boxshare_juan_cora_phil/databaseoutput';

%% access summary data base file
% sensestimdbpath = fullfile(dirname,'sense_stim_database.mat');
load(fullfile(dirname,'database_raw_from_device_settings.mat'));

idxTable = cellfun(@(x) istable(x), masterTableOut.stimState);
idxNonZero = masterTableOut.duration > seconds(5);
idxUse = idxTable & idxNonZero;
masterTableUse = masterTableOut(idxUse,:);
allDeviceSettingsOut = allDeviceSettingsOut(idxUse);
for s = 1:size(masterTableUse,1)
    [pn,fn] = fileparts(allDeviceSettingsOut{s});
    timeStart = report_start_end_time_td_file_rcs(fullfile(pn,'RawDataTD.json'));
    isValidTime = ~isempty(timeStart.duration); 
    if isValidTime
        timeStart.startTime.TimeZone             = 'America/Los_Angeles';
        timeStart.endTime.TimeZone               = 'America/Los_Angeles';
        masterTableUse.idxkeep(s) = 1;
        masterTableUse.timeStart(s) = timeStart.startTime;
        masterTableUse.timeEnd(s) = timeStart.endTime;
        masterTableUse.duration(s) = timeStart.duration;
    else
        masterTableUse.idxkeep(s) = 0;
        masterTableUse.timeStart(s) = NaT;
        masterTableUse.timeEnd(s) = NaT;
        masterTableUse.duration(s) = seconds(0);
    end
end
masterTableUse = masterTableUse(logical(masterTableUse.idxkeep),:);
masterTableUse.duration.Format = 'hh:mm:ss';