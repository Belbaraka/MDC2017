% LS estimate

close all;
clear all;

load phaseEstimate.mat

% plot to see what we have
figure;
plot(phaseEstimate, '-*'); grid on;
title('Phase drift due to CFO');

N = length(phaseEstimate);

% create the matrix H
H = [1:N; ones(1,N)]';

% calculate the LS estimate
v = inv(H'*H)*H'*phaseEstimate(:); % using inv() to implement the LS formula "verbatim"
%v = (H'*H)\(H'*phaseEstimate(:)); % here we use mldivide(\)

% plot to check the estimate
figure;
plot(phaseEstimate, '--*'); grid on; hold on;
plot(H*v,'-r');
legend('Original data', 'LS line fit');
