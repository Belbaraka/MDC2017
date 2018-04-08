function x = read_signed(p, sf, a, n, s)
%READ_SIGNED Extracts data from a page using two's complement format
%   X = READ_SIGNED(P, SF, A, N, S)
%   Arguments:
%     P   Page (P is a 300x5 matrix of bits {0,1}, each column is a  subframe)
%     SF  Subframe ID
%     A   Starting bit
%     N   Number of bits
%     S   Exponent of scaling factor (factor = 2^S)
%   
%   X = m * 2^S, where m is the mantissa represented by the N bits (expressed
%   in base 10)
%   Does not require Communications toolbox

bits = p(a:a + n - 1, sf);

if bits(1) == 0
    x = my_bi2de(bits', 'left-msb') * 2^s;
else
    bits = ~bits;
    x = -1 * (my_bi2de(bits', 'left-msb') + 1) * 2^s;
end

end

