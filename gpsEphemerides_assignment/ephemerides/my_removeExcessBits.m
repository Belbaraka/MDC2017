function [s, ind] = my_removeExcessBits(bits)
%REMOVEEXCESSBITS Extracts the complete subframes in the bit sequence obtained from a satellite
%   [S, IDX] = REMOVEEXCESSBITS(BITS) detects the start of the first
%   subframe in the row vector BITS (values in {-1,+1}) by correlating
%   with the GPS preamble (stored in gpsc.preamble as a sequence of
%   1s and 0s). If the negative of the preamble is found all bits
%   are inverted. IDX is the index into BITS where the first subframe
%   starts; incomplete subframes at the beginning and at the end of
%   BITS are removed and the sequence of bits is converted into a
%   sequence of {0,1} values ({1,-1} <-> {0,1}) and returned into
%   vector S.
%
% Hints: 
% - The preamble is stored in gpsc.preamble as a sequence of 0s and 1s.
% - It is not enough to just find one preamble: the preamble is 8 bits
%   long and it is not unlikely that this 8-bit sequence is also
%   present somewhere in the middle of the data sequence. You should
%   use the fact that there is one preamble in every subframe (every
%   300 bits).
% - Use round() on your correlation or inner product values in order to
%  eliminate MATLAB's rounding errors.

global gpsc;
if isempty(gpsc)
    gpsConfig();
end

N_subf=floor(length(bits)/gpsc.bpsf);
preamble=gpsc.preamble;
preamble=-2*preamble+1;

preamble_e=horzcat(preamble,zeros([1,gpsc.bpsf-length(preamble)]));
preamble_e=repmat(preamble_e,1,N_subf);

[val1, idx1]=max(round(xcorr(bits,preamble_e)));
[val2, idx2]=min(round(xcorr(bits,preamble_e)));
if(abs(val1)>abs(val2))
    ind=mod(idx1-length(bits)+1,300);
else
    ind=mod(idx2-length(bits)+1,300);
    bits=-bits; %invert the bits
end

s=bits(ind:ind+N_subf*gpsc.bpsf-1);
s=-0.5*(s-1);

end


