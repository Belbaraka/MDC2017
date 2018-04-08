function c = satCode(s, freq)
%SATCODE Returns C/A code sequence
%  C = SATCODE(S) returns the C/A code sequence of satellite S as a row
%  vector, sampled at chip rate. The elements of C are in the set {-1, 1}.
%  C = SATCODE(S, 'fs') returns the C/A code sequence at the sampling rate
%  rather than at the chip rate.

% $Id: satCode.m 1137 2010-10-13 15:46:16Z jimenez $

% Load global GPS configuration
global gpsc;

% Name of the file that contains the C/A codes
FILENAME = '../data/CAcodes.mat';

% Check arguments
if nargin < 2
    fs = false;
elseif strcmpi(freq, 'fs')
    fs = true;
else
    error('Invalid value for second argument')
end

% Initialize persistent variable to store the code array
persistent satCAcodes;

if isempty(satCAcodes)
    a = load(FILENAME);
    satCAcodes = a.satCAcodes;
end

% Return the row corresponding to the specified satellite.
c = satCAcodes(s, :);

% If desired, upsample the code sequence to sampling frequency
if fs
    c = kron(c, ones(1, gpsc.spch));
end

end