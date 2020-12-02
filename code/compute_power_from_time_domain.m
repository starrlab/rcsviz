%% function compute_power_from_time_domain()
% this function computes fft based power from a time domain signal using hann window (100%)
clear all, close all, clc

transform2rcsUnits = 1;

% laod RCS data
addpath('/Users/juananso/Dropbox (Personal)/Work/Git_Repo/UCSF-rcs-data-analysis/code')
datafolder = uigetdir('/Users/juananso/Dropbox (Personal)/Work/DATA/power')
[timeDomainSettings,timeDomainData,AccelData,PowerData, powerSettings,FFTData, metaData] = DEMO_ProcessRCS(datafolder);

% extracting time domai signal and settings
t0 = timeDomainData.DerivedTime;
t = seconds(t0-t0(1))/1000;
key0 = timeDomainData.key0;

% either invert from lfp mV to lfp internal rcs value or from mV to uV
if transform2rcsUnits
    lfp_mv = key0-mean(key0); 
    CONFIG_TRIM_CH = 236; % This is specific to device and Ch (deviceSettings)
    lfpGain_ch = 250*(CONFIG_TRIM_CH/255);
    fpReadUnitsValue = 48644.8683623726;
    lfp_rcs = lfp_mv * (lfpGain_ch*fpReadUnitsValue) / (1000*1.2);
    lfp_td = lfp_rcs;
else % transform mV to uV
    lfp_uV = 1e3*(key0-mean(key0)); 
    lfp_td = lfp_uV;
end

% extracting power band, fft and power settings
PB1 = PowerData.Band1;
tpwr = PowerData.DerivedTime;
tpwrs = seconds(tpwr-tpwr(1))/1000;
interval_ms = powerSettings.fftConfig.interval; % is given in ms

fftBinsHz = powerSettings.powerBandsInHz.fftBins;
binStart = powerSettings.powerBands{1}.band0Start;
binStart(1) = binStart(1)+1; % not clear why but it gives closer results
binEnd = powerSettings.powerBands{1}.band0Stop;
binEnd(1) = binEnd(1)+1; % not clear why but it gives closer results
fftSize = powerSettings.powerBandsInHz.fftSize;
sr = timeDomainSettings.samplingRate;

% from excel sheet for 64,250,1024 fftpoints
switch fftSize
    case 64, fftpt_overlapcalc = 62;
    case 256, fftpt_overlapcalc = 250;
    case 1024, fftpt_overlapcalc = 1000;
end

% time window parameters
overlap = 1-(sr*interval_ms/1e3/fftpt_overlapcalc);
timewin = fftSize/sr;
tpwrs = tpwrs + seconds(timewin); % add offset of first power sample after first fft
L = fftSize; % timeWin is now named L, number of time window points

% create hann taper function, equivalent to the Hann 100% 
hann_win = 0.5*(1-cos(2*pi*(0:L-1)/(L-1)));
figure(1)
plot(hann_win,'-o')
title('Hann Window (100%)')
xlabel('samples')
ylabel('scale 0 to 1')

% plot the data
fig2 = figure(2); fontSize = 16;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [1/2, 0, 1/2, 1]);
set( findall(fig2, '-property', 'fontsize'), 'fontsize', fontSize)

% plot benchtop time domain signal
subplot(411)
plot(t,lfp_td)
title('One trial of data')

% output fft parameter
subplot(424), hold on
axis off
startCol1 = -0.2;
startY = 0.9;
% first col
text(startCol1,startY+0.1,'FFT settings')
text(startCol1,startY,['sr = ', num2str(sr), 'Hz'])
text(startCol1,startY-.1,['fftsize = ', num2str(L), 'pnts'])
text(startCol1,startY-.2,['fft time window = ', num2str(timewin*1e3), 'ms'])
text(startCol1,startY-.3,['fft interval = ', num2str(interval_ms), 'ms'])
text(startCol1,startY-.4,['fft overlap = ', num2str(overlap*100), '%'])
% second col
startCol2 = startCol1+0.5;
text(startCol2,startY+0.1,'FFT Power Bins')
text(startCol2,startY,['fLowerBin = ', num2str(fftBinsHz(binStart)), 'Hz'])
text(startCol2,startY-0.1,['fUpperBin = ', num2str(fftBinsHz(binEnd)), 'Hz'])
text(startCol2,startY-.2,['all bins avg Power= ', num2str(fftBinsHz(binStart:binEnd))])

% plot next fft segment window and the hanned equivalent
subplot(423), hold on
stime = 1; % sample 1 of data set where window starts
plot(t(stime:stime+L-1),lfp_td(stime:stime+L-1))
plot(t(stime:stime+L-1),lfp_td(stime:stime+L-1)'.*hann_win,'r')
title('One short-time window of data, windowed')
legend('raw lfp_td','lfp_td * hann')
if transform2rcsUnits
    ylabel('voltage (rcs au)')
else
    ylabel('voltage (uV)')
end
set( findall(fig2, '-property', 'fontsize'), 'fontsize', fontSize)

% plot power signal from RCS
subplot(414)
yyaxis left
plot(tpwrs,PB1,'color','b','LineWidth',2)
ylabel('power (rcs au)')
title(['Mean Power Value from RCS = ',num2str(mean(PB1))])

% loop get fft of window of data using time window increments
numFFTWindows_calcfromTD = ceil(length(lfp_td)/L/(1-overlap))+1; 
for ii=1:numFFTWindows_calcfromTD
    figure(2)
    % check at least one time window available before reach end signal
    if stime+L <= length(t)        
        % indicate where in time the running window is on time domain signal
        subplot(411), hold on
        plot(t(stime+L),0,'ok')
        if transform2rcsUnits
            ylabel('voltage (rcs au)')
        else
            ylabel('voltage (uV)')
        end

        % plot of fft time window, raw (blue) and hanned (red) segments
        subplot(423), hold off
        plot(t(stime:stime+L-1),lfp_td(stime:stime+L-1)), hold on
        plot(t(stime:stime+L-1),lfp_td(stime:stime+L-1)'.*hann_win,'r')
        title('time window for next fft')
        if transform2rcsUnits
            ylabel('voltage (rcs au)')
        else
            ylabel('voltage (uV)')
        end
        legend('raw signal','hann windowed')

        % calculate average Power (squared fft of time windowed signal)
        X = fft(lfp_td(stime:stime+L-1)'.*hann_win,L);
        SSB = X(1:L/2); % single sided
        SSB(2:end) = 2*SSB(2:end); % scaling step 1, to go from Dobulbe Sided to Single Sided
        YFFT = abs(SSB/(L/2)); % scaling step 2, dividing by (#?) time window length
        fftPower = 2*(YFFT.^2);
        avgPower(ii) = (1/length(binStart:binEnd))*sum(fftPower(binStart:binEnd));
        
        % plot calculated fft of last time window
        subplot(413)
        yyaxis right, plot(fftBinsHz(1:length(YFFT)),YFFT,'-+r');
        title('fft last time window'), xlabel('frequency (Hz)')
        if transform2rcsUnits
            ylabel('|X(f)| (rcs au)')
        else
            ylabel('|X(f)| (uV^2)')
        end
        
        % superimpose actual fft from RCS
        if ii<=size(FFTData,1)
            yyaxis left
            plot(fftBinsHz,FFTData.FftOutput{ii},'-ob');
            ylabel('fft (rcs au)')
            xlabel('frequency (Hz)')
            legend('fft rcs','fft calculated')
        end

        % plot caculated power (red +) on same pannel as RCS (magenta)
        if ii<=length(tpwrs)
            subplot(414)
            yyaxis right
            plot(tpwrs(1:ii),avgPower(1:ii),'-r','LineWidth',2)

            if transform2rcsUnits
                ylabel('power (rcs au)')
            else
                ylabel('power (uV^2)')
            end
            legend('power rcs','power calculated')
        end
    else
        % do nothing
    end   
    set( findall(fig2, '-property', 'fontsize'), 'fontsize', fontSize)    
    stime = stime + (L - ceil(L*overlap));
    pause(0.1)
end
legend(['avg power rcs = ',num2str(num2str(mean(PB1)))],...
       ['avg power calculated = ',num2str(mean(avgPower))])
title(['power rcs / power calculated = ', num2str(mean(PB1)/mean(avgPower))])

% display the ration between mean Power RCS and calculated power from TD
disp(['avg power rcs = ',num2str(mean(PB1))])
disp(['avg power calculated = ',num2str(mean(avgPower))])
disp(['Ratio rcs to calculated = ',num2str(mean(PB1)/mean(avgPower))])