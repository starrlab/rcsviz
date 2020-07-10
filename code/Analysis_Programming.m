
%% plotting RCS sense data from a session folder for basic visualization
close all; clear all; clc
includeToolbox();

%% input parameters
plotMontage = 0;
loadAllDataInSessionsFolder = 0;
concatenateAllevents = 0;

%% data paths
% datapathAll = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593205514505/DeviceNPC700436H';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593206205651/DeviceNPC700436H';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593207192304/DeviceNPC700436H';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593208334311/DeviceNPC700436H';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593208710319/DeviceNPC700436H';

subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593621265584/DeviceNPC700430H';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593622890480/DeviceNPC700430H';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593623681795/DeviceNPC700430H';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593624709046/DeviceNPC700430H';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593625251718/DeviceNPC700430H';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593627135536/DeviceNPC700430H';

%% create data base log file
if loadAllDataInSessionsFolder
    MAIN_load_rcsdata_from_folders(datapathAll);
end

%% Looking at the event data
if concatenateAllevents
    concantenate_event_data(datapathAll);
end

eventTable = loadEventLog([subfoldpath,'/EventLog.json'])

%% extract programming inforamtion
countStimEvents = 0;
for ii=1:size(eventTable,1)
    % extract therapy group
    if contains(eventTable.EventType{ii,:},'001') 
        stimTherapyStr = eventTable.EventType(ii);
    else
        stimTherapyStr = [];
    end
    % extract stim amplitudes    
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

% extracting the stim Amp value
stimAmplitudesNum = str2num(char(stimAmplitudes{:,:}));

figure, title(stimTherapyStr), fontSize = 12;
ax1 = subplot(10,1,1);
plot(datenum(eventTable.UnixOnsetTime(idxStimEvent)),stimAmplitudesNum), hold on, plot(datenum(eventTable.UnixOnsetTime(idxStimEvent)),stimAmplitudesNum,'o')
datetick('x', 'HH:MM:SS',  'keepticks');

%% Access time domain raw data for all channels
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] = MAIN_load_rcs_data_from_folder(subfoldpath);

%% access device settings/sense channels
deviceSettings = loadDeviceSettings([subfoldpath,'/DeviceSettings.json']);
for ii=1:size(deviceSettings,2)
    deviceSettings(ii).timeStart
    deviceSettings(ii).timeEnd
    deviceSettings(ii).duration
    deviceSettings(ii).tdData.chanFullStr
end

%%%% here
stimSettings = loadStimulationSettings([subfoldpath,'/DeviceSettings.json'])
    
%% plot neural data
if strcmp(deviceSettings(1).tdData(1).sampleRate,'500Hz')
    sr = 500;
end

y0 = outdatcomplete.key0; y0 = (y0-mean(y0))*1e3; 
y1 = outdatcomplete.key1; y1 = (y1-mean(y1))*1e3;
y2 = outdatcomplete.key2; y2 = (y2-mean(y2))*1e3;
y3 = outdatcomplete.key3; y3 = (y3-mean(y3))*1e3;

t = outdatcomplete.derivedTimes;

% compute spectrogram 
specRes = 500e-3; % seconds
overlapPerc = 80;
minThreshold = -1;
t0 = seconds(specRes);

% pallidal
freqBnd = [5 30];
[sp0,fp0,tp0] = pspectrum(y0,sr,'spectrogram','Leakage',1,'OverlapPercent',overlapPerc, ...
    'MinThreshold',minThreshold,'FrequencyLimits',freqBnd,'TimeResolution', specRes);

tp0dur = seconds(tp0); tp0_date = t0+t(1)+tp0dur; 

[sp1,fp1,tp1] = pspectrum(y1,sr,'spectrogram','Leakage',1,'OverlapPercent',overlapPerc, ...
    'MinThreshold',minThreshold,'FrequencyLimits',freqBnd,'TimeResolution', specRes);
tp1dur = seconds(tp1); tp1_date = t0+t(1)+tp1dur; 

% cortex
freqBnd = [5 100];
[sp2,fp2,tp2] = pspectrum(y2,sr,'spectrogram','Leakage',1,'OverlapPercent',overlapPerc, ...
    'MinThreshold',minThreshold,'FrequencyLimits',freqBnd,'TimeResolution', specRes);
tp2dur = seconds(tp2); tp2_date = t(1)+tp2dur; 

[sp3,fp3,tp3] = pspectrum(y3,sr,'spectrogram','Leakage',1,'OverlapPercent',overlapPerc, ...
    'MinThreshold',minThreshold,'FrequencyLimits',freqBnd,'TimeResolution', specRes);
tp3dur = seconds(tp3); tp3_date = t(1)+tp3dur; 

ax2 = subplot(10,1,2);
plot(datenum(t),y0)
datetick('x', 'HH:MM:SS',  'keepticks');
ax3 = subplot(10,1,3);
pcolor(datenum(tp0_date),fp0,10*log10(abs(sp0))); shading flat
datetick('x', 'HH:MM:SS',  'keepticks');
set(ax2,'xlim',[datenum(t(1)) datenum(t(end)+seconds(2))])
set(ax3,'xlim',[datenum(tp0_date(1)) datenum(tp0_date(end)+seconds(2))])

ax4 = subplot(10,1,4);
plot(datenum(t),y1)
datetick('x', 'HH:MM:SS',  'keepticks');
ax5 = subplot(10,1,5);
pcolor(datenum(tp1_date),fp1,10*log10(abs(sp1))); shading flat
datetick('x', 'HH:MM:SS',  'keepticks');
set(ax4,'xlim',[datenum(t(1)) datenum(t(end)+seconds(2))])
set(ax5,'xlim',[datenum(tp1_date(1)) datenum(tp1_date(end)+seconds(2))])

ax6=subplot(10,1,6);
plot(datenum(t),y2)
datetick('x', 'HH:MM:SS',  'keepticks');
ax7=subplot(10,1,7);
pcolor(datenum(tp2_date),fp2,10*log10(abs(sp2))); shading flat 
datetick('x', 'HH:MM:SS',  'keepticks');
set(ax6,'xlim',[datenum(t(1)) datenum(t(end)+seconds(2))])
set(ax7,'xlim',[datenum(tp3_date(1)) datenum(tp3_date(end)+seconds(2))])

ax8=subplot(10,1,8);
plot(datenum(t),y3)
datetick('x', 'HH:MM:SS',  'keepticks');
ax9=subplot(10,1,9);
pcolor(datenum(tp3_date),fp3,10*log10(abs(sp3))); shading flat
datetick('x', 'HH:MM:SS',  'keepticks');
set(ax8,'xlim',[datenum(t(1)) datenum(t(end)+seconds(2))])
set(ax9,'xlim',[datenum(tp3_date(1)) datenum(tp3_date(end)+seconds(2))])

% plot acc data
acc.x = outdatcompleteAcc.XSamples-mean(outdatcompleteAcc.XSamples);
acc.y = outdatcompleteAcc.YSamples-mean(outdatcompleteAcc.YSamples);
acc.z = outdatcompleteAcc.ZSamples-mean(outdatcompleteAcc.ZSamples);
acc.norm = sqrt(acc.x.^2+acc.y.^2+acc.z.^2);
tacc = outdatcompleteAcc.derivedTimes;
ax10=subplot(10,1,10);
hold on
plot(datenum(tacc),acc.norm)
% ,'b',tacc,acc.y,'g',tacc,acc.z,'m',tacc,acc.norm,'k')
datetick('x', 'HH:MM:SS',  'keepticks');

set(ax1,'xlim',[datenum(min(tacc)) datenum(max(tacc))])
set(ax1,'ylim',[0 max(stimAmplitudesNum)])

linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10],'x')

%% calculate PSD of neral data between changes in stim amplitude
t_stim_delta = eventTable.UnixOnsetTime(idxStimEvent);
figure(10); title(stimTherapyStr)
for ii=1:length(t_stim_delta)-1
    t1 = t_stim_delta(ii);
    t2 = t_stim_delta(ii+1);
    % extract neural data btw t1 & t2
    t_idx = find(t>t1 & t<t2);
    % refine t_idx to avoid first 20% of data (contains dc shift)
    t_idx2 = t_idx(round(length(t_idx)/5):end); 
    if ~isempty(t_idx) && (ii==1 || ii==(length(t_stim_delta)-1))
        [fftOut,ff]   = pwelch(y0(t_idx2),sr,sr/2,0:1:sr/2,sr,'psd');
        figure(10); ax1 = subplot(221); hold on
        plot(ff,log10(fftOut),'DisplayName',['Amp = ',num2str(stimAmplitudesNum(ii))])
        legend('-DynamicLegend');
        figure(1); subplot(10,1,2); hold on; plot(datenum(t(t_idx)),y0(t_idx),'o')
        [fftOut,ff]   = pwelch(y1(t_idx2),sr,sr/2,0:1:sr/2,sr,'psd');
        figure(10); ax3 = subplot(223); hold on
        plot(ff,log10(fftOut),'DisplayName',['Amp = ',num2str(stimAmplitudesNum(ii))])    
        legend('-DynamicLegend');
        [fftOut,ff]   = pwelch(y2(t_idx2),sr,sr/2,0:1:sr/2,sr,'psd');
        ax2 = subplot(222); hold on
        plot(ff,log10(fftOut),'DisplayName',['Amp = ',num2str(stimAmplitudesNum(ii))])
        legend('-DynamicLegend');
        [fftOut,ff]   = pwelch(y3(t_idx2),sr,sr/2,0:1:sr/2,sr,'psd');
        ax4 = subplot(224); hold on
        plot(ff,log10(fftOut),'DisplayName',['Amp = ',num2str(stimAmplitudesNum(ii))])
        legend('-DynamicLegend');
    end
end

set([ax1,ax2,ax3,ax4],'xlim',[0 100])
%% Montage
%  1) first time analysing montage data, run
%       - open_and_save_montage_data_in_sessions_directory(mainFolderSessions)
%       - plot_compare_montage_data_from_saved_montage_files((mainFolderSessions)
if plotMontage
    plot_compare_montage_data_from_saved_montage_files(datapathAll,'500Hz')
end

