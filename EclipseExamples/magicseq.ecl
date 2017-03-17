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
	Sequence :: 0..N-1,  %list 的domain constraint针对的是list 里面的每一个 entry 的.
	(
	    for(I,0,N-1),
	    foreach(Xi, Sequence),
	    foreach(I, Integers),
	    param(Sequence)
	do
	    occurrences(I, Sequence, Xi)  %如果发现无法理解,就,比如10的 output 里面,想这里就是occurrence(0, [6,...], 6),用具体的数字来 plug 进去帮助理解
	),

	N #= sum(Sequence),		% two redundant constraints
	N #= Sequence*Integers,

	search(Sequence, 0, first_fail, indomain, complete, []).

