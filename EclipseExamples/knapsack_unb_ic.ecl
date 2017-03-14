%
% ECLiPSe SAMPLE CODE
%
% Unbounded Knapsack problem from
% http://rosettacode.org/wiki/Knapsack_problem
% There is an unlimited supply of items, but
% weight and volume restrictions on the knapsack
%
% Using ic as interval solver with both integer and real variables.
% Note the code to find all optimal solutions (click 'more').
%

:- lib(ic).
:- lib(branch_and_bound).

model(Weights, Volumes, Values, MaxW, MaxV, Amounts, Value) :-
	length(Values,   N),
	length(Amounts,  N),
	Amounts #:: 0..inf,
	Amounts*Weights $=< MaxW,
	Amounts*Volumes $=< MaxV,
	Amounts*Values  $=  Value.

% Find one optimal solution
solve(Weights, Volumes, Values, MaxW, MaxV, Amounts, Value) :-
	model(Weights, Volumes, Values, MaxW, MaxV, Amounts, Value),
	Cost #= -Value,		% need Cost for minimizing!
	minimize(search(Amounts, 0, largest, indomain_reverse_split, complete, []), Cost).

% Alternatively: find all optimal solutions
solve_all(Weights, Volumes, Values, MaxW, MaxV, Amounts, Value) :-
	model(Weights, Volumes, Values, MaxW, MaxV, Amounts, Value),
	Cost #= -Value,		% need Cost for minimizing!
	% compute optimal Cost only
	bb_min(search(Amounts, 0, largest, indomain_reverse_split, complete, []),
		Cost,[],_,Cost,_),
	% find all solutions with Cost
	search(Amounts, 0, largest, indomain_reverse_split, complete, []).

main :-
	data(Names, Values, Weights, Volumes, MaxW, MaxV),
%	solve(Weights, Volumes, Values, MaxW, MaxV, _Amounts, Value),
	solve_all(Weights, Volumes, Values, MaxW, MaxV, Amounts, Value),
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
