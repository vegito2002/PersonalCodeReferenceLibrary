/*
    Enigma 995 by Susan Denham (New Scientist 5/9/98)

              This is the layout of the digit buttons on my telephone.
    1 2 3     My boss's telephone number uses each of the ten digits
    4 5 6     once and it starts with 0. Furthermore each pair of
    7 8 9     adjacent digits is also adjacent (horizontally, vertically
      0       or diagonally) on the telephone keyboard. (By coincidence
              my own number, 0895632147, has the same properties.)
    I have just looked through my boss's telephone number and written
    down a list of all the two-figure numbers that can be seen in it
    by reading a pair of adjacent digits (which would be 89, 95, 56... 
    in my number).  In that list, some of the numbers are special in
    that they consist of two digits which are also consecutive (such
    as 89, 56, 32 and 21 in my number).  I have worked out the product
    of those special numbers and it is the year in which my boss will
    be 50.  And if I look at the number of the year in which she was
    born, no two adjacent digits are adjacent (either way round) in
    her telephone number.  What is her telephone number?
*/

/*
    ECLiPSe solution by Joachim Schimpf, IC-Parc
    Note that there is an implicit assumption that the boss is not very
    young: there are a couple of solutions with a birth year of 1997 :-)
*/

:- lib(ic).


solve(Number-YearOfBirth) :-

	length(Number, 10),		% A 10-digit phone number
	Number :: 0..9,
	Number = [0|_],			% the first is zero
	alldifferent(Number),		% all 10 digits are used
	adjacent_pairs(Number, Pairs),	% look at the pairs
	(
	    foreach(X-Y, Pairs),
	    fromto(1, Product, Product*XYor1, Year50)
	do
	    adjacent_on_keypad(X,Y),	% each pair is adjacent, and
	    XYor1 :: 1..98,		% a potential factor for the
	    pair_factor(X,Y,XYor1)	% year computation
	),
	YearOfBirth #= eval(Year50) - 50,% this is the year of birth
	YearOfBirth :: 1938..1996,	% she's not yet 50 in 1998
	[Y1,Y2,Y3,Y4] :: 0..9,		% look at the year's digits
	YearOfBirth #= 1000*Y1+100*Y2+10*Y3+Y4,
	( foreach(Yi-Yj, [Y1-Y2,Y2-Y3,Y3-Y4]), param(Pairs) do
	    ( foreach(X-Y, Pairs), param(Yi,Yj) do
		X-Y ~= Yi-Yj,		% pairs are not similar to
		X-Y ~= Yj-Yi		% the phone number pairs
	    )
	),

	labeling(Number).		% find a solution!


% build a list of pairs of adjacent elements in List
adjacent_pairs(List, Pairs) :-
	( fromto(List,  [X,Y|Rest], [Y|Rest], [_]),
	  fromto(Pairs, [X-Y|Pairs1], Pairs1, [])
	do
	    true
	).


% wait until X and Y are instantiated, then bind XYor1 to X*Y or 1
delay pair_factor(X,Y,_XYor1) if var(X);var(Y).
pair_factor(X, Y, XYor1) :-
	( abs(X-Y) =:= 1 -> XYor1 is 10*X+Y ; XYor1 = 1 ).


% wait until X and Y are instantiated, then check adjacency
delay adjacent_on_keypad(X,Y) if var(X);var(Y).
adjacent_on_keypad(X,Y) :- adjacent_on_keypad1(Y,X).
adjacent_on_keypad(X,Y) :- adjacent_on_keypad1(X,Y).

adjacent_on_keypad1(1,2).	% horizontal
adjacent_on_keypad1(2,3).
adjacent_on_keypad1(4,5).
adjacent_on_keypad1(5,6).
adjacent_on_keypad1(7,8).
adjacent_on_keypad1(8,9).
adjacent_on_keypad1(1,4).	% vertical
adjacent_on_keypad1(4,7).
adjacent_on_keypad1(2,5).
adjacent_on_keypad1(5,8).
adjacent_on_keypad1(8,0).
adjacent_on_keypad1(3,6).
adjacent_on_keypad1(6,9).
adjacent_on_keypad1(2,6).	% down diagonal
adjacent_on_keypad1(1,5).
adjacent_on_keypad1(5,9).
adjacent_on_keypad1(4,8).
adjacent_on_keypad1(7,0).
adjacent_on_keypad1(2,4).	% up diagonal
adjacent_on_keypad1(3,5).
adjacent_on_keypad1(5,7).
adjacent_on_keypad1(6,8).
adjacent_on_keypad1(9,0).

