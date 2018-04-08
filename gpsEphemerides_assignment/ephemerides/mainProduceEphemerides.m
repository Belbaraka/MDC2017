function [] = mainProduceEphemerides(satellites)
%MAINPRODUCEEPHEMERIDES Produces the ephemerides and pseudoranges for the visible satellites
%   MAINPRODUCEEPHEMERIDES(SATELLITES) loops over the vector of
%   integers SATELLITES, and processes the raw bits received from each
%   of these visible satellites to extract the ephemeris data and
%   compute the pseudorange For each integer in SATELLITES, the raw
%   bits are loaded from file bitsNN-long.mat in the 'data' directory,
%   where nn is the satellite number.  When called with no arguments,
%   the list of visible satellites to process is taken from file
%   'foundSat.mat' in the gpsc.datadir directory (this file is generated
%   by FINDSATELLITES) If the parity check is passed and the information
%   decoded succesfully, results for each satellite are saved in
%   <gpsc.datadir>/ephemerisAndPseudorangeNN.mat, and a list of correctly
%   decoded satellites is saved in <gpsc.datadir>/correct_sats.mat



close all; clear all;

% declare gpsc as global, and if it is not initialized, do it
global gpsc; 
if isempty(gpsc)
    gpsConfig();
end
gpsc.postfix = '-long';

function_mapper; % setup function handles

% Set default values if no list of satellites is given
if ((nargin < 1) || isempty(satellites))
    found = load(fullfile(gpsc.datadir, 'foundSat.mat'));
    satellites = found.visible_sats;
end    

correct_sats = []; % subset of visible satellites for which the parity check is correct
idx_firstBitSubframe = []; % idx to the first bit of subframe for each satellite correctly decoded
tau_firstBitSubframe = [];

% Process each visible satellite in a loop
indexSat = 1; % Nicolae: add a growing index which increases only for correct_sats
for sat = satellites
    sat
    % load the raw bits
    bits_filename = fullfile(gpsc.datadir, sprintf('bits%02d%s.mat', sat, gpsc.postfix));
    if exist(bits_filename, 'file')
        fprintf(1, 'Loading %s ...', bits_filename);
        aux = load(bits_filename);
        %fprintf(1, 'Taus: %d', aux.taus);
        
        % Nicolae: if the satellite lost sync, there could be less
        % bits than needed (7*300 + 300), so we discard the satellite
        if length(aux.decodedBits) < 2400
            fprintf('\n')
            warning('mainProduceEphemerides:notEnoughBits', 'Satellite %02d has only %d bits decoded, skipping\n', sat, length(aux.decodedBits));
            continue; % go on to process next satellite
        end
        
        
    else
        warning('mainProduceEphemerides:missingFile', 'File %s does not exist, skipping\n', bits_filename);
        continue; % go on to process next satellite
    end
    
    % filename for results
    ephemeris_filename = sprintf('ephemerisAndPseudorange%02d.mat', sat);
    
    
    % Nicolae: look for subframes [1 2 3] and align everything with
    % respect to the first satellite
    try
        [subframes, subframesIDs, idx] = getSubframes(aux.decodedBits);
        % If no error has been raised so far, we can add the current sat to the list of correctly decoded satellites
        correct_sats = [correct_sats, sat]; %#ok<AGROW>
        
        if indexSat == 1
            % for the first sat, get the index where the sequence of
            % subframes 1 2 3 starts
            currentSf = subframesIDs;
            sf123IDtmp = strfind(currentSf(2:end), [1 2 3]); % (start from 2nd element to account for the case where we just miss subframe 1 for some sats)
            sf123IDFirstSat = sf123IDtmp(1);
            idx = idx + gpsc.bpsf*(sf123IDFirstSat - 1 + 1); % move the index to the start of subframe no. 1
            ephemeris = readEphemeris(subframes(:,sf123IDFirstSat + [0 1 2] + 1));
            %ephemeris.t_tr = ephemeris.t_tr - 6*sf123IDFirstSat; % if the reference idx is set at 1st frame
            fprintf(1, 'Found first [1 2 3] group at position %i. Using subframes %s from positions %s.\n\n', sf123IDFirstSat+1, mat2str(currentSf(sf123IDFirstSat + [0 1 2] + 1)), mat2str(sf123IDFirstSat + [0 1 2] + 1));
            
        else
            % for the other ones, align with the first one
            currentSf = subframesIDs;
            sf123IDtmp = strfind(currentSf, [1 2 3]);
            sf123IDdiff = abs(sf123IDtmp - sf123IDFirstSat); % find the closest [1 2 3] sequence to the first sat reference
            [~, indexClosest] = min(sf123IDdiff);
            sf123ID = sf123IDtmp(indexClosest);
            idx = idx + gpsc.bpsf*(sf123ID - 1); % move the index to the start of subframe no. 1
            ephemeris = readEphemeris(subframes(:,sf123ID + [0 1 2]));
            %ephemeris.t_tr = ephemeris.t_tr - 6*(sf123ID-1); % if the reference idx is set at 1st frame
            fprintf(1, 'Found first [1 2 3] group at position %i. Using subframes %s from positions %s.\n\n', sf123ID, mat2str(currentSf(sf123ID + [0 1 2])), mat2str(sf123ID + [0 1 2]));
            
        end
        
        idx_firstBitSubframe = [idx_firstBitSubframe, idx]; %#ok<AGROW>
        tau_firstBitSubframe = [tau_firstBitSubframe, aux.taus(idx)]; %#ok<AGROW>
        indexSat = indexSat + 1;
        
        % store (or compare with solution) obtained ephemerides
        if gpsc.store
            save(fullfile(gpsc.resultsdir, ephemeris_filename), 'ephemeris');
            fprintf(1, 'Saved ephemeris for satellite %02d in file %s\n\n', sat, fullfile(gpsc.resultsdir, ephemeris_filename));
        else
            solution = load(fullfile(gpsc.datadir, ephemeris_filename));
            if (compare_ephemerides_structures(ephemeris, solution.ephemeris) == false)
                fprintf(2, 'Obtained ephemeris does not match the solution for satellite %02d\n', sat);
            else
                fprintf(1, 'Correct ephemeris for satellite %02d\n\n', sat);
            end
        end
        
    catch e  % Nicolae: If some predefined error, exit gracefully; rethrow other errors
        if (strcmp(e.identifier, 'LCM:NoStartSubframe'))
            fprintf(1, '\n');
            warning('LCM:NoStartSubFrame', 'Unable to find the start of a subframe, skipping satellite %02d\n', sat);
        elseif (strcmp(e.identifier, 'LCM:NotEnoughSubframes'))
            fprintf(1, '\n');
            warning('LCM:NotEnoughSubframes', 'Not enough subframes, skipping satellite %02d\n', sat);
        elseif (strcmp(e.identifier, 'establishParity:unsuccessful'))
            fprintf(1, '\n');
            warning('LCM:ParityCheckFailed', 'Parity Check Failed, skipping satellite %02d\n', sat);
        else
            fprintf(1, 'Unexpected error, will terminate.\n');
            rethrow(e);
        end
        
    end % try
    
end % for sat



% check or store list of correctly decoded satellites
if gpsc.store
    save(fullfile(gpsc.resultsdir, 'correct_sats.mat'), 'correct_sats');
    fprintf(1, 'Saved list of correctly decoded satellites to %s\n', fullfile(gpsc.resultsdir, 'correct_sats'));
else
    solution = load(fullfile(gpsc.datadir, 'correct_sats.mat'));
    if ((length(correct_sats) ~= length(solution.correct_sats)) || any(correct_sats ~= solution.correct_sats))
        fprintf(2, 'Your list of correctly decoded satellites differs from the solution, you may have done an error\n');
    end
end


% now compute the pseudoranges
tau_ref = min(tau_firstBitSubframe); % This is the receiver time for which the user position will be computed
% tau_ref = 1;                         % If we set this to one, we will compute the position when the receiver starts collecting data

for s = 1:length(correct_sats)
    
    sat = correct_sats(s);
    ephemeris_filename = sprintf('ephemerisAndPseudorange%02d.mat', sat);
    aux = load(fullfile(gpsc.datadir, sprintf('bits%02d%s.mat', sat, gpsc.postfix)));
    
    %pseudorange = computePseudorange(aux.taus, aux.nus, tau_ref, idx_firstBitSubframe(s));
    pseudorange = computePseudorange(aux.taus,  tau_ref, idx_firstBitSubframe(s));
    
    
    % check or store solution
    if gpsc.store
        save(fullfile(gpsc.resultsdir, ephemeris_filename), 'pseudorange', '-append');
        fprintf(1, 'Saved pseudorange for satellite %02d in file %s\n', sat, fullfile(gpsc.resultsdir, ephemeris_filename));
    else
        solution = load(fullfile(gpsc.datadir, ephemeris_filename));
        %    pseudorange-solution.pseudorange
        if (abs(solution.pseudorange - pseudorange)>1e-4)
            fprintf(2, 'Obtained pseudorange does not match the solution for satellite %02d\n', sat);
        else
            fprintf(1, 'Correct pseudorange for satellite %02d\n', sat);
        end
    end
    
end



end % function mainProduceEphemerides


function b = compare_ephemerides_structures(es1, es2)

% This function returns TRUE if the two ephemerides estructures are identical,
% otherwise it returns FALSE

b = true;
fn = fieldnames(es1);

% Convert both to cell
esc1 = struct2cell(es1);
esc2 = struct2cell(es2);

for k = 1:length(fn)
    if (esc1{k} ~= esc2{k})
        fprintf(2, '   ** Differing field: %s should be %d and it is %d\n', fn{k}, esc1{k}, esc2{k});
        b = false;
    end
end

end
