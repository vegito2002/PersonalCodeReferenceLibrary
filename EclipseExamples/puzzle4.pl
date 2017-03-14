/*
    4.  Take 16 coins and put them in four rows of four each.  Remove 6
    leaving an even number of coins in each row and each column.(Kordemsky)
*/

:- lib(ic).
:- lib(matrix_util).

solve(Rows) :-
	matrix(4, 4, Rows, Cols),
	concat(Rows, Coins),
	Coins :: 0..1,
	sum(Coins) #= 10,
	( foreach(Row, Rows) do sum(Row) #= 2*_ ),
	( foreach(Col, Cols) do sum(Col) #= 2*_ ),

	labeling(Coins), 

	( foreach(Row, Rows) do writeln(Row) ).

