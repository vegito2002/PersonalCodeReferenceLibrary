/*
    11.  Is there a number which when divided by 3 gives a remainder of 1;
    when divided by 4, gives a remainder of 2; when divided by 5, gives a
    remainder of 3; and when divided by 6, gives a remainder of 4? 
    (Kordemsky)
*/

:- lib(ic).

solve(X) :-
	X #> 0,
	X #= A*3 + 1,
	X #= B*4 + 2,
	X #= C*5 + 3,
	X #= D*6 + 4,
	labeling([X,A,B,C,D]).
