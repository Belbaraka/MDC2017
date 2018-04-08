function [newTau, newDoppler] = adjustTauAndDoppler(sat_number, tau, doppler)
%ADJUSTTAUANDDOPPLER is called once in a while to update the estimates of tau and the Doppler
%   [NEWTAU, NEWDOPPLER] = ADJUSTTAUANDDOPPLER(SAT_NUMBER, TAU, DOPPLER)
%   will return the updated values NEWDOPPLER and the NEWTAU for the
%   satellite SAT_NUMBER, based on a search around the initial values
%   TAU AND DOPPLER

% $Id: adjustTauAndDoppler.m 1137 2010-10-13 15:46:16Z jimenez $
% Created by Bixio and Stephane Nov. 2009

function_mapper; % initialize the function handles

% Nicolae: extended from (-2:1:2)
deltaTau = (-10:1:10); % we search several points around the current tau

newTau = adjustTau(sat_number, tau, deltaTau, doppler);

% Now deal with the Doppler:
% The idea is to compute the inner product at three points, namely at the
% current Doppler estimate as well as fCorr Hz before and fCorr Hz
% after. We know (from experiments) that the top of the curve that plots
% the absolute value of the inner product as a function of the Doppler can
% be approximated by a second degree polynomial of the form ax^2+bx+c.
% Hence we find the coefficients of the second degree polynomial that goes
% through the calculated points. The value of x that corresponds to the
% maximum is then -b/(2a). 

fCorr = 20;
newDoppler = adjustDoppler(sat_number, newTau, doppler, fCorr);

end
