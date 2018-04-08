% estimate the Doppler by correlating with the abs(fft(P/N sequence))

close all;
clear all;

Ts = 1e-5; % sampling time in [s]
desiredResolution = 1; % in [Hz]

load r.mat
load p.mat

% see what we have in r
scatterplot(r); grid on;
title('Received signal');

% size of the FFT
N = ceil(1/(Ts*desiredResolution));

pFft = fft(p,N);
rFft = fft(r,N);

R = xcorr(abs(rFft),abs(pFft));

% display to see how good is the correlation
figure;
plot(R); grid on
title('Xcorr result'); 

[~, indexMax] = max(R);
trueIndex = indexMax - length(rFft)

% check the resolution
frequencyResolution = 1/(N*Ts)

estimatedDoppler = trueIndex*frequencyResolution

% correct the signal y and plot it
timeLine = (0:length(r)-1)*Ts;
rCorrected = r.*exp(-1j*2*pi*estimatedDoppler*timeLine);

scatterplot(rCorrected); grid on;
title('Received signal corrected for Doppler');
