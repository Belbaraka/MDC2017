%MAINPRODUCEBITS This script reads the sampled GPS signal from disk and
%   processes it to detect the visible satellites, get synchronization
%   and obtain the raw bit message sent sent by the visible satellites

% $Id: mainProduceBits.m 1543 2013-01-28 13:45:33Z tarniceriu $
% Created by Bixio and Stephane Dec. 2009

%% Initialization

global gpsc;
if isempty(gpsc)
	gpsConfig();
end	

% Nicolae: for debug
mainProduceBits_debug = gpsc.store;

findSatellites();
decodeSatellites();
