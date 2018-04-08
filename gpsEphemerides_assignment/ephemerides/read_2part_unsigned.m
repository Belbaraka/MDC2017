function x = read_2part_unsigned(p, sf, am, nm, al, nl, s)
%READ_2PART_UNSIGNED Extracts data from a page when the data is stored in two different locations
%   X = READ_2PART_UNSIGNED(P, SF, AM, NM, AL, NL, S)
%   Arguments:
%     P   Page (P is a 300x5 matrix of bits {0,1})
%     SF  Subframe ID
%     AM  Starting bit (MSB part)
%     NM  Number of bits (MSB part)
%     AL  Starting bit (LSB part)
%     NL  Number of bits (LSB part)
%     S   Exponent of scaling factor (factor = 2^S)
%   
%   X = m * 2^S, where m is the mantissa represented by the two chunks of bits
%   (expressed in base 10)

% $Id: read_2part_unsigned.m 1180 2010-11-16 22:57:55Z jimenez $

bits_msb = p(am:am + nm - 1, sf);
bits_lsb = p(al:al + nl - 1, sf);

x = bi2de([bits_msb; bits_lsb]', 'left-msb') * 2^s;

end

