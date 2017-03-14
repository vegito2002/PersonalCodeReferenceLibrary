%
% The binary sudoku as explained here
% http://cstheory.stackexchange.com/questions/16982/how-hard-is-binary-sudoku-puzzle
%
% An NxN matrix must be filled with 0s and 1s such that:
%  - each row and each column contains an equal number of 0s and 1s
%  - no two rows or two columns are identical
%  - no sequences of 3 or more consecutive 0s or 1s in rows or columns
% 
% ?- solve(2, M).
% M = []([](1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0),
%        [](0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1),
%        [](1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0),
%        [](1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0),
%        [](0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1),
%        [](0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0),
%        [](1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1),
%        [](1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1),
%        [](0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0),
%        [](0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0),
%        [](1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1),
%        [](0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1))
% Yes (0.03s cpu, solution 1, maybe more)
% 

:- lib(gfd).

solve(Name, Mat) :-
    problem(Name, Mat),
    dim(Mat, [N,N]),
    Mat #:: 0..1,
    N #= 2*K,
    ( for(I,1,N), param(Mat,K,N) do
        sum(Mat[I,1..N]) #= K,
        sum(Mat[1..N,I]) #= K,
        sequence(1, 2, 3, Mat[I,1..N]),
        sequence(1, 2, 3, Mat[1..N,I]),
        ( for(J,I+1,N), param(Mat,I,N) do
            lex_ne(Mat[I,1..N], Mat[J,1..N]),
            lex_ne(Mat[1..N,I], Mat[1..N,J])
        )
    ),
    labeling(Mat).

problem(2, [](
    [](_,1,0,_,_,_,_,0,_,_,0,_),
    [](_,1,1,_,_,1,_,_,_,_,_,_),
    [](_,_,_,_,_,_,_,_,1,_,_,0),
    [](_,_,0,0,_,_,_,_,_,_,_,0),
    [](_,_,_,_,_,_,1,1,_,0,_,_),
    [](_,1,_,0,_,1,1,_,_,_,1,_),
    [](_,_,_,_,_,_,_,_,1,_,_,_),
    [](1,_,_,1,_,_,_,_,_,_,0,_),
    [](_,1,_,_,_,_,_,_,0,_,_,_),
    [](_,_,_,_,_,_,_,0,_,_,_,_),
    [](1,_,_,_,_,_,_,_,_,_,_,1),
    [](_,1,_,1,_,_,_,_,_,0,0,_))).

