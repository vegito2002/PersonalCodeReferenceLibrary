/*
     A B C D
     E F G H
     I J K L
     M N O P

    Each of the squares in the above grid can be in one of two states,
    lit(white) or unlit(red).  If the player clicks on a square then that
    square and all squares in the same row and column will toggle between
    the two states.  Each mouse click constitutes one move and the objective
    of the puzzle is to light all 16 squares in the least number of moves. 
*/

:- lib(ic).
:- lib(branch_and_bound).
:- lib(matrix_util).

solve(SquaresClicked) :-

	initial_state(InitRows),

	matrix(4, 4, Rows, Cols),

	flatten(Rows, SquaresClicked),
	SquaresClicked :: 0..1,

	% To toggle a square's state, an odd number of neighbours must
	% be clicked. If square is already on, click an even number.
	( foreach(Row, Rows), foreach(InitRow, InitRows), param(Cols) do
	    ( foreach(Col, Cols),
	      fromto(Row, [X|RowTail], RowTail, []),
	      fromto([], RowHead, [X|RowHead], _ReversedRow),
	      foreach(InitX, InitRow)
	    do
		sum(Col) + sum(RowHead) + sum(RowTail) #= 2*_ + 1 - InitX
	    )
	),

	NClicks #= sum(SquaresClicked),
        bb_min(labeling(SquaresClicked), NClicks, bb_options{strategy:step}),
	
	( foreach(Row, Rows) do
	    writeln(Row)
	).


initial_state([		% sample initial state
    [1,1,0,1],
    [0,0,0,1],
    [1,1,1,1],
    [0,0,0,1]
]).
