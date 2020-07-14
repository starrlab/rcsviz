% plot psd during programming



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
        
        
        ll = round(size(signal,1)/15000)-35;
        c = parula(ll);
         figure
        %plot data
        
        t=1;
        for i=1:ll
            [psd,F] = pwelch(signal.key0(t:t+15000)',Fs,Fs/2,Fs,Fs);
            P(i,:)=psd;
            t=t+15000;
        end        
       
        subplot(2,2,1)
        
        for i = 1:ll
            hold on;
            plot(F,log10(P(i,:)),'color',c(i,:))
        end
        xlim([0 100])
        ylim([-8 -2])
        
        if ~isempty(outRec) && length(outRec)==1
            title(outRec.tdData(1).chanOut)
        else
            title('Gpi')
        end
        
        
        t=1;
        for i=1:ll
            [psd,F] = pwelch(signal.key1(t:t+15000)',Fs,Fs/2,Fs,Fs);
            P(i,:)=psd;
            t=t+15000;
        end        
       
        subplot(2,2,2)
        
        for i = 1:ll
            hold on;
            plot(F,log10(P(i,:)),'color',c(i,:))
        end
        xlim([0 100])
        ylim([-8 -2])
        
        if ~isempty(outRec) && length(outRec)==1
            title(outRec.tdData(2).chanOut)
        else
            title('Gpe')
        end
        
        t=1;
        for i=1:ll
            [psd,F] = pwelch(signal.key2(t:t+15000)',Fs,Fs/2,Fs,Fs);
            P(i,:)=psd;
            t=t+15000;
        end        
       
        subplot(2,2,3)
        
        for i = 1:ll
            hold on;
            plot(F,log10(P(i,:)),'color',c(i,:))
        end
        xlim([0 100])
        ylim([-8 -2])
        
        if ~isempty(outRec) && length(outRec)==1
            title(outRec.tdData(3).chanOut)
        else
            title('S1')
        end
        
        t=1;
        for i=1:ll
            [psd,F] = pwelch(signal.key3(t:t+15000)',Fs,Fs/2,Fs,Fs);
            P(i,:)=psd;
            t=t+15000;
        end        
       
        subplot(2,2,4)
        
        for i = 1:ll
            hold on;
            plot(F,log10(P(i,:)),'color',c(i,:))
        end
        if ~isempty(outRec) && length(outRec)==1
            title(outRec.tdData(4).chanOut)
        else
            title('M1')
        end
        xlim([0 100])
        ylim([-8 -2])
       
        
        if length(outRec)==1
            saveas(gcf,[dirname '/figures/' save_name '_' datestr(outRec.timeStart) '_psd'],'fig');
        else
            saveas(gcf,[dirname '/figures/' save_name '_' datestr(outRec(1).timeStart) '_psd'],'fig');
        end
    end
end