function [t_out,Y_out] = preprocessTDSignals(outdatcomplete,fillPacketLossGaps,sampleRate)

% inputs:
% 1) outdatcomplete
% 2) factor X: to multiply average time difference of samples (eg. 1000); to
% identify gaps ### needs more validation to establish range and suggested

% removes DC and transforms to mV to microvolts and puts the neural signals into a matrix 4xm (m number of samples of the time domain signal)
y0 = outdatcomplete.key0; y0 = (y0-mean(y0))*1e3; 
y1 = outdatcomplete.key1; y1 = (y1-mean(y1))*1e3;
y2 = outdatcomplete.key2; y2 = (y2-mean(y2))*1e3;
y3 = outdatcomplete.key3; y3 = (y3-mean(y3))*1e3;

Y(1,:) = y0;
Y(2,:) = y1;
Y(3,:) = y2;
Y(4,:) = y3;

t = outdatcomplete.derivedTimes;

if fillPacketLossGaps
    %% find for large time gaps greater than X second and fill it with Zeros
    t_num = datenum(t);
    figure(10)
    subplot(211)
    plot(t_num,Y(1,:),'o')
    t_num_diff = diff(t_num);
    subplot(212);plot(t_num(1:end-1),t_num_diff,'+r')
    mean_val = mean(t_num_diff);
    [peak,gapIdx] = findpeaks(t_num_diff,'Threshold',mean_val*sampleRate*2) % packet loss longer than 2 x sample rate ### sr = 500 (hard coded)

    if isempty(gapIdx) % no packet loss higher than 2 seconds
        Y_out = Y;
        t_out = t;   

    else % there is packet loss for longer than 2 seconds
        hold on, plot(t_num(gapIdx),peak,'o')
        subplot(211), hold on, plot(t_num(gapIdx),Y(1,gapIdx),'+r')
        hold on, plot(t_num(gapIdx+1),Y(1,gapIdx+1),'+g')

        numGaps = length(gapIdx)
        gapDur = abs(t(gapIdx)-t(gapIdx+1));
        gapDur.Format = 's'

        t_sample = diff(t(1:gapIdx(1)));
        t_sample.Format = 's'
        figure(100)
        histogram(seconds(t_sample)) ; % 2 ms (500 sampling rate)

        t_new = t;
        Y_new = Y(:,:);    
        for ii=1:length(gapIdx)
            gapDur(ii)
            numSampleGap = seconds(gapDur(ii)) * 500; % ### sr IS HARD CODED ###
            % for ii=1:length(gapIdx)
            t_gap = linspace(t(gapIdx(ii)),t(gapIdx(ii)+1),numSampleGap);
            Y_gap = zeros(4,int64(numSampleGap));
            figure(10);subplot(211), hold on, plot(datenum(t_gap),Y_gap(1:length(t_gap)),'+g')
            t_new = [t_new(1:gapIdx);t_gap';t_new(gapIdx+1:end)];
            Y_new = [Y_new(:,1:gapIdx),Y_gap,Y_new(:,gapIdx+1:end)];
        end

        %% output filled with zeros where there are data gaps with a time diff of X (seconds or samples) ## to be figure out
        if size(t_new,1)~=size(Y_new,2)
            diffSize_tY = size(t_new,1)-size(Y_new,2);
            if diffSize_tY > 0 % more time samples (adding one 0 to Y)
                Y_out = [Y_new,zeros(4,abs(diffSize_tY))];
            elseif diffSize_tY < 0 % more Y samples (removing last sample from Y)
                Y_out = Y_new(:,1:end-abs(diffSize_tY));
            end
        else % nothing to fix
            Y_out = Y_new;
        end
        t_out = t_new;
    end
    
else % no need to fill in packet loss gaps
    Y_out = Y';
    t_out = t';
end

end