% function create_pat_database_around_med_event(fp, tw1, tw2, saveOutputData, plotInstanceRawData)
%% creates database of Off/On med data sets
% Input arguments
% fn: pointer to folder path to a patient's side sessions folder
% tw1: time window 1, minutes before med taken to extract from dataset
% tw2: time window 2, minutes after med taken to extract from dataset
% savedata: (0,1) indicates if data should be saved (output.mat) file in fn
% plotinstance: (0,1) indicates if 1 raw data segment data to be plotted

close all; clear all; clc; warning off;

%% this section is to enter the variables while creating function+debugging
patNumStr = 'RCS09';
saveOutputData = 1;
plotInstanceRawData = 1;

tw1 = 5;   % minutes before med taken
tw2 = 60;   % minutes after med taken
xMorning = 8;   % ### not being used for now
xEvening = 18;  % ### not being used for now
medTypes = {'Rytary', 'Baclofen','Sinemet'}; % ### not being used for now

%% first instance of folder localization (### for now just lookin in SCBS)
fp1 = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/';
fp2 = [patNumStr,' Un-Synced Data/SummitData/'];
fp3 = ['SummitContinuousBilateralStreaming/',patNumStr];

%% for each side (Left, Right)
for numSides=1:2

    if numSides==1
        ffside = fullfile(fp1,fp2,[fp3,'L','/']);
        disp('##################### LEFT SIDE ######################')
    elseif numSides==2
        ffside = fullfile(fp1,fp2,[fp3,'R','/']);
        disp('##################### RIGT SIDE ######################')
    end
    
    %% short ouput form of patient's folder ID information

    disp(['data set corresponding to "...', ffside(end-41:end),'"'])
    disp('_____________________________________________________________________')

    %% access all event data in folder
    eventData = extractEventData(ffside);
    disp('all Event data in folder concatenated...')
    disp('_____________________________________________________________________')

    %% point into data based on event input: medication time
    allEventData = eventData.allEvents;
    allMedEvents = allEventData.medEvents
    allMedTimes = allMedEvents.medTimes
    disp(['overall number of medication events = ', num2str(size(allMedTimes,1))])
    disp('_____________________________________________________________________')

    %% look different days, var = 0 means for any kind of med
    [medDays,locsMeds] = getMedDays(allMedEvents, 0);
    disp('different days of meds taken (and seession start date time): ')
    medDays
    disp('_____________________________________________________________________')

    %% for each day, extract first and last med time
    ii = 1;
    firstLastMedPerDay = table();
    countTable = 1;

    while ii<=length(allMedTimes)
        nextMedTime = allMedTimes(ii);
        nextDay = nextMedTime.Day;
        locs = find(allMedTimes.Day(ii:end) == nextDay);
        locsInMonth = find(locs<31);
        medTimesInDay = allMedTimes(ii-1+locsInMonth);
        firstLastMedPerDay.locFirstMedTime(countTable) = ii;
        firstLastMedPerDay.firstMed(countTable) = medTimesInDay(1);
        firstLastMedPerDay.locLastMedTime(countTable) = ii+locsInMonth(end)-1;
        firstLastMedPerDay.lastMed(countTable) = medTimesInDay(end);
        ii = ii + locsInMonth(end);
        countTable = countTable + 1;
    end

    %  ### not being used for now ### % search morning, evening med consistency
    locs1MedDay = find(firstLastMedPerDay.locFirstMedTime == firstLastMedPerDay.locLastMedTime);
    firstLastMedPerDay.only1Med(locs1MedDay) = 1;
    locsMorn = find(firstLastMedPerDay.firstMed.Hour < xMorning);
    firstLastMedPerDay.MorningTime(locsMorn) = 1;
    locsEve = find(firstLastMedPerDay.lastMed.Hour > xEvening);
    firstLastMedPerDay.EveningTime(locsEve) = 1;
    %  ### not being used for now ###

    disp('first and last med taken per day:')
    firstLastMedPerDay
    disp('_____________________________________________________________________')

    %% loop for each Med
    output = table();
    counter = 0;
    disp('looping for all med events...')

    for ii= 1:size(allMedEvents,1)
        disp([num2str(ii),' from ', num2str(size(allMedEvents,1)), ' ...'])
        nextEvent = allMedEvents(ii,:);
        sessionTime = datetime(allMedEvents.sessionTime(ii),'TimeZone','local');
        nextMedTime = datetime(allMedEvents.medTimes(ii),'TimeZone','local');

        tbefmed = nextMedTime - minutes(tw1);
        taftmed = nextMedTime + minutes(tw2);

        fs = fullfile(ffside,['Session',char(allMedEvents.sessionid(ii))]);    

        % remove outlier datasets
        % 1) incomplete data set pat RCS03L, Session1580263974773
        % 2) malformed device settings .json RCS03R, Session1581098896109
        % 3) malformed device settings .json RCS03R, Session1581229068622
        if strcmp(ffside(end-41:end),'SummitContinuousBilateralStreaming/RCS03L/') && (ii==51 || ii==52)...
            || (strcmp(ffside(end-41:end),'SummitContinuousBilateralStreaming/RCS03R/') && (ii==38 || ii==40 || ii==45 || ii==46))
            dataSet = [];
            disp(':( missing or corrupt .josn (time domain or device settings)')
            disp(['session folder ignored, Session: ',char(allMedEvents.sessionid(ii))])
            disp(['med event ignored, event: ',char(allMedEvents.EventSubType(ii))])
            disp('_____________________________________________________________________')        
        else
            disp(['session time: ',char(allMedEvents.sessionTime(ii))])
            disp(['folder Session: ',char(allMedEvents.sessionid(ii))])
            [outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] = MAIN_load_rcs_data_from_folder(fs);          
        end

        if ~isempty(outdatcomplete)
            tstartdata = datetime(outdatcomplete.derivedTimes(1),'TimeZone','local');
            tenddata = datetime(outdatcomplete.derivedTimes(end),'TimeZone','local');

            % check if requirement for med analysis timewindow is met
            if tbefmed >= sessionTime && taftmed <= tenddata 
                counter = counter + 1;
                locStart = find(datetime(outdatcomplete.derivedTimes,'TimeZone','local') > tbefmed,1);
                locEnd = find(datetime(outdatcomplete.derivedTimes,'TimeZone','local') > taftmed,1);
                dataSegment.neural = outdatcomplete(locStart:locEnd,:);
                
                locStart = find(datetime(outdatcompleteAcc.derivedTimes,'TimeZone','local') > tbefmed,1);
                locEnd = find(datetime(outdatcompleteAcc.derivedTimes,'TimeZone','local') > taftmed,1);
                dataSegment.acceler = outdatcompleteAcc(locStart:locEnd,:);
                
                if plotInstanceRawData && counter == 1 % just for 1st instance
                        plotRawDataSegment(dataSegment,nextMedTime,'tmed')
                end

                % access sense settings
                dirFiles = dir(fs);
                for jj = 1:size(dirFiles,1)
                    lengthsF(jj) = length(dirFiles(jj).name);
                end
                locDevF = find(lengthsF >= 15,1);
                deviceName = dirFiles(locDevF).name;
               
                ffdevice = fullfile(fs,deviceName,'DeviceSettings.json');
                deviceSettings = loadDeviceSettings(ffdevice);
                stimSettings = loadStimulationSettings(ffdevice);

                % extract event types and subtypes (e.g. symptoms, other comments) within time windw
                locEventsTw = find(allEventData.eventOut.HostUnixTime > tbefmed & allEventData.eventOut.HostUnixTime < taftmed);           

                disp(['total number of events in med time window = ',num2str(length(locEventsTw))])
                allEventsTw = table();
                for jj=1:length(locEventsTw)
                    allEventsTw.EventNumber(jj,:) = jj;
                    allEventsTw.HostUnixTime(jj,:) = allEventData.eventOut.HostUnixTime(locEventsTw(jj));
                    allEventsTw.Type(jj,:) = allEventData.eventOut.EventType(locEventsTw(jj));
                    allEventsTw.SubTypes(jj,:) = allEventData.eventOut.EventSubType(locEventsTw(jj));
                end

                disp('all events within time window:')
                allEventsTw
                disp('_____________________________________________________________________')

                % extract time events within timewindow around med time
                locsEvMedWin = find(allMedEvents.HostUnixTime >= tbefmed & ...
                                    allMedEvents.HostUnixTime <= taftmed);

                disp(['total number med events in med time window = ',num2str(length(locsEvMedWin))])
                medEvents = table();
                for jj=1:length(locsEvMedWin)
                    medEvents.EventNumber(jj,:) = jj;
                    medEvents.HostUnixEventTime(jj,:) = allMedEvents.HostUnixTime(locsEvMedWin(jj));
                    medEvents.Type(jj,:) = allMedEvents.EventType(locsEvMedWin(jj));
                    medEvents.SubType(jj,:) = allMedEvents.EventSubType(locsEvMedWin(jj));
                end
                disp('table of events within med time window:')
                medEvents
                disp('_____________________________________________________________________')

                % concatenate output table and include events within data segment
                output = fillNextOutputRow(output,counter,ii,nextMedTime,[tbefmed taftmed],allMedEvents,...
                                    allEventsTw,medEvents,dataSegment,deviceSettings,stimSettings);

            end
        end

    end

    disp('_____________________________________________________________________')
    disp(['total events extracted with time window requirement : ',num2str(counter)])
    head(output)
    disp('_____________________________________________________________________')

    if saveOutputData && counter > 1
        save(fullfile([ffside,'db_event_medTime_tb',num2str(tw1),'_ta',num2str(tw2),'.mat']),'output','-v7.3')
    end

end

% end
