function x = getData(a, b)
%GET_DATA Access stored GPS samples
%   X = GET_DATA(A,B) returns a vector containing GPS samples, starting
%   at index A and ending at index B. The length of the returned vector
%   is thus B - A + 1.

% $Id: getData.m 1383 2011-12-19 15:04:40Z tarniceriu $


global gpsc; % Declare gpsc as global, so we can access the GPS configuration parameters
if isempty(gpsc)
    gpsConfig();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Path to the directory containing the data files
DATADIR = gpsc.datadir;


% Samples per file
SPF = gpsc.spf;

% Where to write log messages (use 'stdout' for standard output,
% '/dev/null' for no output)
%LOGFILE = '/dev/null';
LOGFILE = 'stdout';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Persistent variables (declaration)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data cache array. This will contain the data loaded from disk
persistent cache_cur cache_prev;

% Remember which chunks we have in the cache
persistent cache_cur_chunk cache_prev_chunk;

if isempty(cache_cur_chunk)
    cache_cur_chunk = 0;
end
if isempty(cache_prev_chunk)
    cache_prev_chunk = 0;
end

% Index of first and last sample that is in the cache
persistent start_cur start_prev;

% Keep track of the size of the final block
persistent final_block;

if isempty(final_block)
    final_block = 0;
end

% Initialize the file descriptor for logging

if strcmpi(LOGFILE, 'stdout')
    fid = 1;
elseif strcmpi(LOGFILE, 'stderr')
    fid = 2;
else
    fid = fopen(LOGFILE, 'a');
    if (fid == -1)
        error('Could not open logfile %s for writing', LOGFILE);
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main part
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First let's check a few things. It is not possible to read before the
% first sample in the cache, and it isn't possible either to access a
% sample that is past the next data file.
if a > b
    error('Starting index must be smaller than or equal to the end index');
end

% In which chunks are the endpoints of the data we want?
achunk = ceil(double(a)/SPF);
bchunk = ceil(double(b)/SPF);

if (bchunk - achunk) > 1
    error('Requested data range is too large');
end

%Now that the argument seem to be valid, we can do the actual job. 

% NOTE
% How files are loaded into the cache is still optimised for sequential
% reading. Note how cache_prev is wiped below in certain circumstances

% b should always be in cur_chunk or prev_chunk
if (bchunk ~= cache_cur_chunk && bchunk ~= cache_prev_chunk)
    % We need to load a new chunk

    % Check if this is a sequential read
    if (bchunk == cache_cur_chunk+1)
        cache_prev_chunk = cache_cur_chunk;
        cache_prev = cache_cur;
        start_prev = start_cur;
    else
        % This isnt sequential, discard the prev
        cache_prev_chunk = 0;
        cache_prev = [];
        start_prev = [];
    end

    % Load the file
    if ~exist(mkfn(bchunk,DATADIR),'file')
        error('LCM:EndOfData', 'End of data was reached');
    end

    fprintf(fid, 'Loading %s...', mkfn(bchunk, DATADIR));
    aux = load(mkfn(bchunk, DATADIR));
    toto = aux.toto; % Nicolae
    fprintf(fid, 'done.\n');

    final_block = 0;
    % Bail if the loaded block is not of the size we expect
    if (numel(toto) ~= SPF)
        % We dont have sPF samples in this block, allowed if this is the
        % final block
        if (exist(mkfn(bchunk+1,DATADIR),'file'))
            error('LCM:MalformedData', 'File %s did not contain the correct number of samples', mkfn(achunk, DATADIR))
        else
            % This is the final block, and keep track of how many samples
            % we have in it
            final_block = numel(toto);
        end

    end

    % Store in current cache
    cache_cur = transpose(toto);
    cache_cur_chunk = bchunk;

    % Update index
    start_cur = (bchunk-1)*SPF + 1;
end

% We now have the correct end chunk loaded. Load the previous one if we
% need it

% We have already verified achunk fits out constraints at this point. It is
% valid and is not less than one smaller than bchunk
if (achunk ~= bchunk && achunk ~= cache_prev_chunk)
    % Load achunk
    fprintf(fid, 'Loading %s...', mkfn(achunk, DATADIR));
    load(mkfn(achunk, DATADIR));
    fprintf(fid, 'done.\n');

    % Bail if the loaded block is not of the size we expect
    if (numel(toto) ~= SPF)
        error('LCM:MalformedData', 'File %s did not contain the correct number of samples', mkfn(achunk, DATADIR))
    end

    % Store in current cache
    cache_prev = transpose(toto);
    cache_prev_chunk = achunk;

    % Update index
    start_prev = (achunk-1)*SPF + 1;

end

% We now have the correct chunks in memory. Return what was asked for


% Work out which bits we want
prev_chunk_ind = [];
cur_chunk_ind = [];

if (a < start_cur)
    prev_chunk_ind = a-start_prev+1: min(SPF,b-start_prev+1);
end
if (b >= start_cur)
    cur_chunk_ind = max(1,a-start_cur+1):b-start_cur+1;
end

% If we are asking for something past the end of the data, produce an error
if (final_block > 0 && b-start_cur+1 > final_block)
    error('LCM:EndOfData', 'End of data was reached');
end

x = [ cache_prev(prev_chunk_ind) cache_cur(cur_chunk_ind) ];

% Close logfile (unless fid is set to stdout or stderr)
if (fid ~= 1 && fid ~= 2)
    fclose(fid);
end

end

% This function returns the filename corresponding to a data file number
function f = mkfn(n, d)

    f = sprintf('%s/%02d.mat', d, n);
    

end
