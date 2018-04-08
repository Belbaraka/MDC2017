function [subframes, subframesIDs] = my_bits2subframes(bits)
%BITS2SUBFRAMES Returns a matrix containing the subframes in the desired order
%   [SUBFRAMES, SUBFRAMESIDS] = BITS2SUBFRAMES(BITS) returns the matrix
%   SUBFRAMES having as its columns the subframes extracted from BITS.
%   The IDs of the subframes are returned in SUBFRAMESIDS.  BITS must
%   be a row vector containing a concatenation of subframes (0 and 1
%   elements) that have already been checked for parity.  Provided that
%   BITS is sufficiently long, SUBFRAMES contains the subframes with
%   id 1,2,3, in that order. (It might contain additional subframes.)
%   These are the subframes that we use to obtain the ephemerides.

global gpsc;
if isempty(gpsc)
    gpsConfig();
end

bpsf=gpsc.bpsf;
nsf=floor(length(bits)/bpsf);
subframes=zeros([bpsf nsf]);
subframesIDs=zeros([1 nsf]);
for i=1:nsf
    istart=(i-1)*bpsf+1;
    sf=bits(istart:istart+bpsf-1);
    b50=sf(50);b51=sf(51);b52=sf(52);
    ID=bi2de([b50 b51 b52],'left-msb');
    
    subframes(:,i)=transpose(sf);
    subframesIDs(i)=ID;
end

%subframes=subframes(any(subframes,2),any(subframes,1));
%subframesIDs=subframesIDs(any(subframesIDs,2),any(subframesIDs,1));

