
%% plotting RCS sense data from a session folder for basic visualization
close all; clear all; clc
includeToolbox();

%% input parameters
plotMontage = 0;
loadAllDataInSessionsFolder = 0;
concatenateAllevents = 0;

%% data paths
% datapathAll = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593205514505/DeviceNPC700436H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593206205651/DeviceNPC700436H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593207192304/DeviceNPC700436H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593208334311/DeviceNPC700436H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593208710319/DeviceNPC700436H';
% 
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593621265584/DeviceNPC700430H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593622890480/DeviceNPC700430H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593623681795/DeviceNPC700430H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593624709046/DeviceNPC700430H';
subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593625251718/DeviceNPC700430H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593627135536/DeviceNPC700430H';

%% create data base log file
if loadAllDataInSessionsFolder
    MAIN_load_rcsdata_from_folders(datapathAll);
end

%% looking at the event data
if concatenateAllevents
    concantenate_event_data(datapathAll);
end

eventTable = loadEventLog([subfoldpath,'/EventLog.json'])

%% access device settings/sense channels
[senseSettings,stimActiveSettings,stimGroups] = loadSenseStimSettings([subfoldpath,'/DeviceSettings.json']);
% identify settings closer to programming
% sensesetings during programming, subeventtype codes:change stim Amp ('015'), incremebt stim amp ('013')
stimIncIdx = find(contains(eventTable.EventType,'013') | contains(eventTable.EventType,'015'));
if size(senseSettings,1) > 1
    for ii=1:size(senseSettings,1)
        time_dist(ii) = abs(senseSettings.timeStart(ii)-eventTable.HostUnixTime(stimIncIdx(1)));
    end
end
[val,idx] = min(time_dist);
senseSettingsProgr = senseSettings(idx,:);

%% extract programming inforamtion
[stimAmplitudes,idxStimEvent] = getProgrammingAmplitudeChanges(eventTable);
stimAmplitudesNum = str2num(char(stimAmplitudes{:,:}));

%% Create main Figure/Pannel
strName = ['Stim electrodes: ',char(stimActiveSettings.electrodes), ...
            ', PW = ',num2str(stimActiveSettings.pulseWidth_mcrSec),...
                ', rate = ', num2str(stimActiveSettings.rate_Hz)];
fig1 = figure(1), fontSize = 16;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [1/2, 0, 1/2, 1]);

% top pannel contains programming amplitudes
ax1 = subplot(10,1,1);
plot(datenum(eventTable.UnixOnsetTime(idxStimEvent)),stimAmplitudesNum), hold on
stem(datenum(eventTable.UnixOnsetTime(idxStimEvent)),stimAmplitudesNum,'o')
text(datenum(eventTable.UnixOnsetTime(idxStimEvent)),stimAmplitudesNum+0.2,stimAmplitudes)
title(strName)  
ylabel('stim (mA)')
datetick('x', 'HH:MM:SS',  'keepticks');
legend('stim ampl trend','next stim value')
set( findall(fig1, '-property', 'fontsize'), 'fontsize', fontSize)

%% Access time domain raw data for all channels
[outdatcomplete,outRec,eventTable,outdatcompleteAcc,powerOut,adaptiveTable] = MAIN_load_rcs_data_from_folder(subfoldpath);
    
% prepare neural data
sr = senseSettingsProgr.samplingRate;
[t,Y] = preprocessTDSignals(outdatcomplete);

% compute spectrogram 
[Sp,Fp,Tp,specRes] = computeSpectrogram(Y,sr,[5 30],[1 100]);
t0 = seconds(specRes);
tpdur = seconds(Tp(1,:)); tp_date = t0+t(1)+tpdur; 

for ii=1:4
    ax(2*ii) = subplot(10,1,ii*2);
    plot(datenum(t),Y(ii,:))
    datetick('x', 'HH:MM:SS',  'keepticks');
    ax(2*ii+1) = subplot(10,1,ii*2+1);
    temp = 10*log10(abs(Sp(ii,:,:)));
    pcolor(datenum(tp_date),Fp(ii,:),squeeze(temp(1,:,:))); shading flat
    datetick('x', 'HH:MM:SS',  'keepticks');
    set(ax(2*ii),'xlim',[datenum(t(1)) datenum(t(end)+seconds(2))]);
    set(ax(2*ii+1),'xlim',[datenum(tp_date(1)) datenum(tp_date(end)+seconds(2))]);
end
axCount = 2*ii+1;

% plot acc data
axCount = axCount + 1;
[tacc,accSig] = preprocessAccSignals(outdatcompleteAcc);
ax(axCount)=subplot(10,1,10);
plot(datenum(tacc),accSig.norm)
datetick('x', 'HH:MM:SS',  'keepticks');
set(ax(axCount),'xlim',[datenum(min(tacc)) datenum(max(tacc))])
set(ax(axCount),'ylim',[0 1.1*max(accSig.norm)])
ylabel('acc (centiG)')
xlabel('time (dateTime)')
linkaxes(ax(:),'x')
set( findall(fig1, '-property', 'fontsize'), 'fontsize', fontSize)

%% calculate and plot extreme cases of PSD of neural data as function of changes in stim amplitude
% prepare figure
strName = ['Stim electrodes: ',char(stimActiveSettings.electrodes), ...
            ', PW = ',num2str(stimActiveSettings.pulseWidth_mcrSec),...
                ', rate = ', num2str(stimActiveSettings.rate_Hz)];
fig2 = figure(2), set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 0.5, 0.5]);

t_stim_delta = eventTable.UnixOnsetTime(idxStimEvent);
for ii=1:length(t_stim_delta)-1
    t1 = t_stim_delta(ii);
    t2 = t_stim_delta(ii+1);
    % extract neural data btw t1 & t2
    t_idx = find(t>t1 & t<t2);
    if ~isempty(t_idx) && (ii==1 || ii==(length(t_stim_delta)-1)) % this is to choose the extreme cases (ii=1->first amplitude & ii=end->last ampltidue)
        % refine t_idx to avoid first 20% of data (contains dc shift)
        t_idx2 = t_idx(round(length(t_idx)/5):end); 
        for jj=1:size(Y,1)
            [fftOut,ff]   = pwelch(Y(jj,t_idx2),sr,sr/2,0:1:sr/2,sr,'psd');
            % segment of points used in the original time domain signal
            if jj==1
                figure(1); subplot(10,1,2); hold on; plot(datenum(t(t_idx)),Y(jj,t_idx),'o')
            end
            % update figure panel
            figure(2); ax2(jj) = subplot(2,2,jj); hold on
            plot(ff,log10(fftOut),'DisplayName',['Amp = ',num2str(stimAmplitudesNum(ii))])
            legend('-DynamicLegend');
            xlabel('freq (Hz)'), ylabel('Power  (log_1_0\muV^2/Hz)');
            switch jj
                case 1, title(senseSettingsProgr.chan1)
                case 2, title(senseSettingsProgr.chan2)
                case 3, title(senseSettingsProgr.chan3)
                case 4, title(senseSettingsProgr.chan4)
            end
            
        end
    end
end

set(ax2,'xlim',[0 100])
set( findall(fig2, '-property', 'fontsize'), 'fontsize', fontSize)

%% Montage
%  1) first time analysing montage data, run
%       - open_and_save_montage_data_in_sessions_directory(mainFolderSessions)
%       - plot_compare_montage_data_from_saved_montage_files((mainFolderSessions)
if plotMontage
    plot_compare_montage_data_from_saved_montage_files(datapathAll,'500Hz')
end