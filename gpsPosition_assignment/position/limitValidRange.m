function t_out = limitValidRange(t_in)
%T_OUT = LIMITVALIDRANGE(T_IN) Correct ephemerides reference time to be in the range [-302400, 302400]
%   This subfunction adds or subtracts 604800 to limit the given time
%   to be in the interval [-302400, 302400] in accordance with the GPS
%   standard (see IS-GPS-200D Table 20-IV, p.97)

% $Id: limitValidRange.m 1176 2010-11-16 15:27:09Z jimenez $    

    t_out = t_in;

    if (t_in < -302400)
        t_out = t_out + 604800;
    end

    if (t_in > 302400)
        t_out = t_out - 604800;
    end

end % function limitValidRange
