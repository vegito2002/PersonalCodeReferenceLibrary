/*
    1.  Twelve draught pieces are arranged in a square frame with four on
    each side.  Try placing them so there are 5 on each side.  (Kordemsky)

    Maybe this problem is not described very well but I wanted to stick
    with the original text from Kordemsky.  The problem may be stated in
    terms of guards on the wall of a square fort.  If a guard stands on a
    side wall then he may only watch that particular wall whereas a guard
    at a corner may watch two walls.  If twelve guards are positioned such
    that there are two on each side wall and one at each corner then there
    are four guards watching each wall.  How can they be rearranged such
    that there are five watching each wall? 
*/

:- lib(ic).

solve(Board) :-
	Board = [NW,N,NE,W,E,SW,S,SE],

	Board :: 0..12,
	sum(Board) #= 12,
	NW + N + NE #= 5,
	NE + E + SE #= 5,
	NW + W + SW #= 5,
	SW + S + SE #= 5,

	labeling(Board),

	printf("%3d%3d%3d\n", [NW,N,NE]),
	printf("%3d   %3d\n", [ W,   E]),
	printf("%3d%3d%3d\n", [SW,S,SE]).

