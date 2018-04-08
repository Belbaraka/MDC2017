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


H=fft(h,num_carriers);
stem(abs(H));
for i=1:num_carriers
    if(psd_mask(i)==0)
        H(i)=0;
    end
end
H(H==0)=[];
lambda=H;
end
 

