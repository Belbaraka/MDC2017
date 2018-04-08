% MIMO_PERFORMANCE simulates the performance of MIMO communciation system
% at different SNRs

clear all;
close all;

%% Parameter Selection
antennas  = 2; 
modtype   = 'qam';  % 'qam', 'psk'
M         = 4;      % constellation size: 4, 16, 64

Es_sigma2 =  1:20; % list of SNRs for simulations

trials_per_snr      = 1e3; % number of times a new channel is generated per SNR
symbols_per_trial   = 1e4; % number of symbols over which the channel is constant

test_zf   = true;  % test the ZF equalizer? (set to true after implementing the equalizer)
test_lmmse = true; % test the LMMSE equalizer? (set to true after implementing the equalizer)


%% Main Simulation Loop

if ~test_zf && ~test_lmmse
    fprintf('Nothing to simulate\n');
    return;
end

if test_zf
    ser_zf = zeros(size(Es_sigma2));
    mse_zf = zeros(size(Es_sigma2));
end

if test_lmmse
    ser_lmmse = zeros(size(Es_sigma2));
    mse_lmmse = zeros(size(Es_sigma2));
end

rng('shuffle');

% 1.3.2 - Get the mapping
switch(lower(modtype))
        case 'qam'
                mapping = my_qamMap(M);
        case 'psk'
                mapping = my_pskMap(M);
        otherwise
                error('Unsupported modulation type');
end


% Normalize constellation to unit average energy
mapping = mapping./sqrt(mean(abs(mapping).^2));


for k = 1:numel(Es_sigma2)
    SNR = Es_sigma2(k);
    fprintf('SNR = %g, ',SNR);
    for iter = 1:trials_per_snr
        tx_digits  = randi(M, 1, symbols_per_trial) - 1;
        tx_symbols = my_encoder(tx_digits, mapping);
        
        tx_symbols = reshape(tx_symbols, antennas, []);
        
        [rx_symbols, H] = mimo_channel(tx_symbols, SNR, antennas);

        
        if test_zf % Zero-forcing
            suff_stat = zeroForcing_equalizer(rx_symbols,H);
            
            mse_zf(k) = mse_zf(k) + noise_norm(tx_symbols, suff_stat);
            
            % Reshape the sufficient statistics to a row vector
            suff_stat = reshape(suff_stat, 1, []);
            rx_digits = my_decoder(suff_stat , mapping);
            
            ser_zf(k) = ser_zf(k) + sum(rx_digits ~= tx_digits);
        end
        
        if test_lmmse % LMMSE
            suff_stat = lmmse_equalizer(rx_symbols, H, 10^(-0.1*SNR));
            
            mse_lmmse(k) = mse_lmmse(k) + noise_norm(tx_symbols, suff_stat);
            
            % Reshape the sufficient statistics to a row vector
            suff_stat = reshape(suff_stat, 1, []);
            rx_digits = my_decoder(suff_stat , mapping);
            
            ser_lmmse(k) = ser_lmmse(k) + sum(rx_digits ~= tx_digits);
        end
    

    end
    
    if test_zf
        mse_zf(k) = mse_zf(k) / (trials_per_snr*symbols_per_trial);
        ser_zf(k) = ser_zf(k) / (trials_per_snr*symbols_per_trial);
        
        fprintf('SER (ZF)   = %g, MSE (ZF)   = %g\t', ...
            ser_zf(k), mse_zf(k));
    end
    
    if test_lmmse
        mse_lmmse(k) = mse_lmmse(k) / (trials_per_snr*symbols_per_trial);
        ser_lmmse(k) = ser_lmmse(k) / (trials_per_snr*symbols_per_trial);


        fprintf('SER (LMMSE) = %g, MSE (LMMSE) = %g', ...
            ser_lmmse(k), mse_lmmse(k));
    end
    fprintf('\n');
end




%% Plot the results
figure;
subplot(1,2,1);
if test_zf
    semilogy(Es_sigma2, ser_zf);
    hold on;
end
if test_lmmse
    semilogy(Es_sigma2, ser_lmmse);
end

if test_zf && test_lmmse
    legend('Zero Forcing', 'MMSE');
elseif test_zf
    legend('Zero Forcing');
else
    legend('MMSE');
end
grid on;
xlabel('Channel SNR [dB]');
ylabel('Symbol Error Rate');

subplot(1,2,2);
if test_zf
    plot(Es_sigma2, -10*log10(mse_zf));
    hold on;
end
if test_lmmse
    plot(Es_sigma2, -10*log10(mse_lmmse));
end
if test_zf && test_lmmse
    legend('Zero Forcing', 'MMSE');
elseif test_zf
    legend('Zero Forcing');
else
    legend('MMSE');
end
grid on;
xlabel('Channel SNR [dB]');
ylabel('Decoding SNR [dB]');

%%
function z = noise_norm(txSymbols, sufficientStatistics)
effectiveNoise = sufficientStatistics- txSymbols;
effectiveNoise = effectiveNoise(:);
z = effectiveNoise' * effectiveNoise;
end
