% TEST_OFDM Script to test the OFDM transmitter / channel / receiver


clear all; close all; 
%clc

% System parameters
num_carriers = 256;    % total number of carriers
num_zeros = 5;         % number of unsused carriers (at each end of the frequency spectrum)
prefix_length = 25;    % length of the cyclic prefix
num_ofdm_symbols = 10000; % number of OFDM symbols per frame (1 will be used to transmit the preamble and the rest for data)
M_preamble = 4;        % we use 4-QAM for the preamble
M_data = 4;           % we use 4-QAM for the data

SNR = 30; % in dB

% Derived parameters
num_useful_carriers = num_carriers - 2 * num_zeros;

constel_preamble = my_qamMap(M_preamble);
% constel_preamble = constel_preamble /  var(constel_preamble,1);  '1' parameter to use the biased estimator

constel_data = my_qamMap(M_data);
% constel_data = constel_data /  var(constel_data,1);  '1' parameter to use the biased estimator

% Transmitter
% Generate preamble and data
preamble = randi([0, M_preamble-1], [num_useful_carriers, 1]);
preamble_symbols = my_encoder(preamble, constel_preamble);
%preamble_symbols=ones(size(preamble_symbols));

data = randi([0, M_data-1], [num_useful_carriers * (num_ofdm_symbols-1), 1]);
data_symbols = my_encoder(data, constel_data);

E_s = var(constel_data,1);  % average energy of data symbols; '1' parameter to use the biased estimator

% Generate OFDM signal to be transmitted
psd_mask = [zeros(1,num_zeros), ones(1,num_useful_carriers),  ...
    zeros(1,num_zeros)];
% (a simple mask that zeros out carriers at the end and the beginning of
% spectrum)
tx_signal = ofdm_tx_frame(num_carriers, ...
    psd_mask, ...
    prefix_length, preamble_symbols, data_symbols);
E_tx = var(tx_signal); % power of transmitted signal

% Channel

% CP should be >= L-1, where L is the channel length; 
% (L-1) is the length of the channel history 
channel_length = prefix_length+1; 

% random impulse response for test purposes
%h = 1/sqrt(2) * (randn(1,channel_length) + 1i*randn(1,channel_length)); 
%h = randn(1,channel_length);


%  multipath channel described in class
amplitudes = randn(1,4); %Gaussian distribution, N(0,1) 
Ka         = eye(4);
delays     = [0 0.5 1.2 1.4];
h          = create_multipath_channel_filter(amplitudes, delays);

% simple channel 
% which just adds WGN (non frequency selective channel, i.e, no ISI).
% to use it, uncomment the following line
% h = [1 zeros(1,channel_length-1)]; 

% normalize impulse response
h = h/norm(h)

if (length(h) > prefix_length+1)
     warning('test_ofdm:impulseResponseTooLong', 'The channel impulse response is larger than the cyclic prefix length => it will create ISI');
end

% convolve tx_signal with channel impulse response
rx_signal = conv(tx_signal, h);

% add AWGN
sigma = 10^(-SNR/20) * sqrt(E_tx);
noise = sigma/sqrt(2)* (randn(size(rx_signal)) + 1i*randn(size(rx_signal)));

rx_signal_noisy = rx_signal + noise;

% Receiver
Rf = ofdm_rx_frame(rx_signal_noisy, num_carriers, psd_mask, prefix_length);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%Channel coefficient estimation

% h known
lambda1 = channel_est1(num_carriers, psd_mask, h);

% delays and variances known
% sigma2=num_carriers*sigma^2; %the fft transform increases the noise variance!
% lambda2 = sol_channel_est2(Rf, num_carriers, psd_mask, preamble_symbols, Ka,...
%     delays, sigma2); 
% 
%no channel information known, we estimate Ky from the data
% lambda3 = sol_channel_est3(Rf, num_carriers, psd_mask, preamble_symbols, sigma2); 
% 
%no channel information known, we use the pedestrian approach of dividing
%the channel output by the preamble
% lambda4 = sol_channel_est4(Rf, preamble_symbols);


%We determine the variance of each estimate (or the error)
%Note: The differences between channel_est3 and channel_est4 are
%visible at low values of SNR. 
% var2 = var(lambda1-lambda2.')
% var3 = var(lambda1-lambda3.')
% var4 = var(lambda1-lambda4.')
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Channel equalization, demodulation and determining SER


%- The channel response is assumed to remain constant during the whole frame

eq_signal1 = Rf .* repmat(1./lambda1(:), 1, num_ofdm_symbols); 
suf_statistics1 = eq_signal1(:); 
estim_data1 = my_decoder(suf_statistics1(length(preamble_symbols)+1:end), constel_data);
SER1 = sum(estim_data1 ~= data) / numel(data) %#ok<NOPTS>

    % debugging information
    suf_data1 = suf_statistics1(length(preamble_symbols)+1:end);
    figure(); plot(suf_data1, '*b'); xlabel('Re'); ylabel('Im'); title('Received constellation after OFDM demodulation and equalization');
    hold on; plot(constel_data, '+r'); grid on; legend('Received constellation', 'Transmitted constellation');

% eq_signal2 = Rf .* repmat(1./lambda2, 1, num_ofdm_symbols); 
% suf_statistics2 = eq_signal2(:); 
% estim_data2 = my_decoder(suf_statistics2(length(preamble_symbols)+1:end), constel_data);
% SER2 = sum(estim_data2 ~= data) / numel(data) %#ok<NOPTS>

% eq_signal3 = Rf .* repmat(1./lambda3, 1, num_ofdm_symbols); 
% suf_statistics3 = eq_signal3(:);  
% estim_data3 = my_decoder(suf_statistics3(length(preamble_symbols)+1:end), constel_data); % returns decimal numbers in 0 .. length(constel_data) - 1
% SER3 = sum(estim_data3 ~= data) / numel(data) %#ok<NOPTS>


% eq_signal4 = Rf .* repmat(1./lambda4, 1, num_ofdm_symbols); 
% suf_statistics4 = eq_signal4(:);  
% estim_data4 = my_decoder(suf_statistics4(length(preamble_symbols)+1:end), constel_data); % returns decimal numbers in 0 .. length(constel_data) - 1
% SER4 = sum(estim_data4 ~= data) / numel(data) %#ok<NOPTS>

