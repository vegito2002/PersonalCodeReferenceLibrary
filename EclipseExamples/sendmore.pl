%
% ECLiPSe SAMPLE CODE
%
% AUTHOR:	Joachim Schimpf, IC-Parc
%
% DESCRIPTION:	Two versions of the famous SEND+MORE=MONEY puzzle
%

:- lib(ic).

sendmore1(Digits) :-
    Digits = [S,E,N,D,M,O,R,Y],
    Digits :: [0..9],
    alldifferent(Digits),
    S #\= 0,
    M #\= 0,
                 1000*S + 100*E + 10*N + D
               + 1000*M + 100*O + 10*R + E
    #= 10000*M + 1000*O + 100*N + 10*E + Y,
    labeling(Digits).


sendmore2(Digits) :-			% different model, with carries
    Digits = [S,E,N,D,M,O,R,Y],
    Digits :: [0..9],
    Carries = [C1,C2,C3,C4],
    Carries :: [0..1],
    alldifferent(Digits),
    S #\= 0,
    M #\= 0,
    C1         #= M,
    C2 + S + M #= O + 10*C1,
    C3 + E + O #= N + 10*C2,
    C4 + N + R #= E + 10*C3,
         D + E #= Y + 10*C4,
    labeling(Carries),
    labeling(Digits).

