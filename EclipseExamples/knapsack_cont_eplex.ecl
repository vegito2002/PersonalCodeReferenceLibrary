%
% ECLiPSe SAMPLE CODE
%
% Continuous Knapsack problem from
% http://rosettacode.org/wiki/Knapsack_problem
% Pack (possibly fractional) amounts of each item, obeying the knapsack
% weight constraint.  There is a limited supply of each item type.
%
% Using eplex as linear solver
%

:- lib(eplex).

model(Weights, Values, Capacity, Amounts, TotalWeight, TotalValue) :-
	(
	    foreach(Weight,Weights),
	    foreach(Value,Values),
	    foreach(Amount,Amounts),
	    foreach(Amount*Price,TakenValues)
	do
	    Amount $:: 0.0..Weight,
	    Price is Value/Weight
	),
	sum(Amounts) $= TotalWeight,
	TotalWeight $=< Capacity,
	sum(TakenValues) $= TotalValue.

solve(Weights, Values, Capacity, Amounts, Weight, Value) :-
	model(Weights, Values, Capacity, Amounts, Weight, Value),
	optimize(max(Value), _Opt).

main :-
    	data(Names, Weights, Values, Capacity),
	solve(Weights, Values, Capacity, Amounts, Weight, Value),
	( foreach(Amount,Amounts), foreach(Name,Names) do
	    ( Amount > 0 -> printf("%.2f %w%n", [Amount,Name]) ; true )
	),
	writeln(weight=Weight;value=Value).


% data(Names, Weights, Values, Capacity)
data(
    [beef,pork, ham,greaves,flitch,brawn,welt,salami,sausage],
    [ 3.8, 5.4, 3.6,    2.4,   4.0,  2.5, 3.7,   3.0,    5.9],
    [  36,  43,  90,     45,    30,   56,  67,    95,     98],
    15
).
