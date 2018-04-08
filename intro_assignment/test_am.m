function test_am()
clear all;
close all;
fi=10;
fc=300;
fs=4000;
A=1;
K=1;

%message signal
figure;
t=linspace(0,1,fs);
m=0.5*cos(2*pi*fi*t);
tfplot(m,fs,'m','Message signal');

%modulated signal
figure;
s=my_ammod(m,K,A,fc,fs);
tfplot(s,fs,'s','Modulated signal');

%recovered signal
figure;
m_d=my_amdemod(s,fc,fs);
tfplot(m_d,fs,'m_d','Demodulated signal');

%sound(m,fs);
%sound(m_d,fs);
end

