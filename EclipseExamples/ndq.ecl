% 
% Non-dominating queens problem:
%
%	Place N queens on an NxN board such that the minimal number
%	of squares is under attack. The queens may attack each other.
%
% Author: Joachim Schimpf, IC-Parc
% Requires: ECLiPSe>=5.8
%

:- lib(ic).
:- lib(branch_and_bound).

ndq(N, Board, Attacked, NAttacks) :-
	dim(Board, [N,N]),		% Bool: field [I,J] is occupied
	flatten_matrix(Board, Fields),
	Fields :: 0..1,
	sum(Fields) #= N,

	dim(Attacked, [N,N]),		% Bool: field [I,J] is under attack
	flatten_matrix(Attacked, Attacks),
	Attacks :: 0..1,
	NAttacks #= sum(Attacks),
	( multifor([I,J],1,N), param(Board,Attacked,N) do
	    findall(K-L,
		(between(1,N,1,K), between(1,N,1,L), attacks(K,L,I,J)),
		AttackPos),
	    ( foreach(K-L,AttackPos), param(Board,Attacked,I,J) do
		Attacked[I,J] #>= Board[K,L]
	    )
	),

	bb_min(labeling(Fields), NAttacks, _).


    attacks(K,L,I,J) :-			% field [K,L] attacks [I,J]
	( K =:= I -> true
	; L =:= J -> true
	; K-L =:= I-J -> true
	; K+L =:= I+J
	).

    flatten_matrix(M, Xs) :-
	dim(M, Dims),
	( multifor(Index,1,Dims), foreach(X,Xs), param(M) do
	    subscript(M, Index, X)
	).

