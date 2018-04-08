function s = my_establishParity(ws)
%ESTABLISHPARITY Checks the parity of the GPS words 
%   S = ESTABLISHPARITY(WS) checks the parity of the subframe sequence
%   WS and flips the first 24 bits if the last bit of the previous
%   word is 1. The result is S. (The last two bits of each subframe
%   are 0 by convention.) If the parity check fails, a warning is
%   issued; otherwise a message indicating success is displayed. Both
%   the input WS and the output S are binary (0 and 1) row vectors
%   containing a multiple of subframes.


    % declare gpsc as global, and if it is not initialized, do it
    global gpsc;
    if isempty(gpsc)
        gpsConfig();
    end	

    % Parity check matrix (cf. GPS standard)
    H = [...
        1 0 1 0 1 0 % d1
        1 1 0 1 0 0 % d2 
        1 1 1 0 1 1 % ...
        0 1 1 1 0 0
        1 0 1 1 1 1
        1 1 0 1 1 1
        0 1 1 0 1 0
        0 0 1 1 0 1
        0 0 0 1 1 1
        1 0 0 0 1 1
        1 1 0 0 0 1
        1 1 1 0 0 0
        1 1 1 1 0 1
        1 1 1 1 1 0
        0 1 1 1 1 1
        0 0 1 1 1 0
        1 0 0 1 1 0
        1 1 0 0 1 0
        0 1 1 0 0 1
        1 0 1 1 0 0
        0 1 0 1 1 0
        0 0 1 0 1 1
        1 0 0 1 0 1
        0 1 0 0 1 1 % d24
        1 0 1 0 0 1 % D29*
        0 1 0 1 1 0 % D30*
        ];
    % Other needed parameters
    BPW = 30;             % Bits per word
    DBPW = 24;            % Databits per word

    % Check parameter validity
    nsf = length(ws) / gpsc.bpsf;
    if nsf ~= floor(nsf)
        error('WS must contain a multiple of subframes');
    end

    % Total number of words
    nw = nsf * gpsc.wpsf;

    % Flag to indicate whether parity check passed. Set this to false if you
    % detect a parity error somewhere. 
    passed = true;

    % COMPLETE THE ALGORITHM HERE
    % Note: For the first word of WS, you can assume that D29* and D30* are
    % zero (The last two bits of each subframe are 0 by convention.)
    % ...
    
    D29=0;
    D30=0;
    for i=1:nw
        wstart=(i-1)*BPW+1;
        wend=wstart+BPW-1;
        if(D30==1)
            ws(wstart:wstart+DBPW-1)=1-ws(wstart:wstart+DBPW-1);
        end
        
        
        synd=mod([ws(wstart:wstart+DBPW-1) D29 D30]*H+ws(wstart+DBPW:wend),2);
        
        if nnz(synd)~=0
            passed=false;
        end
        D29=ws(wend-1);
        D30=ws(wend);
    end
    
    s=ws;
    
    
    % ...
       
    % Display a warning if there was an error
    if ~passed
        error('establishParity:unsuccessful', 'Parity check failed.');
    else
         fprintf(1, 'Parity check passed\n');
    end
