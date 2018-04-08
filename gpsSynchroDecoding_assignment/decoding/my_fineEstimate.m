function [doppler_estim, IP_result] = my_fineEstimate(sat_number, coarse_tau, coarse_doppler, doppler_step)
%FINE_ESTIMATE Refine estimates of the Doppler shift in a GPS signal
%   [DOPPLER_ESTIM_F,IP_RESULT]=FINE_ESTIMATE(SAT_NUMBER,TAU_ESTIM,
%     DOPPLER_ESTIM_C,DOPPLER_STEP)
%   Improve the estimation of the Doppler shift corresponding to
%   satellite SAT_NUMBER doing a refined search around the coarse
%   estimate DOPPLER_ESTIM_C, by doing inner products (rather than
%   correlations) with multiple repetitions of its C/A code (In our
%   case the number of repetitions is 10) TAU_ESTIM is the estimation
%   obtained from COARSE_ESTIMATE(). The search grid for the estimation
%   is centered around DOPPLER_ESTIM_C and its resolution (in Hz)
%   is given by DOPPLER_STEP. The search range is COARSE_ESTIMATE +
%   20*DOPPLER_STEP*[-1 1]. The outputs of the function are an improved
%   estimation DOPPLER_ESTIM_F of the Doppler shift and the absolute
%   value of the inner product between the repeated C/A code appropriately
%   shifted and the Doppler corrected received signal.


global gpsc;

%C/A code
ca=satCode(sat_number,'fs');
Lca=length(ca);
c=repmat(ca,1,10);


Tstart1=coarse_tau;
Tend1=Tstart1+10*Lca-1;
data1=getData(Tstart1,Tend1);

Tstart2=Tend1+1;
Tend2=Tstart2+10*Lca-1;
data2=getData(Tstart2, Tend2);


Lr=length(data1);
t=linspace(0,(Lr-1)/gpsc.fs,Lr);


%range search
minr=-20*doppler_step+coarse_doppler;
maxr=20*doppler_step+coarse_doppler;

IP_result=0;



for fcnu=minr : doppler_step : maxr
    r1=data1.*exp(-1i*2*pi*fcnu*t);
    r2=data2.*exp(-1i*2*pi*fcnu*t);
    val1=abs(sum(r1.*c));
    val2=abs(sum(r2.*c));
    val=max([val1 val2]);
    if val>IP_result
        IP_result=val;
        doppler_estim=fcnu;
        
    end
    
end

end




