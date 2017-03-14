/*
    7.A farmer leaves 45 casks of wine, of which 9 each are full,
    three-quarters full, half full, one quarter full and empty.  His five
    nephews want to divide the wine and the casks without changing wine
    from cask to cask in such a way that each receives the same amount of
    wine and the same number of casks, and further so that each receives
    at least one of each kind of cask, and no two of them receive the same
    number of every kind of cask.  (Kraitchik)
*/

:- lib(ic).
:- lib(ic_global).
:- lib(matrix_util).

solve(Casks) :-

    % model

	matrix(5, 9, Sons, Cols),
	( foreach(Son, Sons) do
	    ordered(=<, Son),
	    sum(Son) #= 18		% Each son receives 18 units of wine
	),

	flatten(Sons, Casks),
	Casks :: 0..4,			% Casks contain 0..4 units

	( for(Units,0,4), param(Casks), param(Sons) do
	    occurrences(Units, Casks, 9),	% 9 casks of each type
	    ( foreach(Son, Sons), param(Units) do
		occurrences(Units, Son, Nunits), Nunits #>= 1
	    )
	),

	all_different_lists(Sons),

    % search

	( foreach(Col, Cols) do
	    ( foreach(Cask, Col) do
		indomain(Cask)
	    )
	),
	
	( foreach(Son, Sons) do		% print solution
	    writeln(Son)
	).


% auxiliary constraint definition

all_different_lists(Sons) :-
	( fromto(Sons, [Son1|Sons1], Sons1, []) do
	    ( foreach(Son2, Sons1), param(Son1) do
	    	Son1 ~= Son2
	    )
	).

