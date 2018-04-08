% FUNCTION_MAPPER Initialize function handles so that different implementations of a function can be easily interchanged
% Comment/uncomment one line of every pair to choose between your implementation and our solutions


% functions called from getEphemerisAndPseudorange:

computePseudorange = str2func('my_computePseudorange');
%computePseudorange = str2func('sol_computePseudorange');

% functions called from getSubframes:

removeExcessBits = str2func('my_removeExcessBits');
%removeExcessBits = str2func('sol_removeExcessBits'); % uncomment to use the solution

establishParity = str2func('my_establishParity');
%establishParity = str2func('sol_establishParity'); % uncomment to use the solution

bits2subframes = str2func('my_bits2subframes');
%bits2subframes = str2func('sol_bits2subframes');
%bits2subframes = str2func('sol_bits2subframes_c'); %to avoid using the communications toolbox


