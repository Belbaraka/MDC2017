%MAINFINDPOSITION Process ephemerides to obtain the GPS receiver position

% $Id: mainFindPosition.m 1545 2013-01-28 14:44:58Z tarniceriu $
% Create by Bixio and Stephane Nov. 2009

function_mapper; % setup function handles

[latitude, longitude, height] = rcvrpos();

fprintf('Receiver latitude : %.6f\n', latitude);
fprintf('Receiver longitude : %.6f\n', longitude);
fprintf('Receiver height : %.6f\n\n', height);

% This prints a link to googlemap 
url = sprintf('http://maps.google.com/maps?q=%.6f,%.6f', latitude, longitude);
fprintf(1, 'Link to Google Maps: <a href="%s">%s</a>\n', url, url);

% This prints a link to earthtools (where we can check the height above sea level)
%     url = sprintf('http://www.earthtools.org/index.php?x=%.6f&y=%.6f&z=14', longitude, latitude);
%     fprintf(1, 'Link to Earthtools: <a href="%s">%s</a>\n', url, url);
