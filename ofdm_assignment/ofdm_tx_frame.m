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

N=sum(psd_mask);% number of useful carrieres
unused_freq=num_carriers-sum(psd_mask);
L0=mod(length(data_symbols),N);

if L0~=0
    data_symbols=vertcat(data_symbols,zeros(L0,1));
end

Lsymb=length(data_symbols);
F=Lsymb/N; % frame length
data_symbols=reshape(data_symbols,[N,F]);

data_symbols=[zeros(unused_freq/2,F); data_symbols; zeros(unused_freq/2,F)];
training_symbols=[zeros(unused_freq/2,1); training_symbols; zeros(unused_freq/2,1)];

pre_tx=ifft([training_symbols data_symbols],num_carriers);
prefix=pre_tx(num_carriers-prefix_length+1:num_carriers,:);

tx_symbols=[prefix;pre_tx];
tx_symbols=tx_symbols(:);






end


