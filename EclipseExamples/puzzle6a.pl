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
:- lib(ic_global).

solve(Barrels) :-
	% For each son, we have a list of 7 variables (one per barrel)
	% whose values indicate their filling degree (0,1,2)

	length(Son1, 7),	% Each son receives 7 barrels (containers)
	length(Son2, 7),
	length(Son3, 7),
	Sons = [Son1,Son2,Son3],

	flatten(Sons, Barrels),
	Barrels :: 0..2,	% Barrels contain 0,1 or 2 units of honey
	occurrences(0, Barrels, 7),	% And there are 7 of each type
	occurrences(1, Barrels, 7),
	occurrences(2, Barrels, 7),

	( foreach(Son, Sons) do
	    sum(Son) #= 7,	% Each son gets 7 half-barrel units of honey
				% And at most 4 barrels of each type
	    occurrences(0, Son, Nempty), Nempty #=< 4,
	    occurrences(1, Son, Nhalf),  Nhalf  #=< 4,
	    occurrences(2, Son, Nfull),  Nfull  #=< 4,
	    ordered(=<, Son)	% This condition removes symmetric solutions
	),

	labeling(Barrels),
	
	( foreach(Son, Sons) do
	    writeln(Son)
	).

