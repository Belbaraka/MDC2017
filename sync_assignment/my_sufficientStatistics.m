function [x,y] = my_sufficientStatistics(r, h, USF)
%MY_SUFFICIENTSTATISTICS Processes the output of the channel to generate
% sufficient statistics about the transmitted symbols.
%
%   X = MY_SUFICIENTSTATISTICS(R, H, USF) produces sufficient statistics
%   about the transmitted symbols, given the signal received in vector
%   R, the impulse response H of the basic pulse (transmitting filter),
%   and the integer USF (upsampling factor), which is the number of 
%   samples per symbol.
%
%   [X,Y] = MY_SUFICIENTSTATISTICS(R, H, USF) produces, in addition to
%   sufficient statistics for decision (as described above), the output 
%   of the matched filter Y (before down-sampling).


% For the implementation we use the matched filter, followed by downsampling
% by a factor USF

% here we assume h is a row vector

h_matched = conj(fliplr(h));
% in our case h_matched = h, since h is real and symmetric

% the matched filter output before downsampling is
y = conv(r, h_matched);


% Picking the desired matched filter outputs:
% Comment: the matched filter output (before downsampling) is the correlation
% between the received signal and h. The first useful sample is the 
% length(h) th correlation result. At the end there are length(h)-1 unused
% correlation results. 

y = y(length(h):end-length(h)+1);
   
x = y(1:USF:end);



