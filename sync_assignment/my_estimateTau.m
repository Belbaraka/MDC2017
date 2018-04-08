function tau_estim = my_estimateTau(rx_signal, preamble)
%TAU_ESTIM = MY_ESTIMATE_TAU(RX_SIGNAL, PREAMBLE)
% Estimates the channel delay by computing the inner products between
% the received signal (RX_SIGNAL) and the time-shifted copies of the
% known-to-receiver signal (PREAMBLE) and finding the maximizing
% time-shift.


[argval, argmax]=max(xcorr(rx_signal,preamble));

Lr=length(rx_signal);
tau_estim=argmax-Lr;

end