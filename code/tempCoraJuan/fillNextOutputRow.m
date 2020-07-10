function out = fillNextOutputRow(out,counter,ii,nextMedTime,twindow,allMedEvents,...
                                    allEventsTw,medEvents,dataSegment,deviceSettings,stimSettings)
%% creates output table with each of the follwoing column elements
% MedTime, sesionID, MedType, Events in data, derivedTimes, sr, lfps/ecogs, channel numbers

    out.MedTime(counter) = nextMedTime;
    out.timeWindow{counter} = twindow;
    if ~isempty(allMedEvents)
        out.SessionID(counter) = allMedEvents.sessionid(ii);
        out.MedType(counter) = allMedEvents.EventSubType(ii);
    end
    out.Annotations{counter} = allEventsTw;
    if ~isempty(medEvents)
        out.MedEvents{counter} = medEvents;
    end
    out.derivedTimes{counter} = dataSegment.neural.derivedTimes; % gets brain signals, sr, derivedTimes
    % sample rate, record unique value unless there is change of sr
    
    loc = find(diff(dataSegment.neural.samplerate)~=0);
    if isempty(loc)
        out.sampleRate(counter) = dataSegment.neural.samplerate(1);
    else
        out.sampleRate{counter} = dataSegment.neural.samplerate;
    end

    out.key0{counter} = dataSegment.neural.key0; % gets brain signals, sr, derivedTimes
    out.ch0{counter} = strcat('-',char(deviceSettings.tdData(1).minusInput),',+',deviceSettings.tdData(1).plusInput);

    out.key1{counter} = dataSegment.neural.key1; % gets brain signals, sr, derivedTimes
    out.ch1{counter} = strcat('-',char(deviceSettings.tdData(2).minusInput),',+',deviceSettings.tdData(2).plusInput);

    out.key2{counter} = dataSegment.neural.key2; % gets brain signals, sr, derivedTimes
    out.ch2{counter} = strcat('-',char(deviceSettings.tdData(3).minusInput),',+',deviceSettings.tdData(3).plusInput);

    out.key3{counter} = dataSegment.neural.key3; % gets brain signals, sr, derivedTimes
    out.ch3{counter} = strcat('-',char(deviceSettings.tdData(4).minusInput),',+',deviceSettings.tdData(4).plusInput);
    
    %% add accelerometer data
    out.accelerData{counter} = dataSegment.acceler;
    
    %% add stim settings data
    if ~isempty(stimSettings)
        out.Stim_on(counter) = stimSettings.stimulation_on;
        out.StimSettings{counter} = stimSettings;
    else
        out.Stim_on(counter) = NaN;
        out.StimSettings{counter} = NaT;
    end
    
end