
%% plot DBS off vs DBS on

close all; clear all; clc

PAT = 'RCS10';
path1 = '/Users/juananso/Box Sync/RCS_GP_data_analysis_boxshare_juan_cora_phil/databaseoutput/mat_files_dbs_off_on_per_patient/RCS10L_PSD_DBS_Off_day_ConfigCh1.mat';
path2 = '/Users/juananso/Box Sync/RCS_GP_data_analysis_boxshare_juan_cora_phil/databaseoutput/mat_files_dbs_off_on_per_patient/RCS10L_PSD_DBS_On_day.mat';
savedir = '/Users/juananso/Box Sync/RCS_GP_data_analysis_boxshare_juan_cora_phil/databaseoutput/mat_files_dbs_off_on_per_patient/figures';

freqs = [4 8 12 20 30 60 80];   
OPPACITY = 0.2; % <0.5
YLIM = [-2 3];
fontSize = 18;
BLUE = [0 0 255]/255;
GREEN = [0 255 0]/255;
GREENOLIVE = [11 102 35]/255;
RED = [255 0 0]/255;
MINUTES = 10;
Fs = 250;
WINDOW = Fs;           % segment length and Hamming window length for welch's method
NOVERLAP = round(Fs*0.5);         % # signal samples that are common to adjacent segments for welch's method
NFFT = Fs;

%% 

for datasetii=1:2
    
    switch datasetii
        case 1, dataset = load(path1); colorTraces = BLUE; stimOn = 0;
        case 2, dataset = load(path2); colorTraces = RED; stimOn = 1;
    end
    
    
    Key0_chunked_all = dataset.outputToSave.key0{1}';
    Key1_chunked_all = dataset.outputToSave.key1{1}';
    Key2_chunked_all = dataset.outputToSave.key2{1}';
    Key3_chunked_all = dataset.outputToSave.key3{1}';
    
    chsrkey(1) = dataset.outputToSave.chsrkey0;
    chsrkey(2) = dataset.outputToSave.chsrkey1;
    chsrkey(3) = dataset.outputToSave.chsrkey2;
    chsrkey(4) = dataset.outputToSave.chsrkey3;
    
    if strcmp(PAT,'RCS09') && datasetii==2 % this pt has GP chs off and on exchanged
        tempkey0 = Key0_chunked_all;
        tempkey1 = Key1_chunked_all;
        Key0_chunked_all = tempkey1;
        Key1_chunked_all = tempkey0;
        tempchsrkey = chsrkey(1);
        chsrkey(1) = chsrkey(2);
        chsrkey(2) = tempchsrkey;
    end

    %% plots
    fig1 = figure(2), set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 0.5, 0.75]); hold on   
    SIGNAL = [];
    outputToSave = table;

    for ii=1:4
        ax1(ii) = subplot(2,2,ii);
        hold on
        switch ii
            case 1, SIGNAL = Key0_chunked_all'; strtitlefix = 'GPi'; 
            case 2, SIGNAL = Key1_chunked_all'; strtitlefix = 'GPe'; 
            case 3, SIGNAL = Key2_chunked_all'; strtitlefix = 'S1'; 
            case 4, SIGNAL = Key3_chunked_all'; strtitlefix = 'M1';
         end
        [psd,F] = pwelch(SIGNAL,WINDOW,NOVERLAP,NFFT,Fs);
        
        switch datasetii
            case 1, p1 = plot(F,log10(psd),'Color',colorTraces); p = p1; chstr = char(chsrkey(ii));
                if ii == 4
                    text(60,2,chstr(1:6),'color',colorTraces);
                else
                     text(60,2,chstr(1:4),'color',colorTraces);
                end
            case 2, p2 = plot(F,log10(psd),'Color',colorTraces); p = p2; chstr = char(chsrkey(ii));
                if ii == 4
                    text(60,+1.6,chstr(1:6),'color',colorTraces);
                else
                     text(60,1.6,chstr(1:4),'color',colorTraces);
                end
        end
        
        if datasetii == 1
            for pi=1:size(p,1)
                p(pi).Color = [p(pi).Color, OPPACITY]; % add oppacity component
            end
        end

        %% add lines for freq bands
        hold on;
        for fi=1:length(freqs)
            plot([freqs(fi) freqs(fi)],[-3 4],':k','linewidth',1)
        end
        title(strtitlefix)
        xlabel('freq (Hz)'), ylabel('Power  (log_1_0\muV^2/Hz)');
        if datasetii==2
            [~,hObj] = legend([p1(1) p2(1)],'DBS OFF','DBS ON')
            hL=findobj(hObj,'type','line');  % get the lines, not text
            set(hL,'linewidth',10)  
        end

    end
    set(ax1,'ylim',YLIM)
    set(ax1,'xlim',[0 100])
    set(ax1,'xtick',[4 8 12 20 30 60 80])
    set(ax1,'xticklabel',[4 8 12 20 30 60 80])
    set( findall(fig1, '-property', 'fontsize'), 'fontsize', fontSize)
   
end

%% save figures
str1 = path1(119:end-4);
str2 = path2(119:end-4);
PATandSide = str1(1:6);
titleStr = 'DBS OFF vs DBS ON';
sgtitle([PATandSide,', ',num2str(MINUTES),' minutes PSD, ',titleStr,', recorded hours: ', dataset.outputToSave.recordedHours])
set(findall(fig1, '-property', 'fontsize'), 'fontsize', fontSize)

figNameFig = [str1,'_',str2,'.fig'];
figNamePng = [str1,'_',str2,'.png'];
pointFigFig = fullfile(savedir,figNameFig);
saveas(fig1,pointFigFig)
pointFigPng = fullfile(savedir,figNamePng);
saveas(fig1,pointFigPng)
