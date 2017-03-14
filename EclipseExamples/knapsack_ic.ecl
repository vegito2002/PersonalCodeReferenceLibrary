%
% ECLiPSe SAMPLE CODE
%
% 0-1-Knapsack problem from
% http://rosettacode.org/wiki/Knapsack_problem/0-1
% Pack 0 or 1 item of each type, obeying knapsack weight constraint.
%
% Using ic as a finite-domain solver
% 

:- lib(ic).
:- lib(branch_and_bound).

model(Weights, Values, Capacity, Knapsack, Weight, Value) :-
	length(Weights, N),
	length(Knapsack,   N),
	Knapsack #:: 0..1,
	Knapsack*Weights #= Weight,
	Weight #=< Capacity,
	Knapsack*Values #= Value.

solve(Weights, Values, Capacity, Knapsack, Weight, Value) :-
	model(Weights, Values, Capacity, Knapsack, Weight, Value),
	Cost #= -Value,
	minimize(search(Knapsack, 0, input_order, indomain_max, complete, []), Cost).

main :-
    	data(Names, Weights, Values, Capacity),
	solve(Weights, Values, Capacity, Knapsack, Weight, Value),
	( foreach(Taken,Knapsack), foreach(Name,Names) do
	    ( Taken==1 -> writeln(Name) ; true )
	),
	writeln(weight=Weight;value=Value).


% data(Names, Weights, Values, Capacity)
data(
    [map,compass,water,sandwich,glucose,tin,banana,apple,cheese,beer,
       'suntan cream',camera,'t-shirt',trousers,umbrella,'waterproof trousers',
       'waterproof overclothes','note-case',sunglasses,towel,socks,book],
    [  9,13,153, 50,15,68,27,39,23,52,11,32,24,48,73,42,43,22, 7,18, 4,30],
    [150,35,200,160,60,45,60,40,30,10,70,30,15,10,40,70,75,80,20,12,50,10],
    400
).


