%
% ECLiPSe SAMPLE CODE
%
% 0-1-Knapsack problem from
% http://rosettacode.org/wiki/Knapsack_problem
% Pack 0 or 1 item of each type, obeying knapsack weight constraint.
%
% Using ic (as a finite-domain solver) and ic_sets (set-solver)
%

:- lib(ic).
:- lib(ic_sets).
:- lib(branch_and_bound).

model(Weights, Values, Capacity, Knapsack, Weight, Value) :-
	dim(Weights, [N]),
	dim(Values,  [N]),
	intset(Knapsack, 1, N),		% Knapsack is a subset of integers 1..N
	Weight #=< Capacity,
	weight(Knapsack, Weights, Weight),
	weight(Knapsack, Values, Value).

solve(Weights, Values, Capacity, Knapsack, Weight, Value) :-
	model(Weights, Values, Capacity, Knapsack, Weight, Value),
	Cost #= -Value,		% need Cost for minimizing!
	minimize(insetdomain(Knapsack,_,heavy_first(Values),in_notin), Cost).

main :-
    	data(Names, Weights, Values, Capacity),
	solve(Weights, Values, Capacity, Knapsack, Weight, Value),
	( foreach(I,Knapsack), param(Names) do
	    arg(I, Names, Name),
	    writeln(Name)
	),
	writeln(weight=Weight;value=Value).


% data(Names, Weights, Values, Capacity)
data(
    [](map,compass,water,sandwich,glucose,tin,banana,apple,cheese,beer,
       'suntan cream',camera,'t-shirt',trousers,umbrella,'waterproof trousers',
       'waterproof overclothes','note-case',sunglasses,towel,socks,book),
    [](  9,13,153, 50,15,68,27,39,23,52,11,32,24,48,73,42,43,22, 7,18, 4,30),
    [](150,35,200,160,60,45,60,40,30,10,70,30,15,10,40,70,75,80,20,12,50,10),
    400
).
