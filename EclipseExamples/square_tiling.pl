
:- nodbgcomp.
:- lib(ic).


% How to cover a square with square tiles of the given sizes

% problem(Nr, SquareSize, TileSizes)
problem(1, 19,[10,9,7,6,4,4,3,3,3,3,3,2,2,2,1,1,1,1,1,1]).
problem(2,112,[50,42,37,35,33,29,27,25,24,19,18,17,16,15,11,9,8,7,6,4,2]).
problem(3,175,[81,64,56,55,51,43,39,38,35,33,31,30,29,20,18,16,14,9,8,5,4,3,2,1]).


squares(ProblemNr, Xs, Ys) :-
        problem(ProblemNr,Size,Sizes),
        squares(Size, Sizes, Xs, Ys).

squares(Size, Sizes, Xs, Ys) :-
        ( foreach(X,Xs), foreach(Y,Ys), foreach(S,Sizes), param(Size) do
            Sd is Size-S+1,
            [X,Y] :: 1..Sd
        ),
        no_overlap(Xs, Ys, Sizes),
        capacity(Xs, Sizes, Size),
        capacity(Ys, Sizes, Size),
        mylabeling(Xs), mylabeling(Ys).

no_overlap(Xs, Ys, Sizes) :-
        ( fromto(Xs,    [X|XXs], XXs, []),
          fromto(Ys,    [Y|YYs], YYs, []),
          fromto(Sizes, [S|SSs], SSs, [])
        do
            ( foreach(X1,XXs), foreach(Y1,YYs), foreach(S1,SSs), param(X,Y,S) do
                    no_overlap(X, Y, S, X1, Y1, S1)
            )
        ).

no_overlap(X1, Y1, S1, X2, Y2, S2) :-
        X1+S1 #=< X2  or  X2+S2 #=< X1  or  Y1+S1 #=< Y2  or  Y2+S2 #=< Y1.

capacity(Cs, Sizes, Size) :-
        ( for(Pos,1,Size), param(Cs,Size,Sizes) do
            ( foreach(C,Cs), foreach(S,Sizes), param(Pos),
              foreach(S*B,Sum)
            do
                    ::(C, Pos-S+1..Pos, B)
            ),
            sum(Sum) #= Size
        ).


mylabeling(InitialList) :-
        search(InitialList, 0, smallest, indomain, complete, []).

