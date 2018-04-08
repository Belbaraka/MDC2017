% succesive decoding and phase drift correction for OFDM blocks

close all;
clear all;

load rx_signal.mat

% See what we have there
figure;
plot(rx_signal,'*'); grid on;
title('The received OFDM blocks after equalization');

% Vector for storing the phase rotations
phaseEstimate = zeros(1, size(rx_signal,2));

for i = 1:size(rx_signal,2)
    
   % Decode the current block
   currentBlock = rx_signal(:,i);
   Ydec = 2*(real(currentBlock)>0)-1 +1j*(2*(imag(currentBlock)>0)-1);
   
   % LS estimate of the phase
   phaseEstimate(i) = angle(Ydec(:)'*currentBlock(:));
    
   % Correct the remaining blocks
   phase_corr = repmat(phaseEstimate(i), size(rx_signal,1),1);
   rx_signal(:,i:end) = rx_signal(:,i:end) .* exp(-1j*phase_corr);
  
end

% Plot the corrected signal
figure;
plot(real(rx_signal), imag(rx_signal),'*');
grid on; title('Phase-corrected OFDM blocks');

% Plot the phase evolution over blocks
figure;
plot(cumsum(phaseEstimate),'-*'); grid on;
title('The running phase');
