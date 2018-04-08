function tfplot(s, fs, name, plottitle)
% TFPLOT Time and frequency plot
%    TFPLOT(S, FS, NAME, TITLE) displays a figure window with two
%    subplots.  Above, the signal S is plotted in time domain; below,
%    the signal is plotted in frequency domain. NAME is the "name" of the
%    signal, e.g., if NAME is 's', then the labels on the y-axes will be
%    's(t)' and '|s_F(f)|', respectively.  TITLE is the title that will
%    appear above the two plots.

%plot the time signal s
subplot(2,1,1);

%get the number of samples and duration of time signal
samples=length(s);
duration=samples/fs;
t=linspace(0,duration,samples);

plot(t,s);
title(plottitle);
xlabel('t[s]');
ylabel(strcat(name,'_F (t)'));

%compute the DFT of signal S
s_f=fft(s);
N=length(s_f);

%plot the frequency signal 
subplot(2,1,2);

f=linspace(-fs/2,fs/2,N);
plot(f,fftshift(abs(s_f)));
xlabel('f[Hz]');
ylabel(strcat('|',name,'(f)|'));
end





