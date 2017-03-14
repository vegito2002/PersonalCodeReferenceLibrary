/*
    2.  Supposing that eleven coins with round holes are worth 15 bits,
    while eleven square ones are worth 16 bits, and eleven of triangular
    shape are worth 17 bits, tell how many round, square or triangular
    pieces of cash would be required to purchase an item worth eleven
    bits.  (Loyd)
*/

:- lib(ic).
:- lib(branch_and_bound).

% We scale this constraint by 11 to have only integers
% NRound*15/11 + NSquare*16/11 + NTriang*17/11 #= 11

solve(Coins) :-
	Coins = [NRound,NSquare,NTriang],
	Coins :: 0..11,
	NRound*15 + NSquare*16 + NTriang*17 #= 121,
	NCoins #= sum(Coins),

	bb_min(labeling(Coins), NCoins, bb_options{strategy:step}),

	printf("%d round, %d square, %d triangular\n", Coins).
