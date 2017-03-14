%
% Problem:
%
%	From: marco <marco.falda@gmail.com>
%	Newsgroups: comp.lang.prolog
%	Subject: CLP-FD suggestions
%	Date: Wed, 9 Dec 2009 05:20:12 -0800 (PST)
% 
%	I would like to solve a simple problem in CLP: assign 26 groups of
%	people of various sizes to 6 slots respecting the capacity of each
%	slot and minimizing the conflicts among the preferences of people.
%	Preferences are expressed, for each group, as a list of distances from
%	optimum.
%	...
%
% Solution:
%
%	This solution uses a combination of linear programming solver (eplex)
%	and finite domain solver (ic).  The finite domain solver handles all
%	constraints, including integrality.  The linear solver solves the
%	continuous relaxation (ignoring integrality) of the problem, thus
%	providing a lower bound on the Cost variable.  Moreover, the labeling
%	procedure is guided by the fractional solutions to the relaxation as
%	a heuristic.
%
%	Note that it would be possible to add constraints that are (or can be)
%	handled by the finite domain solver alone.
%
%	Joachim Schimpf, Monash University, Dec 2009.
%	This code may be freely used for any purpose.
%


:- lib(eplex).
:- lib(ic).
:- lib(branch_and_bound).

solve(Cost, Slots) :-
	data(Pref, Cap, Size),
	model(Pref, Cap, Size, Slots, Obj),
	ic:(Cost #= eval(Obj)),
	eplex_solver_setup(min(Obj), Cost, [sync_bounds(yes)], [deviating_bounds]),
	minimize(lp_guided_search(Slots), Cost),
	( foreacharg(Slot,Slots) do writeln(Slot) ).

lp_guided_search(Xs) :-
	( foreachelem(X,Xs) do
	    eplex_var_get(X, solution, RelaxedSol),
	    Guess is integer(round(RelaxedSol)),
	    ( X = Guess ; X #\= Guess )
	).


model(Pref, Cap, Size, Slots, Obj) :-
	dim(Cap, [NSlots]),
	dim(Size, [NGroups]),

	dim(Slots, [NSlots,NGroups]),
	[ic,eplex]: (Slots[1..NSlots,1..NGroups] $:: 0.0..1.0),
	ic: integers(Slots[1..NSlots,1..NGroups]),

	( for(T,1,NSlots), param(Slots,Cap,Size,NGroups) do
	    ( for(G,1,NGroups), foreach(U,Used), param(Slots,Size,T) do
		U = Size[G] * Slots[T,G]
	    ),
	    [ic,eplex]: (sum(Used) $=< Cap[T])
	),

	( for(G,1,NGroups), param(Slots,NSlots) do
	    [ic,eplex]: (sum(Slots[1..NSlots,G]) $= 1)
	),

	( multifor([T,G],1,[NSlots,NGroups]), foreach(C,Cs), param(Pref,Slots) do
	    C = Pref[T,G] * Slots[T,G]
	),
	Obj = sum(Cs).


data(Prefs, Capac, Compon) :-
	Prefs = [](
		 [](1, 2, 6, 5, 6, 6, 3, 4, 4, 1, 2, 4, 4, 3, 1, 5, 1, 4, 5, 6, 5, 2, 5, 5, 3, 2),
		 [](2, 3, 3, 2, 1, 4, 4, 2, 2, 6, 3, 1, 5, 5, 5, 6, 4, 2, 6, 4, 4, 5, 6, 2, 2, 1),
		 [](5, 1, 1, 6, 3, 5, 5, 3, 6, 5, 5, 3, 6, 2, 4, 1, 6, 3, 2, 5, 1, 1, 2, 6, 4, 3),
		 [](3, 6, 5, 3, 5, 3, 2, 1, 3, 3, 4, 2, 1, 1, 6, 2, 3, 5, 1, 3, 6, 3, 4, 3, 6, 5),
		 [](4, 4, 4, 4, 2, 2, 1, 6, 1, 4, 6, 5, 2, 4, 2, 3, 5, 6, 4, 2, 3, 6, 1, 1, 1, 6),
		 [](6, 5, 2, 1, 4, 1, 6, 5, 5, 2, 1, 6, 3, 6, 3, 4, 2, 1, 3, 1, 2, 4, 3, 4, 5, 4)
		),
	Capac = [](18, 18, 18, 18, 18, 18),
	Compon = [](5, 4, 4, 4, 3, 3, 3, 3, 3, 4, 4, 5, 5, 2, 5, 3, 4, 4, 3, 3, 3, 5, 2, 4, 4, 5).

