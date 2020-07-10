function stimStatus = loadStimulationSettings(fn)

%%%%%%%%%%%%%%% this code is pasted from rcsanalysis (repo) work on progress
%%%%%%%%%%%%%%% loadDeviceSettingsForMontage.m Juan/Ro'ee

%% load stimulation config (this )
% this code (re stim sweep part) assumes no change in stimulation from initial states
% this code will fail for stim sweeps or if any changes were made to
% stimilation 
% need to fix this to include stim changes and when the occured to color
% data properly according to stim changes and when the took place for in
% clinic testing 

DeviceSettings = jsondecode(fixMalformedJson(fileread(fn),'DeviceSettings'));

% fix issues with device settings sometiems being a cell array and
% sometimes not 
if isstruct(DeviceSettings)
    DeviceSettings = {DeviceSettings};
end

if isstruct(DeviceSettings)
    DeviceSettings = {DeviceSettings};
end
therapyStatus = DeviceSettings{1}.GeneralData.therapyStatusData;
groups = [ 0 1 2 3]; 
groupNames = {'A','B','C','D'}; 
stimState = table(); 
cnt = 1; 
for g = 1:length(groups) 
    fn = sprintf('TherapyConfigGroup%d',groups(g));
    for p = 1:4
        if DeviceSettings{1}.TherapyConfigGroup0.programs(p).isEnabled==0
            stimState.group(cnt) = groupNames{g};
            if (g-1) == therapyStatus.activeGroup
                stimState.activeGroup(cnt) = 1;
                if therapyStatus.therapyStatus
                    stimState.stimulation_on(cnt) = 1;
                else
                    stimState.stimulation_on(cnt) = 0;
                end
            else
                stimState.activeGroup(cnt) = 0;
                stimState.stimulation_on(cnt) = 0;
            end
            
            stimState.program(cnt) = p;
            stimState.pulseWidth_mcrSec(cnt) = DeviceSettings{1}.(fn).programs(p).pulseWidthInMicroseconds;
            stimState.amplitude_mA(cnt) = DeviceSettings{1}.(fn).programs(p).amplitudeInMilliamps;
            stimState.rate_Hz(cnt) = DeviceSettings{1}.(fn).rateInHz;
            elecs = DeviceSettings{1}.(fn).programs(p).electrodes.electrodes;
            elecStr = ''; 
            for e = 1:length(elecs)
                if elecs(e).isOff == 0 % electrode active 
                    if e == 17
                        elecUse = 'c'; 
                    else
                        elecUse = num2str(e-1);
                    end
                    if elecs(e).electrodeType==1 % anode 
                        elecSign = '-';
                    else
                        elecSign = '+';
                    end
                    elecSnippet = [elecSign elecUse ' '];
                    elecStr = [elecStr elecSnippet];
                end
            end

            stimState.electrodes{cnt} = elecStr; 
            cnt = cnt + 1; 
        end
    end
end 
if ~isempty(stimState)
    stimStatus = stimState(logical(stimState.activeGroup),:);
else
    stimStatus = [];
end

end