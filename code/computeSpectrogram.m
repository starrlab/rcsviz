function [Sp,Fp,Tp,specRes] = computeSpectrogram(Y,sr,freqBnd1,freqBnd2)

%% assumes two frequency bands and creates
% pallidal, freqBnd1
% cortex, freqBnd2
% if no freq band arguments passed, default [1, 100]
% uses following parameters for spectrogram
% specRes = 500e-3; % seconds
% overlapPerc = 80;
% minThreshold = -1;

specRes = 500e-3; % seconds
overlapPerc = 80;
minThreshold = -1;

if isempty(freqBnd1) || isempty(freqBnd2)
    freqBnd1 = [1 100];
    freqBnd2 = [1 100];
end

for ii=1:size(Y,1)
    % assign freq band
    if ii==1 || i==2
        freqBnd = freqBnd1;
    else
        freqBnd = freqBnd2;
    end
    
    [sptemp,fptemp,tptemp] = pspectrum(Y(ii,:),sr,'spectrogram','Leakage',1,'OverlapPercent',overlapPerc, ...
                                'MinThreshold',minThreshold,'FrequencyLimits',freqBnd,'TimeResolution', specRes);
    Sp(ii,:,:) = sptemp;
    Fp(ii,:,:) = fptemp;
    Tp(ii,:,:) = tptemp;
   
 end