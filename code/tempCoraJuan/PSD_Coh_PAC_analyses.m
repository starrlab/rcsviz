%% analyses on off med

clear all, close all, clc

[dirname] = uigetdir(pwd,'choose a dir with rcs .json data');

file = fullfile(dirname, 'db_event_medTime_tb5_ta60');

load(file)

savepath = fullfile(dirname, '/Results/');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  PSD
%%%%%% 1. Compute PSD
for i = 5:size(output,1)
    
    if i~=17 % ignore outlier case in RCS03L with only 1 sample
        sr=output.sampleRate(i);
        dur = 60*sr; %sec
        t1 = 60*4*sr;
        t2=t1+dur;

        %off med
        [fftOut,ff]   = pwelch(output.key0{i}(t1:t2),sr,sr/2,0:1:sr/2,sr,'psd');
        psd_all_off(i,:,1) = fftOut;
        [fftOut,ff]   = pwelch(output.key1{i}(t1:t2),sr,sr/2,0:1:sr/2,sr,'psd');
        psd_all_off(i,:,2) = fftOut;
        [fftOut,ff]   = pwelch(output.key2{i}(t1:t2),sr,sr/2,0:1:sr/2,sr,'psd');
        psd_all_off(i,:,3) = fftOut;
        [fftOut,ff]   = pwelch(output.key3{i}(t1:t2),sr,sr/2,0:1:sr/2,sr,'psd');
        psd_all_off(i,:,4) = fftOut;

        %on med
        [fftOut,ff]   = pwelch(output.key0{i}(end-dur:end),sr,sr/2,0:1:sr/2,sr,'psd');
        psd_all_on(i,:,1) = fftOut;
        [fftOut,ff]   = pwelch(output.key1{i}(end-dur:end),sr,sr/2,0:1:sr/2,sr,'psd');
        psd_all_on(i,:,2) = fftOut;
        [fftOut,ff]   = pwelch(output.key2{i}(end-dur:end),sr,sr/2,0:1:sr/2,sr,'psd');
        psd_all_on(i,:,3) = fftOut;
        [fftOut,ff]   = pwelch(output.key3{i}(end-dur:end),sr,sr/2,0:1:sr/2,sr,'psd');
        psd_all_on(i,:,4) = fftOut;
    end
    
end

%%%%% Plot On off med stim off
%1. plot PSD all data on off med stim off
ch = {'-0,+1','-2,+3','-0,+2','-8,+9','-10,+11'};
col = [10 12 10 14 16];
psd_ch = [1 2 1 3 4];
% stim_on = find(output.Stim_on==1);
% stim_off = find(isnan(output.Stim_on));
stim_on = [38:61];
stim_off = [1:37];

figure
for i = 1:5    
    ok=find(strcmp(table2cell(output(:,col(i))),ch{i}));
    ok = intersect(ok,stim_off);
    if ~isempty(ok)
        subplot(2,3,i)
        plot(ff,log10(psd_all_off(ok,:,psd_ch(i))),'b','LineWidth',.5)
        hold on
        plot(ff,log10(psd_all_on(ok,:,psd_ch(i))),'r','LineWidth',.5)
        xlim([0 100])
        ylim([-10 -3])
        title(ch{i})
        set(gca,'FontSize',16)
        set(gcf,'color','w')
    end
end
saveas(gcf,fullfile(savepath,'PSD_on_off_med_stimoff'),'fig');
close 

% 2.plot PSD error bar on off med stim off
options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 2;
options.error      = 'std';
options.x_axis=ff;

for i = 1:5    
    ok=find(strcmp(table2cell(output(:,col(i))),ch{i}));
    ok = intersect(ok,stim_off);
    if ~isempty(ok)
        subplot(2,3,i)
        options.color_area = [128 193 219]./255;    % Blue theme
        options.color_line = [ 52 148 186]./255;
        plot_areaerrorbar(log10(psd_all_off(ok,:,psd_ch(i))),options)
        hold on
        options.color_area = [243 169 114]./255;    % Orange theme
        options.color_line = [236 112  22]./255;
        plot_areaerrorbar(log10(psd_all_on(ok,:,psd_ch(i))),options)
        xlim([0 100])
        ylim([-10 -3])
        title(ch{i})
        set(gca,'FontSize',16)
        set(gcf,'color','w')
        if i==5
            legend('off med','','on med','')
        end
    end
end
saveas(gcf,fullfile(savepath,'PSD_area_on_off_med_stimoff'),'fig');
close 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% on off med stim on 
%1. plot PSD all data on off med stim on

figure
for i = 1:5    
    ok=find(strcmp(table2cell(output(:,col(i))),ch{i}));
    ok = intersect(ok,stim_on);
    if ~isempty(ok)
        subplot(2,3,i)
        plot(ff,log10(psd_all_off(ok,:,psd_ch(i))),'b','LineWidth',.5)
        hold on
        plot(ff,log10(psd_all_on(ok,:,psd_ch(i))),'r','LineWidth',.5)
        xlim([0 100])
        ylim([-10 -3])
        title(ch{i})
        if i==5
            legend('off med','on med')
        end
        set(gca,'FontSize',16)
        set(gcf,'color','w')
    end
end
saveas(gcf,fullfile(savepath,'PSD_on_off_med_stimon'),'fig');
close 

% 2. plot PSD error bar on off med stim on
options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 2;
options.error      = 'std';
options.x_axis=ff;

for i = 1:5    
    ok=find(strcmp(table2cell(output(:,col(i))),ch{i}));
    ok = intersect(ok,stim_on);
    if ~isempty(ok)
        subplot(2,3,i)
        options.color_area = [128 193 219]./255;    % Blue theme
        options.color_line = [ 52 148 186]./255;
        plot_areaerrorbar(log10(psd_all_off(ok,:,psd_ch(i))),options)
        hold on
        options.color_area = [243 169 114]./255;    % Orange theme
        options.color_line = [236 112  22]./255;
        plot_areaerrorbar(log10(psd_all_on(ok,:,psd_ch(i))),options)
        xlim([0 100])
        ylim([-10 -3])
        title(ch{i})
        if i==5
            legend('off med','','on med','')
        end
        set(gca,'FontSize',16)
        set(gcf,'color','w')
    end
end
saveas(gcf,fullfile(savepath,'PSD_area_on_off_med_stim_on'),'fig');
close 

%2 on off stim 

% plot PSD error bar on off stim med off
options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 2;
options.error      = 'std';
options.x_axis=ff;

for i = 1:5    
    ok=find(strcmp(table2cell(output(:,col(i))),ch{i}));
    on = intersect(ok,stim_on);
    off = intersect(ok,stim_off);
    if ~isempty(ok)
        subplot(2,3,i)
        options.color_area = [128 193 219]./255;    % Blue theme
        options.color_line = [ 52 148 186]./255;
        plot_areaerrorbar(log10(psd_all_off(off,:,psd_ch(i))),options)
        hold on
        options.color_area = [243 169 114]./255;    % Orange theme
        options.color_line = [236 112  22]./255;
        plot_areaerrorbar(log10(psd_all_off(on,:,psd_ch(i))),options)
        xlim([0 100])
        ylim([-10 -3])
        title(ch{i})
        if i==5
            legend('off stim','','on stim','')
        end
        set(gca,'FontSize',16)
        set(gcf,'color','w')
    end
end
saveas(gcf,fullfile(savepath,'PSD_area_on_off_stim_med_off'),'fig');
close

% plot PSD error bar on off stim med on
options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 2;
options.error      = 'std';
options.x_axis=ff;
for i = 1:5
    ok=find(strcmp(table2cell(output(:,col(i))),ch{i}));
    on = intersect(ok,stim_on);
    off = intersect(ok,stim_off);
    if ~isempty(ok)
        subplot(2,3,i)
        options.color_area = [128 193 219]./255;    % Blue theme
        options.color_line = [ 52 148 186]./255;
        plot_areaerrorbar(log10(psd_all_on(off,:,psd_ch(i))),options)
        hold on
        options.color_area = [243 169 114]./255;    % Orange theme
        options.color_line = [236 112  22]./255;
        plot_areaerrorbar(log10(psd_all_on(on,:,psd_ch(i))),options)
        xlim([0 100])
        ylim([-10 -3])
        title(ch{i})
        if i==5
            legend('off stim','','on stim','')
        end
        set(gca,'FontSize',16)
        set(gcf,'color','w')
    end
end
saveas(gcf,fullfile(savepath,'PSD_area_on_off_stim_med_on'),'fig');
close

%3 all condition
figure
for i = 1:5
    ok=find(strcmp(table2cell(output(:,col(i))),ch{i}));
    on = intersect(ok,stim_on);
    off = intersect(ok,stim_off);
    if ~isempty(ok)
        subplot(2,3,i)
        plot(ff,mean(log10(psd_all_off(off,:,psd_ch(i)))),'b','LineWidth',1.5)
        hold on
        plot(ff,mean(log10(psd_all_off(on,:,psd_ch(i)))),'g','LineWidth',1.5)
        plot(ff,mean(log10(psd_all_on(off,:,psd_ch(i)))),'r','LineWidth',1.5)
        plot(ff,mean(log10(psd_all_on(on,:,psd_ch(i)))),'k','LineWidth',1.5)
        xlim([0 100])
        ylim([-8.5 -4.5])
        title(ch{i})
        set(gca,'FontSize',16)
        set(gcf,'color','w')
        if i==5
        legend('offmed offstim','offmed onstim','onmed offstim','onmed onstim','FontSize',14)
        end
    end
end
saveas(gcf,fullfile(savepath,'PSD_on_off_stim_on_off_med'),'fig');
close

options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 2;
options.error      = 'std';
options.x_axis=ff;

for i = 1:5    
    ok=find(strcmp(table2cell(output(:,col(i))),ch{i}));
    on = intersect(ok,stim_on);
    off = intersect(ok,stim_off);
    if ~isempty(ok)
        subplot(2,3,i)
        options.color_area = [128 193 219]./255;    % Blue theme
        options.color_line = [ 52 148 186]./255;
        plot_areaerrorbar(log10(psd_all_on(off,:,psd_ch(i))),options)
        hold on
        options.color_area = [243 169 114]./255;    % Orange theme
        options.color_line = [236 112  22]./255;
        plot_areaerrorbar(log10(psd_all_on(on,:,psd_ch(i))),options)
        hold on
        options.color_area = [119 172 48]./255;    % Orange theme
        options.color_line = [119 172 48]./255;
        plot_areaerrorbar(log10(psd_all_off(off,:,psd_ch(i))),options)
        hold on
        options.color_area = [128 128 128]./255;    % Orange theme
        options.color_line = [128 128 128]./255;
        plot_areaerrorbar(log10(psd_all_off(on,:,psd_ch(i))),options)
        xlim([0 100])
        ylim([-10 -3])
        title(ch{i})
        if i==5
        legend('offmed offstim','','offmed onstim','','onmed offstim','','onmed onstim','','FontSize',14)
        end
        set(gca,'FontSize',16)
        set(gcf,'color','w')
    end
end
saveas(gcf,fullfile(savepath,'PSD_area_on_off_stim_on_off_med'),'fig');
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Coherence
% compute coherence  
for i = 1:size(output,1)
    
    sr=output.sampleRate(i);
    dur = 60*sr; %sec
    t1 = 60*4*sr;
    t2=t1+dur;
    
    %off med
    [Cxy,F] = mscohere(output.key0{i}(t1:t2),output.key2{i}(t1:t2),sr,sr/2,sr,sr);
    Coh_all_off(i,:,1) = Cxy;   

    [Cxy,F] = mscohere(output.key0{i}(t1:t2),output.key3{i}(t1:t2),sr,sr/2,sr,sr);
    Coh_all_off(i,:,2) = Cxy;   

    [Cxy,F] = mscohere(output.key1{i}(t1:t2),output.key2{i}(t1:t2),sr,sr/2,sr,sr);
    Coh_all_off(i,:,3) = Cxy;   

    [Cxy,F] = mscohere(output.key1{i}(t1:t2),output.key3{i}(t1:t2),sr,sr/2,sr,sr);
    Coh_all_off(i,:,4) = Cxy;   

   %on med
    [Cxy,F] = mscohere(output.key0{i}(end-dur:end),output.key2{i}(end-dur:end),sr,sr/2,sr,sr);
    Coh_all_on(i,:,1) = Cxy;   

    [Cxy,F] = mscohere(output.key0{i}(end-dur:end),output.key3{i}(end-dur:end),sr,sr/2,sr,sr);
    Coh_all_on(i,:,2) = Cxy;   

    [Cxy,F] = mscohere(output.key1{i}(end-dur:end),output.key2{i}(end-dur:end),sr,sr/2,sr,sr);
    Coh_all_on(i,:,3) = Cxy;   

    [Cxy,F] = mscohere(output.key1{i}(end-dur:end),output.key3{i}(end-dur:end),sr,sr/2,sr,sr);
    Coh_all_on(i,:,4) = Cxy;   
  
end

%off stim
ch1 = {'-2,+3','-2,+3','-0,+2','-0,+2','-0,+1','-0,+1'};
ch2 = {'-8,+9','-10,+11','-8,+9','-10,+11','-8,+9','-10,+11'};
col1 = [12 12 10 10 10 10];
col2 = [14 16 14 16 14 16];
psd_ch = [3 4 1 2 1 2];
% stim_on = find(output.Stim_on==1);
% stim_off = find(isnan(output.Stim_on));

figure
for i = 1:6    
    ok=find(strcmp(table2cell(output(:,col1(i))),ch1{i}) & strcmp(table2cell(output(:,col2(i))),ch2{i}));
    ok = intersect(ok,stim_off);
    if ~isempty(ok)
        subplot(3,2,i)
        plot(F,mean(Coh_all_off(ok,:,psd_ch(i))),'b','LineWidth',.5)
        hold on
        plot(F,mean(Coh_all_on(ok,:,psd_ch(i))),'r','LineWidth',.5)
        xlim([0 100])
        ylim([0 0.6])
        title([ch1{i} ch2{i}])
        set(gca,'FontSize',16)
        set(gcf,'color','w')
        if i==5
            legend('off med','on med')
        end
    end
end
saveas(gcf,fullfile(savepath,'Coh_on_off_med_stimoff'),'fig');
close

% 2.plot PSD error bar on off med stim off
close all
options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 2;
options.error      = 'std';
options.x_axis=ff;

for i = 1:6    
     ok=find(strcmp(table2cell(output(:,col1(i))),ch1{i}) & strcmp(table2cell(output(:,col2(i))),ch2{i}));
    ok = intersect(ok,stim_off);
    if ~isempty(ok)
        subplot(3,2,i)
        options.color_area = [128 193 219]./255;    % Blue theme
        options.color_line = [ 52 148 186]./255;
        plot_areaerrorbar(squeeze(Coh_all_off(ok,:,psd_ch(i))),options)
        hold on
        options.color_area = [243 169 114]./255;    % Orange theme
        options.color_line = [236 112  22]./255;
        plot_areaerrorbar(squeeze(Coh_all_on(ok,:,psd_ch(i))),options)
         xlim([0 100])
        ylim([0 0.4])
        title([ch1{i} ch2{i}])
        set(gca,'FontSize',16)
        set(gcf,'color','w')
        if i==5
            legend('off med','off med','on med','on med')
        end
    end
end
saveas(gcf,fullfile(savepath,'Coh_area_on_off_med_stimoff'),'fig');
close

%on stim

figure
for i = 1:6    
    ok=find(strcmp(table2cell(output(:,col1(i))),ch1{i}) & strcmp(table2cell(output(:,col2(i))),ch2{i}));
    ok = intersect(ok,stim_on);
    if ~isempty(ok)
        subplot(3,2,i)
        plot(F,mean(Coh_all_off(ok,:,psd_ch(i))),'b','LineWidth',.5)
        hold on
        plot(F,mean(Coh_all_on(ok,:,psd_ch(i))),'r','LineWidth',.5)
        xlim([0 100])
        ylim([0 0.6])
        title([ch1{i} ch2{i}])
        set(gca,'FontSize',16)
        set(gcf,'color','w')
        if i==5
            legend('off med','on med')
        end
    end
end
saveas(gcf,fullfile(savepath,'Coh_on_off_med_stimon'),'fig');
close

% 2.plot PSD error bar on off med stim off
close all
options.handle     = figure(1);
options.alpha      = 0.5;
options.line_width = 2;
options.error      = 'std';
options.x_axis=ff;

for i = 1:6    
     ok=find(strcmp(table2cell(output(:,col1(i))),ch1{i}) & strcmp(table2cell(output(:,col2(i))),ch2{i}));
    ok = intersect(ok,stim_on);
    if ~isempty(ok)
        subplot(3,2,i)
        options.color_area = [128 193 219]./255;    % Blue theme
        options.color_line = [ 52 148 186]./255;
        plot_areaerrorbar(squeeze(Coh_all_off(ok,:,psd_ch(i))),options)
        hold on
        options.color_area = [243 169 114]./255;    % Orange theme
        options.color_line = [236 112  22]./255;
        plot_areaerrorbar(squeeze(Coh_all_on(ok,:,psd_ch(i))),options)
         xlim([0 100])
        ylim([0 0.4])
        title([ch1{i} ch2{i}])
        set(gca,'FontSize',16)
        set(gcf,'color','w')
        if i==5
            legend('off med','','on med','')
        end
    end
end
saveas(gcf,fullfile(savepath,'Coh_area_on_off_med_stimon'),'fig');
close

% all conditions
figure
for i = 1:6    
    ok=find(strcmp(table2cell(output(:,col1(i))),ch1{i}) & strcmp(table2cell(output(:,col2(i))),ch2{i}));
    on = intersect(ok,stim_on);
    off = intersect(ok,stim_off);
    if ~isempty(ok)
        subplot(3,2,i)
        plot(F,mean(Coh_all_off(off,:,psd_ch(i))),'b','LineWidth',.5)
        hold on
        plot(F,mean(Coh_all_off(on,:,psd_ch(i))),'g','LineWidth',.5)
        plot(F,mean(Coh_all_on(off,:,psd_ch(i))),'r','LineWidth',.5)
        plot(F,mean(Coh_all_on(on,:,psd_ch(i))),'k','LineWidth',.5)
        xlim([0 100])
        ylim([0 0.4])
        title([ch1{i} ch2{i}])
        set(gca,'FontSize',16)
        set(gcf,'color','w')
        if i==5
            legend('offmed offstim','offmed onstim','onmed offstim','onmed onstim','FontSize',14)
        end
    end
end 
saveas(gcf,fullfile(savepath,'Coh_on_off_stim_on_off_med'),'fig');
close

%         
%         
%         
% figure
% subplot(3,2,1)
% ok=find(strcmp(output.ch1,'-2,+3') & strcmp(output.ch2,'-8,+9'));
% plot(F,Cxy_key1_2_off(ok,:),'b','LineWidth',.5)
% hold on
% plot(F,Cxy_key1_2_on(ok,:),'r','LineWidth',.5)
% xlim([0 125])
% title('GPe S1')
% legend('off med','on med')
% set(gca,'FontSize',16)
% 
% subplot(3,2,2)
% ok=find(strcmp(output.ch1,'-2,+3') & strcmp(output.ch3,'-10,+11'));
% plot(F,Cxy_key1_3_off(ok,:),'b','LineWidth',.5)
% hold on
% plot(F,Cxy_key1_3_on(ok,:),'r','LineWidth',.5)
% xlim([0 125])
% title('GPe M1')
% set(gca,'FontSize',16)
% 
% subplot(3,2,3)
% ok=find(strcmp(output.ch0,'-0,+2') & strcmp(output.ch2,'-8,+9'));
% plot(F,Cxy_key0_2_off(ok,:),'b','LineWidth',.5)
% hold on
% plot(F,Cxy_key0_2_on(ok,:),'r','LineWidth',.5)
% xlim([0 125])
% title('GPi-e S1')
% set(gca,'FontSize',16)
% 
% subplot(3,2,4)
% ok=find(strcmp(output.ch0,'-0,+2') & strcmp(output.ch3,'-10,+11'));
% plot(F,Cxy_key0_3_off(ok,:),'b','LineWidth',.5)
% hold on
% plot(F,Cxy_key0_3_on(ok,:),'r','LineWidth',.5)
% xlim([0 125])
% title('GPi-e M1')
% set(gca,'FontSize',16)
% 
% subplot(3,2,5)
% ok=find(strcmp(output.ch0,'-0,+1') & strcmp(output.ch2,'-8,+9'));
% plot(F,Cxy_key0_2_off(ok,:),'b','LineWidth',.5)
% hold on
% plot(F,Cxy_key0_2_on(ok,:),'r','LineWidth',.5)
% xlim([0 125])
% title('GPi S1')
% set(gca,'FontSize',16)
% 
% subplot(3,2,6)
% ok=find(strcmp(output.ch0,'-0,+1') & strcmp(output.ch3,'-10,+11'));
% plot(F,Cxy_key0_3_off(ok,:),'b','LineWidth',.5)
% hold on
% plot(F,Cxy_key0_3_on(ok,:),'r','LineWidth',.5)
% xlim([0 125])
% title('GPi M1')
% set(gca,'FontSize',16)
% saveas(gcf,'Coh_on_off_med','fig');
% 
% subplot(3,2,6)
% ok=find(strcmp(output.ch0,'-0,+1') & strcmp(output.ch3,'-10,+11'));
% plot(F,Cxy_key1_3_off(ok,:),'b','LineWidth',.5)
% hold on
% plot(F,Cxy_key1_3_on(ok,:),'r','LineWidth',.5)
% xlim([0 125])
% title('GPe M1')
% set(gca,'FontSize',16)
% set(gcf,'color','w')
% saveas(gcf,'Coh_on_off_med','fig');
% 
% % plot Coh error bars
% close all
% options.handle     = figure(1);
% options.alpha      = 0.5;
% options.line_width = 2;
% options.error      = 'std';
% options.x_axis=F;
% 
% subplot(3,2,1)
% ok=find(strcmp(output.ch1,'-2,+3') & strcmp(output.ch2,'-8,+9'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(Cxy_key1_2_off(ok,:),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(Cxy_key1_2_on(ok,:),options)
% xlim([0 125])
% ylim([0 0.5])
% title('GPe S1')
% legend('off med','on med')
% set(gca,'FontSize',16)
% 
% subplot(3,2,2)
% ok=find(strcmp(output.ch1,'-2,+3') & strcmp(output.ch3,'-10,+11'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(Cxy_key1_3_off(ok,:),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(Cxy_key1_3_on(ok,:),options)
% xlim([0 125])
% ylim([0 0.5])
% title('GPe M1')
% set(gca,'FontSize',16)
% 
% subplot(3,2,3)
% ok=find(strcmp(output.ch0,'-0,+2') & strcmp(output.ch2,'-8,+9'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(Cxy_key0_2_off(ok,:),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(Cxy_key0_2_on(ok,:),options)
% xlim([0 125])
% ylim([0 0.5])
% title('GPi-e S1')
% set(gca,'FontSize',16)
% 
% subplot(3,2,4)
% ok=find(strcmp(output.ch0,'-0,+2') & strcmp(output.ch3,'-10,+11'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(Cxy_key0_3_off(ok,:),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(Cxy_key0_3_on(ok,:),options)
% xlim([0 125])
% ylim([0 0.5])
% title('GPi-e M1')
% set(gca,'FontSize',16)
% 
% subplot(3,2,5)
% ok=find(strcmp(output.ch0,'-0,+1') & strcmp(output.ch2,'-8,+9'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(Cxy_key0_2_off(ok,:),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(Cxy_key0_2_on(ok,:),options)
% xlim([0 125])
% ylim([0 0.5])
% title('GPi S1')
% set(gca,'FontSize',16)
% 
% subplot(3,2,6)
% ok=find(strcmp(output.ch0,'-0,+1') & strcmp(output.ch3,'-10,+11'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(Cxy_key0_3_off(ok,:),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(Cxy_key0_3_on(ok,:),options)
% xlim([0 125])
% ylim([0 0.5])
% title('GPi M1')
% set(gcf,'color','w')
% saveas(gcf,'Coh_on_off_med_errorbar','fig');
% 
% 
%                     
% % compute PAC         
% 
% 
% 
% 






% for i = 1:size(output,1)
%     
%     sr=output.sampleRate(i);
%     dur = 60*sr; %sec
%     t1 = 60*4*sr;
%     t2=t1+dur;
%     
%     %key0
%     [fftOut,ff]   = pwelch(output.key0{i}(t1:t2),sr,sr/2,0:1:sr/2,sr,'psd');
%     psd_key0_off(i,:) = fftOut;
%     [fftOut,ff]   = pwelch(output.key0{i}(end-dur:end),sr,sr/2,0:1:sr/2,sr,'psd');
%     psd_key0_on(i,:) = fftOut;
%     
%     %key1
%     [fftOut,ff]   = pwelch(output.key1{i}(t1:t2),sr,sr/2,0:1:sr/2,sr,'psd');
%     psd_key1_off(i,:) = fftOut;
%     [fftOut,ff]   = pwelch(output.key1{i}(end-dur:end),sr,sr/2,0:1:sr/2,sr,'psd');
%     psd_key1_on(i,:) = fftOut;
%     
%     %key2
%     [fftOut,ff]   = pwelch(output.key2{i}(t1:t2),sr,sr/2,0:1:sr/2,sr,'psd');
%     psd_key2_off(i,:) = fftOut;
%     [fftOut,ff]   = pwelch(output.key2{i}(end-dur:end),sr,sr/2,0:1:sr/2,sr,'psd');
%     psd_key2_on(i,:) = fftOut;
%     
%     %key3
%     [fftOut,ff]   = pwelch(output.key3{i}(t1:t2),sr,sr/2,0:1:sr/2,sr,'psd');
%     psd_key3_off(i,:) = fftOut;
%     [fftOut,ff]   = pwelch(output.key3{i}(end-dur:end),sr,sr/2,0:1:sr/2,sr,'psd');
%     psd_key3_on(i,:) = fftOut;
% end

% % %plot PSD all data
% % ch = {'-0,+1','-2,+3','-0,+2','-1,+3','-8,+9','-10,+11'};
% % col = [8 10 8 10 12 14];
% % figure
% % for i = 1:6
% % 
% % subplot(2,4,i)
% % ok=find(strcmp(table2cell(output(:,col(i))),ch{i}));
% % 
% % plot(ff,log10(psd_key0_off(ok,:)),'b','LineWidth',.5)
% % hold on
% % plot(ff,log10(psd_key0_on(ok,:)),'r','LineWidth',.5)
% % xlim([0 125])
% % ylim([-10 -3])
% % title('-0,+1')
% % set(gca,'FontSize',16)
% % 
% 
% figure
% subplot(2,3,1)
% ok=find(strcmp(output.ch0,'-0,+1'));
% plot(ff,log10(psd_key0_off(ok,:)),'b','LineWidth',.5)
% hold on
% plot(ff,log10(psd_key0_on(ok,:)),'r','LineWidth',.5)
% xlim([0 125])
% ylim([-10 -3])
% title('-0,+1')
% set(gca,'FontSize',16)
% 
% subplot(2,3,2)
% ok=find(strcmp(output.ch1,'-2,+3'));
% plot(ff,log10(psd_key1_off(ok,:)),'b','LineWidth',.5)
% hold on
% plot(ff,log10(psd_key1_on(ok,:)),'r','LineWidth',.5)
% xlim([0 125])
% ylim([-10 -3])
% title('-2,+3')
% set(gca,'FontSize',16)
% 
% subplot(2,3,3)
% ok=find(strcmp(output.ch0,'-0,+2'));
% plot(ff,log10(psd_key1_off(ok,:)),'b','LineWidth',.5)
% hold on
% plot(ff,log10(psd_key1_on(ok,:)),'r','LineWidth',.5)
% xlim([0 125])
% ylim([-10 -3])
% title('-0,+2')
% set(gca,'FontSize',16)
% 
%  %2) cortex
% subplot(2,3,4)
% ok=find(strcmp(output.ch2,'-8,+9'));
% plot(ff,log10(psd_key2_off(ok,:)),'b','LineWidth',.5)
% hold on
% plot(ff,log10(psd_key2_on(ok,:)),'r','LineWidth',.5)
% xlim([0 125])
% ylim([-10 -3])
% title('-8,+9')
% set(gca,'FontSize',16)
% 
% subplot(2,3,5)
% ok=find(strcmp(output.ch3,'-10,+11'));
% plot(ff,log10(psd_key3_off),'b','LineWidth',.5)
% hold on
% plot(ff,log10(psd_key3_on),'r','LineWidth',.5)
% xlim([0 125])
% ylim([-10 -3])
% title('-10,+11')
% set(gca,'FontSize',16)
% set(gcf,'color','w')
% saveas(gcf,'PSD_on_off_med','fig');
% 
% %plot PSD error bars
% options.handle     = figure(1);
% options.alpha      = 0.5;
% options.line_width = 2;
% options.error      = 'std';
% options.x_axis=ff;
%    
% %1) Gp
% subplot(2,3,1)
% ok=find(strcmp(output.ch0,'-0,+1'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(log10(psd_key0_off(ok,:)),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(log10(psd_key0_on(ok,:)),options)
% xlim([0 125])
% ylim([-10 -3])
% title('-0,+1')
% set(gca,'FontSize',16)
% 
% subplot(2,3,2)
% ok=find(strcmp(output.ch1,'-2,+3'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(log10(psd_key1_off(ok,:)),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(log10(psd_key1_on(ok,:)),options)
% xlim([0 125])
% ylim([-10 -3])
% title('-2,+3')
% set(gca,'FontSize',16)
% 
% subplot(2,3,3)
% ok=find(strcmp(output.ch0,'-0,+2'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(log10(psd_key0_off(ok,:)),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(log10(psd_key0_on(ok,:)),options)
% xlim([0 125])
% ylim([-10 -3])
% title('-0,+2')
% set(gca,'FontSize',16)
% 
%  %2) cortex
% subplot(2,3,4)
% ok=find(strcmp(output.ch2,'-8,+9'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(log10(psd_key2_off(ok,:)),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(log10(psd_key2_on(ok,:)),options)
% xlim([0 125])
% ylim([-10 -3])
% title('-8,+9')
% set(gca,'FontSize',16)
% 
% subplot(2,3,5)
% ok=find(strcmp(output.ch3,'-10,+11'));
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;    
% plot_areaerrorbar(log10(psd_key3_off(ok,:)),options)
% hold on
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
% plot_areaerrorbar(log10(psd_key3_on(ok,:)),options)
% xlim([0 125])
% ylim([-10 -3])
% title('-10,+11')
% set(gcf,'color','w')
% set(gca,'FontSize',16)
% saveas(gcf,'PSD_on_off_med_errorbars','fig');
% 
%            