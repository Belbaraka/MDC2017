function c = my_pskMap(M)
%MY_PSKMAP Creates constellation for Phase Shift Keying modulation
% C = MY_PSKMAP(M) outputs a 1xM vector with the complex symbols of the
% PSK constellation of alphabet size M, where M is an integer power of 2

if not((floor(log2(M))==log2(M) && log2(M)>0))
    error('M must be in the form M = 2^K, where K is a positive integer.');
end



%define de number coordinates in the X and Y axis
x=0:M-1;
x=(2*pi/M)*x;
x=arrayfun(@cos,x);

y=0:M-1;
y=(2*pi/M)*y;
y=arrayfun(@sin,y);


%compute final 1*M vector
c=x+y*1i;

end

