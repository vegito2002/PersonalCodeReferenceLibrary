/*
    9.  Three men who had a monkey bought a pile of mangoes.  At night one
    of the men came to the pile of mangoes while the others slept and,
    finding that there was just one more mango than could be exactly
    divided by three, tossed the extra mango to the monkey and took away
    one third of the remainder.  Then he went back to sleep. 

    Presently another of them awoke and went to the pile of mangoes.  He
    also found just one too many to be divided by three so he tossed the
    extra one to the monkey, took one third of the remainder, and returned
    to sleep. 

    After a while the third rose also, and he too gave one mango to the
    monkey and took away the whole number of mangoes which represented
    precisely one third of the rest. 

    Next morning the men got up and went to the pile.  Again they found
    just one too many, so they gave one to the monkey and divided the rest
    evenly.  What is the least number of mangoes with which this can be
    done?  (Kraitchik)
*/

:- lib(ic).
:- lib(branch_and_bound).

solve(N) :-
	(N -1)*2/3 #= N1,
	(N1-1)*2/3 #= N2,
	(N2-1)*2/3 #= N3,
	(N3-1)/3 #>= 1,
	bb_min(labeling([N]), N, bb_options{strategy:step}).
