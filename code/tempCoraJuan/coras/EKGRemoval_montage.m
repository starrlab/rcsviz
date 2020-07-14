function [splineData] = EKGRemoval_montage(signal,srates)

% define paramaters
Fs = srates(1);
mindist = 100/Fs*1000; % min 250ms between peaks
tpeak = 15/Fs*1000; % 50ms before and after peaks for interpolation


[v,p]=findpeaks(abs(signal),'MinPeakHeight',mean(abs(signal))+2*std(abs(signal)),'MinPeakDistance',mindist);

figure
plot(abs(signal))
hold on
plot(p,v,'o')

artifactStarts = [p-tpeak];
artifactEnds = [p+tpeak];

% Spline
splineData = signal;

    for i = 2:length(artifactStarts)-2
        currentArtifactBounds = [artifactStarts(i) artifactEnds(i)];
        replacementValues = spline(currentArtifactBounds,splineData(currentArtifactBounds),artifactStarts(i):artifactEnds(i) );
        
        splineData(artifactStarts(i):artifactEnds(i)) = replacementValues;
        clear replacementValues
    end

signal_clean(i)