function [doppler_estim, tau_estim, IP_result] = my_coarseEstimate(sat_number, doppler_step)
%COARSE_ESTIMATE Find coarse estimates of Doppler shift and delay in a GPS signal
%   [DOPPLER_ESTIM,TAU_ESTIM,IP_RESULT]=COARSE_ESTIMATE(SAT_NUMBER,DOPPLER_STEP)
%   Estimation is done correlating multiple repetitions (10 in our
%   case) of the C/A code for satellite SAT_NUMBER with the received
%   signal (to be read from disk using function GETDATA). DOPPLER_STEP,
%   specified in Hz, sets the resolution of the search grid for Doppler
%   estimation. The absolute Doppler search range to be considered is
%   obtained from the field 'dopplermax' of the global struct variable
%   'gpsc'.  Return value DOPPLER_ESTIM is the estimation of the
%   Doppler shift (fc*nu); TAU_ESTIM, in number of samples, specifies
%   where the first C/A code starts in the received signal (TAU_ESTIM
%   should be an integer smaller than gpsc.chpc*gpsc.spch) IP_RESULT is
%   the absolute value of the inner product between the appropriately
%   shifted version of multiple repetitions (10) of the C/A code for
%   satellite SAT_NUMBER and the Doppler corrected received signal.
%   (In FINDSATELLITES() the satellites will be ordered according to
%   the strength of their IP_RESULT)

global gpsc;
maxdoppler=gpsc.maxdoppler;

%get C/A code
ca=satCode(sat_number,'fs');
Lca=length(ca);
c=repmat(ca,1,10);



%we need two chuncks of data of length 11C/A - 1 samples each
Tstart1=1;
Tend1=11*Lca-1;
data1=getData(Tstart1, Tend1);

Tstart2=Tend1+1;
Tend2=Tstart2+11*Lca-2;
data2=getData(Tstart2, Tend2);

IP_result=0;
Lr=length(data1);

t=linspace(0,(Lr-1)/gpsc.fs,Lr);


for fcnu=-maxdoppler/2 : doppler_step : maxdoppler/2
    r1=data1.*exp(-1i*2*pi*fcnu*t);
    r2=data2.*exp(-1i*2*pi*fcnu*t);
    [val1,idx1]=max(abs(xcorr(r1,c)));
    [val2,idx2]=max(abs(xcorr(r2,c)));
    val=max([val1 val2]);
    if val>=IP_result
        IP_result=val;
        doppler_estim=fcnu;
        if val==val1
        idx=idx1;
        else idx=idx2;
        end 
        tau_estim=mod(idx-Lr,gpsc.chpc*gpsc.spch)+1;
    end
    
end
end
