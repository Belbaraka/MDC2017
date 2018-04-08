function [lat, long, h] = my_rcvrpos(sat)
%RCVRPOS   Compute GPS receiver position in WGS84 coordinate system
%   [LAT, LONG, H] = RCVRPOS(SAT) returns the latitude, longitude and
%   altitude in the WGS-84 geodetic system of a GPS receiver. SAT is a
%   vector of at least four satellite numbers whose data is to be used. 
%   If SAT is not specified, a default set of satellites is loaded from
%   the list found in the file <gpsc.datadir>/correct_sats.mat

%   TBC: To Be Completed

global gpsc; % declare gpsc as global, so we can access to it

% if gpsc has not been initialized yet, do it
if isempty(gpsc)
    gpsConfig();
end

function_mapper; % initializes function handles

% Set default satellites if not specified
if (nargin < 1)
    correct = load(fullfile(gpsc.datadir, 'correct_sats.mat'));
    sat = correct.correct_sats;
else
    if numel(sat)<4
        error('rcvrpos:solve_rcvr_eq:NotEnoughSatellites', 'You need at least four satellites to compute the receiver position');
    end
end

% Compute satellite positions and pseudoranges at transmission times of
% first received subframe
sp = zeros(length(sat), 3); % Pre-allocation for satellite positions
rho_c = zeros(1, length(sat)); % Pre-allocation for corrected pseudoranges

for k = 1:length(sat)
    
    % Load ephemeris and pseudorange for k-th visible satellite
    filename = fullfile(gpsc.datadir, sprintf('ephemerisAndPseudorange%02d.mat', sat(k)));
    aux = load(filename);
    ephemeris = aux.ephemeris;
    pseudorange = aux.pseudorange;
    

    % Compute satellite clock offset 
    % From the ephemeris data, get the time t_s when the start of the reference subframe is supposed to be transmitted 
    % (in reality it is transmited at t_tr - delta_t_s)
    t_tr = ephemeris.t_tr; 

    % Since delta_t_s depends on E_k, and in turn we want to have E_k at a
    % time that depends on delta_t_s, we compute delta_t_s and E_k iteratively
    
    delta_t_s = 0;      % Our initial estimate of the offset
    time = t_tr-pseudorange/gpsc.C;
    t = time - delta_t_s; % Our initial estimate of the GPS time
    
    % The following loop updates the GPS time at each iteration considering the new delta_t_s
    % Stop when delta_t_s varies by less than 10^(-10)
    
    delta_t_s_tol = 1e-10;
    while true
        last_delta_ts = delta_t_s;
        E_k = calcE(ephemeris, t);
        delta_t_s = calcDeltaT(ephemeris, E_k, t);
    	            
        t = time - delta_t_s; % Correct time by satellite clock offset to get GPS time        
        if (abs(delta_t_s - last_delta_ts) < delta_t_s_tol)
            break; % no more iterations needed
        end        
    end  

    
    % Compute satellite position at GPS time t_tr - pseudorange(k)/c-delta_t_s,
    % in reference system ECEF(t_tr - pseudorange(k)/c-delta_t_s)
    sp(k, :) = satpos(ephemeris, t_tr-pseudorange/gpsc.C -delta_t_s);
    
    % Determine the corrected pseudorange from the pseudorange and the satellite clock offset
    rho_c(k) = gpsc.C*delta_t_s+pseudorange; % TBC

    % The next step corrects the ECEF position of the satellites to
    % express all of them in the same reference system. We choose ECEF(t_tr)
    anomalie=gpsc.Omega_dot_e*(rho_c(k)/gpsc.C);
    sp(k, :) = rotate_z(sp(k,:),-anomalie); % TBC

    
end % for k = 1:length(sat)

% Compute receiver position in ECEF(t_tr) by iteratively solving the equation system
[rp_ecef, b] = solve_rcvr_eq(sp, rho_c);

% b=t*-Delta_t_r-t_tr is the time difference between the time of flight at the receiver
% time t* and the corrected pseudorange (converted to a time dividing
% by the speed of light)
% b includes the effect of receiver clock offset (Delta_t_r)

% At this point we have the receiver position at t* in ECEF(t_tr). All
% need to do is to find  the position in ECEF(t*)
Omega_dot_e=gpsc.Omega_dot_e;

rp_ecef =rotate_z(rp_ecef,-Omega_dot_e*b);  % TBC

% Convert to WGS84
[long, lat, h] = ecef2wgs84(rp_ecef(1), rp_ecef(2), rp_ecef(3));

end % function rcvrpos()


function [rp, b] = solve_rcvr_eq(sp, rho_c)

% [RP, B] = SOLVE_RCVR_EQ(SP, RHO_C) solves the receiver position equation
% system, given the satellite position matrix SP and the corrected
% pseudorange vector RHO_C.
% The dimensions of SP are NUMSAT x 3, where NUMSAT is the number of
% visible and correctly decoded satellites; RHO_C is a row vector of NUMSAT
% elements
% Output RP is the receiver position
% Output B accounts for the receiver clock offset (and for the difference between the pseudoranges and the actual time of flight)

global gpsc;
% Compute number of satellites, raise an error if there are not enough satellites
numsat = size(sp, 1);
if (numsat < 4)
    error('rcvrpos:solve_rcvr_eq:NotEnoughSatellites', 'You need at least four satellites to compute the receiver position');
end

% Start with an initial guess
rp = zeros(1, 3);
b = 0;

% The idea is to use Newton's method for finding roots: x:f(x) = 0;
% Start with x_0 = 0, x_1 = x_0 - f(x_0)/f'(x_0), ..., x_n+1 = x_n -f(x_n)/f'(x_n)

% Since we have more equations (6) than unknowns (4), we will (almost) never
% find a solution for which f(x_sol) = 0.
% So we loop until the solution we find does not change much
e = inf;
d = inf;
f = 1000;
while (abs(e) > f) % stop if the norm of the solution does not change anymore
    
    g = zeros(numsat, 1);
    dg = zeros(numsat, 4);
    for k = 1:numsat
        g(k,:) = norm(sp(k,:) - rp) - (rho_c(k) + b); % this is f(x_k)
        dg(k,:) = [-(sp(k,:) - rp) / norm(sp(k,:) - rp), -1]; % this is the derivative, f'(x_k)
    end
    
    dub = -pinv(dg) * g; % solve for x the equation f'(x_k)(x-x_k) + f(x_k) = 0
    next = [rp, b] + dub.'; % x_k+1 = x_k - f(x_k)/f'(x_k)
    rp = next(1:3);
    b = next(4);
    
    e = d - norm(g); % stop if the norm of the solution does not change anymore
    d = norm(g);
end
% convert b to seconds
b=b/gpsc.C;

end % function solve_rcvr_eq()
