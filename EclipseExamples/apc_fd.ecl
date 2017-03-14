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
%	This solution uses a finite domain solver (ic).
%	Using a naive predefined search procedure is very slow. 
%	Using a greedy heuristic guided by the preferences finds
%	good solutions quickly, but struggles to prove optimality.
%	This is because the boolean model does not give a good cost
%	bound with CP techniques.
%
%	See also hybrid ic/eplex solution, and the modified ic model
%	using extra integer variables and element constraints.
%
%	Joachim Schimpf, Monash University, Dec 2009.
%	This code may be freely used for any purpose.
%


:- lib(ic).
:- lib(branch_and_bound).

solve(Cost, Slots) :-
	data(Pref, Cap, Size),
	model(Pref, Cap, Size, Slots, Obj),
	Cost #= eval(Obj),
	% a standard search routine is very slow
%	minimize(search(Slots,0,input_order,indomain_max,complete,[]), Cost),
	% use a problem-specific heuristic
	bb_min(heuristic_search(Slots,Pref), Cost, bb_options{timeout:10}),
	( foreacharg(Slot,Slots) do writeln(Slot) ).


heuristic_search(Slots, Pref) :-
	dim(Pref, [NSlots,NGroups]),
	% pair the decision variables with their preferences
	( multifor([T,G],1,[NSlots,NGroups]), foreach(P-X,PXs), param(Pref,Slots) do
	    P is Pref[T,G],
	    X is Slots[T,G]
	),
	% sort them in descending order
	sort(1, >=, PXs, SPXs),
	% label left-to-right, trying zeros first
	( foreach(_-X,SPXs) do
	    indomain(X, min)
	).


model(Pref, Cap, Size, Slots, Obj) :-
	dim(Cap, [NSlots]),
	dim(Size, [NGroups]),

	dim(Slots, [NSlots,NGroups]),
	Slots[1..NSlots,1..NGroups] $:: 0.0..1.0,
	integers(Slots[1..NSlots,1..NGroups]),

	( for(T,1,NSlots), param(Slots,Cap,Size,NGroups) do
	    ( for(G,1,NGroups), foreach(U,Used), param(Slots,Size,T) do
		U = Size[G] * Slots[T,G]
	    ),
	    sum(Used) $=< Cap[T]
	),

	( for(G,1,NGroups), param(Slots,NSlots) do
	    sum(Slots[1..NSlots,G]) $= 1
	),

	( multifor([T,G],1,[NSlots,NGroups]), foreach(C,Cs), param(Pref,Slots) do
	    C = Pref[T,G] * Slots[T,G]
	),
	Obj = sum(Cs).



%data(Prefs, Capac, Compon) :-
%	Prefs = []([](0, 1, 1), [](1, 0, 0)), % slot 1 is the first choice for group 1, a second choice for groups 2 and 3
%	Capac = [](8, 6), % the first slot can receive 8 people, the second 6
%	Compon = [](5, 3, 4). % the first group has 5 people, the second 3, the third 4

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

