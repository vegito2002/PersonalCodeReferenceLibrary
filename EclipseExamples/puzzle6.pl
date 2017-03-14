/*
    6.  Once upon a time there was an aged merchant of Baghdad who was
    much respected by all who knew him.  He had three sons, and it was a
    rule of his life to treat them all exactly alike.  Whenever one
    received a present, the other two were each given one of equal value. 
    One day this worthy man fell sick and died, bequeathing all his
    possessions to his three sons in equal shares. 

    The only difficulty that arose was over the stock of honey.  There
    were exactly twenty-one barrels.  The old man had left instructions
    that not only should every son receive an equal quantity of honey, but
    should receive exactly the same number of barrels, and that no honey
    should be transferred from barrel to barrel on account of the waste
    involved.  Now, as seven of these barrels were full of honey, seven
    were half full, and seven were empty, this was found to be quite a
    puzzle, especially as each brother objected to taking more than four
    barrels of the same description - full, half full, or empty. 

    Can you show how they succeeded in making a correct division of the
    property?  (Dudeney)
*/

:- lib(ic).
:- lib(matrix_util).

solve(Sons) :-
	% For each son we have a list of 3 variables indicating
	% how many empty, half and full barrels he gets

	matrix(3, 3, Sons, Caps),
	Capacities = [0,1,2],		% half barrel units

	( foreach(Son, Sons), param(Capacities) do
	    sum(Son) #= 7,		% Each son receives 7 barrels in total
	    Son :: 0..4,		% and no more than 4 of each type
	    Son*Capacities #= 7		% Each son gets 7 units of honey
	),

	( foreach(Cap, Caps) do
	    sum(Cap) #= 7		% There are 7 barrels of each capacity
	),

	flatten(Sons, Variables),
	labeling(Variables),
	
	( foreach(Son, Sons) do
	    writeln(Son)
	).

