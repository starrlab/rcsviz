function [adaptivechanges,detectorChanges,adaptiveSettings] = temp_reading_adaptive_sessions_changes(varargin)
% this is a tester function to run and analyze output of different
% prototype functions to read adaptive changes from deviceSettings.json

%% add toolbox  
pathrcscode = '/Users/juananso/Dropbox (Personal)/Work/Git_Repo/rcsanalysis/matlab';
addpath(pathrcscode);
    
%% this is only used if deviceSettings.json not passed as input argument
% long session with lots of changes
FOLDER_PATH = fullfile(pwd, '/DataSets/longRecordingsManyChangesDataSet/RCS08R/Session1589320314167/DeviceNPC700421H'); 
% short session with few other no changes
% FOLDER_PATH = fullfile(pwd, '/DataSets/shortRecordingNoChangesDataSet/Session1585158666205/DeviceNPC700239H');  

if ~isempty(varargin) && isfolder(varargin)
    datadir = varargin{1};
else %% init directory in case not passed as argument
    datadir = FOLDER_PATH;
end

%% load data
fprintf('loading all data...\n')

% this prototype function detects if embedded is turned on
adaptivechanges = getAdaptiveChanges(fullfile(datadir,'DeviceSettings.json'));

% this prototype function reads out all changes in the detector settings
detectorChanges = getDetectorSettings(fullfile(datadir,'DeviceSettings.json'));

% this prototype function reads out all changes in the adaptive settings
adaptiveSettings = getAdaptiveSettings(fullfile(datadir,'DeviceSettings.json'));

% comparing the time points when 'embedded turned on' (adaptive on) 
plot(adaptivechanges.timeChange,ones(1,size(adaptivechanges,1)),'om','MarkerSize',10), hold on

% with the time points when a setting was changed in the detector
plot(detectorChanges.timeChange,ones(1,size(detectorChanges,1)),'xb','MarkerSize',10)

end