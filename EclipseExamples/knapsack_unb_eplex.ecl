%
% ECLiPSe SAMPLE CODE
%
% Unbounded Knapsack problem from
% http://rosettacode.org/wiki/Knapsack_problem
% There is an unlimited supply of items, but
% weight and volume restrictions on the knapsack
%
% Using eplex as a mixed-integer solver
%

:- lib(eplex).

model(Weights, Volumes, Values, MaxW, MaxV, Amounts, Value) :-
	length(Values,   N),
	length(Amounts,  N),
	Amounts $:: 0..inf,
	integers(Amounts),
	Amounts*Weights $=< MaxW,
	Amounts*Volumes $=< MaxV,
	Amounts*Values  $=  Value.

solve(Weights, Volumes, Values, MaxW, MaxV, Amounts, Value) :-
	model(Weights, Volumes, Values, MaxW, MaxV, Amounts, Value),
	optimize(max(Value), _Value).

main :-
	data(Names, Values, Weights, Volumes, MaxW, MaxV),
	solve(Weights, Volumes, Values, MaxW, MaxV, Amounts, Value),
	( foreach(Amount,Amounts), foreach(Name,Names) do
	    printf("%d of %w%n", [Amount,Name])
	),
	writeln(value=Value).


% data(Names, Values, Weights, Volumes, MaxW, MaxV)
data(
    [panacea, ichor,  gold],
    [   3000,  1800,  2500],
    [    0.3,   0.2,   2.0],
    [  0.025, 0.015, 0.002],
    25,
    0.25
).
