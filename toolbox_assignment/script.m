close all;

N=1000000; %Number of bits
input_bi=randi([0,1],1,N); % rand vector input

M=4; %number of symbols
mapping=my_qamMap(M); % M-QAM modulation scheme 
%mapping=my_pskMap(M); %M-PSK modulation scheme

SNR=10; % symbol energy to noise variance

bitspersymb=log2(M); %number of bits used per symbol
A=reshape(input_bi,[N/bitspersymb,bitspersymb]); % we should always have that N=k*bitspersymp
input_de=bi2de(A,'left-msb');

y=my_encoder(input_de,mapping); %encode the symbols

USF=16;  %16 samples/symbol is a good enough value
beta=0.22;
span=10;
h=rcosdesign(beta,span,USF); %root raised cosine filter 
tfplot(h,USF,'h','RRC with beta=0.22');

s=my_symbols2samples(y,h,USF); %waveform former
%s=s/norm(s);

SNR_db=10*log10(SNR); % SNR in db

%Es=norm(mapping)^2/length(mapping);
%noise_variance=(Es/SNR)/2;
%X=randn(size(s))/sqrt(noise_variance);
%X=X/norm(X);
%Y=randn(size(s))/sqrt(noise_variance);
%Y=Y/norm(Y);

%s_noisy=s+X+1i*Y;


power_s=10*log10(rms(s)^2);
s_noisy=awgn(s,SNR_db,power_s);


[x,y]=my_sufficientStatistics(s_noisy,h,USF); %n-tuple former -- matched filter


%decode received signal
z=my_decoder(x,mapping);
input_bi_received=reshape(de2bi(z,'left-msb'),[1 N]);

%display consellation diagram
sPlotFig = scatterplot(x,1,0,'c.');
hold on;
scatterplot(mapping,1,0,'r*',sPlotFig);
legend('After Matched Filter','Constellation');
hold off;

%practice erros
diff=abs(input_bi-input_bi_received);
error1=sum(diff)/N; % BER
error2=nnz(input_de-z)/N; %SER


%theoretical errors
[BER,SER] = berawgn(SNR,'qam',M,'nondiff');



disp('theoretical BER error');
disp(BER);
disp('BER error');
disp(error1);
disp('theoretical SER error');
disp(SER);
disp('SER error');
disp(error2);



