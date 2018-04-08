function newTau = my_adjustTau(sat_number, tau, deltaTau, doppler)
%ADJUSTTAU Uses the current estimates of tau and Doppler to adjust tau
%   NEWTAU = ADJUSTTAU(SAT_NUMBER, TAU, DELTATAU, DOPPLER) Integer
%   SAT_NUMBER specifies the satellite we want to track. TAU is the
%   current estimate of the sample corresponding to the beginning of
%   the next unprocessed bit. DELTATAU is a vector of candidate taus
%   around the current tau estimate to be considered in the optimization
%   (for instance, DELTATAU = (-2:1:2) to look at two samples before and
%   two samples ahead of the current estimate). DOPPLER is the current
%   estimate of the Doppler frequency. The returned value NEWTAU will
%   be in the range [TAU+min(DELTATAU), TAU+max(DELTATAU)] The new tau
%   is estimated by correlating the received signal with 20 repetitions
%   of the C/A code (the code that forms one bit).


global gpsc;
fs=gpsc.fs;

CA=satCode(sat_number,'fs');
Lca=length(CA);
rCA=repmat(CA,1,20);
Ld=length(deltaTau);

IPmax=0;

t=linspace(tau,(20*Lca-1)/fs+tau,20*Lca);
corr=exp(-1i*2*pi*doppler*t);
for i=1:Ld
    Tstart=tau+deltaTau(i);
    Tend=Tstart+20*Lca-1;
    r=getData(Tstart,Tend);
  
    r=r.*corr;
    val=abs(sum(r.*rCA));
    if(IPmax<val)
        IPmax=val;
        newTau=Tstart;
    end
end
