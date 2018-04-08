rolloff = 0.25;     % Rolloff factor
span = 6;           % Filter span in symbols
sps = 4;            % Samples per symbol

b = rcosdesign(rolloff, span, sps);

d = 2*randi([0 1], 100, 1) - 1;
disp(size(d));

x = upfirdn(d, b, sps);
disp(size(x));

r = x + randn(size(x))*0.01;


y = upfirdn(r, b, 1, sps);
disp(size(y));
