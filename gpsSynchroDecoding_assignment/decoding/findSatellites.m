function [] = findSatellites()
%FINDSATELLITES Scans the data for the presence of satellites
%   FINDSATELLITES reads the data using the function GETDATA and saves
%   in file foundSat.mat the relevant parameters for the satellites it
%   finds.  It actually saves four row vectors; each vector has as many
%   elements as the number of visible satellites. The four vectors are:
%   'visible_sats', 'tau_vector', 'doppler_vector', 'Rmax_vector'. For
%   each visible satellite,
%   - 'visible_sats'
%              contains the number assigned to the visible satellites
%   - 'tau_vector'
%              contains the position of the sample that marks the
%              beginning of the first full C/A code within the data
%   - 'doppler_vector'
%              contains the Doppler (nu*f_c) for the visible satellites
%   - 'RMaxVector'
%              contains the inner product results between the CAcode
%              and corresponding chunk of data that accounts for tau
%              and Doppler estimates

% $Id: findSatellites.m 1196 2010-11-25 16:05:24Z jimenez $
% Created by Bixio and Stephane Nov. 2009

global gpsc; % declare gpsc as global, so we can access to it

% if gpsc has not been initialized yet, do it
if isempty(gpsc)
    gpsConfig();
end

function_mapper; % initializes function handles

% Number of satellites
num_sats = 39; % this is a safe number. There are actually less than 39 satellites.
num_sats_to_keep = 6; % how many sats we keep for computing the position % Nicolae


%% Coarse estimation of Doppler and delay

% initialize the matrices that will contain the intermediate search results
coarse_innerproducts = zeros(1, num_sats);
coarse_taus = zeros(1, num_sats);
coarse_dopplers = zeros(1, num_sats);
visible_sats = []; % we will fill this vector as we find visible satellites

coarse_doppler_step = 100; % [Hz]
% The rationale is that 100 Hz means 100 periods in one second,
% i.e., 0.1 periods in one millisecond, which is the length of a C/A code.

for sat = 1:num_sats % loop for satellite
    
    [coarse_dopplers(sat), coarse_taus(sat), coarse_innerproducts(sat)] = ...
        coarseEstimate(sat, coarse_doppler_step);
    
    fprintf(1, 'IP for satellite %d is (R = %.2f)\n', sat, coarse_innerproducts(sat));
    
end
% sort the list in decreasing order and take the first num_sats_to_keep sattelites
[~, index_sat] = sort(coarse_innerproducts, 'descend');
visible_sats = index_sat(1:num_sats_to_keep);
fprintf(1, 'We have selected the strongest IP satellites %s: \n', sprintf('%d ', visible_sats));



%% Refine estimation
% Refined Doppler search (only for those satellites that are visible)

refined_innerproducts = zeros(1, length(visible_sats));
refined_taus = zeros(1, length(visible_sats));
refined_dopplers = zeros(1, length(visible_sats));

fine_doppler_step = coarse_doppler_step/10;

% Header for the summary of results
fprintf(1, '\n\nSat R     fd       tau\n');
fprintf(1, '-----------------------\n');

for i = 1:length(visible_sats)
    sat_number = visible_sats(i);
    
    [refined_dopplers(i), refined_innerproducts(i)] = fineEstimate(sat_number, coarse_taus(sat_number), coarse_dopplers(sat_number), fine_doppler_step);
    refined_taus(i) = coarse_taus(sat_number);
    
    % Display results
    fprintf(1, '%3d %5.0f %8.2f %4d\n', sat_number, refined_innerproducts(i), refined_dopplers(i),  refined_taus(i));
end
fprintf(1, '\n');

%% Save or compare results

tau_vector = refined_taus;
doppler_vector = refined_dopplers;
Rmax_vector = refined_innerproducts; %#ok<NASGU>
% Nicolae, debug:
%findSatellites_debug = gpsc.store;
if gpsc.store
    % save the results in file foundSat.mat in the gpsc.resultsdir
    save(fullfile(gpsc.resultsdir, 'foundSat.mat'), 'visible_sats', 'tau_vector', 'doppler_vector', 'Rmax_vector');
else
    solution = load(fullfile(gpsc.datadir, 'foundSat.mat'));
    if ~isempty(setdiff(visible_sats, solution.visible_sats))
        error('Your list of detected satellites differs from the solution.');
    elseif ~isempty(setdiff(doppler_vector, solution.doppler_vector))
        error('Your Doppler frequencies differ from the solution.');
    elseif ~isempty(setdiff(tau_vector, solution.tau_vector))
        error('Your taus differ from the solution.');
    else
        fprintf(1, '%s: Successful.\n\n', mfilename());
    end
end
