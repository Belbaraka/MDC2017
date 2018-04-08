clear all;close all;
load phaseEstimate.mat

stem(phaseEstimate);

N=length(phaseEstimate);
i=1:N;
H=[transpose(i),ones(N,1)];

aux=H'*H;
inv_aux=aux\eye(size(aux));
y=phaseEstimate(:);
v_LS=inv_aux*H'*y;%formula dereivde in Q5

estim_line=v_LS(1)*i+v_LS(2); %phase estimate

hold on;
stem(estim_line);