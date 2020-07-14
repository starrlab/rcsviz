
function RCS_time_spect(varargin)

%% function load rcs data from a folder
if isempty(varargin)
    [dirname] = uigetdir(pwd,'choose a dir with rcs session folders');
else
    dirname  = varargin{1};
end

TD_files_name = findFilesBVQX(dirname,'RawDataTD.mat');
%Device_files_name = findFilesBVQX(dirname,'DeviceSettings.mat');


for f = 1:size(TD_files_name,1)
    
    load(TD_files_name{f})
    signal = outdatcomplete;
    
    Fs=srates(1);
    WINDOW = Fs;           % segment length and Hamming window length for welch's method
    NOVERLAP = round(Fs*0.5);         % # signal samples that are common to adjacent segments for welch's method
    NFFT = Fs;
    %save_name = erase(TD_files_name{f},'/Users/cora_starr_lab/Documents/Cora/raw_data/ECOG_data/RCS/RCS03/starrlab/rcs03l/');
    
    save_name = erase(TD_files_name{f},[dirname '/']);
    save_name = erase(save_name,'DeviceNPC700411H/RawDataTD.mat');
    save_name = erase(save_name,'DeviceNPC700447H/RawDataTD.mat');
    
    %save_name = save_name(1:end-22);%% uncomment for aDBS
    save_name = replace(save_name,'/','_');
    
    if ~isempty(signal)
        
        load([TD_files_name{f}(1:end-13) 'DeviceSettings.mat'])
      
        %accel
        accel=[];
        load([TD_files_name{f}(1:end-13) 'RawDataAccel.mat'])
        accel = sqrt(outdatcomplete.XSamples.^2 + outdatcomplete.YSamples.^2 + outdatcomplete.ZSamples.^2);
        Fs_accel = outdatcomplete.samplerate(1);
        
        %plot data
        figure
        subplot(5,1,1)
        [S,Fspect,T,P] = spectrogram(signal.key0',WINDOW,NOVERLAP,NFFT,Fs);
        T=T/3600; % time in min
        imagesc(T, Fspect,zscore(abs(S)));
        axis xy
        ylim([0 100])
        caxis([0 .05])
        set(gca,'xtick',[]);
        set(gca,'xcolor',[1 1 1])
        
        if ~isempty(outRec) && length(outRec)==1
            title(outRec.tdData(1).chanOut)
        else
            title('Gpi')
        end
        
        subplot(5,1,2)
        [S,Fspect,T,P] = spectrogram(signal.key1',WINDOW,NOVERLAP,NFFT,Fs);
        T=T/3600; % time in min
        imagesc(T, Fspect,zscore(abs(S)));
        axis xy
        ylim([0 100])
        caxis([0 .05])
        set(gca,'xtick',[]);
        set(gca,'xcolor',[1 1 1])
        
        if ~isempty(outRec) && length(outRec)==1
            title(outRec.tdData(2).chanOut)
        else
            title('Gpe')
        end
        
        subplot(5,1,3)
        [S,Fspect,T,P] = spectrogram(signal.key2',WINDOW,NOVERLAP,NFFT,Fs);
        T=T/3600; % time in h
        imagesc(T, Fspect,zscore(abs(S)));
        axis xy
        ylim([0 100])
        caxis([0 .25])
        set(gca,'xtick',[]);
        set(gca,'xcolor',[1 1 1])
        
        if ~isempty(outRec) && length(outRec)==1
            title(outRec.tdData(3).chanOut)
        else
            title('S1')
        end
        
        subplot(5,1,4)
        [S,Fspect,T,P] = spectrogram(signal.key3',WINDOW,NOVERLAP,NFFT,Fs);
        T=T/3600; % time in min
        imagesc(T, Fspect,zscore(abs(S)));
        axis xy
        ylim([0 100])
        caxis([0 .25])
        if ~isempty(outRec) && length(outRec)==1
            title(outRec.tdData(4).chanOut)
        else
            title('M1')
        end
        
        subplot(5,1,5)
        T = 0:Fs_accel/1000:length(accel)*Fs_accel/1000;
        T=T(1:end-1);
        %T=T/3600;
        plot(T,accel)
        xlim([0 T(end)])
        set(gca,'xtick',[]);
        set(gca,'xcolor',[1 1 1])
        
        if length(outRec)==1
            saveas(gcf,[dirname '/figures/' save_name '_' datestr(outRec.timeStart)],'fig');
        else
            saveas(gcf,[dirname '/figures/' save_name '_' datestr(outRec(1).timeStart)],'fig');
        end
    end
end