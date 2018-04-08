% FUNCTION_MAPPER Initialize function handles so that different implementations of a function can be easily interchanged
% Comment/uncomment one line of every pair to choose between your implementation and the compiled solution

% functions called from findSatellites:

       coarseEstimate = str2func('my_coarseEstimate');
 %    coarseEstimate = str2func('sol_coarseEstimate'); % uncomment to use the compiled solution

      fineEstimate = str2func('my_fineEstimate'); 
     %fineEstimate = str2func('sol_fineEstimate'); % uncomment to use the compiled solution

% functions called from decodeSatellites:

       findFirstBit = str2func('my_findFirstBit');
 %  findFirstBit =  str2func('sol_findFirstBit'); % uncomment to use the compiled solution
    
       adjustDoppler = str2func('my_adjustDoppler');
 %   adjustDoppler = str2func('sol_adjustDoppler'); % uncomment to use the compiled solution
    
       adjustTau = str2func('my_adjustTau');
 %   adjustTau = str2func('sol_adjustTau'); % uncomment to use the compiled solution

       doInnerProductsBitByBit = str2func('my_doInnerProductsBitByBit');
  %  doInnerProductsBitByBit = str2func('sol_doInnerProductsBitByBit'); % uncomment to use the compiled solution
    
       innerProductsToBits = str2func('my_innerProductsToBits');
   % innerProductsToBits = str2func('sol_innerProductsToBits');  % uncomment to use the compiled solution
