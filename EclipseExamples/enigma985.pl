/*
    Enigma 985 by Colin Singleton (New Scientist 27/6/98)

    George has invested his savings in gold - a circular chain of eight
    linked gold rings.  The rings are all different sizes, although
    each is a whole number of ounces in weight - the total is 57
    ounces.
    The chain has been designed so that the first time that George
    wishes to sell some of his gold, he can remove any whole number of
    ounces from the chain, either as a single link, or as a chain of
    linked rings.
    Given that there is no 3-ounce ring, nor a 6-ounce ring, list the
    weights of the eight rings in order, starting with the two smallest.

    ECLiPSe solution by Joachim Schimpf, IC-Parc
*/

:- lib(ic).

solve(ChainList) :-
	length(ChainList, 8),
	ChainList :: [1..2,4..5,7..57],		% the possible weights
	ChainList = [1|_],			% fix position of weight 1 ring
	Sum8 #= sum(ChainList),			% weight of the whole chain

	% now make a list Totals of all subchain weights
	ChainArray =.. [chain|ChainList],
	(
	    for(Length,1,7),
	    fromto([Sum8], Totals0, Totals1, Totals),
	    param(ChainArray)
	do
	    (
		for(First,1,8),
		fromto(Totals0, Totals2, [Total|Totals2], Totals1),
		param(Length,ChainArray)
	    do
		% subchain starting at First, length Length
		(
		    for(I, First, First+Length-1),
		    fromto(0, Sum0, Sum0 + RingWeight, Sum),
		    param(ChainArray)
		do
		    RingWeight = ChainArray[((I-1) mod 8) + 1]
		),
		Sum #= eval(Total)			% weight of this subchain
	    )
	),

	Totals :: 1..57,
	alldifferent(Totals),
	alldifferent(ChainList),
	ChainArray[2] #< ChainArray[8],		% exclude symmetric solution

        search(ChainList, 0, first_fail, indomain, complete, []).
