function plot_adaptive_data(varargin)
% plot basic adaptive data from one session
% assumes no changes in adaptive settings
% in future versions we should include checks for variuous sessions

TD_CH_NUM_PLOT = 1;

includeToolbox

if length(varargin) > 0
    pathsessionfolder = vararing{1};
else
    pathsessionfolder = '/Users/juananso/Box Sync/juan_roee_data_share/Adaptive/DataSets/shortRecordingNoChangesDataSet/Session1585158666205';
end

% GET TIME DOMAIN SIGNALS
% ch0: subcortical signal 1
% ch1: subcortical signal 2
% ch2: coritcal signal 1 (S1)
% ch3: coritcal signal 2 (M1)
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerTable] = MAIN_load_rcs_data_from_folder(pathsessionfolder);

sr = unique(getSampleRate(outdatcomplete.samplerate));
[t,Y] = preprocessTDSignals(outdatcomplete,1,sr);
[Sp,Fp,Tp,specRes] = computeSpectrogram(Y,sr,[1 50],[1 50]);

% GET POWER DATA
% pb1: power band 0
% pb2: power band 1
% pb3: power band 2
% pb4: power band 3
% ... (up to power band 8)
pb1 = powerTable.powerTable.Band1;
pb2 = powerTable.powerTable.Band2;

uxtimesPower = datetime(powerTable.powerTable.PacketGenTime/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
yearUsePower = mode(year(uxtimesPower)); 
idxKeepYearPower = year(uxtimesPower)==yearUsePower;

% GET DETECTOR DATA (LD thresholds, LD0, current, and state)
% adaptive and detector settings tables
% ld0: linear discriminant detector 0
% ld1: linear discriminant detector 1
fnDeviceSettings = char(fullfile(findFilesBVQX(pathsessionfolder,'DeviceSettings.json')));
adaptiveTable = getAdaptiveSettings(fnDeviceSettings);
detectorTable = getDetectorSettings(fnDeviceSettings);
fnAdaptive = char(fullfile(findFilesBVQX(pathsessionfolder,'AdaptiveLog.json')));
adaptiveStruct = readAdaptiveJson(fnAdaptive);
ld0 = adaptiveStruct.adaptive.LD0_output;

uxtimesDetec = datetime(powerTable.powerTable.PacketGenTime/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
yearUseDetec = mode(year(uxtimesDetec)); 
idxKeepYearDetec = year(uxtimesDetec)==yearUseDetec;

% PREPROCESS TIME DOMAIN SIGNALS
% bandpassfilt: butterworth(1,100) 

% PLOTS
% Panel 1: time domain (raw, bandpassfilt)
% Panel 2: spectrogram
% Panel 3: power bands
% Panel 4: current
% Panel 5: state

%% TO DO:
- decide on x axis (seconds or datetime)
- implement that for each of the panels

    
end