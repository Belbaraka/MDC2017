clear all;close all;

load p.mat
load r.mat

Ts=1e-5;
Lr=length(r);
Lp=length(p);

%N=nextpow2(2*1e5);

%compute rF
NFFTr=2^nextpow2(Lr);
r_F=(fft(r,NFFTr));
r_F=Ts*fftshift(r_F);

abs_r_F=abs(r_F);%take the absolute value

%compute pF
NFFTp=2^nextpow2(Lp);
p_F=abs(fft(p,NFFTp));
p_F=Ts*fftshift(p_F);

abs_p_F=abs(p_F);%take the absolute value

[val,idx]=max(xcorr(abs_r_F,abs_p_F));
d=idx-Lr+1

t=linspace(0,(Lr-1)*Ts,Lr);
r=r.*exp(-1j*2*pi*d*t);

scatter(real(r),imag(r));

