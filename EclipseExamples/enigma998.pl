/*

From New Scientist, 26 September 1998, No 2153, p49

---------------------------------------------------
Enigma 998: Multiple Purchases - by Richard England
---------------------------------------------------

THE denominations of coins in circulation which are less than a pound
are 50, 20, 10, 5, 2 and 1p.

Harry, Tom and I went into a shop recently and each made a purchase
costing less than £1(100p). The cost of each of these purchases was 
different. We each paid with a £1 coin and each received four coins
in change - in each case the change due could not be given in fewer
than four coins; but equally if we had paid the exact price for our
purchases it would have been possible for each of us to have done so
with four coins, but not with fewer.

The total cost of our three purchases was not only more than, but 
also an exact multiple of, the total amount of change than between
us we received.

What did each of our purchases cost?

*/

% File:         enigma998.pl
% Author(s):    Vassilis Liatsos <vl@icparc.ic.ac.uk>
%
% Description:  Solution for "Enigma 998: Multiple Purchases" 
%               in the ECLiPSe constraint programming language
%               Enigma 998 appeared in:
%               "New Scientist, 26 September 1998, No 2153, p49"
%               See description above
%
% Use:          start eclipse:  eclipse
%               load file by:   [enigma998].
%               get solution:   solve(X).
%
% Date:         7 October 1998
% Copyright     IC-Parc, Imperial College, UK


:- lib(ic).

solve([P1,P2,P3]):-
	% Find all possible prices for purchases of each
	findall(Price,possible_prices(Price,_),Prices),
	[P1,P2,P3]::Prices,
	TotalSpent #= P1+P2+P3,
	TotalChange #= 300 - TotalSpent,
	% Total cost of purchases more than total amount of change
	TotalSpent #> TotalChange,
	% In fact exact multiple (greater than 0)
	Mul #>0,
	TotalSpent #= Mul*TotalChange,
	% impose an ordering on prices (which have to be different)
	P1 #< P2, P2 #< P3,
	% Try a multiple
	indomain(Mul),
	% label prices
	labeling([P1,P2,P3]).

possible_prices(Price,Change):-
        [Price, Change] :: 0..100, 
	[X50, X10, X5, X1] :: 0..1,
	[X20,X2]::0..2,
        X50 + X20 + X10 + X5 + X2 + X1#=4,
	% Remove redundancy
	X2+X1#<3, % can't have two 2p and one 1p (you could use one 5p)
	X20+X10#<3, % can't have two 20p and one 10p (you could use one 50p)
	% can't have one 5p, two 2p and one 1p (you could use one 10p)
	% This is subsumed by X2+X1<3
	% X5+X2+X1#<4, 

	Price #= 50 * X50 + 20 * X20 + 10 * X10 + 5 * X5 + 2 * X2 + 1 * X1,
        [Y50,Y10,Y5,Y1]::0..1,
	[Y20,Y2]::0..2,
        Change #= 100-Price,
        Change #= 50 * Y50 + 20 * Y20 + 10 * Y10 + 5 * Y5 + 2 * Y2 + 1 * Y1,
        Y50+Y20+Y10+Y5+Y2+Y1 #= 4,
	
	% Remove redundancy (same as above)
	Y2+Y1#<3,
	Y20+Y10#<3,
	% This is subsumed by Y2+Y1<3
	% Y5+Y2+Y1#<4,
	
	% enumerate
        labeling([X50,X20,X10,X5,X2,X1,Y50,Y20,Y10,Y5,Y2,Y1]).

