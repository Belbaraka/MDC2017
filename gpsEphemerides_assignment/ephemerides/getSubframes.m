function [subframes, subframesIDs, idx] = getSubframes(bits)
%GETSUBFRAMES Extracts the subframes from the bit stream transmitted by a satellite
%   [SUBFRAMESIDS, SUBFRAMES, IDX] = GETSUBFRAMES(BITS) takes the BITS of
%   a satellite and returns in SUBFRAMES and SUBFRAMESIDS the subframes
%   and their IDs respectivelly. In IDX the function returns the index
%   into vector BITS where the first subframe with ID=1 starts

% $Id: getSubframes.m 15.09.2016 chiurtu $


% declare gpsc as global, and if it is not initialized, do it
global gpsc;
if isempty(gpsc)
    gpsConfig();
end

function_mapper; % initializes function handles

% Find the first bit of a subframe and remove the bits that precede it and
% the bits at the end that don't make a full subframe. It also returns the
% position (in bits) of the first retained bit within the input "bits".
[s_pre, idx] = removeExcessBits(bits);

% Make sure that the parity is fulfilled and flip the bits as needed.
% The function implements Table 20-XIV.
s = establishParity(s_pre);

% Order the bits into a matrix that has as its columns the subframes.
% Return as well the IDs of the subframes.
[subframes, subframesIDs] = bits2subframes(s);

if (size(subframes, 2) < 8)
    error('At least %d subframes are required (got only %d)', 8, size(subframes, 2));
end

end
