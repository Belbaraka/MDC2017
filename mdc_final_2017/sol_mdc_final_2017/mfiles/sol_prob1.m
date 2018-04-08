% MMSE channel estimation in time domain

close all;
clear all;

load prob1.mat

% Create the matrix C
firstRow = [x(1), zeros(1,length(h)-1)];
firstColumn = [x(:); zeros(length(h)-1,1)];
C = toeplitz(firstColumn, firstRow);

% Compute the covariance matrices
Khy = K_h*C';
Ky = C*K_h*C' + (sigma*sigma)*eye(length(y));

% MMSE estimate
hEstimate = Khy*inv(Ky)*y(:); % using inv() to implement the MMSE formula "verbatim"
% hEstimate = Khy*(Ky\y(:)); % here we use mldivide(\)

% check the result
figure;
plot(abs(hEstimate),'-*'); grid on; hold on;
plot(abs(h), '--d'); title('Magnitude');
legend('Estimated channel', 'Actual channel');
