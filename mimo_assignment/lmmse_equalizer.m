function suff_stat = lmmse_equalizer(rx_symbols, H, sigma2)
%LMMSE_EQUALIZER implements a linear MMSE equalizer for the MIMO channel
% SUFF_STAT = LMMSE_EQUALIZER(RX_SYMBOLS, H, SIGMA2) computes the
% sufficient statistic for decision according to the linear MMSE rule.
% RX_SYMBOLS: is the column vector of received symbols.
% H: is the channel matrix. It has to have the same number of rows as
% the number of rows of RX_SYMBOLS.
% SIGMA2: The noise variance.
%
% SUFF_STAT: is the equalized signal, used for decision.
%
% If RX_SYMBOLS is a matrix, the function works on each column
% separately, hence SUFF_STAT will be a matrix with the same number of
% columns as RX_SYMBOLS.

if(size(H,1)~=size(rx_symbols,1))
    error('incorrect channel matrix')
end

Kz=sigma2*eye(size(rx_symbols,1));

Ky=H*conj(transpose(H))+Kz;
invKy=Ky\eye(size(Ky));

B=conj(transpose(H))*invKy;
suff_stat=B*rx_symbols;



end