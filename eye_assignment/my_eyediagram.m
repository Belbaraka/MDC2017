function my_eyediagram(y, Fs, T)
%MY_EYEDIAGRAM Generates an eye diagram
% MY_EYEDIAGRAM(Y, FS, T) plots the eye diagram corresponding to the
% sampled matched filter output Y, assuming the sampling frequency is
% Fs and the symbol duration is T


N=2*T*Fs; %number of samples per trace
k=floor(length(y)/N); %number of trace
y=y(1:k*N); %truncate the match filter output
y=reshape(y,[N k]);
%y=arrayfun(norm,y);

x=linspace(-T,T,N);

plot(x,real(y));
ylabel('Amplitude'); xlabel('Time [s]'); 


end


