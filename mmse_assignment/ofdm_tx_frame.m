function tx_symbols = ofdm_tx_frame(num_carriers, psd_mask, prefix_length, training_symbols, data_symbols)
%OFDM_TX_FRAME Generates an OFDM frame
%   TX_SYMBOLS = OFDM_TX_FRAME(NUM_CARRIERS, PSD_MASK, PREFIX_LENGTH, ...
%       TRAINING_SYMBOLS, DATA_SYMBOLS)
%
%       NUM_CARRIERS: number of carriers per OFDM block (power of 2) 
%       PSD_MASK: A {0,1}-valued vector of length NUM_CARRIERS used to
%         to turn off individual carriers if necessary (e.g., so as to 
%         avoid interference with other systems)
%       PREFIX_LENGTH: length of cyclic prefix (in number of samples) 
%       TRAINING_SYMBOLS: vector of symbols known to the receiver, used 
%         to aid channel estimation (length equal to 
%         NUM_CARRIERS-sum(PSD_MASK), i.e, the number of useful carriers)
%       DATA_SYMBOLS: vector of symbols to transmit (if the number of data
%         symbols is not a multiple of the number of useful carriers it 
%         will be padded with zeros)
%
%   TX_SYMBOLS: The generated OFDM symbols, corresponding to one OFDM 
%   frame with the training symbols transmitted during the first OFDM 
%   block and the data transmitted in the subsequent OFDM blocks.

if ~isscalar(num_carriers) || num_carriers < 0  || mod(num_carriers,1) ~= 0
    error('ofdm_tx_frame:dimensionMismatch', ...
        'NUM_CARRIERS must be a positive scalar integer');
end

if ~isscalar(prefix_length) || prefix_length < 0  || mod(prefix_length,1) ~= 0
    error('ofdm_tx_frame:dimensionMismatch', ...
        'PREFIX_LENGTH must be a positive scalar integer');
end

if ~ isvector(psd_mask)|| numel(psd_mask) ~= num_carriers
    error('ofdm_tx_frame:dimensionMismatch',...
        'PSD_MASK must be a vector of length %d', ...
        num_carriers);
end

if any(psd_mask ~= 0 & psd_mask ~= 1)
    error('ofdm_tx_frame:invalidMask',...
        'PSD_MASK must be {0,1}-valued');
end


psd_mask = logical(psd_mask);

%determine the number of useful carriers
num_useful_carriers = sum(psd_mask == 1);

if (numel(training_symbols) ~= num_useful_carriers)
    error('ofdm_tx_frame:dimensionsMismatch', ...
          'PREAMBLE must contain exactly %d symbols', ...
          num_useful_carriers);
end

num_data_symbols = numel(data_symbols);
num_ofdm_symbols = ceil(num_data_symbols/ num_useful_carriers);
num_symbols_padding =  num_ofdm_symbols * num_useful_carriers- num_data_symbols; % number of zero symbols to add to have an exact number of OFDM symbols
data_symbols = [data_symbols(:); zeros(num_symbols_padding, 1)];

num_ofdm_symbols = num_ofdm_symbols + 1; % we use one OFDM symbol for the preamble (to aid channel estimation)

% build matrix: the first column is for the preamble, and the following for the data
B = zeros(num_useful_carriers, num_ofdm_symbols);
B(:,1) = training_symbols(:);
B(:,2:end) = reshape(data_symbols(:), num_useful_carriers, []);

% map B to A which incldues zeros at the masked positions and elements of A
% at non-masked positions
A = zeros(num_carriers, num_ofdm_symbols);
A(psd_mask,:) = B;

% A = [zeros(num_zeros, num_ofdm_symbols); B; zeros(num_zeros, num_ofdm_symbols)]; % A is size num_carriers x num_ofdm_symbols

% Do the IFFT (MATLAB IFFT applied on a matrix returns a matrix with the IFFT of every column)
a0 = ifft(A, num_carriers);

% Before sending through the channel we have to add the cyclic prefix
a = [a0(num_carriers-prefix_length+1:num_carriers,:); a0];

% serialize, so that the output is a column vector
tx_symbols = a(:);

