% FUNCTION_MAPPER Script to initialize function handles so that different implementations of a function can be easily interchanged
% Comment/uncomment one line of every pair to choose between your implementation and the compiled solution

% functions called from mainFindPosition

     rcvrpos = str2func('my_rcvrpos');   % uncomment to use your own implementation
    %  rcvrpos = str2func('sol_rcvrpos');  % uncomment to use the compiled solution

% functions called from rcvrpos:

     rotate_z = str2func('my_rotate_z');  % uncomment to use your own implementation
    %  rotate_z = str2func('sol_rotate_z'); % uncomment to use the compiled solution
      
      
       calcE = str2func('my_calcE');  % uncomment to use your own implementation
     % calcE = str2func('sol_calcE'); % uncomment to use the compiled solution
      
       calcDeltaT = str2func('my_calcDeltaT');  % uncomment to use your own implementation
      %calcDeltaT = str2func('sol_calcDeltaT'); % uncomment to use the compiled solution
      
     satpos =  str2func('my_satpos'); % uncomment to use your own implementation
    % satpos = str2func('sol_satpos'); % uncomment to use the compiled solution
