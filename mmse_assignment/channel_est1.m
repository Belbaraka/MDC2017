function lambda = channel_est1(num_carriers, psd_mask, h)
%CHANNEL_EST1 Computes the channel coefficients in the frequency domain
%from channel impulse response
%   LAMBDA = CHANNEL_EST1(NUM_CARRIERS, PSD_MASK, H)
%
%       NUM_CARRIERS: number of carriers per OFDM block (FFT/IFFT size)
%       PSD_MASK: The PSD Mask used by the receiver.
%         A {0,1}-valued vector of length NUM_CARRIERS used to
%         to turn off individual carriers if necessary (e.g., so as to 
%         avoid interference with other systems)
%       H: Channel impulse response.
%
%   LAMBDA: Column vector containing channel coefficients in the frequency
%   domain. The number of elements of LAMBDA equals the number of ones in
%   PSD_MASK. (We do not care about channel gains on the carriers that 
%   are turned off.)



if ~isscalar(num_carriers) || num_carriers < 0  || mod(num_carriers,1) ~= 0
    error('channel_est1:dimensionMismatch', ...
        'NUM_CARRIERS must be a positive scalar integer');
end

if ~isvector(psd_mask)|| numel(psd_mask) ~= num_carriers
    error('channel_est1:dimensionMismatch',...
        'PSD_MASK must be a vector of length %d', ...
        num_carriers);
end

if any(psd_mask ~= 0 & psd_mask ~= 1)
    error('channel_est1:invalidMask',...
        'PSD_MASK must be {0,1}-valued');
end
psd_mask = logical(psd_mask);

lambda = fft(h, num_carriers); % DFT of the first column of H
lambda = lambda(psd_mask); % We need only the non-zero subcarriers
 

