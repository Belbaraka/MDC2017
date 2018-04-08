clear all;close all;

load prob1.mat

%create the matrix c using toepiltz
r=[x zeros(1,length(h)-1)];
col=[x(1) zeros(1,length(h)-1)];

C=transpose(toeplitz(col,r));
K_z=sigma*eye(size(C*K_h*C'));

aux=C*K_h*C'+K_z;
inv_aux=aux\eye(size(aux));

estim_h=C'*K_h*inv_aux*x;%formula derived

