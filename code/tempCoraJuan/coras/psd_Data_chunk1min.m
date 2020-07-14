
function psd_Data_chunk1min(varargin)

%% function load rcs data from a folder
if isempty(varargin)
    [dirname] = uigetdir(pwd,'choose a dir with rcs session folders');
else
    dirname  = varargin{1};
end

TD_files_name = findFilesBVQX(dirname,'RawDataTD.mat');
%Device_files_name = findFilesBVQX(dirname,'DeviceSettings.mat');

Key0_chunked_all =[];
Key1_chunked_all =[];
Key2_chunked_all =[];
Key3_chunked_all =[];
good=[];
for f = 1:size(TD_files_name,1)
    f
    load(TD_files_name{f})
    if ~isempty(outdatcomplete) 
        signal = outdatcomplete(:,1:4);
        
        Fs=srates(1);
        
        period_psd = 1000/Fs*60*60*10; %sec
        
        T= 1:period_psd:size(signal,1)-period_psd;
        
        if length(T)>1 && Fs==250
            for i = 1:length(T)
                tt = T(i);
                Key0_chunked(i,:) = table2array(signal(tt:tt+period_psd-1,1))';
                Key1_chunked(i,:) = table2array(signal(tt:tt+period_psd-1,2))';
                Key2_chunked(i,:) = table2array(signal(tt:tt+period_psd-1,3))';
                Key3_chunked(i,:) = table2array(signal(tt:tt+period_psd-1,4))';
                file(i)=f;
            end
            
            Key0_chunked_all = [Key0_chunked_all; Key0_chunked];
            Key1_chunked_all = [Key1_chunked_all; Key1_chunked];
            Key2_chunked_all = [Key2_chunked_all; Key2_chunked];
            Key3_chunked_all = [Key3_chunked_all; Key3_chunked];
            
            good = [good;f];
            
        end
    end
end

WINDOW = Fs;           % segment length and Hamming window length for welch's method
NOVERLAP = round(Fs*0.5);         % # signal samples that are common to adjacent segments for welch's method
NFFT = Fs;
    
%compute PSD
figure

subplot(2,2,1)
[psd,F] = pwelch(Key0_chunked_all',250,125,250,250);
plot(F,log10(psd),'k')
subplot(2,2,2)
[psd,F] = pwelch(Key1_chunked_all',250,125,250,250);
plot(F,log10(psd),'k')
subplot(2,2,3)
[psd,F] = pwelch(Key2_chunked_all',250,125,250,250);
plot(F,log10(psd),'k')
subplot(2,2,4)
[psd,F] = pwelch(Key3_chunked_all',250,125,250,250);
plot(F,log10(psd),'k')
        
        %plot data
        figure
        subplot(5,1,1)
        [S,Fspect,T,P] = spectrogram(signal.key0',WINDOW,NOVERLAP,NFFT,Fs);
        T=T/3600; % time in min
        imagesc(T, Fspect,abs(S));
        axis xy
        ylim([0 100])
        caxis([0 .1])
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
        imagesc(T, Fspect,abs(S));
        axis xy
        ylim([0 100])
        caxis([0 .1])
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
        imagesc(T, Fspect,abs(S));
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
        imagesc(T, Fspect,abs(S));
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
            saveas(gcf,[dirname '/figures/' save_name(1:end-14) '_' datestr(outRec.timeStart)],'fig');
        else
            saveas(gcf,[dirname '/figures/' save_name(1:end-14) '_' datestr(outRec(1).timeStart)],'fig');
        end
    end
end