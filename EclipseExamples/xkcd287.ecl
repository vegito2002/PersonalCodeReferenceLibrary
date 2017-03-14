%
% A small example solving the problem from the cartoon
% http://xkcd.com/287/
%

:- lib(ic).

solve(Amounts) :-
        Total = 1505,
        Prices = [215, 275, 335, 355, 420, 580],

        length(Prices, N),
        length(Amounts, N),
        Amounts :: 0..Total//min(Prices),
        Amounts * Prices #= Total,

        labeling(Amounts).

