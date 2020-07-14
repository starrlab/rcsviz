function plot_montage_GP_Cx_PSD_PAC_batch(varargin)

if isempty(varargin)
    [dirname] = uigetdir(pwd,'choose a dir with rcs session folders');
else
    dirname  = varargin{1};
end

% off meds off dbs
% params.datadir{1} = '/Users/cora_starr_lab/Documents/Cora/raw_data/ECOG_data/RCS/RCS_03/RCS03L_adaptive/3month/rcs03l/off_med_off_dbs/montage/Session1568397494782/DeviceNPC700411H';
% 
% params.outdir  = '/Users/cora_starr_lab/Documents/Cora/raw_data/ECOG_data/RCS/RCS_03/RCS03L_adaptive/3month/rcs03l/off_med_off_dbs/montage/Session1568397494782/DeviceNPC700411H';
% params.figdir  = '/Users/cora_starr_lab/Documents/Cora/raw_data/ECOG_data/RCS/RCS_03/RCS03L_adaptive/3month/rcs03l/off_med_off_dbs/montage/Session1568397494782/DeviceNPC700411H';
% params.side    = 'L';
montage_duration = {'00:00:40'};

montage_name = findFilesBVQX(dirname,'montage');
TD_files_name = findFilesBVQX(montage_name,'RawDataTD.mat');
%Device_files_name = findFilesBVQX(dirname,'DeviceSettings.mat');


for f = 1:size(TD_files_name,1)
    
    load(TD_files_name{f})
    
    save_name = erase(TD_files_name{f},[dirname '/']);
    save_name = erase(save_name,'DeviceNPC700411H/RawDataTD.mat');
    save_name = erase(save_name,'DeviceNPC700447H/RawDataTD.mat');
    
    %save_name = save_name(1:end-22);%% uncomment for aDBS
    save_name = replace(save_name,'/','_');
    
    if ~isempty(outdatcomplete)
        
        load([TD_files_name{f}(1:end-13) 'DeviceSettings.mat'])
        load([TD_files_name{f}(1:end-13) 'EventLog.mat'])
        
        idxnonzero = find(outdatcomplete.PacketRxUnixTime~=0);
        packtRxTimes    =  datetime(outdatcomplete.PacketRxUnixTime(idxnonzero)/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        
        
        idxTimeCompare = find(outdatcomplete.PacketRxUnixTime~=0,1);
        packRxTimeRaw  = outdatcomplete.PacketRxUnixTime(idxTimeCompare);
        packtRxTime    =  datetime(packRxTimeRaw/1000,...
            'ConvertFrom','posixTime','TimeZone','America/Los_Angeles','Format','dd-MMM-yyyy HH:mm:ss.SSS');
        derivedTime    = outdatcomplete.derivedTimes(idxTimeCompare);
        timeDiff       = derivedTime - packtRxTime;
        
        secs = outdatcomplete.derivedTimes;
        
%         % find start events
%         idxStart = cellfun(@(x) any(strfind(x,'Start : config')),eventTable.EventType);
%         idxEnd = cellfun(@(x) any(strfind(x,'Stop : config')),eventTable.EventType);

        % find start events
        idxStart = cellfun(@(x) any(strfind(x,'Start')),eventTable.EventType);
        idxEnd = cellfun(@(x) any(strfind(x,'Stop')),eventTable.EventType);

        % only include montage data
%        out
        % plot data
        d=1
        hfig = figure;
        for c = 1:4
            hsub(c) = subplot(4,1,c);
            hold(hsub(c),'on');
            cfnm = sprintf('key%d',c-1);
            y = outdatcomplete.(cfnm);
            secsUse = secs;
            plot(secsUse,y,'Parent',hsub(c));
            title(cfnm,'Parent',hsub(c));
        end
        linkaxes(hsub,'x');
        % insert event table markers and link them
        ets = eventTable(idxStart,:);
        ete = eventTable(idxEnd,:);
        hpltStart = gobjects(sum(idxStart),4);
        hpltEnd = gobjects(sum(idxStart),4);
        cntStn = 1;
        cntM1 = 1;
        for i = 1:sum(idxStart)
            i
            for c = 1:4
                hsubs = get(hsub(c));
                ylims = hsubs.YLim;
                % start
                [~,idxClosest] = min(abs(packtRxTimes-ets.UnixOffsetTime(i)));
                idxInOutDataCompleteUnits = idxnonzero(idxClosest);
                xval = outdatcomplete.derivedTimes(idxInOutDataCompleteUnits);
                %         xval = ets.UnixOffsetTime(i) + timeDiff;
                startTime = xval;
                hplt = plot([xval xval],ylims,'Parent',hsub(c),'Color',[0 0.8 0 0.7],'LineWidth',3);
                hpltStart(i,c) = hplt;
                % end
                [~,idxClosest] = min(abs(packtRxTimes-ete.UnixOffsetTime(i)));
                idxInOutDataCompleteUnits = idxnonzero(idxClosest);
                xval = outdatcomplete.derivedTimes(idxInOutDataCompleteUnits);
                %         xval = ete.UnixOffsetTime(i)+timeDiff;
                endTime = xval;
                hplt = plot([xval xval],ylims,'Parent',hsub(c),'Color',[0.8 0 0 0.7],'LineWidth',3);
                hpltEnd(i,c) = hplt;
                
                % get raw data
                cfnm = sprintf('key%d',c-1);
                y = outdatcomplete.(cfnm);
                secsUse = secs;
                idxuse = secsUse > (startTime - seconds(5)) & secsUse < (endTime + seconds(5));
                % get sample rate
                % xx - since this is stim sweep assume setting always
                % the same
                idxElectrodes = i;
                sr = str2num(strrep(outRec(idxElectrodes).tdData(c).sampleRate,'Hz',''));
                % get the params of the stim sweep
                rawStr = ets.EventType{i};
                % find stim amp
                idxStrStart = strfind(rawStr,'Stim amp: ');
                idxStrEnd   = strfind(rawStr,'. Stim Rate:');
                stimAmp = str2double(strrep(strrep(rawStr(idxStrStart:idxStrEnd),'Stim amp: ',''),'mA.',''));
                outIdxs(i).idxuse = idxuse;
                outIdxs(i).stimAmp = stimAmp;
                if c <=2
                    % save raw data in order to plot psds
                    app(d).rawDatSTN(cntStn).rawdata = y(idxuse);
                    app(d).rawDatSTN(cntStn).sr = sr;
                    app(d).rawDatSTN(cntStn).chan = sprintf('+%s-%s',outRec(idxElectrodes).tdData(c).plusInput,outRec(idxElectrodes).tdData(c).minusInput);
                    app(d).rawDatSTN(cntStn).chanFullStr = outRec(idxElectrodes).tdData(c).chanFullStr;
                    app(d).rawDatSTN(cntStn).stimAmp = stimAmp;
                    cntStn = cntStn + 1
                else
                    % save raw data in order to plot psds
                    app(d).rawDatM1(cntM1).rawdata = y(idxuse);
                    app(d).rawDatM1(cntM1).sr = sr;
                    app(d).rawDatM1(cntM1).chan = sprintf('+%s-%s',outRec(idxElectrodes).tdData(c).plusInput,outRec(idxElectrodes).tdData(c).minusInput);
                    app(d).rawDatM1(cntM1).chanFullStr = outRec(idxElectrodes).tdData(c).chanFullStr;
                    app(d).rawDatM1(cntM1).stimAmp = stimAmp;
                    cntM1 = cntM1 + 1
                end
            end
        end
        
%         app.rawDatM1=app.rawDatM1(length(app.rawDatM1)-9:length(app.rawDatM1));
%         app.rawDatSTN=app.rawDatSTN(length(app.rawDatSTN)-9:length(app.rawDatSTN));
        
        
        %% filter signal
        
        app_filt=app;
        
        fc=1;% cut off frequency
        fn=250; %nyquivst frequency = sample frequency/2;
        order = 6; %6th order filter, high pass
        [b1 a1]=butter(order,(fc/fn),'high');
        
        for i = 1:length(app.rawDatM1)
            app_filt.rawDatM1(i).rawdata=filtfilt(b1,a1,app.rawDatM1(i).rawdata);
            app_filt.rawDatSTN(i).rawdata=filtfilt(b1,a1,app.rawDatSTN(i).rawdata);
        end
        
        
%         %% reject EKG
%         
%         for i = 1:length(app.rawDatSTN)
%             if ~isempty(strfind(app.rawDatSTN(i).chan,'0'))
%                 app_filt.rawDatSTN(i).rawdata=EKGRemoval_montage(app_filt.rawDatSTN(i).rawdata,app.rawDatSTN(i).sr);
%             end
%         end
%         
        save([TD_files_name{f}(1:end-13) 'processed'],'app','app_filt')
%         
%         
        %% plot montage
        app = app_filt;
        
        close all;
        chanNames = {'rawDatSTN','rawDatM1'};
        %colorsUse = [0.8 0 0 0.8; 0 0.8 0 0.8];
        
        %%plot PSD all contact
        titleUse = {'GP'; 'M1'};
        hfig  = figure; hold on;
        for c = 1:length(chanNames)
            clear electrodeUse
            j=0;
            subplot(1,2,c); hold on;
            for i = 1:length(app.(chanNames{c})) % loop on med state - first is off meds
                rawdat = app.(chanNames{c})(i).rawdata;
                sr     = app.(chanNames{c})(i).sr;
                if ~isempty(sr)
                    j=j+1;
                    [fftOut,ff]   = pwelch(rawdat,sr,sr/2,0:1:sr/2,sr,'psd');
                    plot(ff,log10(fftOut),'LineWidth',4)%,...
                    %'Color',colorsUse(m,:));
                    electrodeUse(j,1:length(app.(chanNames{c})(i).chan))  = app.(chanNames{c})(i).chan;
                end
            end
            
            xlim([3 100]);
            %titleUse = sprintf('%s %s %s',params.side,chanNames{c},electrodeUse);
            title(titleUse{c,:});
            legend(electrodeUse);
            set(gca,'FontSize',18);
            set(gcf,'Color','w');
        end
        saveas(gcf,[dirname '/figures/montage/' save_name(1:end-14) 'PSD'],'fig');
        
        
        %%plot coh only GP cortex
        close all
        
        titleUse = {'Coh GP cortex'};
        hfig  = figure; hold on;
        
        clear electrodeUse
      
        % find GPiGPe S1 M1
        for n= 1:length(app.rawDatSTN)
            ff=find(strcmp(app.rawDatSTN(n).chan,'+1-0'));
            if ~isempty(ff)
                Gpi=n;
            end
            
            ff=find(strcmp(app.rawDatSTN(n).chan,'+3-2'));
            if ~isempty(ff)
                Gpe=n;
            end
            
            ff=find(strcmp(app.rawDatM1(n).chan,'+9-8'));
            if ~isempty(ff)
                S1=n;
            end
            
            ff=find(strcmp(app.rawDatM1(n).chan,'+11-10'));
            if ~isempty(ff)
                M1=n;
            end
        end
        
        n=0;
        for i = [Gpi Gpe]; %length(app.(chanNames{c})) % loop on med state - first is off meds
            rawdat1 = app.(chanNames{1})(i).rawdata; %BG
            for j = [S1 M1]
                rawdat2 = app.(chanNames{2})(j).rawdata; %cortex
                sr     = app.(chanNames{2})(j).sr;
                if ~isempty(sr)
                    [Cxy,F] = mscohere(rawdat1(1:1970),rawdat2(1:1970),sr,sr/2,sr,sr);
                    plot(F,Cxy,'LineWidth',4)%,...
                    %'Color',colorsUse(m,:));
                    elect_name =[app.(chanNames{1})(i).chan app.(chanNames{2})(j).chan];
                    n=n+1;
                    electrodeUse(n,1:length(elect_name))  = elect_name;
                end
            end
        end
        
        xlim([3 100]);
        title(titleUse);
        legend(electrodeUse);
        set(gca,'FontSize',18);
        set(gcf,'Color','w');
        
        saveas(gcf,[dirname '/figures/montage/' save_name(1:end-14) 'COH'],'fig');
                
        close all
        
        %%plot PAC
        PhaseFreqVector=[2:2:50];
        AmpFreqVector=[50:10:200];
        bad_times = [];
        skip = [];
       
        for c = 1:length(chanNames)
            hfig  = figure; hold on;
            for i = 1:6; %length(app.(chanNames{c})) % loop on med state - first is off meds
                              
                rawdat = app.(chanNames{c})(i).rawdata;
                sr     = app.(chanNames{c})(i).sr;
                
                if ~isempty(sr)
                    [Comodulogram] = pac_art_reject_surr(rawdat',sr,PhaseFreqVector,AmpFreqVector,bad_times,skip);
                    tempmat=double(Comodulogram);
                    
                    % plot
                    subplot(2,3,i);                 
                   
                    pcolor(PhaseFreqVector',AmpFreqVector,tempmat');
                    shading interp;
                    caxis([0 0.001]);
                    
                    hold on;
                    title([app.(chanNames{c})(i).chan]);
                    
                end
            end
       
            set(gca,'FontSize',18);
            set(gcf,'Color','w');
            
            if c==1
                saveas(gcf,[dirname '/figures/montage/' save_name(1:end-14) 'PAC_BG'],'fig');
            else
                saveas(gcf,[dirname '/figures/montage/' save_name(1:end-14) 'PAC_Cx'],'fig');
            end
        end
        
        close all
%         % PAC 1000Hz
%         hfig  = figure; hold on;
%         AmpFreqVector=[50:10:400];
%         rawdat = (app.(chanNames{1})(7).rawdata+app.(chanNames{1})(8).rawdata)/2;;
%         sr     = app.(chanNames{1})(7).sr;
%         
%         if ~isempty(sr)
%             [Comodulogram] = pac_art_reject_surr(rawdat',sr,PhaseFreqVector,AmpFreqVector,bad_times,skip);
%             tempmat=double(Comodulogram);
%             
%             % plot
%             subplot(1,2,1);
%             hold on;
%             
%             pcolor(PhaseFreqVector',AmpFreqVector,tempmat');
%             shading interp;
%             caxis([0 0.001]);
%             
%             hold on;
%             title([app.(chanNames{1})(7).chan]);
%             
%         end
%         
%         % PAC 1000Hz
%         AmpFreqVector=[50:10:400];
%         rawdat = (app.(chanNames{2})(9).rawdata+app.(chanNames{2})(10).rawdata)/2;
%         sr     = app.(chanNames{2})(9).sr;
%         
%         if ~isempty(sr)
%             [Comodulogram] = pac_art_reject_surr(rawdat',sr,PhaseFreqVector,AmpFreqVector,bad_times,skip);
%             tempmat=double(Comodulogram);
%             
%             % plot
%             subplot(1,2,2);
%             hold on;
%             
%             pcolor(PhaseFreqVector',AmpFreqVector,tempmat');
%             shading interp;
%             caxis([0 0.001]);
%             
%             hold on;
%             title([app.(chanNames{2})(9).chan]);
%         end
%         
%         set(gca,'FontSize',18);
%         set(gcf,'Color','w');
%         
%         saveas(gcf,[dirname '/figures/montage/' save_name 'PAC_HF'],'fig');
%         
    end
    clear app app_filt outdatcomplete
    
end
