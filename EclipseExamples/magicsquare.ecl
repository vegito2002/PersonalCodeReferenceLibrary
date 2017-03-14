%
% ECLiPSe SAMPLE CODE
%
% AUTHOR:	Joachim Schimpf, IC-Parc
%
% DESCRIPTION:	A magic square of size N is an NxN square filled
%		with the numbers from 1 to N^2 such that the sums of
%		each row, each column and the two main diagonals are
%		equal.
%
%		Some interesting goals:
%
%		magic(4),fail.	% all 880 solutions
%		magic(5).
%		magic(7).

:- lib(ic).

magic(N) :-
	NN is N*N,				% number of square fields
	Sum is N*(NN+1)//2,			% this is the magical sum
	printf("Sum = %d%n", [Sum]),

	dim(Square, [N,N]),			% make the variables
	Square :: 1..NN,			% their range
	alldifferent(Square),			% they are all different

	(
	    for(I,1,N),
	    foreach(U,UpDiag),
	    foreach(D,DownDiag),
	    param(N,Square,Sum)
	do
	    Sum #= sum(Square[I,1..N]),		% sum of row I
	    Sum #= sum(Square[1..N,I]),		% sum of column I
	    U is Square[I,I],
	    D is Square[I,N+1-I]
	),
	Sum #= sum(UpDiag),			% diagonal sums
	Sum #= sum(DownDiag),

	Square[1,1] #< Square[1,N],		% symmetry removal
	Square[1,1] #< Square[N,N],
	Square[1,1] #< Square[N,1],
	Square[1,N] #< Square[N,1],

	% search heuristic: diagonals first, then the rest
	search(UpDiag,0,first_fail,indomain,complete,[]),
	search(DownDiag,0,first_fail,indomain,complete,[]),
	search(Square,0,first_fail,indomain,complete,[]),

	print_square(Square).			% print result


print_square(Square) :-
	dim(Square, [N,N]),
	( for(I,1,N), param(N,Square) do
	    ( for(J,1,N), param(I,Square) do
                Field is Square[I,J],
                printf("%3d", Field)
            ), nl
	), nl.

