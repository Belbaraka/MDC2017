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

L=length(rx_symbols);

num_ofdm_symbols=floor(L/(num_carriers+prefix_length));
rx_symbols=rx_symbols(1:num_ofdm_symbols*(num_carriers+prefix_length));

rx_symbols=reshape(rx_symbols,[num_carriers+prefix_length,num_ofdm_symbols]);
rx_symbols=rx_symbols(prefix_length+1:end,:);

rx_symbols=fft(rx_symbols,num_carriers);
N_unusedf=num_carriers-sum(psd_mask);
Rf=rx_symbols(N_unusedf/2+1:end-N_unusedf/2,:);

end



