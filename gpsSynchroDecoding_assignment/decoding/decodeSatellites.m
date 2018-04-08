function [] = decodeSatellites()
%DECODESATELLITES Obtains the bits transmitted by the visible satellites
%   DECODESATELLITES() will read file "foundSat.mat" (created by
%   FINDSATELLITES()) to retrieve the list of visible satellites and
%   their relevant parameters (where the fist C/A code starts and the
%   Doppler shifts), and will decode and save the bits of each visible
%   satellite in a file called "bits<NN><gpsc.postfix>.mat" where NN is
%   the satellite number, and gpsc.postfix is a text string stored in
%   global variable gpsc and initialized by GPSCONFIG()

% Created by Bixio and Stephane Nov. 2009
% $Id: decodeSatellites.m 1543 2013-01-28 13:45:33Z tarniceriu $


global gpsc; % declare gpsc as global, so we can access to it

% if gpsc has not been initialized yet, do it
if isempty(gpsc)
    gpsConfig();
end

function_mapper; % sets up the function handles

maxNumberOfBits = 5000;   % Max number of bits to decode per satellite
numberOfBitsPerBlock = 5; % Interval during which the estimates of tau and nu are considered reliable, tracking required for larger blocks

% load the information needed to start decoding the visible satellites
aux = load(fullfile(gpsc.datadir, 'foundSat.mat'));
visible_sats   = aux.visible_sats;
tau_vector     = aux.tau_vector;
doppler_vector = aux.doppler_vector;
Rmax_vector    = aux.Rmax_vector;


% Nicolae: to store the doppler, to see how it varies across the data
store_doppler = zeros(length(visible_sats), maxNumberOfBits);

% process one visible satellite at a time
for sat = 1:length(visible_sats);
    %for sat = 1:1;
    
    
    % set the relevant variables for the satellite being considered
    sat_number = visible_sats(sat);
    doppler = doppler_vector(sat);
    tau = tau_vector(sat);
    
    % Display the initial estimates on the screen
    fprintf(1, 'Initial estimate for satellite %d\n', sat_number);
    fprintf(1, '  max R = %.0f\n', Rmax_vector(sat));
    fprintf(1, '  tau index = %d\n', tau);
    fprintf(1, '  fd = %.0f\n', doppler);
    
    % find the beginning of the first bit
    tau = findFirstBit(sat_number, doppler, tau);
    %%%% removed ;
    fprintf(1, 'Found first bit:\n');
    fprintf(1, '  sample position where the first bit starts = %d\n', tau);
    
    % initialize the variables to store the inner products, taus and nus
    bitwiseInnerProductResults = zeros(1, maxNumberOfBits);
    taus = zeros(1, maxNumberOfBits);
    nus =  zeros(1, maxNumberOfBits);
    
    nbits = 0; % number of decoded bits
    
    try % meant to catch the EndOfData
        
        initialPhi = 0;
        % it will keep track of the initial phase,
        % a compensation is needed since the complex exponential used to correct for the Doppler always starts with phase 0
        
        % make an infinite loop that will break when the end of data is reached
        while true
            
            % at the beginning of a new block adjust tau and Doppler
            [tau, doppler] = adjustTauAndDoppler(sat_number, tau, doppler);
            % Nicolae
            store_doppler(sat, nbits+1:nbits+numberOfBitsPerBlock) =  doppler;
            
            %%% removed ;
            
            %{
                % print the new values
                
                  fprintf(1, 'Adjust doppler and tau\n');
                  fprintf(1, '  tau index first bit new block = %d (=%d + %d * 20 * 4092)\n', tau, ...
                             mod(tau, gpsc.spch*gpsc.chpc*gpsc.cpb), ...
                             floor(tau / gpsc.spch/gpsc.chpc/gpsc.cpb));
                  fprintf(1, '  fd = %.0f\n', doppler);
            %}
            
            % Do the inner product
            [newBitwiseInnerProduct, initialPhi] = doInnerProductsBitByBit(numberOfBitsPerBlock, sat_number, doppler, tau, initialPhi);
            bitwiseInnerProductResults(nbits + 1:nbits + length(newBitwiseInnerProduct)) = newBitwiseInnerProduct; % append the newly decoded bits
            
            % Append the corresponding taus: the first value is tau, the remaining values need to be computed using the duration of a bit.
            bit_duration = gpsc.cpb * gpsc.chpc * gpsc.spch / (1 + doppler/gpsc.fc); % bit duration at the receiver (in multiples of gpsc.Ts) % 20 * 1023 * 4 % \nu = Doppler/fc
            taus(nbits+1 : nbits + length(newBitwiseInnerProduct)) = ...
                tau + bit_duration * (0: 1: numberOfBitsPerBlock-1);
            
            nus(nbits+1: nbits + length(newBitwiseInnerProduct)) = doppler/gpsc.fc;
            
            % update the counter of bits
            nbits = nbits + length(newBitwiseInnerProduct);
            
            % update tau to be ready for the next block
            tau = tau + round(numberOfBitsPerBlock * bit_duration);
            
        end % while true
        
    catch e % If end of data was reached, exit gracefully; rethrow other errors
        %fprintf(1,'Debug: the error identifier is: %s.\n', e.identifier); % Nicolae
        if (strcmp(e.identifier, 'LCM:EndOfData'))
            fprintf(1, 'Reached the end of the data\n');
        elseif (strcmp(e.identifier, 'LCM:SyncLost'))
            % fprintf(1, 'Lost sync of satellite %02d, continue with the next satellite.\n', sat_number); % commented out by Nicolae
            warning('LCM:SkipSat', 'Lost sync of satellite %02d, continuing with the next satellite...', sat_number); % Nicolae
        else
            fprintf(1, 'Unexpected error, will terminate.\n');
            rethrow(e);
        end
        
    end % try
    
    % cut away the tail that contains no info
    bitwiseInnerProductResults = bitwiseInnerProductResults(1:nbits);
    taus = taus(1:nbits); %#ok<NASGU>
    nus = nus(1:nbits); %#ok<NASGU>
    
    % decode the bits by calling a function that looks at the change of phase.
    decodedBits = innerProductsToBits(bitwiseInnerProductResults);
    
    if gpsc.store
        % save the results to disk
        filename = fullfile(gpsc.datadir, sprintf('bits%02d%s.mat', sat_number, gpsc.postfix));
        save(filename, 'decodedBits', 'taus', 'nus');
    else
        % compare the results obtained with those stored in disk
        filename = fullfile(gpsc.datadir, sprintf('bits%02d%s.mat', sat_number, gpsc.postfix));
        solution = load(filename);
        if ((sum(decodedBits ~= solution.decodedBits) == 0) || (sum(decodedBits ~= -solution.decodedBits) == 0))
            fprintf(1, 'Successfuly decoded satellite %d.\n', sat_number);
        else
            fprintf(1, 'The vector of bits obtained for satellite %d differs from the solution, you may have done an error.\n', sat_number);
        end
    end
    
    fprintf(1, 'Decoded %d bits\n', nbits);
    fprintf(1, '---------------\n');
    
end % for sat

% Nicolae: to plot the Doppler uncomment:
%{
    figure;
    for j = 1:length(visible_sats)
        plot(store_doppler(j,:));
        hold on;
        grid on;
    end
%}

end % function decodeSatellites
