function E_k= my_calcE(ephdata, t)
%CALCE Obtain the satellite eccentric anomaly
%   E_k = calcE(ephdata, t)
%
%   ephdata: Ephemeris data of the satelite
%   E_k: eccentric anomaly
%   t: the GPS time for which we want to determine DeltaT
%
%   To determine E_k, we need the formulas given in Table 20.IV
%   (sheets 1 and 2), pp. 97-98 of the GPS standard document (Section
%   20.3.3.3.3.1)

%   TBC: To Be Completed

global gpsc; % declare gpsc as global, so we can have access to it

if isempty(gpsc)
    gpsConfig();
end


%Load data from ephdata for easier use (less messy code)
a_s         = ephdata.sqrt_a ^ 2; % Semimajor axis
delta_n     = ephdata.delta_n;    % Correction for mean motion
M_0         = ephdata.M_0;        % Mean anomaly at reference time
t_oe        = ephdata.t_oe;       % Ephemeris reference time
e           = ephdata.e;          % Orbit ellipse eccentricity
mu_e = gpsc.mu_e;

% Mean motion and corrected mean motion
n_0 = sqrt(mu_e/a_s.^3); % TBC
n = n_0 + delta_n; % TBC

% Compute time since reference time and limit it to the correct range
t_k = limitValidRange(t - t_oe);

% Mean anomaly
M_k = M_0 +n* t_k;% TBC

% Iterative algorithm to obtain eccentric anomaly E_k
% We need to solve M_k = E_k - e * sin(E_k) for E_k; since there is no
% analytic solution we use the iterative algorithm seen in class.
E_tolerance = 1e-14;

%%% TBC:STARTBLOCK

E_k=M_k;
tolerance=1;
while (tolerance>E_tolerance)
    E_k1=M_k+e*sin(E_k);
    tolerance=abs(E_k-E_k1);  
    E_k=E_k1;
end



%%% TBC:ENDBLOCK


end % function calcE



