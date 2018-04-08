function lambda = channel_est2(Rf, num_carriers, psd_mask, ...
training_symbols, Ka, delays, sigma2)
%CHANNEL_EST2 Estimate the channel coefficients in the frequency domain
% The channel delays are known. The covariance matrix of channel
% amplitudes is also assumed to be known.
% LAMBDA = CHANNEL_EST2(RF, NUM_CARRIERS, PSD_MASK, ...
% TRAINING_SYMBOLS, KA, DELAYS, SIGMA2)
%
% RF: matrix containing the received signal, returned by
% OFDM_RX_FRAME
% NUM_CARRIERS: number of carriers per OFDM block (FFT/IFFT size)
% PSD_MASK: The PSD Mask used by the receiver.
% A {0,1}-valued vector of numel NUM_CARRIERS used to
% to turn off individual carriers if necessary (e.g., so as to
% avoid interference with other systems)
% TRAINING_SYMBOLS: the training sequence
% KA: the covariance matrix of channel amplitudes
% DELAY: vector containing the delay for each path in the
% multipath channel (normalized to symbol period).
% SIGMA2: noise variance
% LAMBDA: Column vector containing channel coefficients in the frequency
% domain. The number of elements is LAMBDA equals the number of ones
% in PSD_MASK. (It is impossible to estimate the channel response on
% the carriers that were turned off by the transmitter.)

alphas=transpose(diag(Ka));

N=num_carriers;
K_D=zeros(N);

for line_i=1:N
    i=line_i;
    if(i>=N/2)
        i=i-N;
    end
    for column_k=1:N
        k=column_k;
        if(k>=N/2)
            k=k-N;
        end
        K_D(line_i,column_k)=sum(alphas.*exp(-1j*2*pi*delays*(i-k)/N));
    end
end

useful_freq=sum(psd_mask);
unused_freq=num_carriers-useful_freq;

%remove the unwanted rows/colums
%K_D=K_D(unused_freq/2:end-unused_freq/2-1,unused_freq/2:end-unused_freq/2-1);

psd_mask = logical(psd_mask);
K_D=K_D(psd_mask,psd_mask);

S=diag(training_symbols);
S_dag=conj(transpose(S));

K_DY=K_D*S_dag;

K_Z=diag(repmat(sigma2,1,useful_freq));
K_Y=S*K_D*S_dag+K_Z;



% mean_columns=repmat(mean(Rf),sum(psd_mask),1);
% Rf=Rf-mean_columns;

lambda=K_DY*(K_Y\Rf(:,1));
%lambda=mean(D,2);
%lambda=lambda-repmat(mean(lambda),length(lambda),1);

end