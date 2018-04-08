function x = read_2part_signed(p, sf, am, nm, al, nl, s)
%READ_2PART_SIGNED Extracts data from a page when the data is stored in two different locations in two's complement format
%   X = READ_2PART_SIGNED(P, SF, AM, NM, AL, NL, S)
%     P   page (P is a 300x5 matrix of bits {0,1})
%     SF  Subframe ID
%     AM  Starting bit (MSB part)
%     NM  Number of bits (MSB part)
%     AL  Starting bit (LSB part)
%     NL  Number of bits (LSB part)
%     S   Exponent of scaling factor 
%   
%   X = m*2^S, where m is the mantissa represented by the two chunks of
%   bits (expressed in base 10).
%   Does not require Communications toolbox.

bits_msb = p(am:am + nm - 1, sf);
bits_lsb = p(al:al + nl - 1, sf);

bits = [bits_msb; bits_lsb];

if bits(1) == 0
    x = my_bi2de(bits', 'left-msb') * 2^s;
else
    bits = ~bits;
    x = -1 * (my_bi2de(bits', 'left-msb') + 1) * 2^s;
end


end
