%% Pipeline functions for basic manipulation of RCS data

% to add toolboxes with basic functions and keep a simple root directory
% 'toolboxes' contains the basic needed functions to extract the data
addpath(genpath(fullfile(pwd,'toolboxes')));

% transforms .json to .mat files and gives database overview in folder
MAIN_load_rcs_data_from_folder(PATH_TO_SESSION_FOLDER)
MAIN_load_rcsdata_from_folders(PATH_TO_SESSIONS_FOLDER)

% read device settings
loadDeviceSettings(PATH_TO_DEVICESETTINGS_JSON)

% read event logs
loadEventLog(PATH_TO_EVENTLOG_JSON)

% load power data
loadPowerData(PATH_TO_RAWPOWERDATA_JSON)