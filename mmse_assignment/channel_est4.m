function lambda = channel_est4(Rf, training_symbols)
%CHANNEL_EST4 Estimate the channel coefficients in the frequency domain
% There is no channel information available. The channel coefficients
% are computed as the ratio between the first received OFDM symbol
% and the preamble
% LAMBDA = CHANNEL_EST4(RF, TRAINING_SYMBOLS)
%
% RF: matrix containing the received signal, returned by
% OFDM_RX_FRAME
% TRAINING_SYMBOLS: the training sequence


S_inv=diag(1./training_symbols);
Y_1=Rf(:,1);

lambda=S_inv*Y_1;
end