%% plotting RCS sense data from a session folder for basic visualization

includeToolbox;
addpath(genpath(fullfile(pwd,'tempCoraJuan')));

%% access folder
datapathroot = fullfile('/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/',...
                         'RCS10 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS10L/');
sessionfolder = 'Session1592585002796'; % montage
sessionfolder = 'Session1592585677141'; % UDPRS
sessionfolder = 'Session1592587303476'; % off to on transition
datapath = setJsonDataPath(datapathroot,sessionfolder)

%% basic raw data plotting
datapath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/montages/RCS10R/Session1593204818806/DeviceNPC700430H';

%% Device settings
deviceSettings = loadDeviceSettings([datapath,'/DeviceSettings.json']);
eventLog = loadEventLog([datapath,'/EventLog.json']);
stimSettings = loadStimulationSettings([datapath,'/DeviceSettings.json']);   % this is from loadDeviceSettingsForMontage.m (rcsanalysis)
plot_raw_rcs_data(datapath)