function gpsConfig()
%GPS_CONFIG Initialize GPS configuration parameters
%   GPS_CONFIG() defines all GPS configuration options (constants, etc)
%   and sets them in the structure 'gpsc'.
%   GPS_CONFIG must be called only once, before 'gpsc' is accessed for the
%   first time. Any function that subsequently uses 'gpsc' must declare
%   the variable as global:
%      global gpsc;
%
%   Summary of configuration variables
%   (access each of these as 'gpsc.<name>')
%
%     fs              % Sampling frequency [Hz]
%     spch            % Samples per chip
%     spc             % Samples per code
%     spb             % Samples per bit
%     spp             % Samples per block
%     chpc            % Chips per code
%     cpb             % Codes per bit
%     bpp             % Bits per block
%
%     Ts              % Sampling time [s]
%     Tc              % Time of one code [s]
%     Tp              % Time of one block [s]
%     bps             % Bit rate [bps]
%     cr              % Chip rate [chips/s]
%     maxdoppler      % Maximum absolute doppler shift [Hz]
%
%     bpw             % Bits per word
%     bpsf            % Bits per subframe
%     preamble        % GPS subframe preamble
%     wpsf            % Words per subframe
%
%     fc              % GPS carrier frequency L1 [Hz]
%     Omega_dot_e     % Earth's rotational rate [rad/s]
%     mu_e            % Earth's universal gravitational constant [m^3/s^2]
%     pi_gps          % Pi as defined in the GPS standard
%     C               % Speed of light [m/s]
%
%     datadir         % Directory where data files are kept

% $Id: gpsConfig.m 1144 2010-10-15 15:00:00Z jimenez $


global gpsc; % Declare structure as global

% If gpsc is not empty, it has been defined before and we can exit the
% function here. 
if ~isempty(gpsc)
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMULATION OPTIONS                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Put here any configuration parameters necessary for your simulation.

% Bits per block
gpsc.bpp = 10;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BASIC GPS CONSTANTS                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Samples per chip
gpsc.spch = 4;

% Chips per code
gpsc.chpc = 1023;

% Codes per bit
gpsc.cpb = 20;

% Bit rate [bps]
gpsc.bps = 50;

% GPS carrier frequency L1 [Hz]
gpsc.fc = 154 * 10.23e6;

% GPS subframe preamble
gpsc.preamble=[1 0 0 0 1 0 1 1];

% Maximum absolute doppler shift [Hz]
gpsc.maxdoppler = 10e3; %  = 10 kHz

% Earth's universal gravitational constant [m^3/s^2]
gpsc.mu_e = 3.986005e14;

% Earth's rotational rate [rad/s]
gpsc.Omega_dot_e = 7.2921151467e-5; 

% Pi as defined in the GPS standard
gpsc.pi_gps = 3.1415926535898;

% Speed of light [m/s]
gpsc.C = 299792458;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DERIVED CONSTANTS                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sampling frequency [Hz] // 4 * 1023 * 20 * 50 = 4 092 000 [Hz]
gpsc.fs = gpsc.spch * gpsc.chpc * gpsc.cpb * gpsc.bps;

% Sampling time [s]
gpsc.Ts = 1 / gpsc.fs;

% Samples per code
gpsc.spc = gpsc.spch * gpsc.chpc;

% Samples per bit
gpsc.spb = gpsc.spc * gpsc.cpb;

% Chip rate [chips/s]
gpsc.cr = gpsc.chpc * gpsc.cpb * gpsc.bps;

% Time of one code [s]
gpsc.Tc = gpsc.spc * gpsc.Ts;

% Samples per block
gpsc.spp = gpsc.bpp * gpsc.spb;

% Time of one block [s]
gpsc.Tp = gpsc.spp * gpsc.Ts;

% Bits per word
gpsc.bpw = 30;

% Words per subframe
gpsc.wpsf = 10;

% Bits per subframe
gpsc.bpsf = gpsc.bpw * gpsc.wpsf;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMULATION PARAMETERS                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data file directory
gpsc.datadir = '../data'; %  ~/handson/2007/gps/data_nov2005';

% Number of samples per file
gpsc.spf = 8179460;

% used to store the files
gpsc.store = false;
gpsc.postfix = '';
