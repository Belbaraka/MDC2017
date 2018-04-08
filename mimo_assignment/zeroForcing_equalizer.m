function suff_stat = zeroForcing_equalizer(rx_symbols, H)
%ZEROFORCING_EQUALIZER implements a zero-forcing equalizer for MIMO
%channel
% SUFF_STAT = ZEROFORCING_EQUALIZER(RX_SYMBOLS, H) computes the
% sufficient statistic for decision by inverting the channel matrix H.
% RX_SYMBOLS: is the column vector of received symbols.
% H: is the channel matrix. It has to have the same number of rows as
% the number of rows of RX_SYMBOLS.
%
% SUFF_STAT: is the equalized signal, used for decision.
%
% If RX_SYMBOLS is a matrix, the function works on each column
% separately, hence SUFF_STAT will be a matrix with the same number of
% columns as RX_SYMBOLS. 

if(size(H,1)~=size(rx_symbols,1))
    error('incorrect channel matrix')
end

suff_stat=H\rx_symbols;



end