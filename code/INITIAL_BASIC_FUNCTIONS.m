%% Pipeline functions for basic manipulation of RCS data

close all; clear all; clc

% path to RCS data
PATH_TO_SESSION_FOLDER = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS09/09-15-2020_dataPoint_titration_0.1mA/SCBS/RCS09L';

% to add toolboxes with basic functions and keep a simple root directory
% 'toolboxes' contains the basic needed functions to extract the data
% includeToolbox
addpath(genpath(fullfile(pwd,'toolboxes')));

% transforms .json to .mat files and gives database overview in folder
MAIN_load_rcsdata_from_folders(PATH_TO_SESSION_FOLDER)

% read device settings
deviceSettingsPaths = findFilesBVQX(PATH_TO_SESSION_FOLDER,'DeviceSettings.json');
devicesettings = loadDeviceSettings(char(deviceSettingsPaths(1)))

% read event logs
loadEventLog(PATH_TO_EVENTLOG_JSON)

% load power data
loadPowerData(PATH_TO_RAWPOWERDATA_JSON)