% FUNCTION_MAPPER Initializes function handles so that different implementations of a function can be easily interchanged
% Comment/uncomment one line of every pair to choose between your implementation and the compiled solution

    hw3_plot_noiseless_eye = str2func('sol_plot_noiseless_eye');
   %  hw3_plot_noiseless_eye = str2func('plot_noiseless_eye');  % uncomment to use your solution

    hw3_eyediagram = str2func('sol_eyediagram');
   %  hw3_eyediagram = str2func('my_eyediagram');  % uncomment to use your solution

    hw3_qamMap = str2func('sol_qamMap');
%     hw3_qamMap = str2func('my_qamMap');  % uncomment to use your solution

    hw3_pskMap = str2func('sol_pskMap');
%     hw3_pskMap = str2func('my_pskMap');  % uncomment to use your solution

    hw3_encoder = str2func('sol_encoder');
%     hw3_encoder = str2func('my_encoder');  % uncomment to use your solution

    hw3_decoder = str2func('sol_decoder');
%     hw3_decoder = str2func('my_decoder');  % uncomment to use your solution

    hw3_symbols2samples = str2func('sol_symbols2samples');
%     hw3_symbols2samples = str2func('my_symbols2samples');  % uncomment to use your solution

    hw3_sufficientStatistics = str2func('sol_sufficientStatistics');
%     hw3_sufficientStatistics = str2func('my_sufficientStatistics');  % uncomment to use your solution

    hw3_bi2de = str2func('sol_bi2de');
%     hw3_bi2de = str2func('my_bi2de');  % uncomment to use your solution

    hw3_de2bi = str2func('sol_de2bi');
%     hw3_de2bi = str2func('my_de2bi');  % uncomment to use your solution
