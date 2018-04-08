function tau = my_findFirstBit(sat_number, doppler, tau)
%FINDFIRSTBIT Scans the Doppler corrected data to locate the begining of a bit
%   TAU = FINDFIRSTBIT(SAT_NUMBER,DOPPLER,TAU) reads the data starting
%   at TAU (beginning of a C/A code as obtained by FINDSATELLITES()),
%   corrects it for Doppler using the estimate DOPPLER, and uses the
%   C/A code for satellite SAT_NUMBER to search for the beginning of
%   a bit. The beginning is declared if the phase of the inner product
%   after we shift by the length of a C/A code varies by roughly pi (is
%   in the range [-3*pi/4, 3*pi/4]). The function returns the index of
%   the first sample of the first complete bit.


global gpsc;

fs=gpsc.fs;


CA=satCode(sat_number,'fs');
Lca=length(CA);


Tstart=tau;
Tend=Tstart+Lca-1;

r1=getData(Tstart,Tend);
Lr=length(r1);
t=linspace(tau,(Lr-1)/fs+tau,Lr);



%correct doppler 
corr1=exp(-1i*2*pi*doppler*t);
r1=r1.*corr1;
IP1=sum(r1.*CA);


Tstart=Tend+1;
Tend=Tstart+Lca-1;
r2=getData(Tstart,Tend);
shift=exp(-1i*2*pi*doppler*Lca/gpsc.fs);
corr2=shift*corr1;

r2=r2.*corr2;
IP2=sum(r2.*CA);


phase=angle(IP1*conj(IP2));

while(phase<3*pi/4 && phase>-3*pi/4)  
    IP1=IP2;
    tau=tau+Lca;
    corr2=shift*corr2;
    Tstart=Tend+1;
    Tend=Tstart+Lca-1;
    r=getData(Tstart,Tend);
    r=r.*corr2;
    IP2=sum(r.*CA);
    phase=angle(IP1*conj(IP2));  
end
tau=mod(Lca+tau,gpsc.spb);
end
