function compute_power_from_time_domain()

% this function computes fft based power from a time domain signal using hann window (100%)

close all, clear all, clc
timewin = 500; % 50 t0 10,000 ms
sr = 1000; % [250, 500, 1000]

% convert ms to idx
timewinidx = round(timewin*1e-3*sr);

% create hann taper function, equivalent to the Hann 100% 
hann_win = .5*(1-cos(2*pi*(0:timewinidx-1)/(timewinidx-1)));
hann_win_mat = hann(timewinidx); 
figure, plot(hann_win), hold on, plot(hann_win_mat,'o')

% create sample sinusoid signal or load a data segment (note the sr of data
% segment should be defined as sr)
fs = sr;
f = 10;
A = 1;
T = 10;
ts = 1/fs;
t = 0:ts:T;
d = A*sin(2*pi*f*t);

figure
subplot(311)
plot(t,d)
title('One trial of data')

stime = 1; % sample 1 of data set where window starts
subplot(323)
plot(t(stime:stime+timewinidx-1),d(stime:stime+timewinidx-1))
hold on
plot(t(stime:stime+timewinidx-1),d(stime:stime+timewinidx-1).*hann_win,'r')
title('One short-time window of data, windowed')

dfft = fft(d(stime:stime+timewinidx-1).*hann_win);
f    = linspace(0,sr/2,floor(length(hann_win)/2)+1); % frequencies of FFT
subplot(313)
plot(f(2:end),abs(dfft(2:floor(length(hann_win)/2)+1)).^2,'.-');
title('power spectrum from that time window')