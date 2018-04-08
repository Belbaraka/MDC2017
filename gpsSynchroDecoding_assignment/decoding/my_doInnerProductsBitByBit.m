function [newBitwiseInnerProduct, nextInitialPhi, nextInitialTau] = my_doInnerProductsBitByBit(nBits, sat_number, doppler, tau, initialPhi)
%DOINNERPRODUCTSBITBYBIT Does the inner product one bit at a time.
%   [NEWBITWISEINNERPRODUCTS, NEXTINITIALPHI, NEXTINITIALTAU] =
%   DOINNERPRODUCTSBITBYBIT(NBITS,SAT_NUMBER,DOPPLER,TAU,INITIALPHI)
%   Returns in NEWBITWISEINNERPRODUCTS the inner products of NBITS (done
%   one bit at a time) with repeated C/A code for satellite SAT_NUMBER,
%   applying Doppler correction DOPPLER, and assuming that the first bit
%   considered starts at sample TAU and that the initial phase for the
%   Doppler correction is INITIALPHI. In NEXTINITIALPHI and NEXTINITIALTAU
%   the function returns the initial phase for the Doppler correction
%   and the initial TAU required to process the next block of bits in
%   a subsequent function call.


global gpsc;

newBitwiseInnerProduct=zeros(1,nBits);

CA=satCode(sat_number,'fs');
Lca=length(CA);
rCA=repmat(CA,1,20);

Tstart=tau;
Tend=Tstart+20*Lca-1;

Lr=20*Lca;

t=linspace(0, (Lr-1)/gpsc.fs,Lr);

doppler_corr=exp(-1i*2*pi*doppler*t);
corr=doppler_corr*exp(-1i*initialPhi);



for i=1:nBits
    r=getData(Tstart,Tend);
    r=r.*corr;
    newBitwiseInnerProduct(i)=sum(r.*rCA);
    Tstart=Tend+1;
    Tend=Tstart+20*Lca-1;
    initialPhi=initialPhi+2*pi*Lr*doppler/gpsc.fs;
    corr=doppler_corr*exp(-1i*initialPhi);
end

nextInitialTau=round(tau+nBits*Lr/(1+doppler/gpsc.fc));
nextInitialPhi=initialPhi;

end