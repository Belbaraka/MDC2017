function [long, lat, h] = ecef2wgs84(x, y, z)
%ECEF2WGS84   Computes the user position in ellipsoid coordinates
%  [LAT LONG H] = ECEF2WGS84(X, Y, Z) accepts the position of the user
%  (receiver) in the ECEF coordinate system and uses the WGS-84 model
%  to compute the corresponding latitude (LAT), longitude (LONG), and
%  altitude (H).

%  $Id: ecef2wgs84.m 1259 2010-12-22 13:32:03Z jimenez $

    % WGS-84 constants
    EP = 0.00335281066474; 
    AE = 6378137;

    % Tolerance for iteration
    epsilon = 1e-3;

    % Compute distance from earth
    r = norm([x y z]);

    % Longitude
    long = rad2deg(atan(y / x));

    % Latitude
    lc = atan(z / norm([x y])); % Would be correct if the earth were spherical
    l = lc;

    diff = inf;
    while diff > epsilon
        next_l = lc + EP * sin(2 * l);
        diff = abs(next_l - l);
        l = next_l;
    end

    lat = rad2deg(l);

    % Altitude
    ro = AE * (1 - EP * sin(l) ^ 2);
    h = r - ro;

end



function D = rad2deg(R)

    % Helper function: radians to degree conversion
	
    if (nargin ~= 1)
        error('ecef2wgs84:rad2deg:wrongSyntax', 'Incorrect number of arguments');
    elseif ~isreal(R)
         warning('ecef2wgs84:rad2deg:complexArgument', 'Imaginary parts of complex ANGLE argument ignored');
         R = real(R);
    end

    D = R*180/pi;

end
