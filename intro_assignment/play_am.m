function play_am()
clear all;
close all;
am_signal=importdata('am_signal.mat');
fc=20000;
fs=100000;
m_d=my_amdemod(transpose(am_signal),fc,fs);
m_d=downsample(m_d,10);
sound(m_d,fs/10);
end
