/*
    3.  A woman was carrying a basket of eggs to market when a passer-by
    bumped her.  She dropped the basket and all the eggs broke.  The
    passer-by, wishing to pay for her loss, asked, 'How many eggs were in
    your basket?'

    'I don't remember exactly,' the woman replied, 'but I do recall that
    whether I divided the eggs by 2,3,4,5 or 6 there was always one egg
    left over.  When I took the eggs out in groups of seven, I emptied the
    basket.'

    What is the least number of eggs that broke? (Kordemsky) 
*/

:- lib(ic).
:- lib(branch_and_bound).

solve :-
	Eggs #> 0,
	Eggs/7 #= _,
	(Eggs-1)/6 #= _,
	(Eggs-1)/5 #= _,
	(Eggs-1)/4 #= _,
	(Eggs-1)/3 #= _,
	(Eggs-1)/2 #= _,

	bb_min(labeling([Eggs]), Eggs, bb_options{strategy:step}),
	
	printf("Number of Eggs: %d\n", [Eggs]).

