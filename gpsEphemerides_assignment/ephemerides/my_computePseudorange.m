function pseudorange = my_computePseudorange(taus, tau_ref, idx_firstBitSubframe)
%COMPUTEPSEUDORANGE Compute pseudorange for one GPS satellite
%   PSEUDORANGE = COMPUTEPSEUDORANGE(TAUS, TAU_REF, TAU_FIRSTBITSUBFRAME)
%   TAUS: vector of indices into the received samples where each decoded 
%   bit begins. The length of TAUS is equal to the number of decoded bits.
%   TAU_REF: (scalar) index into the vector of received samples where the 
%   position of the receiver is to be computed.
%   IDX_FIRSTBITSUBRAME: index into the sequence of bits where the first 
%   subframe starts for this satellite.
%   PSEUDORANGE: computed pseudorange for the satellite (in meters).

%tau_ref should be biger than 0; (reference time should be after turning on the receiver)
%tau_ref considered to be lower than the start of the first complete
%subframe


global gpsc;
if isempty(gpsc)
    gpsConfig();
end

Tb=gpsc.Tc*gpsc.cpb;%duration of a bit
C=gpsc.C;%speed of light
N=length(taus);
counter=0;
for i=1:N
    if(taus(i)<=idx_firstBitSubframe && taus(i)>=tau_ref)
       counter=counter+1; 
    end
   
end    

pseudorange=C*Tb*counter/N;
end