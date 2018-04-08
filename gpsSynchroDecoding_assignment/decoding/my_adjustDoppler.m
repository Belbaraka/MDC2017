function newDoppler = my_adjustDoppler(sat_number, tau, doppler, fCorr)
%ADJUSTDOPPLER Tracks the evolution of the Doppler frequency
%   NEWDOPPLER = ADJUSTDOPPLER(SAT_NUMBER, TAU, DOPPLER, FCORR) SAT_NUMBER
%   selects the satellite we want to track, TAU is the current estimate
%   of the sample corresponding to the beginning of the next unprocessed
%   bit and DOPPLER is the current Doppler estimate. The estimation method
%   is based in computing the inner products of the C/A code repeated 20
%   times (duration of a bit) with the received signal corrected with the
%   current estimate of the Doppler and corrected with a value slightly
%   higher (DOPPLER+FCORR) and a value slightly lower (DOPPLER-FCORR). In
%   our code we use FCORR = 20. From experiments we know that the value
%   of the inner product as a function of Doppler can be approximated
%   by a second order polynomial: with these three points we find the
%   coefficients of this polynomial and then NEWDOPPLER is the Doppler
%   value for which the polynomial achieves its maximum.

global gpsc;

CA=satCode(sat_number,'fs');
Lca=length(CA);
rCA=repmat(CA,1,20);


Tstart=tau;
Tend=Tstart+20*Lca-1;
r=getData(Tstart,Tend);
Lr=length(r);
t=linspace(tau,(Lr-1)/gpsc.fs+tau,Lr);

IP1=abs(sum((r.*exp(-1i*2*pi*(doppler-fCorr)*t)).*rCA));
IP2=abs(sum((r.*exp(-1i*2*pi*doppler*t)).*rCA));
IP3=abs(sum((r.*exp(-1i*2*pi*(doppler+fCorr)*t)).*rCA));

mat2=[doppler-fCorr,doppler,doppler+fCorr]';
mat1=mat2.^2;
mat3=ones(3,1);

D=[mat1,mat2,mat3];
F=[IP1,IP2,IP3]';

coefs=D\F;
a=coefs(1);
b=coefs(2);
newDoppler=-b/(2*a);


end