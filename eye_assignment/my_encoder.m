function y = my_encoder(x, mapping)
%MY_ENCODER Maps a vector of M-ary integers to constellation points
% Y = MY_ENCODER(X, MAPPING) outputs a vector of (possibly complex)
% symbols from the constellation specified as second parameter,
% corresponding to the integer valued symbols of X. Input X can be
% a row or column vector, and output Y has the same dimensions as X.
% If the length of vector MAPPING is M, then the message symbols of
% X must be integers between 0 and M-1.

M=length(mapping);
if((max(x)>=M || min(x)<0))
    error('Message symbols of X must be integers between 0 and M-1');
end

x=x+1;
[m,n]=size(x);
y=mapping(x);
y=reshape(y,[m,n]);

end