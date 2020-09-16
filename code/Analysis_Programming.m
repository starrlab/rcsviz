
%% plotting RCS sense data from a session folder for basic visualization
close all; clear all; clc
includeToolbox();

%% input parameters
MIN_SECONDS_PSD = 10;

%% data paths
% datapathAll = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593205514505/DeviceNPC700436H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593206205651/DeviceNPC700436H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593207192304/DeviceNPC700436H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593208334311/DeviceNPC700436H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593208710319/DeviceNPC700436H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593209178827/DeviceNPC700436H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10L/Session1593626264750/DeviceNPC700436H';

% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593621265584/DeviceNPC700430H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593622890480/DeviceNPC700430H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593623681795/DeviceNPC700430H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593624709046/DeviceNPC700430H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593625251718/DeviceNPC700430H';
% subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/1month/programming/RCS10R/Session1593627135536/DeviceNPC700430H';

subfoldpath = '/Users/juananso/Dropbox (Personal)/Work/DATA/RCS_patients/RCS10/Adjustment08252020/RCS10R/Session1598390123476/DeviceNPC700430H';

%% init folder to save figures and conditions/events file
mkdir(subfoldpath,'Figures');
saveFigDir = fullfile(subfoldpath,'/Figures');

%% load events table
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
    [val,idx] = min(time_dist);
else
    idx = 1;
end
senseSettingsProgr = senseSettings(idx,:);

%% extract programming inforamtion
[stimAmplitudes,idxStimEvent] = getProgrammingAmplitudeChanges(eventTable);
stimAmplitudesNum = str2num(char(stimAmplitudes{:,:}));

%% extract event information associated to stim changes and events & print it in a pdf
idxConitions = find(strcmp(eventTable.EventType,'conditions'));
idxMedication = find(strcmp(eventTable.EventType,'medication'));
conditionsReport = eventTable.EventSubType(idxConitions,:);
unixTimeReport = eventTable.HostUnixTime(idxConitions);

fid = fopen([saveFigDir,'/Conditions.txt'],'wt');
fprintf(fid, '%s\n', ['SessionTime: ',char(eventTable.sessionTime(idxConitions(1)))])
fprintf(fid, '%s\n', ['SessionID: ',char(eventTable.sessionid(idxConitions(1)))])
fprintf(fid, '%s\n', '---------------------------------------------------')
% fprintf(fid, '%s\n', ['Last Medicaiton: ',char(eventTable.EventSubType(idxMedication(1)))])

fprintf(fid, '%s\n', 'Stim and sense settings:')
fprintf(fid, '%s\n', ['Stim electrodes: ',char(stimActiveSettings.electrodes)])
fprintf(fid, '%s\n', ['Sense ch1: ',char(senseSettingsProgr.chan1)])
fprintf(fid, '%s\n', ['Sense ch2: ',char(senseSettingsProgr.chan2)])
fprintf(fid, '%s\n', ['Sense ch3: ',char(senseSettingsProgr.chan3)])
fprintf(fid, '%s\n', ['Sense ch4: ',char(senseSettingsProgr.chan4)])
fprintf(fid, '%s\n', '---------------------------------------------------')

fprintf(fid, '%s\n', 'Medications:')
for ii=1:size(idxMedication,1)  
    fprintf(fid, '%s\n', [char(eventTable.HostUnixTime(ii)),'   ', char(eventTable.EventSubType(idxMedication(ii)))]);
end
fprintf(fid, '%s\n', '---------------------------------------------------')

fprintf(fid, '%s\n', 'Conditions:')
for ii=1:size(conditionsReport,1)  
    fprintf(fid, '%s\n', [char(unixTimeReport(ii)),'   ', char(conditionsReport(ii,:))]);
end
fprintf(fid, '%s\n', '---------------------------------------------------')

fclose(fid);

%% Create main Figure/Pannel
strName = ['Stim electrodes: ',char(stimActiveSettings.electrodes), ...
            ', PW = ',num2str(stimActiveSettings.pulseWidth_mcrSec),...
                ', rate = ', num2str(stimActiveSettings.rate_Hz)];
fig1 = figure(1), fontSize = 16;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [1/2, 0, 1/2, 1]);

% top pannel contains programming amplitudes
ax(1) = subplot(10,1,1);
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
[t,Y] = preprocessTDSignals(outdatcomplete,1,sr);

% compute spectrogram 
[Sp,Fp,Tp,specRes] = computeSpectrogram(Y,sr,[5 30],[1 100]);
t0 = seconds(specRes);
tpdur = seconds(Tp(1,:)); tp_date = t0+t(1)+tpdur; 
figure(1)
for ii=1:4
    ax(2*ii) = subplot(10,1,ii*2);
    plot(datenum(t),Y(ii,:))
    datetick('x', 'HH:MM:SS',  'keepticks');
    ylabel('Voltage (\muV)')
    ax(2*ii+1) = subplot(10,1,ii*2+1);
    temp = 10*log10(abs(Sp(ii,:,:)));
    pcolor(datenum(tp_date),Fp(ii,:),squeeze(temp(1,:,:))); shading flat
    subPlotPos = get(ax(2*ii+1),'Position');
    colorbar(ax(2*ii+1),'Position',[subPlotPos(3)+0.15 subPlotPos(2)+0.01 0.01 0.05])
    ylabel('frequency (Hz)')

    
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
fig2 = figure('name',strName), set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 0.5, 0.75]);
t_stim_delta = eventTable.UnixOnsetTime(idxStimEvent);
col1Grad = linspace(1,0,length(t_stim_delta)-2);
red = [1,0,0];
green = [0,1,0];
newcolors = red;
for ii=1:length(col1Grad)-1
    newcolors(ii+1,:) = [1,1-col1Grad(ii),0];
end
newcolors = [newcolors;green];
for ii=1:length(t_stim_delta)-1
    t1 = t_stim_delta(ii);
    t2 = t_stim_delta(ii+1);
    % extract neural data btw t1 & t2
    t_idx = find(t>t1 & t<t2);
    if ~isempty(t_idx)
        % refine t_idx to avoid first 20% of data (contains dc shift)
        t_idx2 = t_idx(round(length(t_idx)/5):end); 
        if length(t_idx2)>MIN_SECONDS_PSD*sr % at least 5 seconds of sample
            for jj=1:size(Y,1)
                [fftOut,ff]   = pwelch(Y(jj,t_idx2),sr,sr/2,0:1:sr/2,sr,'psd');
                % segment of points used in the original time domain signal
                if jj==1
                    figure(fig1); subplot(10,1,2); hold on; plot(datenum(t(t_idx)),Y(jj,t_idx),'Color',newcolors(ii,:),'Marker','o')
                end
                % update figure panel
                figure(fig2); ax2(jj) = subplot(2,2,jj); hold on
                if ii==length(t_stim_delta)-1
                    plot(ff,log10(fftOut),'Color',newcolors(ii,:),'DisplayName',['Amp = ',num2str(stimAmplitudesNum(ii))],'LineWidth',2)
                else
                    plot(ff,log10(fftOut),'Color',newcolors(ii,:),'DisplayName',['Amp = ',num2str(stimAmplitudesNum(ii))],'LineWidth',1)
                end
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
end

set(ax2,'xlim',[0 100])
set( findall(fig2, '-property', 'fontsize'), 'fontsize', fontSize)

%% save figures
figureName = 'Tdomain.fig';
pointFig = fullfile(saveFigDir,figureName);
saveas(fig1,pointFig)
figureName = 'Tdomain.png';
pointFig = fullfile(saveFigDir,figureName);
saveas(fig1,pointFig)

figureName = 'PSD.fig';
pointFig = fullfile(saveFigDir,figureName);
saveas(fig2,pointFig)
figureName = 'PSD.png';
pointFig = fullfile(saveFigDir,figureName);
saveas(fig2,pointFig)

