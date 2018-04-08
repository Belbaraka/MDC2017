close all;


Fs=5000;
R=100;
USF=Fs/R;
span1=6;
span2=20;

%beta=0
pulse1=rcosdesign(0,span1,USF,'sqrt');
%[p1, p2]=tfplot(pulse1,Fs,'pulse','beta=0 and span=6T');
pulse2=rcosdesign(0,span2,USF,'sqrt');

%beta=0.3
pulse3=rcosdesign(0.3,span1,USF,'sqrt');
pulse4=rcosdesign(0.3,span2,USF,'sqrt');

%beta=0.9
pulse5=rcosdesign(0.9,span1,USF,'sqrt');
pulse6=rcosdesign(0.9,span2,USF,'sqrt');

figure;
subplot(2,3,1);
plot_noiseless_eye(pulse1, Fs, USF); 
title('\beta=0, Truncated at 6T');

subplot(2,3,4);
plot_noiseless_eye(pulse2, Fs, USF); 
title('\beta=0, Truncated at 20T');

subplot(2,3,2);
plot_noiseless_eye(pulse3, Fs, USF); 
ylabel('Amplitude'); xlabel('Time [s]');
title('\beta=0.3, Truncated at 6T');

subplot(2,3,5);
plot_noiseless_eye(pulse4, Fs, USF); 
title('\beta=0.3, Truncated at 20T');

subplot(2,3,3);
plot_noiseless_eye(pulse5, Fs, USF); 
title('\beta=0.9, Truncated at 6T');

subplot(2,3,6);
plot_noiseless_eye(pulse6, Fs, USF);
title('\beta=0.9, Truncated at 20T');

figure;
subplot(2,3,1);
tfplotTime(pulse1, Fs, '\phi','\beta=0 and span=3T ');

subplot(2,3,4);
tfplotTime(pulse2, Fs, '\phi','\beta=0 and span=6T ');

subplot(2,3,2);
tfplotTime(pulse3, Fs, '\phi','\beta=0.3 and span=3T ');

subplot(2,3,5);
tfplotTime(pulse4, Fs, '\phi','\beta=0.3 and span=6T ');

subplot(2,3,3);
tfplotTime(pulse5, Fs, '\phi','\beta=0.9 and span=3T ');

subplot(2,3,6);
tfplotTime(pulse6, Fs, '\phi','\beta=0.9 and span=6T ');

figure;
subplot(2,3,1);
tfplotFreq(pulse1, Fs, '\phi','\beta=0 and span=3T ');

subplot(2,3,4);
tfplotFreq(pulse2, Fs, '\phi','\beta=0 and span=6T ');

subplot(2,3,2);
tfplotFreq(pulse3, Fs, '\phi','\beta=0.3 and span=3T ');

subplot(2,3,5);
tfplotFreq(pulse4, Fs, '\phi','\beta=0.3 and span=6T ');

subplot(2,3,3);
tfplotFreq(pulse5, Fs, '\phi','\beta=0.9 and span=3T ');

subplot(2,3,6);
tfplotFreq(pulse6, Fs, '\phi','\beta=0.9 and span=6T ');

