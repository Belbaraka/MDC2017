close all;

%% Parameters

N=10000; %Number of bits
Fs=50; %sampling frequency
input_bi=randi([0,1],1,N); % rand vector input

M=4; %number of symbols
mapping=my_qamMap(M); % M-QAM modulation scheme 
%mapping=my_pskMap(M); %M-PSK modulation scheme

%SNR_db=10;
SNR_db=15; % symbol energy to noise variance
%SNR_db=20;

%% Tx encoding

bitspersymb=log2(M); %number of bits used per symbol
A=reshape(input_bi,[N/bitspersymb,bitspersymb]); % we should always have that N=k*bitspersymp
input_de=bi2de(A,'left-msb');

tx_symbols=my_encoder(input_de,mapping); %encode the symbols

Es=mean(abs(tx_symbols).^2);%energy of transmitted symbols

figure();
plot(tx_symbols, '*');
grid on; 
xlabel('Re'); 
ylabel('Im');
title('Tx constellation');



%% Pulse shaping
USF=50;  
%beta=0.9;
beta=0.22;
span=16;
T=1;
h=rcosdesign(beta,span,USF,'sqrt'); %root raised cosine filter 
h=h/norm(h);
tfplot(h,USF,'h','RRC with beta=0.22');

tx_signal=my_symbols2samples(tx_symbols,h,USF); %waveform former

%% Sampling offset

d=0;% no offset
%d=1;
%d=4;
%d=8;
tx_signal=padarray(tx_signal,d,'pre'); % add d zeros at the beginning of the signal
tx_signal=tx_signal(1:end-d); 

%% Awgn + Sufficent Statistics
rx_noisy=awgn(tx_signal,SNR_db,10*log10(Es));%add awgn to tx_signal


 
%% Eye Diagram
figure;
my_eyediagram(output_mf,Fs,T);

figure();
plot(rx_symb, '*');
grid on;
xlabel('Re');
ylabel('Im');
title('Rx constellation at the output of the matched filter');

%% Rx decoding
z=my_decoder(rx_symb,mapping);
input_bi_received=reshape(de2bi(z,'left-msb'),[1 N]);


%% Error calculations

diff=abs(input_bi-input_bi_received);
error1=sum(diff)/N; % BER
error2=nnz(input_de-z)/numel(z); %SER

[BER,SER] = berawgn(SNR_db,'qam',M,'nondiff');

disp('theoretical BER error');
disp(BER);
disp('BER error');
disp(error1);
disp('theoretical SER error');
disp(SER);
disp('SER error');
disp(error2);



