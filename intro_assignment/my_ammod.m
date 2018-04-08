function s=my_ammod(m, K, A, fc, fs)
samples=length(m);
duration=samples/fs;
t=linspace(0,duration,samples);
s=(1+K*m).*(A*cos(2*pi*fc*t));
end