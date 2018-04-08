function h = create_multipath_channel_filter(amplitudes, delays, L)
%CREATE_MULTIPATH_CHANNEL_FILTER(AMPLITUDES, DELAYS) Create sampled response of multipath channel
%   H = CREATE_MULTIPATH_CHANNEL_FILTER(AMPLITUDES, DELAYS)
%   
%   We assume that the shaping pulse is a sinc. This is the reconstruction
%   filter. The length of the tails of the sinc is L.
%   
%   DELAYS and AMPLITUDES are vectors of the same length, specifying the
%   strength and delay of each path. The DELAYS must be specified relative to
%   the sampling period.
%   
%   H contains the samples of filtered impulse response.

if (numel(amplitudes) ~= numel(delays))
    error('create_multipath_channel_filter:wrongInputDimensions', 'AMPLITUDES and DELAYS must be vectors of the same length');
end

timeLine = -L:1:L;
F = repmat(timeLine',1,length(delays));
F = F - repmat(delays(:)',length(timeLine),1);
h = sinc(F)*amplitudes(:);

h = h';

end