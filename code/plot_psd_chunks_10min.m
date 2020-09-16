% output = function get_psd_chunks_10min(varargin)

close all;clear all;clc

%% based on sense stim data base, will access session data based on 1 of 3 criterias
% 1) all data at sampling rate = X (e.g. X = 250, home recordings)
% 2) stimulation off or stimulation on
% 3) awake or sleep data
% in any of those combinations, segragate differences in sense channels

includeToolbox

%% inputs
PAT = 'RCS10';
SIDE = 'R';
colorTraces = 'blue';
PORTION_DATA_PLOTTED = 1;
plotStimOnCh0Pat = 0;
analyseDay = 1; % '0' night, '1' day
stimOn = 0; % '0' DBS off, '1' DBS on
saveFigures = 1;
SR = '250';
MINUTES = 10;
freqs = [4 8 12 20 30 60 80];
OPPACITY = 0.1; % <0.5
YLIM = [-2 3];
fontSize = 18;

%% extract patients side data from device settings master table database
pathdb = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/database';
dbfilename = 'database_from_device_settings.mat';
databaseall = load(fullfile(pathdb,dbfilename));

%% access sense stim data base
basedir = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/';
patspecdir = [PAT,' Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/'];
patsidespecdir = fullfile(basedir,patspecdir,[PAT,SIDE]);

%% init folder to save figures and conditions/events file
mkdir(patsidespecdir,'Figures');
saveFigDir = fullfile(patsidespecdir,'/Figures');

%% directory to save mat files of states DBS off, DBS on
saveMatFile = '/Users/juananso/Box Sync/RCS_GP_data_analysis_boxshare_juan_cora_phil/databaseoutput/mat_files_dbs_off_on_per_patient'

% access session folders within patient directory with session folders
idx = strcmp(databaseall.masterTableOut.patient,PAT) & ...
        strcmp(databaseall.masterTableOut.side,SIDE);
database_patside = databaseall.masterTableOut(idx,:);
count = 1;
for ii=1:size(database_patside,1)
    if ~strcmp(char(database_patside.chan1(ii)),'NA') % not considered 'NA' cases
        if database_patside.senseSettings{ii}.samplingRate == 250
            idsr250(count) = ii;
            count = count + 1;
        end
    end
end

database_250Hz = database_patside(idsr250,:);

% parse data based on conditions
[dbday,dbnight] = getDataDayAndNight(database_250Hz);

if stimOn
    db1 = getDataStimOn(dbday);
else
    db1 = getDataStimOff(dbday);
end

%% separate the different channels in sandwich config
% montages = getDiffMontages(dbtoprocess);
firstSenseConfig = db1.chan1(1,:); % takes first sense config on sub data base
idx = strcmp(db1.chan1,firstSenseConfig);
db1_chsConfig1 = db1(idx,:);
db1_chsConfig2 = db1(~idx,:);


%% concatenate all for each config of chs data, plot it and save figures
if ~isempty(db1_chsConfig2)
    twoConfigChs = 1;
    loopTimes = 2;
else
    twoConfigChs = 0;
    loopTimes = 1;
end

fprintf('here')

for ll=1:loopTimes
    if ll==1
        db2 = db1_chsConfig1;
    elseif ll==2 % there is a second config channel
        db2 = db1_chsConfig2;
    end       
    % default GP 0-1,2-3,configs
    Key0_chunked_all =[];
    Key1_chunked_all =[];
    Key2_chunked_all =[];
    Key3_chunked_all =[];

    good=[];
    stimOn_chunked_all = [];
    recordNumAll = 0;
    stimSettings_all = table();
    senseSettings_all = table();
    counter = 1;
    for ii=1:size(db2,1)
        disp(['file ',num2str(ii),' from ',num2str(size(db2,1)),'...']);  
        dirSession = fullfile(patsidespecdir,db2.session(ii));       
        TD_files_name = findFilesBVQX(dirSession,'RawDataTD.mat');
        if isempty(TD_files_name)
            TD_files_name = findFilesBVQX(dirSession,'RawDataTD.json');
            [outdatcomplete, srates, unqsrates] = MAIN(char(TD_files_name));
        else
            load(char(TD_files_name))
        end
            stimStatus = db2.stimStatus{ll};
            
            if ~isempty(outdatcomplete) 
                signal = outdatcomplete(:,1:4);
                Fs=srates(1);
                period_psd = Fs*60*MINUTES; %60 sec/min * sampling rate
                T= 1:period_psd:size(signal,1)-period_psd;
                if length(T)>1
                    for i = 1:length(T)
                    tt = T(i);
                    Key0_chunked(i,:) = 1e3*(table2array(signal(tt:tt+period_psd-1,1))-mean(table2array(signal(tt:tt+period_psd-1,1))));
                    Key1_chunked(i,:) = 1e3*(table2array(signal(tt:tt+period_psd-1,2))-mean(table2array(signal(tt:tt+period_psd-1,2))));
                    Key2_chunked(i,:) = 1e3*(table2array(signal(tt:tt+period_psd-1,3))-mean(table2array(signal(tt:tt+period_psd-1,3))));
                    Key3_chunked(i,:) = 1e3*(table2array(signal(tt:tt+period_psd-1,4))-mean(table2array(signal(tt:tt+period_psd-1,4))));
                    stimOn_chunked(i,:) = stimStatus.stimulation_on;

                    end

                    Key0_chunked_all = [Key0_chunked_all; Key0_chunked];
                    Key1_chunked_all = [Key1_chunked_all; Key1_chunked];
                    Key2_chunked_all = [Key2_chunked_all; Key2_chunked];
                    Key3_chunked_all = [Key3_chunked_all; Key3_chunked];

                    good = [good;ii];

                    if ll==1
                        stimOn_chunked_all = [stimOn_chunked_all;stimOn_chunked];
                    end

                end
            end
            
            stimSettings_all(counter,:) = stimStatus;
            senseSettings_all(counter,:) = db2.senseSettings{ll};
            counter = counter + 1;
    end

    WINDOW = Fs;           % segment length and Hamming window length for welch's method
    NOVERLAP = round(Fs*0.5);         % # signal samples that are common to adjacent segments for welch's method
    NFFT = Fs;

    %% calculate duration
    duration_hours = (size(Key0_chunked_all,1) * size(Key0_chunked_all,2) / Fs) / 3600;
    hours = floor(duration_hours);
    minutes = abs(hours - duration_hours)*60;
    durationhhmmss = char(duration(hours,minutes,0));
    durationhhmm = durationhhmmss(1:end-3);
    
    %% compute PSD
    fig1(ll) = figure(ll), set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 0.5, 0.75]); hold on   
    SIGNAL = [];
    outputToSave = table();
    for ii=1:4
        ax1(ii) = subplot(2,2,ii);
        hold on
        switch ii
            case 1, SIGNAL = Key0_chunked_all'; outputToSave.chsrkey0{1} = char(db2.chan1(1));
                strtitlefix = {'GPi',char(senseSettings_all.chan1(1))}; outputToSave.key0{1} = SIGNAL;
            case 2, SIGNAL = Key1_chunked_all'; outputToSave.chsrkey1{1} = char(db2.chan2(1));
                strtitlefix = {'GPe',char(senseSettings_all.chan2(1))}; outputToSave.key1{1} = SIGNAL;
            case 3, SIGNAL = Key2_chunked_all'; outputToSave.chsrkey2{1} = char(db2.chan3(1));
                strtitlefix = {'S1',char(senseSettings_all.chan3(1))}; outputToSave.key2{1} = SIGNAL;
            case 4, SIGNAL = Key3_chunked_all'; outputToSave.chsrkey3{1} = char(db2.chan4(1));
                strtitlefix = {'M1',char(senseSettings_all.chan4(1))}; outputToSave.key3{1} = SIGNAL;
         end
        [psd,F] = pwelch(SIGNAL,WINDOW,NOVERLAP,NFFT,Fs,'psd');
        p = plot(F,log10(psd),'Color',colorTraces);
        for pi=1:size(p,1)
            p(pi).Color = [p(pi).Color, OPPACITY]; % add oppacity component
        end

        %% add lines for freq bands
        hold on;
        for fi=1:length(freqs)
            plot([freqs(fi) freqs(fi)],[-3 4],':k','linewidth',1)
    %                 text(freqs(fi)+0.1,-2.8,num2str(freqs(fi)))
        end

        %% to identify if StimOn 0mA in PAT=RCS10
        if plotStimOnCh0Pat
            ffpos = 100*rand(1,size(psd,2));
            if ll==1 && strcmp(PAT,'RCS10') && ii==1 % just for first GP channel (GPi)
                text(ffpos(1:20:end),log10(psd(60,1:20:end)),num2str(stimOn_chunked_all(1:20:end)))
            end
        end

        title(strtitlefix)
        xlabel('freq (Hz)'), ylabel('Power  (log_1_0\muV^2/Hz)');
    end
    set(ax1,'ylim',YLIM)
    set(ax1,'xlim',[0 100])
    set(ax1,'xtick',[4 8 12 20 30 60 80])
    set(ax1,'xticklabel',[4 8 12 20 30 60 80])
    set( findall(fig1(ll), '-property', 'fontsize'), 'fontsize', fontSize)

    if saveFigures
        if stimOn && analyseDay % DBS on & day
            if ~twoConfigChs % just 1 config ch
                figNameFig = 'PSD_DBS_On_day.fig';
                figNamePng = 'PSD_DBS_On_day.png';
                titleStr = 'DBS ON, day';
            elseif twoConfigChs && ll==1
                figNameFig = 'PSD_DBS_On_day_ConfigCh1.fig';
                figNamePng = 'PSD_DBS_On_day_ConfigCh1.png';
                titleStr = 'DBS ON, day, configCh1';
            elseif twoConfigChs && ll==2
                figNameFig = 'PSD_DBS_On_day_ConfigCh2.fig';
                figNamePng = 'PSD_DBS_On_day_ConfigCh2.png';
                titleStr = 'DBS ON, day, configCh2';
            end
        elseif stimOn && ~analyseDay % DBS on & night
            if ~twoConfigChs 
                figNameFig = 'PSD_DBS_On_night.fig';
                figNamePng = 'PSD_DBS_On_night.png';
                titleStr = 'DBS ON, night';
            elseif twoConfigChs && ll==1
                figNameFig = 'PSD_DBS_On_night_ConfigCh1.fig';
                figNamePng = 'PSD_DBS_On_night_ConfigCh1.png';
                titleStr = 'DBS ON, night, configCh1';
            elseif twoConfigChs && ll==2
                figNameFig = 'PSD_DBS_On_night_ConfigCh2.fig';
                figNamePng = 'PSD_DBS_On_night_ConfigCh2.png';
                titleStr = 'DBS ON, night, configCh2';
            end
        elseif ~stimOn && analyseDay % DBS Off & day
            if ~twoConfigChs % just 1 config ch
                figNameFig = 'PSD_DBS_Off_day.fig';
                figNamePng = 'PSD_DBS_Off_day.png';
                titleStr = 'DBS OFF, day';
            elseif twoConfigChs && ll==1
                figNameFig = 'PSD_DBS_Off_day_ConfigCh1.fig';
                figNamePng = 'PSD_DBS_Off_day_ConfigCh1.png';
                titleStr = 'DBS OFF, day, configCh1';
            elseif twoConfigChs && ll==2
                figNameFig = 'PSD_DBS_Off_day_ConfigCh2.fig';
                figNamePng = 'PSD_DBS_Off_day_ConfigCh2.png';
                titleStr = 'DBS OFF, day, configCh2';
            end
        elseif ~stimOn && ~analyseDay % DBS Off & night
            if ~twoConfigChs 
                figNameFig = 'PSD_DBS_Off_night.fig';
                figNamePng = 'PSD_DBS_Off_night.png';
                titleStr = 'DBS OFF, night';
            elseif twoConfigChs && ll==1
                figNameFig = 'PSD_DBS_Off_night_ConfigCh1.fig';
                figNamePng = 'PSD_DBS_Off_night_ConfigCh1.png';
                titleStr = 'DBS OFF, night, configCh1';
            elseif twoConfigChs && ll==2
                figNameFig = 'PSD_DBS_Off_night_ConfigCh2.fig';
                figNamePng = 'PSD_DBS_Off_night_ConfigCh2.png';
                titleStr = 'DBS OFF, night, configCh2';
            end
        end

        if stimOn
            stimAmpStr = unique(stimSettings_all.amplitude_mA);
            if length(stimAmpStr) > 1
                maxStim = max(str2double(stimAmpStr));
                minStim = min(str2double(stimAmpStr));
                stimAmpStr2 = [num2str(minStim),', to ',num2str(maxStim)];
            else
                stimAmpStr2 = num2str(stimStatus.amplitude_mA);
            end
            sgtitle({[char(db2.patient(1)),char(db2.side(1))],...
                    ['stim on, (', char(stimStatus.electrodes),', ', ...
                     stimAmpStr2,' mA, ', ...
                     num2str(stimSettings_all.pulseWidth_mcrSec(1)),' us, ',...
                     'active recharge = ', num2str(stimSettings_all.active_recharge(1)),', ',...
                     'stim rate = ',num2str(stimStatus.rate_Hz),' Hz)'],...
                    [durationhhmm,' (hh:mm), hours of data']})
        else
            sgtitle({[char(db2.patient(1)),char(db2.side(1))],'stim off',[durationhhmm,' (hh:mm), hours of data']});
        end
            
        
        set( findall(fig1(ll), '-property', 'fontsize'), 'fontsize', fontSize)
        pointFigFig = fullfile(saveFigDir,figNameFig);
        saveas(fig1(ll),pointFigFig)
        pointFigPng = fullfile(saveFigDir,figNamePng);
        saveas(fig1(ll),pointFigPng)

        outputToSave.recordedHours = char(sum(duration(db2.duration)));
        ouputMatfileName = [PAT,SIDE,'_',figNameFig(1:end-3),'mat'];
        pointMatFile = fullfile(saveMatFile,ouputMatfileName)
        save(pointMatFile,'outputToSave','-v7.3')

    end

    %% if two ch configs, reset db2 and variables to load 10 min chunks
    db2 = [];
    Key0_chunked = [];
    Key1_chunked = [];
    Key2_chunked = [];
    Key3_chunked = [];
    stimOn_chunked = [];

end