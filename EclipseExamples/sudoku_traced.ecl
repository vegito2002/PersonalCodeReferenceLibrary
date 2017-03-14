% 
% ECLiPSe sample code:  Data-driven tracing of labeling and propagation
%
% Author: Joachim Schimpf, Coninfer Ltd, 2016
%
% The purpose of this example is to show how you can use suspended goals
% to trace the progress of your solution search WITHOUT having to modify
% the search routine.
% 
% This differs from the Sudoku solving code in sudoku.ecl only in the
% addition of the report_labeling/2 and report_propagation/2 predicates.
% 
% The following output should be produced:
%
% ?- solve(1). 
%
%    (0) Propagation result:
%      _  _  2  _  _  5  _  7  9
%      1  _  5  9  _  3  _  _  _
%      9  _  _  _  _  _  6  _  _
%      _  1  _  4  _  _  9  _  _
%      _  9  _  _  _  _  _  8  4
%      _  _  4  _  _  9  _  1  _
%      _  _  9  _  _  _  _  _  _
%      _  _  7  1  _  _  3  _  6
%      6  8  1  3  _  _  4  _  _
%
%    (1) Labeling:
%      3  _  2  _  _  5  _  7  9
%      1  _  5  9  _  3  _  _  _
%      9  _  _  _  _  _  6  _  _
%      _  1  _  4  _  _  9  _  _
%      _  9  _  _  _  _  _  8  4
%      _  _  4  _  _  9  _  1  _
%      _  _  9  _  _  _  _  _  _
%      _  _  7  1  _  _  3  _  6
%      6  8  1  3  _  _  4  _  _
%
%    (1) Propagation result:
%      3  _  2  _  _  5  _  7  9
%      1  _  5  9  _  3  _  _  _
%      9  _  8  _  _  _  6  _  _
%      _  1  _  4  _  _  9  _  _
%      _  9  _  _  _  _  _  8  4
%      _  _  4  _  _  9  _  1  _
%      _  3  9  _  _  _  _  _  _
%      _  _  7  1  _  _  3  _  6
%      6  8  1  3  _  _  4  _  _
%
%    (2) Labeling:
%      3  4  2  _  _  5  _  7  9
%      1  _  5  9  _  3  _  _  _
%      9  _  8  _  _  _  6  _  _
%      _  1  _  4  _  _  9  _  _
%      _  9  _  _  _  _  _  8  4
%      _  _  4  _  _  9  _  1  _
%      _  3  9  _  _  _  _  _  _
%      _  _  7  1  _  _  3  _  6
%      6  8  1  3  _  _  4  _  _
%
%    (2) Labeling:
%      3  6  2  _  _  5  _  7  9
%      1  _  5  9  _  3  _  _  _
%      9  _  8  _  _  _  6  _  _
%      _  1  _  4  _  _  9  _  _
%      _  9  _  _  _  _  _  8  4
%      _  _  4  _  _  9  _  1  _
%      _  3  9  _  _  _  _  _  _
%      _  _  7  1  _  _  3  _  6
%      6  8  1  3  _  _  4  _  _
%
%    (2) Propagation result:
%      3  6  2  8  4  5  1  7  9
%      1  7  5  9  6  3  2  4  8
%      9  4  8  2  1  7  6  3  5
%      7  1  3  4  5  8  9  6  2
%      2  9  6  7  3  1  5  8  4
%      8  5  4  6  2  9  7  1  3
%      4  3  9  5  7  6  8  2  1
%      5  2  7  1  8  4  3  9  6
%      6  8  1  3  9  2  4  5  7
%
% At each depth (D) of the search tree, we print the state of the board
%  - immediately after a variable has been assigned a value ("Labeling")
%  - and after the ensuing propagation has finished ("Propagation result")
% Each labeling step that is not followed by a propagation result indicates
% a failure.
%
% Implementation:
%
% Both report_labeling/2 and report_propagation/2 print the board in its
% current state (variables are printed here as underscores for neat
% formatting, but one could easily print the current domains instead).
%
% The predicate report_labeling/2 is woken on the first instantiation of
% any board variable.  This happens with high priority (1), which means the
% board is printed after the instantiation, but before any resulting
% propagation has started.
%
% The predicate report_propagation/2 is woken on any domain reduction of
% board variables.  However, this happens with low priority (11), so that
% the board is not printed until all propagation activity has ceased.
% The final action of report_propagation/2 is to delay a new pair of
% report_xxx goals for tracing the next labeling step.
%


:- lib(ic).
:- import alldifferent/1 from ic_global.

solve(ProblemName) :-
	problem(ProblemName, Board),
	sudoku(Board),
	report_propagation(0, Board),
	labeling(Board).

    report_labeling(Depth, Board) :-
	printf("(%d) Labeling:%n", [Depth]),
	print_board(Board).

    report_propagation(Depth, Board) :-
	printf("(%d) Propagation result:%n", [Depth]),
	print_board(Board),
	Depth1 is Depth+1,
	% report_labeling/2 wakes with high priority (before propagation)
	suspend(report_labeling(Depth1, Board), 1, Board->inst),
	% report_propagation/2 wakes with low priority (after propagation)
	suspend(report_propagation(Depth1, Board), 11, Board->constrained).


sudoku(Board) :-
	dim(Board, [N2,N2]),
	N is integer(sqrt(N2)),
	Board[1..N2,1..N2] :: 1..N2,
	( for(I,1,N2), param(Board,N2) do
	    Row is Board[I,1..N2],
	    alldifferent(Row),
	    Col is Board[1..N2,I],
	    alldifferent(Col)
	),
	( multifor([I,J],1,N2,N), param(Board,N) do
	    ( multifor([K,L],0,N-1), param(Board,I,J), foreach(X,SubSquare) do
		X is Board[I+K,J+L]
	    ),
	    alldifferent(SubSquare)
	).


print_board(Board) :-
	dim(Board, [N,N]),
	( for(I,1,N), param(Board,N) do
	    ( for(J,1,N), param(Board,I) do
		X is Board[I,J],
		( var(X) -> write("  _") ; printf(" %2d", [X]) )
	    ), nl
	), nl.


%----------------------------------------------------------------------
% Sample data
%----------------------------------------------------------------------

problem(1, [](
    [](_, _, 2, _, _, 5, _, 7, 9),
    [](1, _, 5, _, _, 3, _, _, _),
    [](_, _, _, _, _, _, 6, _, _),
    [](_, 1, _, 4, _, _, 9, _, _),
    [](_, 9, _, _, _, _, _, 8, _),
    [](_, _, 4, _, _, 9, _, 1, _),
    [](_, _, 9, _, _, _, _, _, _),
    [](_, _, _, 1, _, _, 3, _, 6),
    [](6, 8, _, 3, _, _, 4, _, _))).

problem(2, [](
    [](_, _, 3, _, _, 8, _, _, 6),
    [](_, _, _, 4, 6, _, _, _, _),
    [](_, _, _, 1, _, _, 5, 9, _),
    [](_, 9, 8, _, _, _, 6, 4, _),
    [](_, _, _, _, 7, _, _, _, _),
    [](_, 1, 7, _, _, _, 9, 5, _),
    [](_, 2, 4, _, _, 1, _, _, _),
    [](_, _, _, _, 4, 6, _, _, _),
    [](6, _, _, 5, _, _, 8, _, _))).

problem(3, [](
    [](_, _, _, 9, _, _, _, _, _),
    [](_, _, 7, _, 6, _, 5, _, _),
    [](_, _, 3, 5, _, _, _, 7, 9),
    [](4, _, 5, _, _, 9, _, _, 1),
    [](8, _, _, _, _, _, _, _, 7),
    [](1, _, _, 6, _, _, 9, _, 8),
    [](6, 4, _, _, _, 8, 7, _, _),
    [](_, _, 9, _, 1, _, 2, _, _),
    [](_, _, _, _, _, 7, _, _, _))).

problem(4, [](
    [](_, 5, _, _, _, 1, 4, _, _), 
    [](2, _, 3, _, _, _, 7, _, _), 
    [](_, 7, _, 3, _, _, 1, 8, 2), 
    [](_, _, 4, _, 5, _, _, _, 7), 
    [](_, _, _, 1, _, 3, _, _, _), 
    [](8, _, _, _, 2, _, 6, _, _), 
    [](1, 8, 5, _, _, 6, _, 9, _), 
    [](_, _, 2, _, _, _, 8, _, 3), 
    [](_, _, 6, 4, _, _, _, 7, _))).

% Problems 5-8 are harder, taken from
% http://www2.ic-net.or.jp/~takaken/auto/guest/bbs46.html
problem(5, [](
    [](_, 9, 8, _, _, _, _, _, _),
    [](_, _, _, _, 7, _, _, _, _),
    [](_, _, _, _, 1, 5, _, _, _),
    [](1, _, _, _, _, _, _, _, _),
    [](_, _, _, 2, _, _, _, _, 9),
    [](_, _, _, 9, _, 6, _, 8, 2),
    [](_, _, _, _, _, _, _, 3, _),
    [](5, _, 1, _, _, _, _, _, _),
    [](_, _, _, 4, _, _, _, 2, _))).

problem(6, [](
    [](_, _, 1, _, 2, _, 7, _, _),
    [](_, 5, _, _, _, _, _, 9, _),
    [](_, _, _, 4, _, _, _, _, _),
    [](_, 8, _, _, _, 5, _, _, _),
    [](_, 9, _, _, _, _, _, _, _),
    [](_, _, _, _, 6, _, _, _, 2),
    [](_, _, 2, _, _, _, _, _, _),
    [](_, _, 6, _, _, _, _, _, 5),
    [](_, _, _, _, _, 9, _, 8, 3))).

problem(7, [](
    [](1, _, _, _, _, _, _, _, _),
    [](_, _, 2, 7, 4, _, _, _, _),
    [](_, _, _, 5, _, _, _, _, 4),
    [](_, 3, _, _, _, _, _, _, _),
    [](7, 5, _, _, _, _, _, _, _),
    [](_, _, _, _, _, 9, 6, _, _),
    [](_, 4, _, _, _, 6, _, _, _),
    [](_, _, _, _, _, _, _, 7, 1),
    [](_, _, _, _, _, 1, _, 3, _))).

problem(8, [](
    [](1, _, 4, _, _, _, _, _, _),
    [](_, _, 2, 7, 4, _, _, _, _),
    [](_, _, _, 5, _, _, _, _, _),
    [](_, 3, _, _, _, _, _, _, _),
    [](7, 5, _, _, _, _, _, _, _),
    [](_, _, _, _, _, 9, 6, _, _),
    [](_, 4, _, _, _, 6, _, _, _),
    [](_, _, _, _, _, _, _, 7, 1),
    [](_, _, _, _, _, 1, _, 3, _))).

% this one is from http://www.skyone.co.uk/programme/pgefeature.aspx?pid=48&fid=129
problem(9, [](
    [](5, _, 6, _, 2, _, 9, _, 3),
    [](_, _, 8, _, _, _, 5, _, _),
    [](_, _, _, _, _, _, _, _, _),
    [](6, _, _, 2, 8, 5, _, _, 9),
    [](_, _, _, 9, _, 3, _, _, _),
    [](8, _, _, 7, 6, 1, _, _, 4),
    [](_, _, _, _, _, _, _, _, _),
    [](_, _, 4, _, _, _, 3, _, _),
    [](2, _, 1, _, 5, _, 6, _, 7))).

% BBC Focus magazine October 2005
problem(10, [](
    [](_, 6, _, 3, 2, _, _, 7, _),
    [](4, 7, _, _, _, _, _, 3, 2),
    [](_, _, _, 9, _, _, 1, 4, 6),
    [](2, 4, _, 8, _, _, _, _, _),
    [](_, _, 8, _, _, _, 2, _, 1),
    [](1, _, _, _, _, 2, _, _, _),
    [](_, _, 2, 4, 7, 6, 8, _, _),
    [](6, 8, 9, _, _, _, _, 5, 4),
    [](_, _, _, _, 8, _, _, _, _))).

problem(11, [](
    [](1, 8, 2, 7, 5, _, 3, _, 9),
    [](9, 5, 6, _, 3, _, _, 8, _),
    [](3, 4, 7, _, _, 9, _, 5, _),
    [](2, _, 3, _, 4, _, _, 9, 8),
    [](4, _, 8, 9, _, 2, 5, _, 3),
    [](5, 7, 9, 3, 6, 8, 1, 2, 4),
    [](_, 2, _, 4, 9, _, 8, 3, _),
    [](_, 3, _, _, 2, _, 9, _, 5),
    [](_, 9, _, _, _, 3, _, 1, _))).

