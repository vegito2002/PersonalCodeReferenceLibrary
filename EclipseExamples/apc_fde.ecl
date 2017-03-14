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
%	It uses extra integer variables and computes the cost via element
%	constraints, giving a better lower bound and efficient proof of
%	optimality.  A preference-guided search heuristic is used.
%       See also eplex-solution and hybrid ic/eplex solution.
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
	% a standard search routine will find many suboptimal solutions first
%	bb_min(search(Slots,0,input_order,indomain_max,complete,[]), Cost, bb_options{strategy:dichotomic}),
	% use a problem-specific heuristic to find good solution early
	bb_min(heuristic_search(Slots,Pref), Cost, bb_options{strategy:restart}),
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

	% matrix of boolean variables
	dim(Slots, [NSlots,NGroups]),
	Slots :: 0..1,

	% capacity constraints
	( for(T,1,NSlots), param(Slots,Cap,Size,NGroups) do
	    ( for(G,1,NGroups), foreach(U,Used), param(Slots,Size,T) do
		U = Size[G] * Slots[T,G]
	    ),
	    sum(Used) $=< Cap[T]
	),

	% build the cost expression
	( for(G,1,NGroups), foreach(C,Cs), param(Slots,NSlots,Pref) do
	    % map a column of booleans to an integer slot number SlotNr
	    ( for(T,1,NSlots), param(Slots,G,SlotNr) do
		(SlotNr #= T) #= Slots[T,G]
	    ),
	    GroupPrefs is Pref[1..NSlots,G],
	    element(SlotNr, GroupPrefs, C)
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

