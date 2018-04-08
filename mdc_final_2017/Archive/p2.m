close all;clear all;
load rx_signal.mat


%load the first block (very small phase rotation)
start_estim=rx_signal(:,1); % we will use them to estim the rotation
nbSymb=length(rx_signal(1,:));
phases=zeros(1,nbSymb); % contains the estimate rotation for each column

correct_rx=zeros(size(rx_signal));%the phase corrected rx_signal
correct_rx(:,1)=start_estim;
for i=2:nbSymb
    phases(i)=mean(angle(rx_signal(:,i)./correct_rx(:,i-1)));%we know the rotation is the same in each colum
    correct_rx(:,i)=exp(-1j*phases(i))*rx_signal(:,i); %correct the rotation
end

%phases_mat=repmat(phases,length(rx_signal(:,1)),1);
%correct_rx=rx_signal.*exp(-1j*phases_mat);

correct_rx=correct_rx(:);

plot(correct_rx,'*');
