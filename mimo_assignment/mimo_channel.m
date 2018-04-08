function [y, H] = mimo_channel(x, SNR, rxAntennas)
%MIMO_CHANNEL Simulates a MIMO single-path channel
%   [Y, H] = MIMO_CHANNEL(X, SNR, RXANTENNAS) returns the received symbols
%   and the channel matrix.
%     X: is the column vector of TX symbols. Its number of rows determines 
%     the number of TX antennas.
%     SNR: is the signal to noise ratio (in dB).
%     RXANTENNAS: is the number of RX antennas (default = 2).
%   
%     Y: contains the received symbols. It has RXANTENNAS rows.
%     H: the channel matrix.
% 
%     If X is a matrix, the same channel matrix is applied to each column
%     of X.  So, Y will be a matrix with RXANTENANS rows and the same 
%     number of columns as X. This is useful for simulating a channel 
%     that remains constant over more than one symbols period.
%
%     The channel matrix is generated randomly each time the function is 
%     called.  It consists of i.i.d. circularly-symmetric zero-mean
%     unit-variacne complex Gaussian entries.

if nargin < 3
    rxAntennas = 2;
end

if ~isscalar(rxAntennas) || floor(rxAntennas) ~= rxAntennas || ...
        rxAntennas <= 0
    error('mimoChannel:invalidInput', ...
        'RXANTENNAS must be a positive interger');
end

if ~isscalar(SNR)
    error('mimoChannel:invalidInput', 'SNR must be a scalar');
end

txAntennas = size(x, 1);

% Channel Matrix
H = randn(rxAntennas, txAntennas) / sqrt(2) + ...
    1j * randn(rxAntennas, txAntennas) / sqrt(2);

% Add the noise
Es = mean(abs(x(:)).^2); % should be 1 if the constellation has been normalized
y = awgn(H * x, SNR, 10*log10(Es));