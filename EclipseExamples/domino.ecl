%---------------------------------------------------------------------- 
% Subject: domino puzzle
% Date: Mon, 3 Jan 2000 10:42:04 -0800
% From: "Doug Edmunds" <edmunds@pacifier.com>
% To: "eclipse-users" <eclipse-users@icparc.ic.ac.uk>
% 
% Happy New Year!
% 
% Can anyone suggest an approach to solving this type of puzzle?
% 
% There are 28 dominos 0-0 to 6-6 ( 0-0, 0-1,0-2,..., 5-5,5-6,6-6).
% 
% They are layed out randomly on a rectangular shape so that
% there are 8 numbers across and 7 down.  There is no relation 
% between adjoining tiles.  
% 
% Tiles can appear left-right or up-down: 3-5 can be positioned 
% 3-5, 5-3,
% 3 
% 5, 
% or as 
% 5
% 3. 
% 
% The object is to reconstruct the tile-boundaries, using eclipse.  
% No tile is used twice.  Each number in the grid is part on only
% one tile.
% 
% Puzzle pattern:
% 
% 3 1 2 6 6 1 2 2
% 3 4 1 5 3 0 3 6
% 5 6 6 1 2 4 5 0
% 5 6 4 1 3 3 0 0 
% 6 1 0 6 3 2 4 0
% 4 1 5 2 4 3 5 5
% 4 1 0 2 4 5 2 0 
% 
%---------------------------------------------------------------------- 

%
% Solution by Warwick Harvey (Model) and Joachim Schimpf (Code), IC-Parc
%

:- lib(ic).

data([](
    [](3,1,2,6,6,1,2,2),
    [](3,4,1,5,3,0,3,6),
    [](5,6,6,1,2,4,5,0),
    [](5,6,4,1,3,3,0,0),
    [](6,1,0,6,3,2,4,0),
    [](4,1,5,2,4,3,5,5),
    [](4,1,0,2,4,5,2,0)
    )).


solve :-
	data(Board),
	dim(Board, [M,N]),

	one_by_two_tiling(M, N, Left, Up),	% setup tiling sub-problem
	make_display_matrix(Left, left),
	make_display_matrix(Up, up),

	% Make a list Tiles consisting of entries like [3,5]-Bool meaning
	% that Bool represents the use of a tile labelled with [3,5]
	( for(I,1,M),				% collect horizontal tiles
	  fromto(Tiles4,Tiles3,Tiles0,[]),
	  param(Board,Left,N)
	do
	    ( for(J,2,N),
	      fromto(Tiles3,[LTile-LBool|Tiles1],Tiles1,Tiles0),
	      param(Board,Left,I)
	    do
		domino_at(Board, I, J, I, J-1, LTile),
		LBool is Left[I,J]
	    )
	),
	( for(I,2,M),				% collect vertical tiles
	  fromto(Tiles,Tiles8,Tiles5,Tiles4),
	  param(Board,Up,N)
	do
	    ( for(J,1,N),
	      fromto(Tiles8,[UTile-UBool|Tiles6],Tiles6,Tiles5),
	      param(Board,Up,I)
	    do
		domino_at(Board, I, J, I-1, J, UTile),
		UBool is Up[I,J]
	    )
	),
	keysort(Tiles, SortedTiles),
	group_same_key_values(SortedTiles, GroupedTiles),
	( foreach(_Domino-Bools, GroupedTiles) do
	    sum(Bools) #= 1			% Only one tile of each kind!
	),

	term_variables([Left,Up], AllBools),	% search part
	labeling(AllBools),

	pretty_print(Board, Left, Up),		% output result

	fail.					% look for more solutions


% Create two matrices of border-booleans (Left and Up) and constrain
% them to describe a valid 1-by-2 tiling of an M-by-N board
one_by_two_tiling(M, N, Left, Up) :-
	M1 is M+1, N1 is N+1,		% setup the border booleans
	dim(Left,[M,N1]),		% matrix of left-border booleans
	Left[1..M,1] :: 0,		% with dummy columns left and right
	Left[1..M,N1] :: 0,
	Left[1..M,2..N] :: 0..1,
	dim(Up,[M1,N]),			% matrix of upper-border booleans
	Up[1,1..N] :: 0,		% with dummy rows top and bottom
	Up[M1,1..N] :: 0,
	Up[2..M,1..N] :: 0..1,
	( for(I,1,M), param(Left,Up,N) do
	    ( for(J,1,N), param(Left,Up,I) do
		% Tiling constraint: only one adjacent border can be crossed
		1 #= Left[I,J] + Up[I,J] + Left[I,J+1] + Up[I+1,J]
	    )
	).

domino_at(Board, I1, J1, I2, J2, Domino) :-
	Val1 is Board[I1,J1],
	Val2 is Board[I2,J2],
	msort([Val1,Val2], Domino).

pretty_print(Board, Left, Up) :-
	dim(Board, [M,N]),
	( for(I,1,M), param(Board,Left,Up,N) do
	    ( for(J,1,N), param(Left,Board,I) do
		X is Board[I,J], printf(" %d",[X]),
		B is Left[I,J+1], ( B==0 -> write("  ") ; write(" -") )
	    ), nl,
	    ( for(J,1,N), param(Up,I) do
		B is Up[I+1,J], ( B==0 -> write("  ") ; write(" |") ),
		write("  ")
	    ), nl
	), nl.

% general purpose auxiliary
group_same_key_values([], []).
group_same_key_values([K-V|List], [K-[V|KVs]|GroupedList]) :-
	group_same_key_values(List, K, KVs, GroupedList).

    group_same_key_values([], _, [], []).
    group_same_key_values([K-V|List], K, [V|KVs], GroupedList) :- !,
	group_same_key_values(List, K, KVs, GroupedList).
    group_same_key_values([K-V|List], _K, [], [K-[V|KVs]|GroupedList]) :-
	group_same_key_values(List, K, KVs, GroupedList).

