function z = my_symbols2samples(y, h, USF)
%MY_SYMBOLS2SAMPLES Produces the samples of the modulated signal
% Z = MY_SYMBOLS2SAMPLES(Y, H, USF) produces the samples of a
% modulated pulse train. The sampled pulse is given in vector H, and
% the symbols modulating the pulse are contained in vector Y. USF is
% the upsampling factor, i.e., the number of samples per symbol.

y=upsample(y,USF);

%normalize h
h=h/norm(h);

z=conv(y,h);

end
