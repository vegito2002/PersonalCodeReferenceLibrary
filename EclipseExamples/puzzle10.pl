/*
    10.  Three dealers in adjacent stalls at a market were selling apples
    of identical quality, so they had to keep their prices equal.  At the
    end of the day Mr Pappas had sold 10 apples, Mr Gatta 25, and Mrs
    Murphy 30, yet all had taken in the same total.  How much did they
    charge and how much did they take in? 

    Note:  The problem is possible only if the price was changed during
    the course of the day.  Assume just one price change.  (Kraitchik)
*/

:- lib(ic).

solve([Pappas1,Pappas2,Gatta1 ,Gatta2,Murphy1,Murphy2,Price1,Price2,Total]) :-
	Price1 #> 0,
	Price2 #>= Price1,	% remove symmetry
	dealer(10, Pappas1, Pappas2, Price1, Price2, Total),
	dealer(25, Gatta1,  Gatta2,  Price1, Price2, Total),
	dealer(30, Murphy1, Murphy2, Price1, Price2, Total),

	labeling([Price1,Price2,Total]).

dealer(SoldTotal, SoldCheap, SoldExpensive, CheapPrice, ExpensivePrice, Total) :-
	SoldCheap #>= 0, SoldExpensive #>= 0,
	SoldTotal #= SoldCheap + SoldExpensive,
	SoldCheap*CheapPrice + SoldExpensive*ExpensivePrice #= Total.

