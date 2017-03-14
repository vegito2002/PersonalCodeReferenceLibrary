/*
    5.  A side show at Coney Island is described as follows:  "There were
    ten little dummies which you were to knock over with baseballs.  The
    man said:  'Take as many throws as you like at a cent apiece and stand
    as close as you please.  Add up the numbers on all the men that you
    knock down and when the sum amounts to exactly fifty, neither more nor
    less you get a genuine 25 cent Maggie Cline cigar with a gold band
    around it.'"

    The numbers on the ten dummies were 15, 9, 30, 21, 19, 3, 12, 6, 25, 27.
    (Loyd) 
*/

:- lib(ic).
:- lib(branch_and_bound).

solve :-
	Numbers = [15, 9, 30, 21, 19, 3, 12, 6, 25, 27],

	length(Numbers, N),
	length(Vars, N),
	Vars :: 0..1,
	50 #= Vars*Numbers,
	Used #= sum(Vars),

	bb_min(labeling(Vars), Used, bb_options{strategy:step}),

	print_answer(Vars, Numbers).



print_answer(Vars, Numbers) :-
	( foreach(Var, Vars), foreach(Num, Numbers) do
	    ( Var==1 -> printf("%d ",[Num]) ; true )
	).
    
