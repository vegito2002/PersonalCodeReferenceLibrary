/*
    Enigma 1000 by Richard England (New Scientist 10/10/98)

    ENIGMA / M = TIMES
    Each letter stands for a different digit.
    No number starts with zero.

    ECLiPSe solution by Joachim Schimpf, IC-Parc
*/

:- lib(ic).

solve(Letters) :-
	Letters = [E,N,I,G,M,A,T,S],
	Letters :: 0..9,
	E #\= 0, M #\= 0, T #\= 0, 
	alldifferent(Letters),
	100000*E + 10000*N + 1000*I + 100*G + 10*M + A
	    #= M * (10000*T + 1000*I + 100*M + 10*E + S),
	labeling(Letters).
