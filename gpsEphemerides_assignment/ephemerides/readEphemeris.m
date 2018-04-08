function ephdata = readEphemeris(page)
%READEPHEMERIS123 extracts the ephemeris data from subframes 1 to 3
%   EPHDATA = READEPHEMERIS123(DATA) extracts the ephemeris data of subframes
%   1 to 3 from the given page by taking the correct bits and performing
%   the appropriate conversion (scaling, 2-complement, etc.).
%
%   DATA is a 300x3 matrix of zeros and ones, where columns 1 to 3
%   represent the bits of subframes 1 to 3, respectively. 
%
%   The ephemeris data is returned in the following structure:
%
%   Telemetry and HOW (Hand-over word):
%
%     ephdata
%       .TOW1 - .TOW3   Time of the week for subframes 1 to 3 [s]
%       .wn             Week number
%       .alert          Alert bit
%       .antispoof      Antispoof bit
%
%
%   Clock correction parameters:
%
%     ephdata
%       .IODC           Issue index of clock data
%       .t_oc           Clock data reference time
%       .T_GD           Group delay differential
%       .a_f0           0th-order correction term
%       .a_f1           1st-order correction term
%       .a_f2           2nd-order correction term
%
%
%   Orbit Parameters:
%
%     ephdata
%       .IODE           Issue index of ephemeris data
%       .t_oe           Ephemeris reference time
%       .M_0            Mean anomaly at reference time
%       .delta_n        Correction to the computed mean motion
%       .e              Orbit ellipse eccentricity
%       .sqrt_a         Square-root of the semi-major axis
%       .i_0            Inclination angle at reference time
%       .w              Argument of perigee
%       .Omega_0        Longitude of the ascending node at reference time
%
%
%   Orbit correction parameters:
%
%     ephdata
%       .Omegadot       Rate of change of the right ascension
%       .idot           Rate of change of the inclination angle
%       .C_us           Amplitudes of harmonic correction terms for the
%       .C_uc           computed argument of latitude
%       .C_rs           Amplitudes of harmonic correction terms for the
%       .C_rc           computed orbit radius
%       .C_is           Amplitudes of harmonic correction terms for the
%       .C_ic           computed inclination angle
%
%   For  your convenience, the following auxiliary parameter is also added
%   to ephdata:
%       .t_tr           Transmission time (earliest TOW minus 6)

%   $Id: readEphemeris.m 1164 2010-11-02 19:01:26Z jimenez $


global gpsc;
if isempty(gpsc)
    gpsConfig();
end

function_mapper; % setup function handles

% Extract parameters from page according to the GPS standard
ephdata.sfid        = read_unsigned(page, 1, 50, 3, 0);
ephdata.TOW1        = read_unsigned(page, 1, 31, 17, 0) * 6;
ephdata.TOW2        = read_unsigned(page, 2, 31, 17, 0) * 6;
ephdata.TOW3        = read_unsigned(page, 3, 31, 17, 0) * 6;
%     ephdata.TOW4        = read_unsigned(page, 4, 31, 17, 0) * 6;
%     ephdata.TOW5        = read_unsigned(page, 5, 31, 17, 0) * 6;
ephdata.wn          = read_unsigned(page, 1, 61, 10, 0);
ephdata.alert       = read_unsigned(page, 1, 18, 1, 0);
ephdata.antispoof   = read_unsigned(page, 1, 19, 1, 0);

ephdata.IODC        = read_2part_unsigned(page, 1, 83, 2, 211, 8, 0);
ephdata.t_oc        = read_unsigned(page, 1, 219, 16, 4);
ephdata.T_GD        = read_signed(page, 1, 197, 8, -31);
ephdata.a_f0        = read_signed(page, 1, 271, 22, -31);
ephdata.a_f1        = read_signed(page, 1, 249, 16, -43);
ephdata.a_f2        = read_signed(page, 1, 241, 8, -55);

ephdata.IODE        = read_unsigned(page, 2, 61, 8, 0);
ephdata.t_oe        = read_unsigned(page, 2, 271, 16, 4);
ephdata.M_0         = read_2part_signed(page, 2, 107, 8, 121, 24, -31) * gpsc.pi_gps;
ephdata.delta_n     = read_signed(page, 2, 91, 16, -43) * gpsc.pi_gps;
ephdata.e           = read_2part_unsigned(page, 2, 167, 8, 181, 24, -33);
ephdata.sqrt_a      = read_2part_unsigned(page, 2, 227, 8, 241, 24, -19);
ephdata.i_0         = read_2part_signed(page, 3, 137, 8, 151, 24, -31) * gpsc.pi_gps;
ephdata.w           = read_2part_signed(page, 3, 197, 8, 211, 24, -31) * gpsc.pi_gps;
ephdata.Omega_0     = read_2part_signed(page, 3, 77, 8, 91, 24, -31) * gpsc.pi_gps;

ephdata.Omegadot    = read_signed(page, 3, 241, 24, -43) * gpsc.pi_gps;
ephdata.idot        = read_signed(page, 3, 279, 14, -43) * gpsc.pi_gps;
ephdata.C_us        = read_signed(page, 2, 211, 16, -29);
ephdata.C_uc        = read_signed(page, 2, 151, 16, -29);
ephdata.C_rs        = read_signed(page, 2, 69, 16, -5);
ephdata.C_rc        = read_signed(page, 3, 181, 16, -5);
ephdata.C_is        = read_signed(page, 3, 121, 16, -29);
ephdata.C_ic        = read_signed(page, 3, 61, 16, -29);

% Compute the minimum of the TOW times. Since the TOW field of a subframe
% indicates the GPS time of the start of the _next_ subframe, we subtract
% 6 (seconds) from it, since that is the transmission duration of a
% subframe.
mintow = min([
    ephdata.TOW1
    ephdata.TOW2
    ephdata.TOW3]);

ephdata.t_tr = mintow - 6.0;

end
