function [stimAmplitudes,idxStimEvent] = getProgrammingAmplitudeChanges(eventTable)

%% extracts stimulation amplitude changes during programming session

countStimEvents = 0;
for ii=1:size(eventTable,1)
    % this codes are used in Event log to denote an change in amplitude or
    % an increment in amplitude of stimulation
    if contains(eventTable.EventType{ii,:},'013') || contains(eventTable.EventType{ii,:},'015')
        
        countStimEvents = countStimEvents + 1;
        idxStimEvent(countStimEvents) = ii;
        tempStr = char(eventTable.EventType(ii));
        
        if isnumeric(str2num(tempStr(end)))
            lastDigit = str2num(tempStr(end));
        else
            lastDigit = [];
        end
        
        if strcmp(tempStr(end-1),'.')
            colonChar = tempStr(end-1);
        else
            colonChar = [];
        end
        
        if isnumeric(str2num(tempStr(end-2)))
            firstDigit = str2num(tempStr(end-2));
        else
            firstDigit = [];
        end
        
        if ~isempty(firstDigit) && ~isempty(colonChar) && ~isempty(lastDigit) 
            stimAmplitudes{countStimEvents,:} = [num2str(firstDigit),colonChar,num2str(lastDigit)];
        elseif ~strcmp(colonChar,'.')
            stimAmplitudes{countStimEvents,:} = [num2str(lastDigit),'.',num2str(0)];
        end
    end
    
end