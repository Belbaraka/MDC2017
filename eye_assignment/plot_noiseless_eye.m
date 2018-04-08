function plot_noiseless_eye(pulse, Fs, USF, N_symb)
%PLOT_NOISELESS_EYE plots the eye diagram for a given pulse shape and BPSK
%signalling, assuming a noiseless and transparent channel.
% PLOT_NOISELESS_EYE(PULSE, FS, USF) plots the eye diagram for a system
% communicating data symbols via the pulse whose discrete-time samples
% (sampled at a rate of FS samples per second) are given in PULSE and
% its shifts. The data is assume to be communicated at a rate of
% FS/USF symbols per second, the channel is assumed to be ideal and
% noiseless, and the plot is generated using 500 data symbols.
%
% PLOT_NOISELESS_EYE(PULSE, FS, USF, N_SYMB) plots the eye diagram
% using N_SYMB data symbols (instead of the default value of 500).
if(exist('N_symb','var')==0)
    N_symb=500;
end
bpsk_map=my_pskMap(2);%we have 1bit/symbol
data=randi([0,1],1,N_symb);% no need to convert to decimal values since 0 and 1 are the same in binary
y=my_encoder(data,bpsk_map);
y=my_symbols2samples(y,pulse,USF);
[X, Y]=my_sufficientStatistics(y,pulse,USF);
T=USF/Fs;  %symbol duration;
my_eyediagram(Y,Fs,T);











end