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
fftBins = powerSettings.powerBandsInHz.fftBins;
fftBinUpperBound = powerSettings.powerBandsInHz.upperBound(1); % assuming only 1 power band (B1)
fftBinLowerBound = powerSettings.powerBandsInHz.lowerBound(1);
fUpperBin = fftBins(max(find(fftBins<fftBinUpperBound)));
fLowerBin = fftBins(max(find(fftBins<fftBinLowerBound)));
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
timewinidx = round(timewin*sr); % convert ms to idx

% create hann taper function, equivalent to the Hann 100% 
hann_win = .5*(1-cos(2*pi*(0:timewinidx-1)/(timewinidx-1)));

% plot the data
fig1 = figure(1); fontSize = 16;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [1/2, 0, 1/2, 1]);
set( findall(fig1, '-property', 'fontsize'), 'fontsize', fontSize)

% plot benchtop time domain signal
subplot(411)
plot(t,lfp_td)
title('One trial of data')

% output fft parameter
subplot(424), hold on
axis off
text(0,1,['sr = ', num2str(sr), 'Hz'])
text(0,0.9,['fftsize = ', num2str(fftSize), 'pnts'])
text(0,0.8,['fft time window = ', num2str(timewin), 'ms'])
text(0,0.7,['fft interval = ', num2str(interval_ms), 'ms'])
text(0,0.6,['fft overlap = ', num2str(overlap*100), '%'])
text(0.5,1,['fUpperBin = ', num2str(fUpperBin), 'Hz'])
text(0.5,0.9,['fLowerBin = ', num2str(fLowerBin), 'Hz'])

% plot next fft segment window and the hanned equivalent
subplot(423), hold on
stime = 1; % sample 1 of data set where window starts
plot(t(stime:stime+timewinidx-1),lfp_td(stime:stime+timewinidx-1))
plot(t(stime:stime+timewinidx-1),lfp_td(stime:stime+timewinidx-1)'.*hann_win,'r')
title('One short-time window of data, windowed')
legend('raw lfp_td','lfp_td * hann')
if transform2rcsUnits
    ylabel('voltage (rcs au)')
else
    ylabel('voltage (uV)')
end
set( findall(fig1, '-property', 'fontsize'), 'fontsize', fontSize)

% plot power signal from RCS
subplot(414)
yyaxis left
plot(tpwrs,PB1,'color','b','LineWidth',2)
if transform2rcsUnits
    ylabel('power (rcs au)')
else
    ylabel('power (uV^2)')
end
title(['Mean Power Value from RCS = ',num2str(mean(PB1))])

% loop get fft of window of data using time window increments
numFFTWindows_calcfromTD = ceil(length(lfp_td)/timewinidx/(1-overlap))+1; 
for ii=1:numFFTWindows_calcfromTD
    % check at least one time window available before reach end signal
    if stime+timewinidx <= length(t)        
        % indicate where in time the running window is on time domain signal
        subplot(411), hold on
        plot(t(stime+timewinidx),0,'ok')
        if transform2rcsUnits
            ylabel('voltage (rcs au)')
        else
            ylabel('voltage (uV)')
        end

        % plot raw and hanned version (blue) of the time windowed (red) signal segment
        subplot(423), hold off
        plot(t(stime:stime+timewinidx-1),lfp_td(stime:stime+timewinidx-1)), hold on
        plot(t(stime:stime+timewinidx-1),lfp_td(stime:stime+timewinidx-1)'.*hann_win,'r')
        title('time window for next fft')
        if transform2rcsUnits
            ylabel('voltage (rcs au)')
        else
            ylabel('voltage (uV)')
        end

        % calculate average Power (squared fft of time windowed signal)
        yfft = fft(lfp_td(stime:stime+timewinidx-1)'.*hann_win,fftSize);
        fftPower = abs(yfft(1:floor(length(hann_win)/2)+1)).^2;
        fiUp = find(fftBins==fUpperBin); % using frequency bins from fftBins = powerSettings.powerBandsInHz.fftBins;
        fiLow = find(fftBins==fLowerBin);
        avgPower(ii) = (1/length(fiLow:fiUp))*sum(fftPower(fiLow:fiUp));
        
        % plot calculated fft of last time window
        subplot(413)
        yyaxis right, plot(fftBins,fftPower(1:end-1),'-+r');
        title('power spectrum from time window'), xlabel('frequency (Hz)')
        if transform2rcsUnits
            ylabel('power (rcs au)')
        else
            ylabel('power (uV^2)')
        end
        
        % superimpose actual fft from RCS
        if ii<=size(FFTData,1)
            yyaxis left
            plot(fftBins,FFTData.FftOutput{ii},'-ob');
            ylabel('fft (rcs au)')
            xlabel('frequency (Hz)')
            legend('fft rcs','fft calculated')
        end

        % plot caculated power (red +) on same pannel as RCS (magenta)
        subplot(414)
        yyaxis right
        plot(tpwrs(1:ii),avgPower(1:ii),'-+r')
        if transform2rcsUnits
            ylabel('power (rcs au)')
        else
            ylabel('power (uV^2)')
        end

        set( findall(fig1, '-property', 'fontsize'), 'fontsize', fontSize)    
    else
        % do nothing
    end   
    stime = stime + (timewinidx - ceil(timewinidx*overlap));
    pause(0.1)
end

% display the ration between mean Power RCS and calculated power from TD
disp(['mean power from RCS = ',num2str(mean(PB1))])
disp(['mean calculated power = ',num2str(mean(avgPower))])
disp(['Ratio between RCS power and calculate = ',num2str(mean(PB1)/mean(avgPower))])

legend(['power from RCS (mean) = ',num2str(num2str(mean(PB1)))],...
            ['power calculated (mean) = ',num2str(mean(avgPower))])
title(['power rcs / power calculated = ', num2str(mean(PB1)/mean(avgPower))])

% plot all FFT data from INS without any scaling in a different figure
if ~isempty(FFTData)
    numFFTs = size(FFTData,1);
    figure(3), hold on
    for ii=1:numFFTs
        plot(fftBins,FFTData.FftOutput{ii},'o-')    % 1e6 to go from power in mV2 to uV2
    end
end
title('raw fft from RCS in au')
xlabel('frequency (Hz)')