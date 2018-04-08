function lambda = channel_est3(Rf, num_carriers, psd_mask, ...
training_symbols, sigma2)
%CHANNEL_EST3 Estimate the channel coefficients in the frequency domain
% There is no channel information available. Ky is estimated from the
% received data
% LAMBDA = CHANNEL_EST3(RF, NUM_CARRIERS, PSD_MASK, ...
% PREAMBLE_SYMBOLS, SIGMA2)
%
% RF: matrix containing the received signal, returned by
% OFDM_RX_FRAME
% NUM_CARRIERS: number of carriers per OFDM block (FFT/IFFT size)
% PSD_MASK: The PSD Mask used by the receiver.
% A {0,1}-valued vector of numel NUM_CARRIERS used to
% to turn off individual carriers if necessary (e.g., so as to
% avoid interference with other systems)
% TRAINING_SYMBOLS: the training sequence
% SIGMA2: noise variance
% LAMBDA: Column vector containing channel coefficients in the frequency
% domain. The number of elements is LAMBDA equals the number of ones
% in PSD_MASK. (It is impossible to estimate the channel response on
% the carriers that were turned off by the transmitter.)

  
useful_carriers=sum(psd_mask);



%remove training symbol column
Y_1=Rf(:,1);
Rf=Rf(:,2:end);
K_Y=cov(transpose(Rf));

S=diag(training_symbols); 
K_Z=diag(repmat(sigma2,1,useful_carriers));

lambda=S\((K_Y-K_Z)*(K_Y\Y_1));


end