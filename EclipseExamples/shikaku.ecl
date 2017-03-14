% 
% CLP puzzle: perfect rectangle fitting
% 
% This question was asked on Stackoverflow on 2016-03-17
% http://stackoverflow.com/questions/36065451/eclipse-clp-puzzle-perfect-rectangle-fitting
% 
% I'm working on a puzzle known as 'divide-by-box'.  In essence, it's a
% form of perfect rectangle fitting, based on given clues.  The rules are:
% 
%   * Some grid cells contain numbers (this is known input data)
%   * The task is to partition the grid area into rectangular rooms
%     satisfying following constraints:  each room contains exactly one
%     number and the total area of the room is equal to the number in it
% 
% E.g.:
% 
% 4 _ 2
% _ _ _
% _ 3 _
% 
% has solution:
% 
% +-----------+
% | 4  . | 2  |
% | .  . | .  |
% |------+----+
% | .   3  .  |
% +-----------+
% 

%
% Sample solution by Joachim Schimpf, March 2016
%
% In the following, rect(I,J,K,L) represents a rectangle
%
%    (I,J)--(K,J)
%      |      |
%    (I,L)--(K,L)
%
% To run, call for example
%   ?- solve(p(15,1), Rects).
% where p(15,1) is the identifier of the problem instance.

:- lib(ic).     % IC solver
%:- lib(gfd).   % Gecode solver


solve(Name, Rects) :-
        problem(Name, M, N, Hints),
        model(M, N, Hints, Rects),
        term_variables(Rects, Xs),
        search(Xs, 0, smallest, indomain, complete, []),
        print_result(M, N, Hints, Rects).


% Model for MxN grid with given Hints of the form (X,Y,Size)
model(M, N, Hints, Rects) :-
        Frame = rect(1,1,M,N),
        ( foreach((I,J,Size),Hints), foreach(Rect,Rects), param(Frame) do
            rect_size(Rect, Size),
            rect_contains_rect(Frame, Rect),
            rect_contains_point(Rect, point(I,J))
        ),
        no_overlap(Rects).

    rect_size(rect(I,J,K,L), Size) :-
        [Height,Width] #:: 1..Size,
        Height*Width #= Size,
        K #= I+Width-1,
        L #= J+Height-1.

    rect_contains_rect(rect(I1,J1,K1,L1), rect(I2,J2,K2,L2)) :-
        I1 #=< I2, K2 #=< K1,
        J1 #=< J2, L2 #=< L1.

    rect_contains_point(rect(I,J,K,L), point(PI,PJ)) :-
        I #=< PI, PI #=< K,
        J #=< PJ, PJ #=< L.

    no_overlap(rect(I1,J1,K1,L1), rect(I2,J2,K2,L2)) :-
        K1#<I2 or K2#<I1 or L1#<J2 or L2#<J1.                   % reified

    no_overlap(Rects) :-
        ( fromto(Rects,[R1|Rs],Rs,[]) do
            ( foreach(R2,Rs), param(R1) do
                no_overlap(R1, R2)
            )
        ).


%---- auxiliaries

% print result grid (hints are marked with a minus sign)
print_result(M, N, Hints, Rects) :-
        dim(Grid, [M,N]),
        ( foreach(rect(I,J,K,L),Rects),
          foreach((HI,HJ,Size),Hints),
          param(Grid) do
            % get bounds, in case I,J,K,L are still variables
            get_max(I, Imax), get_min(K, Kmin),
            get_max(J, Jmax), get_min(L, Lmin),
            ( multifor([X,Y],[Imax,Jmax],[Kmin,Lmin]), param(Grid,HI,HJ,Size) do
                ( [X,Y]==[HI,HJ] -> Label is -Size ; Label = Size ),
                arg([X,Y], Grid, Label)
            )
        ),
        ( multifor([Y,X],[1,1],[N,M]), param(Grid) do
            ( X==1 -> nl ; true ),
            Size is Grid[X,Y],
            ( var(Size) ->
                printf(" ___", [])
            ;
                printf("%4d", [Size])
            )
        ).


%---- PROBLEM INSTANCES

problem(p(15,1),15,15,[(9,1,4),(11,1,2),(12,1,3),(14,1,3),(2,2,4),(3,2,2),(4,2,2),(8,2,12),(2,3,3),(10,3,3),(1,4,2),(10,4,11),(15,5,7),(8,7,36),(12,8,24),(3,9,27),(13,9,24),(15,9,7),(4,11,3),(8,11,2),(7,12,6),(8,12,2),(7,13,3),(8,13,2),(10,13,3),(4,14,7),(9,14,3),(10,14,2),(11,14,2),(12,14,6),(6,15,8)]).

problem(p(15,2),15,15,[(1,1,9),(11,1,2),(13,1,2),(7,3,36),(13,4,3),(14,4,16),(1,6,2),(7,6,24),(4,7,3),(6,7,8),(2,8,6),(3,8,3),(9,8,7),(7,9,9),(15,9,5),(1,10,5),(3,10,2),(11,10,16),(14,10,5),(1,12,2),(4,12,2),(6,12,3),(10,12,6),(11,12,2),(3,13,3),(7,13,2),(12,13,5),(13,13,7),(1,14,2),(14,14,26),(15,14,2)]).

problem(p(20,1),20,20,[(2,1,2),(4,1,2),(11,1,4),(13,1,2),(1,2,2),(5,2,12),(9,2,35),(16,3,15),(19,3,20),(1,4,2),(1,5,2),(4,6,8),(20,6,5),(14,7,2),(3,8,10),(10,8,5),(1,10,4),(5,11,30),(15,13,60),(7,14,24),(12,14,54),(14,14,13),(9,15,54),(1,16,8),(16,18,6),(17,18,3),(19,18,2),(20,18,8),(20,19,3),(18,20,3)]).

problem(p(20,2),20,20,[(3,1,3),(6,1,2),(8,1,4),(2,2,2),(4,2,4),(9,2,3),(16,2,15),(17,2,3),(18,2,6),(11,3,2),(19,3,2),(20,3,3),(1,4,4),(5,4,7),(9,4,2),(17,4,7),(19,4,2),(4,5,5),(9,5,2),(10,5,3),(12,5,9),(1,6,2),(2,6,2),(7,6,18),(2,7,2),(10,7,2),(13,7,20),(1,9,20),(20,9,3),(4,10,3),(11,10,45),(15,12,28),(19,12,2),(20,12,2),(5,13,2),(8,13,3),(15,13,40),(6,14,2),(9,14,12),(3,15,14),(5,15,4),(6,15,6),(18,15,18),(3,16,2),(4,16,6),(5,18,3),(14,18,15),(17,18,2),(3,19,2),(5,19,4),(10,19,2),(2,20,6),(5,20,3),(6,20,2),(8,20,3),(16,20,2),(17,20,2),(20,20,6)]).

problem(p(25,1),25,25,[(2,1,2),(11,1,10),(15,1,8),(17,1,8),(24,1,2),(13,2,2),(14,2,2),(3,3,6),(12,3,32),(25,3,2),(2,4,2),(4,4,2),(14,4,2),(24,4,8),(25,4,2),(4,5,3),(14,5,4),(13,7,2),(1,8,18),(18,8,56),(21,9,6),(22,9,3),(25,9,4),(2,10,6),(19,10,18),(24,10,4),(10,11,60),(14,11,10),(15,11,4),(23,11,3),(2,12,2),(4,12,5),(10,12,4),(22,12,2),(23,12,3),(24,12,6),(6,13,15),(19,13,2),(21,13,2),(2,14,2),(5,14,28),(17,14,3),(20,14,3),(22,14,2),(18,15,3),(21,15,5),(7,16,7),(12,16,3),(15,16,3),(16,16,2),(9,17,2),(11,17,2),(17,17,3),(20,17,16),(7,18,12),(8,18,2),(9,18,3),(12,18,4),(13,18,9),(19,18,12),(24,18,2),(25,18,3),(1,19,2),(5,19,9),(11,19,2),(3,20,2),(5,20,5),(9,20,2),(20,20,7),(7,21,24),(18,22,6),(20,22,3),(21,22,10),(4,23,6),(5,23,3),(7,23,9),(10,23,12),(16,23,24),(17,23,4),(24,23,5),(1,24,2),(18,24,8),(25,24,2),(2,25,4),(17,25,11)]).

problem(p(3040,1),30,40,[
    (2,1,5), (30,1,3),
    (3,2,3), (4,2,2), (6,2,2),
    (1,3,2), (2,3,2),
    (30,4,3),
    (3,5,2), (8,5,184),
    (4,6,6),
    (3,8,2), (30,8,2),
    (1,9,28), (7,9,2), (11,9,5), (15,9,15), (30,9,2),
    (3,10,3), (6,10,16), (8,10,10), (23,10,3), (30,10,3),
    (4,11,3), (5,11,3), (13,11,3), (22,11,2), (23,11,2),
    (5,12,180), (13,12,2), (22,12,6), (25,12,12),
    (27,13,6), (28,13,9),
    (13,14,4), (30,14,6),
    (21,15,2), (24,15,12),
    (25,16,6), (28,16,10),
    (22,17,66),
    (1,18,2), (12,18,10), (13,18,2),
    (27,19,2), (29,19,7),
    (12,22,4), (27,22,3), (30,22,6),
    (20,23,98),
    (1,24,22), (14,24,4),
    (15,25,24), (18,25,4), (20,25,8), (27,25,4),
    (12,26,5), (28,26,8),
    (13,27,11), (29,27,2),
    (18,28,2), (25,28,7), (29,28,2),
    (20,29,5), (23,29,9), (26,29,2), (29,29,2),
    (22,30,2), (27,30,7),
    (1,31,2), (2,31,2), (15,31,5), (18,31,20), (29,31,4), (30,31,8),
    (14,32,14), (15,32,3), (24,32,4), (26,32,3), (29,32,4),
    (2,33,2), (3,33,6), (13,33,5), (23,33,2),
    (4,34,9), (16,34,3), (17,34,4), (22,34,5), (25,34,4), (29,34,5),
    (10,35,32),
    (14,36,5),
    (2,37,8), (18,37,21), (23,37,24),
    (2,38,2), (23,38,44), (30,38,2),
    (29,39,2), (30,39,2),
    (2,40,4), (4,40,12), (6,40,20), (26,40,2), (28,40,3)
]).


% Simple consistency checks on the input data, to find typos
check_problem(Name) :-
        problem(Name, M, N, Hints),
        ( foreach((I,J,S),Hints),
          foreach(S,Ss),
          fromto(0,I0,I,_),
          fromto(0,J0,J,_),
          param(M,N)
        do
            Hint = (I,J,S),
            ( 0<I, I=<M -> true ; writeln(bad_column:Hint) ),
            ( 0<J, J=<N -> true ; writeln(bad_row:Hint) ),
            ( J>J0 ->
                true
            ; J<J0 ->
                writeln(row_decrease:Hint)
            ; % same row
                ( I>I0 -> true ; writeln(no_col_increase:Hint) )
            )
        ),
        T is sum(Ss),
        L is length(Ss),
        ( T =:= M*N -> true ; writeln(M*N =\= T) ),
        writeln(checked:Name;number_of_hints=L).

