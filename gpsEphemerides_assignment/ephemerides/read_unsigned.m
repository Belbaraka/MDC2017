function x = read_unsigned(p, sf, a, n, s)
%READ_UNSIGNED Extracts data from a page using unsigned format
%   X = READ_UNSIGNED(P, SF, A, N, S)
%   Arguments:
%     P   Page (P is a 300x5 matrix of bits {0,1})
%     SF  Subframe ID
%     A   Starting bit
%     N   Number of bits
%     S   Exponent of scaling factor (factor = 2^S)
%   
%   X = m * 2^S, where m is the mantissa represented by the N bits (expressed
%   in base 10)

% $Id$

bits = p(a:a + n - 1, sf);
x = bi2de(bits', 'left-msb') * 2 ^ s;

end
