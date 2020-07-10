% function create_pat_database_around_med_event(fp, tfixed, tw1, tw2, saveOutputData, plotInstanceRawData)
%% creates database of Off/On med data sets
% Input arguments
% fn: pointer to folder path to a patient's side sessions folder
% tw1: time window 1, minutes before med taken to extract from dataset
% tw2: time window 2, minutes after med taken to extract from dataset
% savedata: (0,1) indicates if data should be saved (output.mat) file in fn
% plotinstance: (0,1) indicates if 1 raw data segment data to be plotted

close all; clear all; clc; warning off;

%% this section is to enter the variables while creating function+debugging
saveOutputData = 1;
% plotInstanceRawData = 1;
fp = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS03 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS03L/';
tfixed = 9; % time in hours 0 to 24 hours time (8 is 8 am; 18 is 8 pm)
tw1 = 10;   % time in minutes before med taken
tw2 = 10;   % time in minutes after med taken

%% short ouput form of patient's folder ID information
disp(['data set corresponding to "...', fp(end-41:end),'"'])
disp('_____________________________________________________________________')

%% access all event data in folder
eventData = extractEventData(fp);
disp('all Event data in folder concatenated...')
tFixedTemp = datetime(1,1,1,tfixed,0,0);
locsWithinTW = find(eventData.allEvents.eventOut.sessionTime.Hour <= tFixedTemp.Hour);
allEventsWithTw = eventData.allEvents.eventOut.sessionTime(locsWithinTW);
temp = diff(allEventsWithTw);
temp2 = seconds(temp);
locs = find(temp2~=0);
disp(['number session folders within fixed hour time window:',num2str(length(locs))])
disp('_____________________________________________________________________')

%% loop for each session folder
output = table();
counter = 0;
disp('looping for each session folder...')

allFilesInDir = dir(fp);
countSessFolds = 0;

for ii=54
    disp([num2str(ii),' from ', num2str(length(allFilesInDir)), ' ...'])

    % ignore the hidden dir files
    if ~(strcmp(allFilesInDir(ii).name,'.') || strcmp(allFilesInDir(ii).name,'..'))
        if strcmp(allFilesInDir(ii).name(1:3),'ses') || strcmp(allFilesInDir(ii).name(1:3),'Ses')
            sessName = allFilesInDir(ii).name;
            countSessFolds = countSessFolds + 1;
            disp(['session folder name: ',sessName])
            fd = fullfile(fp,sessName);
            ft = dir(fd);
            devName = ft(3).name;
            fs = fullfile(fd,devName);
            
            % remove outlier datasets
            % 1) incomplete data set pat RCS03L, Session1559856377371
            % 2)  Session1561217159616
            
            if strcmp(fp(end-41:end),'SummitContinuousBilateralStreaming/RCS03L/') && (ii==4) || (ii==34) || (ii==41)...
                dataSet = [];
                disp(':( not able to read TD data (...)')
                disp(['session folder ignored, Session: ',sessName])
                disp('_____________________________________________________________________')   
            
            else
                % get data loaded
                    dataSet = MAIN_load_rcs_data_from_folder(fs);

                    if ~isempty(dataSet)
                        % load device settings, stim settings and events
                        fd = fullfile(fs,'DeviceSettings.json');
                        deviceSettings = loadDeviceSettings(fd);
                        stimSettings = loadStimulationSettings(fd);
                        fe = fullfile(fs,'EventLog.json');
                        eventLog = loadEventLog(fe);

                        % gets segment data from data set
                        startDSTime = deviceSettings.timeStart;
                        tFixed = datetime(startDSTime.Year,startDSTime.Month,startDSTime.Day,...
                                    tfixed,0,0);                        
                        tbefmed = datetime(tFixed - minutes(tw1),'TimeZone','local');
                        taftmed = datetime(tFixed + minutes(tw2),'TimeZone','local');

                        tstartdata = datetime(dataSet.derivedTimes(1),'TimeZone','local');
                        tenddata = datetime(dataSet.derivedTimes(end),'TimeZone','local');

                        %% check if time window within segment of data
                        if tbefmed >= tstartdata && taftmed <= tenddata 
                            counter = counter + 1;
                            disp(['folders containing time window: ',num2str(counter)])
                            locStart = find(datetime(dataSet.derivedTimes,'TimeZone','local') > tbefmed,1);
                            locEnd = find(datetime(dataSet.derivedTimes,'TimeZone','local') > taftmed,1);
                            dataSegment = dataSet(locStart:locEnd,:);
%                             plotRawDataSegment(dataSegment,tFixed,'tFixMed')

                            % extract event types and subtypes (e.g. symptoms, other comments) within time windw
                            if ~isempty(eventLog)
                                locEventsTw = find(eventLog.HostUnixTime> tbefmed & eventLog.HostUnixTime < taftmed);           
                                disp(['total number of events in med time window = ',num2str(length(locEventsTw))])
                                allEventsTw = table();
                                for jj=1:length(locEventsTw)
                                    allEventsTw.EventNumber(jj,:) = jj;
                                    allEventsTw.HostUnixTime(jj,:) = eventLog.HostUnixTime(locEventsTw(jj));
                                    allEventsTw.Type(jj,:) = eventLog.EventType(locEventsTw(jj));
                                    allEventsTw.SubTypes(jj,:) = eventLog.EventSubType(locEventsTw(jj));
                                end

                                disp('all events within time window:')
                                allEventsTw
                                disp('_____________________________________________________________________')                        

                            end
                            % time med is fixed by researcher
                            allMedEvents = table();
                            medEvent = ['time is defined by researcher: ',char(tFixed)];
                            disp('_____________________________________________________________________')

                            % concatenate output table and include events within data segment
                            output = fillNextOutputRow(output,counter,ii,tFixed,[tbefmed taftmed],allMedEvents,...
                                                allEventsTw,medEvent,dataSegment,deviceSettings,stimSettings);

                        end
                    else
                        disp('Empty data set ignored')
                    end
            end
        end
    end
end

disp('_____________________________________________________________________')
disp(['total folders extracted containing time window requirement : ',num2str(counter)])
head(output)
disp('_____________________________________________________________________')

if saveOutputData && counter > 1
    save(fullfile(fp,'/output_data_fixed_med_time_table.mat'),'output')
end

% end
