function c = my_qamMap(M)
%MY_QAMMAP Creates constellation for square QAM modulations
% C = MY_QAMMAP(M) outputs a 1xM vector with the constellation for the
% quadrature amplitude modulation of alphabet size M, where M is the
% square of an integer power of 2 (e.g. 4, 16, 64, ...). The signal
% constellation is a square constellation.


if not((floor(log2(M)/2)==log2(M)/2 && log2(M)/2>=0))
    error('M must be in the form M = 2^(2K), where K is a positive integer.');
end 

%get the number of point in constellation
K=log2(M)/2;

%define de number coordinates in the X and Y axis
x=-K:K;
x(K+1)=[];
y=-K:K;
y(K+1)=[];
y=fliplr(y);

[X,Y]=meshgrid(x,y);

c_temp=X+Y.*1i;
c=reshape(c_temp,[1,M]);

end