%
% ECLiPSe SAMPLE CODE
%
% A Magic Sequence of length n is a sequence of integers x0 .. xn-1
% such that for all i=0 .. n-1: 
%
%	* xi is an integer between 0 and n-1 
%	* the number i occurs exactly xi times in the sequence. 
%

:- lib(ic).
:- lib(ic_global).


solve(N, Sequence) :-

	length(Sequence, N),		% model from definition
	Sequence :: 0..N-1,
	(
	    for(I,0,N-1),
	    foreach(Xi, Sequence),
	    foreach(I, Integers),
	    param(Sequence)
	do
	    occurrences(I, Sequence, Xi)
	),

	N #= sum(Sequence),		% two redundant constraints
	N #= Sequence*Integers,

	search(Sequence, 0, first_fail, indomain, complete, []).

