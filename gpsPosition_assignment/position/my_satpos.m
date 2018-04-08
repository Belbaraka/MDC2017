function [sp] = my_satpos(ephdata, t)
%SATPOS    Compute satellite position in ECEF coordinate system
%  [SP, DELTA_T_S] = SATPOS(EPHDATA, T) returns the position of the satellite
%  SP at GPS time T.
%  Computations use multiple parameters available in the ephemeris structure 
%  EPHDATA; 
%
%  The position SP is a vector of length 3 of (x,y,z) coordinates in the 
%  ECEF system corresponding to GPS time T.    
%
%  To implement this function we need the formulas given in Table 20.IV
%  (sheets 1 and 2), pp. 97-98 of the GPS standard document (Section 20.3.3.3.3.1)

%  TBC: To Be Completed

global gpsc; % declare gpsc as global, so we can have access to it

% if gpsc has not been initialized yet, do it
if isempty(gpsc)
    gpsConfig();
end

function_mapper; % initializes function handles   

omega       = ephdata.w;          % Argument of perigee
a_s         = ephdata.sqrt_a ^ 2; % Semimajor axis
t_oe        = ephdata.t_oe;       % Ephemeris reference time
e           = ephdata.e;          % Orbit ellipse eccentricity

C_us        = ephdata.C_us;        
C_rs        = ephdata.C_rs;         
C_is        = ephdata.C_is;       
C_uc        = ephdata.C_uc;       
C_rc        = ephdata.C_rc;       
C_ic        = ephdata.C_ic;       % computed inclination angle
idot        = ephdata.idot;       % Rate of change of the inclination angle 
Omegadot    = ephdata.Omegadot;   % Rate of change of the right ascension
Omega_0     = ephdata.Omega_0;    % Longitude of the ascending node at reference time
i_0         = ephdata.i_0;        % Inclination angle at reference time
	
% Determine the satellite eccentric anomaly at time t
E_k = calcE(ephdata, t);


% Time since ephemeris reference time; corrected to be in the range
% [-302400, 302400] (IS-GPS-200D Table 20-IV, p.97)
t_k = limitValidRange(t - t_oe);    

% True anomaly

nu_k = atan2(sqrt(1-e.^2)*sin(E_k),cos(E_k)-e); % TBC

% Argument of latitude
Phi_k = nu_k +omega;  % TBC

% Second harmonic perturbation corrections
delta_u_k = C_us*sin(2*Phi_k)+ C_uc*cos(2*Phi_k);  % TBC
delta_r_k = C_rs*sin(2*Phi_k)+ C_rc*cos(2*Phi_k); % TBC
delta_i_k = C_is*sin(2*Phi_k)+ C_ic*cos(2*Phi_k); % TBC

% Corrected argument of latitude
u_k = Phi_k + delta_u_k; % TBC

% Corrected orbital plane inclination
i_k = i_0 + delta_i_k + idot*t_k;  % TBC

% Corrected radius
r_k = a_s*(1-e*cos(E_k))+delta_r_k;  % TBC

% Angle for ECEF conversion
Omega_dot_e=gpsc.Omega_dot_e;
Omega_k = Omega_0+ (Omegadot-Omega_dot_e)*t_k -Omega_dot_e*t_oe;  % TBC

% Compute (x,y) position in orbit plane
x_k_prim = r_k*cos(u_k);  % TBC
y_k_prim = r_k*sin(u_k);% TBC

% Convert to ECEF coordinates
x_k = x_k_prim*cos(Omega_k) -y_k_prim*cos(i_k)*sin(Omega_k);  % TBC
y_k = x_k_prim*sin(Omega_k) +y_k_prim*cos(i_k)*cos(Omega_k);  % TBC
z_k = y_k_prim*sin(i_k);  % TBC

% Put coordinates into vector
sp = [x_k, y_k, z_k];

end % function satpos

