function [x,y] = my_sufficientStatistics(r, h, USF)
%MY_SUFFICIENTSTATISTICS Processes the output of the channel to generate
% sufficient statistics about the transmitted symbols.
%
% X = MY_SUFICIENTSTATISTICS(R, H, USF) produces sufficient statistics
% about the transmitted symbols, given the signal received in vector
% R, the impulse response H of the basic pulse (transmitting filter),
% and the integer USF (upsampling factor), which is the number of
% samples per symbol.
%
% [X,Y] = MY_SUFICIENTSTATISTICS(R, H, USF) produces, in addition to
% sufficient statistics for decision (as described above), the output
% of the matched filter Y (before down-sampling).


%matched filter
h=h/norm(h);
h=conj(fliplr(h));


y=conv(r,h);
y = y(length(h):end-length(h)+1);
x=downsample(y,USF);




end