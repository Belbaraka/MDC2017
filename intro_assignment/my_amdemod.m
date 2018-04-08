function demod = my_amdemod(s, fc, fs)

%tfplot(s,fs,'s','received');

%samples=length(s);
%duration=(samples-1)/fs;
%t=linspace(0,duration,samples);

m=abs(s);

%fc=1.99905*1E4;
%m=s.*cos(2*pi*fc*t);

%delta=zeros(100);
%delta(1)=1;

[num,den]=butter(4,fc*2/fs);

%impulse_r=filter(num,den,delta);
%tfplot(impulse_r,fs,'h','impulse resp)');

m=filter(num,den,m);
%tfplot(m,fs,'m','message');
m=m-mean(m);
max_m=max(abs(m));
demod=m/max_m;
%demod=filtfilt(num,den,m);
end
