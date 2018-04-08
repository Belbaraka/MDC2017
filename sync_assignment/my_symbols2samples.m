function z = my_symbols2samples(y, h, USF)
%MY_SYMBOLS2SAMPLES Produces the samples of the modulated signal
%   Z = MY_SYMBOLS2SAMPLES(Y, H, USF) produces the samples of a
%   modulated pulse train. The sampled pulse is given in vector H, and
%   the symbols modulating the pulse are contained in vector Y. USF is
%   the upsampling factor, i.e., the number of samples per symbol.

y = y(:); % make sure it is a column vector

% We first upsample the vector of symbols y by factor USF, inserting USF-1
% zeros between every two consecutive samples of y
y_up = upsample(y, USF); 

	% Alternative without using the upsample function: 
	% y_up = kron(y, [1; zeros(USF-1, 1)]);

% Convolve upsampled symbol vector with the shaping pulse h
 z =  conv(y_up, h);
% Result has the shape of the longest. If equal, the shape of the second
% vector
    
    % Alternative: use the filter function instead of conv
    % z = filter(h, 1, y_up);
