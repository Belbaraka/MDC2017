% RECEIVER_SYNC_SCRIPT 
% Simualates data transmission using 4-QAM modulation 
% via root-raised-cosine pulses and plots the eye diagram at the output of
% the receiver's matched filter.  The script plots the eye diagram and the
% RX constellation to illustrate the effect of synchronization algorithms

clear all;
close all;

rng('shuffle');

%% PN Sequence
pn_seq = [-1;1;1;1;1;1;1;-1;-1;-1;-1;-1;-1;-1;1;-1;1;-1;1;-1;1;1;-1;-1;...
    1;1;-1;-1;-1;1;-1;-1;-1;1;-1;1;1;-1;1;-1;-1;1;1;1;-1;-1;1;-1;-1;-1;...
    -1;1;-1;-1;1;-1;1;-1;-1;1;-1;-1;1;1;-1;1;1;-1;1;1;1;-1;-1;-1;1;1;1;1;...
    -1;1;-1;-1;-1;-1;-1;1;1;-1;1;-1;1;-1;-1;-1;1;1;-1;-1;1;-1;1;1;1;-1;...
    1;1;-1;-1;-1;-1;1;1;1;-1;1;-1;1;1;1;1;-1;-1;1;1;1;1;1];
%% Parameter selection

N         = 1E4;   % number of bits to transmit (influence on the accuracy
                   % of the BER/SER estimations)
modtype   = 'qam'; % 'qam', 'psk'
M         = 4;     % constellon size: 4, 16, 64
Es_sigma2 = 35;    % in dB, ratio of the symbol energy to noise variance at
                   % the matched filter output

%% 1. Transmitter

%% 1.1 Design pulse shaping filter (root-raised-cosine)
USF   = 50;        % upsampling factor - should be at least 2 to work
                  % (check the bandwidth of the RRC)
beta  = 0.22;     % roll-off factor
span  = 8;       % length of the truncated pulse is specified in terms of
                  % the number of symbols 

h = rcosdesign(beta, span, USF, 'sqrt'); % here the filter is already
L=length(h);
t=linspace(-L,L,2*L-1);

figure;
plot(t,xcorr(h));
title('Self similarity function of rrc pulse')


% normalized to norm 1

% Make sure that the filter has norm 1. This way we ensure that the SNR at the channel output and at the output of the matched filter are equal
h = h/norm(h);

Fd = 1; % symbol rate
Fs = USF * Fd; % sampling frequency
% Plot the impulse response and frequency response of the filter
%tfplot(h,Fs,'h',['RRC impulse response, \beta = ', num2str(beta)]);


%% 1.2 - Generate random bits
tx_bits = randi(2, ceil(N/log2(M)), log2(M)) - 1; % each row contains M values, equivalent to log2(M) bits
% the -1 at the end is because randi(2,m,n) returns an m by n matrix with
% random entries in {1,2}.

%% 1.3 - Map the source bits into constellation symbols

% 1.3.1 - Convert bits to M-ary symbols
dec_symbols = my_bi2de(tx_bits);

% 1.3.2 - Get the mapping
switch(lower(modtype))
        case 'qam'
                mapping = my_qamMap(M);
        case 'psk'
                mapping = my_pskMap(M);
        otherwise
                error('Unsupported modulation type');
end

% Normalize constellation to unit average energy - not really necessary
mapping = mapping/sqrt(mean(abs(mapping).^2));

% 1.3.3 - Encoder
tx_symbols = my_encoder(dec_symbols, mapping);
Es         = mean(abs(tx_symbols).^2); % should be 1 if the constellation
                                       % has been normalized
% 1.3.4 - Preamble for synchronization
%preamble_symbols = [];      % Use this for no synchronization
 preamble_symbols = [1];
%preamble_symbols = pn_seq;

figure();
subplot(2,2,1);
plot(tx_symbols, '*');
grid on; 
xlabel('Re'); 
ylabel('Im');
title('Tx constellation (unit energy)');


%% 1.4 - From symbols to signals - Shaping filter
tx_signal = my_symbols2samples([preamble_symbols; tx_symbols], h, USF);


%% 2. Channel:

rx_signal = channel(tx_signal,Es_sigma2,8*USF);

% For debugging you can use the second output argument of channel()
% function to know exactly the channel delay:
[rx_signal, ch_delay] = channel(tx_signal,Es_sigma2,8*USF);

%% 3. Receiver

% 3. 0 - correct the sampling time offset (if we have a preamble)
if ~isempty(preamble_symbols)
    preamble_signal = my_symbols2samples(preamble_symbols, h, USF);
    tau_estim   = sol_estimateTau(rx_signal, preamble_signal);

    % For debugging only 
    fprintf('Channel delay = %d samples, Estimated delay = %d samples\n', ...
        ch_delay, tau_estim);

    rx_signal = rx_signal(tau_estim+1:end);
end

% 3. 1 - Get the sufficient statistics about the transmitted symbols
[rx_symbols, mf_output] = my_sufficientStatistics(rx_signal, h, USF);

% remove preamble symbols (if any)
rx_symbols = rx_symbols(numel(preamble_symbols)+1:end);

est_symbols = my_decoder(rx_symbols,mapping);

% plot the constellation at the output of the matched filter (after downsampling)
subplot(2,2,2);
plot(rx_symbols, '*');
grid on;
xlabel('Re');
ylabel('Im');
title('Rx constellation at the output of the matched filter');

subplot(2,2,3);
my_eyediagram(real(mf_output),Fs,1/Fd);
title('Eye Diagarm at the output of the matched filter (in-phase)');
subplot(2,2,4);
my_eyediagram(imag(mf_output),Fs,1/Fd);
title('Eye Diagarm at the output of the matched filter (quadrature)');


if (numel(dec_symbols) > numel(est_symbols))
    fprintf('Some sent symbols are lost.\n');
else
    fprintf('%d out of %d symbols are decoded incorrectly.\n', ...
        sum(est_symbols(1:numel(dec_symbols)) ~= dec_symbols), ...
        numel(dec_symbols));
    fprintf('We have a symbol-error rate of %g.\n', ...
        sum(est_symbols(1:numel(dec_symbols)) ~= dec_symbols) /...
        numel(dec_symbols));
end

%% Plot the TX and RX signals

t = (0:max(numel(tx_signal),numel(rx_signal))-1)*1/Fs;

t_min = 0;  % seconds
t_max = 30; % seconds


figure;
subplot(2,1,1);
plot(t(1:numel(tx_signal)),real(tx_signal),'b');
hold on;
plot(t(1:numel(rx_signal)),real(rx_signal),'r');
grid on;
xlim([t_min, t_max]);
xlabel('t [s]');
title('TX and RX Signals (in-phase)');
legend('TX','RX');
subplot(2,1,2);
plot(t(1:numel(tx_signal)),imag(tx_signal),'b');
hold on;
plot(t(1:numel(rx_signal)),imag(rx_signal),'r');
grid on;
xlim([t_min, t_max]);
xlabel('t [s]');
title('TX and RX Signals (quadrature)');
legend('TX','RX');
