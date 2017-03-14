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

solve(Nephews) :-
	% For each nephew we have a list of 5 variables indicating
	% how many casks of each capacity he gets

	matrix(5, 5, Nephews, Caps),
	Capacities = [0,1,2,3,4],	% in quarters

	( foreach(Nephew, Nephews), param(Capacities) do
	    sum(Nephew) #= 9,		% Each nephew receives 9 casks
	    Nephew :: 1..9,		% and between 1 and 9 of each type
	    Nephew*Capacities #= 18	% Each nephew receives 18 units of wine
	),

	( foreach(Cap, Caps) do
	    sum(Cap) #= 9		% There are 9 casks of each type
	),

	strictly_ascending(Nephews),	% No permutations or duplicates


	( foreach(Cap, Caps) do		% search
	    ( foreach(Cask, Cap) do
		indomain(Cask)
	    )
	),
	
	( foreach(Nephew, Nephews) do	% print solution
	    writeln(Nephew)
	).


% Auxiliary constraint definition: this imposes a strict order on
% the Nephew-lists to implement the non-duplicate condition.
% It also removes symmetries as a useful side effect.

strictly_ascending(Vectors) :-
	( for(I,0,4), foreach(W, Weights) do
	    W is 9^I
	),
	( foreach(Vector, Vectors), foreach(VectorWeight, VectorWeights), param(Weights) do
	    Vector*Weights #= VectorWeight
	),
	ordered(<, VectorWeights).

