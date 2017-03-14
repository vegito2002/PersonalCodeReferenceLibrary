/*
    8.  Place as few knights as possible on a chessboard in such a way
    that each square is controlled by at least one Knight, including the
    squares on which there is a Knight.  How would the formulation differ
    if occupied squares were not to be under attack?  (Schuh)

    [The following code requires ECLiPSe version 4 or later]
*/

:- lib(ic).
:- lib(branch_and_bound).

solve(N) :-
	M is N+4,			% add 2 dummy rows around the board
	dim(Board, [M,M]),

	( for(I,1,N+4), param(Board,N) do
	    ( for(J,1,N+4), param(Board,I,N) do
		( I >= 3, I =< N+2, J >= 3, J =< N+2 ->
		    Board[I,J] :: 0..1,		% proper square
		    threatened(Board, I, J)
		;
		    Board[I,J] #= 0		% dummy square
		)
	    )
	),
	term_variables(Board, Vars),
        Sum #= sum(Vars),
	bb_min((labeling(Vars),print_solution(Board,N)), Sum,
               bb_options{strategy:step}).

threatened(Board, I, J) :-
	Board[I-2,J-1] + Board[I-2,J+1] + Board[I+2,J-1] + Board[I+2,J+1] + 
	Board[I-1,J-2] + Board[I-1,J+2] + Board[I+1,J-2] + Board[I+1,J+2] #> 0.

print_solution(Board,N) :-
	( for(I,3,N+2), param(Board,N) do
	    ( for(J,3,N+2), param(Board,I) do
		Square is Board[I,J],
		printf("%3d", Square)
	    ),
	    nl
	).

