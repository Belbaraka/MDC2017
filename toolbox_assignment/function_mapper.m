% FUNCTION_MAPPER Initializes function handles so that different implementations of a function can be easily interchanged
% Comment/uncomment one line of every pair to choose between your implementation and the compiled solution


   %   hw2_qamMap = str2func('sol_qamMap');
     hw2_qamMap = str2func('my_qamMap');  % uncomment to use your solution

    %hw2_pskMap = str2func('sol_pskMap');
     hw2_pskMap = str2func('my_pskMap');  % uncomment to use your solution

    %hw2_encoder = str2func('sol_encoder');
     hw2_encoder = str2func('my_encoder');  % uncomment to use your solution

   % hw2_decoder = str2func('sol_decoder');
     hw2_decoder = str2func('my_decoder');  % uncomment to use your solution

  %  hw2_symbols2samples = str2func('sol_symbols2samples');
  hw2_symbols2samples = str2func('my_symbols2samples');  % uncomment to use your solution

   % hw2_sufficientStatistics = str2func('sol_sufficientStatistics');
     hw2_sufficientStatistics = str2func('my_sufficientStatistics');  % uncomment to use your solution

    hw2_bi2de = str2func('sol_bi2de');
%     hw2_bi2de = str2func('my_bi2de');  % uncomment to use your solution

    hw2_de2bi = str2func('sol_de2bi');
%     hw2_de2bi = str2func('my_de2bi');  % uncomment to use your solution
