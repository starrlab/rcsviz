% function psdSessionsFolder(dirname)

close all; clear all, clc
%% based on sense stim data base, will access session data based on 1 of 3 criterias
% 1) all data at sampling rate = X (e.g. X = 250, home recordings)
% 2) stimulation off or stimulation on
% 3) awake or sleep data
% in any of those combinations, segragate differences in sense channels

close all; clear all; clc
%% include toolbox
includeToolbox

%% inputs
analyseDay = 1; % '0' night, '1' day
stimOn = 0; % '0' DBS off, '1' DBS on
SR = '250';
MINUTES = 10;

%% access sense stim data base
dirname = '/Users/juananso/Starr Lab Dropbox/RC+S Patient Un-Synced Data/RCS03 Un-Synced Data/SummitData/SummitContinuousBilateralStreaming/RCS03L'

PathToSenseStimDB = char(findFilesBVQX(dirname,'stim_and_sense_settings_table.mat'));

%% init folder to save figures and conditions/events file
mkdir(dirname,'Figures');
saveFigDir = fullfile(dirname,'/Figures');

%% load data
load(PathToSenseStimDB)
senseStimFromOPday = sense_stim_table(3:end,:);

%% select based on sampling freq
idx = contains(senseStimFromOPday.chan1,SR);
dataBase1 = senseStimFromOPday(idx,:)

%% select based on stimulation off or on
if ~stimOn % stim off (therapy inactive)
    idx = find(dataBase1.amplitude_mA == 0); % I use amplitude_mA bcs we had stim on 0 mA in RCS10
else % stim on (therapy active)
    idx = find(dataBase1.amplitude_mA > 0); % I use amplitude_mA bcs we had stim on 0 mA in RCS10
end
dataBase2 = dataBase1(idx,:)

%% select only those awake (7 am is waking up moment)
idx = ~(dataBase2.endTime.Hour < 7);
dataBase2_day = dataBase2(idx,:);
dataBase2_night = dataBase2(~idx,:);

%% asign analysis day or night to analysis
if analyseDay
    db1 = dataBase2_day;
else
    db1 = dataBase2_night;
end

%% separate the different channels in sandwich config
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
    recordNumAll = 0;
    for ii=1:size(db2,1)
        dirSession = fullfile(dirname,db2.sessname(ii));
        TD_files_name = findFilesBVQX(dirSession,'RawDataTD.mat');
        if isfile(char(TD_files_name))
            load(char(TD_files_name))
            deviceSettingsFile = findFilesBVQX(dirSession,'DeviceSettings.json');

            if ~isempty(outdatcomplete) 
                signal = outdatcomplete(:,1:4);
                Fs=srates(1);
                period_psd = Fs*60*MINUTES; %60 sec/min * sampling rate
                T= 1:period_psd:size(signal,1)-period_psd;
                if length(T)>1
                    for i = 1:length(T)
                    tt = T(i);
    %                 figure(1)
    %                 hold on
    %                 plot(table2array(signal(tt:tt+period_psd-1,1))-mean(table2array(signal(tt:tt+period_psd-1,1)))')
                    Key0_chunked(i,:) = 1e3*(table2array(signal(tt:tt+period_psd-1,1))-mean(table2array(signal(tt:tt+period_psd-1,1))));
                    Key1_chunked(i,:) = 1e3*(table2array(signal(tt:tt+period_psd-1,2))-mean(table2array(signal(tt:tt+period_psd-1,2))));
                    Key2_chunked(i,:) = 1e3*(table2array(signal(tt:tt+period_psd-1,3))-mean(table2array(signal(tt:tt+period_psd-1,3))));
                    Key3_chunked(i,:) = 1e3*(table2array(signal(tt:tt+period_psd-1,4))-mean(table2array(signal(tt:tt+period_psd-1,4))));
                    end

                    Key0_chunked_all = [Key0_chunked_all; Key0_chunked];
                    Key1_chunked_all = [Key1_chunked_all; Key1_chunked];
                    Key2_chunked_all = [Key2_chunked_all; Key2_chunked];
                    Key3_chunked_all = [Key3_chunked_all; Key3_chunked];

                    good = [good;ii];
                end
            end
        end
    end

    WINDOW = Fs;           % segment length and Hamming window length for welch's method
    NOVERLAP = round(Fs*0.5);         % # signal samples that are common to adjacent segments for welch's method
    NFFT = Fs;

    %% compute PSD
    fig1(ll) = figure(ll), set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 0.5, 0.75]);
    fontSize = 14;   
    SIGNAL = [];
    for ii=1:4
        ax1(ii) = subplot(2,2,ii);
        switch ii
            case 1, SIGNAL = Key0_chunked_all'; strtitle = char(db2.chan1(1));
            case 2, SIGNAL = Key1_chunked_all'; strtitle = char(db2.chan2(1));
            case 3, SIGNAL = Key2_chunked_all'; strtitle = char(db2.chan3(1));
            case 4, SIGNAL = Key3_chunked_all'; strtitle = char(db2.chan4(1));
        end
        [psd,F] = pwelch(SIGNAL,WINDOW,NOVERLAP,NFFT,Fs);
        plot(F,log10(psd),'b')
        title(strtitle)
        xlabel('freq (Hz)'), ylabel('Power  (log_1_0\muV^2/Hz)');
    end
    set(ax1,'xlim',[0 100])
    set( findall(fig1(ll), '-property', 'fontsize'), 'fontsize', fontSize)

    if stimOn && analyseDay % DBS on & day
        if ~twoConfigChs % just 1 config ch
            figNameFig = 'PSD_DBS_On_day.fig';
            figNamePng = 'PSD_DBS_On_day.png';
            titleStr = 'DBS On, day';
        elseif twoConfigChs && ll==1
            figNameFig = 'PSD_DBS_On_day_ConfigCh1.fig';
            figNamePng = 'PSD_DBS_On_day_ConfigCh1.png';
            titleStr = 'DBS On, day, configCh1';
        elseif twoConfigChs && ll==2
            figNameFig = 'PSD_DBS_On_day_ConfigCh2.fig';
            figNamePng = 'PSD_DBS_On_day_ConfigCh2.png';
            titleStr = 'DBS On, day, configCh2';
        end
    elseif stimOn && ~analyseDay % DBS on & night
        if ~twoConfigChs 
            figNameFig = 'PSD_DBS_On_night.fig';
            figNamePng = 'PSD_DBS_On_night.png';
            titleStr = 'DBS On, night';
        elseif twoConfigChs && ll==1
            figNameFig = 'PSD_DBS_On_night_ConfigCh1.fig';
            figNamePng = 'PSD_DBS_On_night_ConfigCh1.png';
            titleStr = 'DBS On, night, configCh1';
        elseif twoConfigChs && ll==2
            figNameFig = 'PSD_DBS_On_night_ConfigCh2.fig';
            figNamePng = 'PSD_DBS_On_night_ConfigCh2.png';
            titleStr = 'DBS On, night, configCh2';
        end
    elseif ~stimOn && analyseDay % DBS Off & day
        if ~twoConfigChs % just 1 config ch
            figNameFig = 'PSD_DBS_Off_day.fig';
            figNamePng = 'PSD_DBS_Off_day.png';
            titleStr = 'DBS Off, day';
        elseif twoConfigChs && ll==1
            figNameFig = 'PSD_DBS_Off_day_ConfigCh1.fig';
            figNamePng = 'PSD_DBS_Off_day_ConfigCh1.png';
            titleStr = 'DBS Off, day, configCh1';
        elseif twoConfigChs && ll==2
            figNameFig = 'PSD_DBS_Off_day_ConfigCh2.fig';
            figNamePng = 'PSD_DBS_Off_day_ConfigCh2.png';
            titleStr = 'DBS Off, day, configCh2';
        end
    elseif ~stimOn && ~analyseDay % DBS Off & night
        if ~twoConfigChs 
            figNameFig = 'PSD_DBS_Off_night.fig';
            figNamePng = 'PSD_DBS_Off_night.png';
            titleStr = 'DBS Off, night';
        elseif twoConfigChs && ll==1
            figNameFig = 'PSD_DBS_Off_night_ConfigCh1.fig';
            figNamePng = 'PSD_DBS_Off_night_ConfigCh1.png';
            titleStr = 'DBS Off, night, configCh1';
        elseif twoConfigChs && ll==2
            figNameFig = 'PSD_DBS_Off_night_ConfigCh2.fig';
            figNamePng = 'PSD_DBS_Off_night_ConfigCh2.png';
            titleStr = 'DBS Off, night, configCh2';
        end
    end

    sgtitle([char(dataBase1.patient(1)),char(dataBase1.side(1)),', ',num2str(MINUTES),' minutes PSD, ',titleStr,', recorded hours: ', char(sum(duration(db2.duration)))])
    pointFigFig = fullfile(saveFigDir,figNameFig);
    saveas(fig1(ll),pointFigFig)
    pointFigPng = fullfile(saveFigDir,figNamePng);
    saveas(fig1(ll),pointFigPng)

    %% if two ch configs, reset db2 and variables to load 10 min chunks
    db2 = [];
    Key0_chunked = [];
    Key1_chunked = [];
    Key2_chunked = [];
    Key3_chunked = [];
    
end  