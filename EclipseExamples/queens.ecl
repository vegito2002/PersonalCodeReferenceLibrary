% ECLiPSe SAMPLE CODE
%
% AUTHOR:	Joachim Schimpf, IC-Parc
%
% The famous N-queens problem, using finite domains
% and a selection fo different search strategies
%

:- set_flag(gc_interval, 100000000).
:- lib(lists).
:- lib(ic).
:- lib(ic_search).


%--------------------
% The model
%--------------------

queens(N, Board) :-
	length(Board, N),
	Board :: 1..N,
	( fromto(Board, [Q1|Cols], Cols, []) do
	    ( foreach(Q2, Cols), param(Q1), count(Dist,1,_) do
	    	noattack(Q1, Q2, Dist)
	    )
	).

noattack(Q1,Q2,Dist) :-
	Q2 #\= Q1,
	Q2 - Q1 #\= Dist,
	Q1 - Q2 #\= Dist.


%-----------------------
% The search strategies
%-----------------------

labeling(a, AllVars, BT) :-
        search(AllVars, 0, input_order, indomain, complete, [backtrack(BT)]).

labeling(b, AllVars, BT) :-
        search(AllVars, 0, first_fail, indomain, complete, [backtrack(BT)]).

labeling(c, AllVars, BT) :-
        middle_first(AllVars, AllVarsPreOrdered), % static var-select
        search(AllVarsPreOrdered, 0, input_order, indomain, complete, [backtrack(BT)]).

labeling(d, AllVars, BT) :-
        middle_first(AllVars, AllVarsPreOrdered), % static var-select
        search(AllVarsPreOrdered, 0, first_fail, indomain, complete, [backtrack(BT)]).

labeling(e, AllVars, BT) :-
        middle_first(AllVars, AllVarsPreOrdered), % static var-select
        search(AllVarsPreOrdered, 0, first_fail, indomain_middle,
               complete, [backtrack(BT)]). 

% reorder a list so that the middle elements are first

middle_first(List, Ordered) :-
	halve(List, Front, Back),
	reverse(Front, RevFront),
	splice(Back, RevFront, Ordered).


%-----------------------------------
% Toplevel code
%
% all_queens/2 finds all solutions
% first_queens/2 finds one solution
% Strategy is a,b,c,d or e
% N is the size of the board
%-----------------------------------

:- local variable(solutions), variable(backtracks).

all_queens(Strategy, N) :-		% Find all solutions
	setval(solutions, 0),
	setval(backtracks, 0),
	statistics(times, [T0|_]),
	(
	    queens(N, Board),
	    labeling(Strategy, Board, BT),
	    incval(solutions),
	    setval(backtracks, BT),
%	    writeln(Board),
	    fail
	;
	    true
	),
	statistics(times, [T1|_]),
	T is T1-T0,
	getval(solutions, S),
	getval(backtracks, B),
	printf("\nFound %d solutions for %d queens in %w s with %d backtracks%n",
		[S,N,T,B]).


first_queens(Strategy, N) :-		% Find one solution
	statistics(times, [T0|_]),
	queens(N, Board),
	statistics(times, [T1|_]),
	D1 is T1-T0,
	printf("Setup for %d queens done in %w seconds", [N,D1]), nl,
        labeling(Strategy, Board, B),
	statistics(times, [T2|_]),
	D2 is T2-T1,
	printf("Found first solution for %d queens in %w s with %d backtracks%n",
		[N,D2,B]).



/*
Results (first solution):

standard labeling:
    Found 724 solutions for 10 queens in 3.43 seconds

deleteff:
    Found 724 solutions for 10 queens in 3.25999999999999 seconds

    Found first solution for 10 queens in 0.00999999999999091 seconds
    Found first solution for 12 queens in 0.0299999999999727 seconds
    Found first solution for 20 queens in 0.0600000000000591 seconds
    Found first solution for 50 queens in 0.939999999999941 seconds
    Found first solution for 100 queens in 0.289999999999964 seconds

middle_first:
    Found 724 solutions for 10 queens in 2.89999999999998 seconds

    Found first solution for 10 queens in 0.01 seconds
    Found first solution for 12 queens in 0.01 seconds
    Found first solution for 20 queens in 0.39 seconds

middle_first+deleteff:
    Found 724 solutions for 10 queens in 2.65999999999997 seconds

    Found first solution for 10 queens in 0.01 seconds
    Found first solution for 12 queens in 0.01 seconds
    Found first solution for 20 queens in 0.01 seconds
    Found first solution for 50 queens in 0.21 seconds

deleteff+middle_first_indomain:
    Found 724 solutions for 10 queens in 3.32 seconds

    Found first solution for 100 queens in 0.490000000000009 seconds
    Found first solution for 200 queens in 1.41999999999996 seconds
    Found first solution for 500 queens in 25.15 seconds

middle_first+deleteff+middle_first_indomain:
    Found 724 solutions for 10 queens in 2.17 seconds

    Found first solution for 10 queens in 0.0 s with 1 backtracks
    Found first solution for 12 queens in 0.0 s with 3 backtracks
    Found first solution for 20 queens in 0.0 s with 4 backtracks
    Found first solution for 50 queens in 0.04 s with 29 backtracks
    Found first solution for 100 queens in 0.1 s with 6 backtracks
    Found first solution for 200 queens in 1.09 s with 0 backtracks
    Found first solution for 500 queens in 9.16 s with 0 backtracks


*/
