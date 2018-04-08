function z = my_decoder(y, mapping)
%MY_DECODER Minimum distance slicer
% Z = MY_DECODER(Y, MAPPING) demodulates vector Y by finding
% the element of the specified constellation that is closest to each
% element of input Y. Y contains the outputs of the matched filter of
% the receiver, and it can be a row or column vector. MAPPING specifies
% the constellation used, it can also be a row or column vector.
% Output Z has the same dimensions as input Y. The elements of Z are
% M-ary symbols, i.e., integers between 0 and [M=length(MAPPING)]-1.

[X,Y]=meshgrid(mapping,y);

mat=abs(X-Y);
[M, I]=min(transpose(mat));
z=I-1;
z=reshape(z,size(y));


end
