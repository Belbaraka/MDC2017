function Rf = ofdm_rx_frame(rx_symbols, num_carriers, psd_mask, prefix_length)
%OFDM_RX_FRAME Receiver for ODFM signals (without channel equalization) 
%   RF = OFDM_RX_FRAME(RX_SYMBOLS, NUM_CARRIERS, PSD_MASK, PREFIX_LENGTH)
%
%       RX_SYMBOLS: vector with the input symbols in the time domain
%       NUM_CARRIERS: number of carriers per OFDM block (FFT/IFFT size) 
%       PSD_MASK: The PSD Mask used by the receiver.
%         A {0,1}-valued vector of length NUM_CARRIERS used to
%         to turn off individual carriers if necessary (e.g., so as to 
%         avoid interference with other systems)
%       PREFIX_LENGTH: length of cyclic prefix (in number of symbols) 
%   
%   RF: Matrix containing the received OFDM frame. The received symbols
%   are arranged columnwise in a num_carriers x num_ofdm_blocks matrix. 
%   After removing the cyclic prefix we go back to frequency domain and 
%   also remove the zero carriers.


if ~isscalar(num_carriers) || num_carriers < 0  || mod(num_carriers,1) ~= 0
    error('ofdm_rx_frame:dimensionMismatch', ...
        'NUM_CARRIERS must be a positive scalar integer');
end

if ~isscalar(prefix_length) || prefix_length < 0  || mod(prefix_length,1) ~= 0
    error('ofdm_rx_frame:dimensionMismatch', ...
        'PREFIX_LENGTH must be a positive scalar integer');
end


if ~ isvector(psd_mask)|| numel(psd_mask) ~= num_carriers
    error('ofdm_rx_frame:dimensionMismatch',...
        'PSD_MASK must be a vector of length %d', ...
        num_carriers);
end

if any(psd_mask ~= 0 & psd_mask ~= 1)
    error('ofdm_rx_frame:invalidMask',...
        'PSD_MASK must be {0,1}-valued');
end

psd_mask = logical(psd_mask);


rx_symbols = rx_symbols(:);

% compute number of complete OFDM symbols received
num_ofdm_symbols = floor((length(rx_symbols))/(num_carriers+prefix_length));
rx_symbols=rx_symbols(1:num_ofdm_symbols*(num_carriers+prefix_length));

% "remove" cylic prefix:
rx_withCP = reshape(rx_symbols((1 : num_ofdm_symbols * (num_carriers + prefix_length))), prefix_length+num_carriers, num_ofdm_symbols); 
rx_noCP = rx_withCP(prefix_length+(1:num_carriers), :); % remove rows corresponding to cyclic prefix

% go to the frequency domain
Rf = fft(rx_noCP, num_carriers);


% remove the zero carriers
Rf = Rf(psd_mask, :);


