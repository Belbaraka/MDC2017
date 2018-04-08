function tfplotTime(s, fs, name, plottitle)
% TFPLOT Time and frequency plot
%    TFPLOT(S, FS, NAME, TITLE) displays a figure window with two
%    subplots.  Above, the signal S is plotted in time domain; below,
%    the signal is plotted in frequency domain. NAME is the "name" of the
%    signal, e.g., if NAME is 's', then the labels on the y-axes will be
%    's(t)' and '|s_F(f)|', respectively.  TITLE is the title that will
%    appear above the two plots.


% Note: Since TITLE is the name of a built-in Matlab function, you cannot
% use it as the name of a function argument.  In the following code, we
% called the argument PLOTTITLE instead 

if ~isscalar(fs)
    error('Fs must be scalar');
end

% Compute the time and frequency scales
t = linspace(0, (length(s)-1) / fs, length(s));

% First plot: time
plot(t, s); grid on;
xlabel('t [s]'); ylabel(sprintf('%s(t)', name));
title(plottitle);

end

