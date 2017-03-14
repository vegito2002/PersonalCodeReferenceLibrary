/*
   The Crowded Chessboard

   Authors: Jesper Hansen, IMM, DTU.
   Authors: Joachim Schimpf, IC-Parc.

   You are given a chessboard together with 8 queens, 8 rooks, 14
   bishops, and 21 knights. The puzzle is to arrange the 51 pieces on
   the chessboard so that no queen shall attack another queen, no rook
   attack another rook, no bishop attack another bishop, and no knight
   attack another knight. No notice is to be taken of the intervention
   of pieces of another type from that under consideration - that is,
   two queens will be considered to attack one another although there
   may be, say, a rook, a bishop, and a knight between them. It is not
   difficult to dispose of each type of piece seperately; the
   difficulty comes in when you have to find room for all the
   arrangements on the board simultaneously. (Dudeney 1917)    
   (Other reference: http://ite.pubs.informs.org/Vol2No2/ChlondToase/)

   In this version we solve the more general problem with N queens, N
   rooks, 2*N-2 bishops and K knights. The number of knights are
   maximised.

   With N =  8, no more than 21 knights can be placed.
   With N =  9, no more than 29 knights can be placed.
   With N = 10, no more than 37 knights can be placed.
   With N = 11, no more than 47 knights can be placed.
   With N = 12, no more than 57 knights can be placed.
   With N = 13, no more than 69 knights can be placed.
   With N = 14, no more than 81 knights can be placed.
   With N = 15, no more than 94 knights can be placed.
   With N = 16, no more than 109 knights can be placed.

   To compute a 21-knights solution, call
   ?- chess(8,21,Solution).
   to compute a maximum-knights solution, call
   ?- chess(8,NK,Solution).
*/

:- lib(eplex).

chess(N,NK,M) :-
	% lp_set(result_channel, +output),
	% lp_set(log_channel, +log_output),

        dim(M,[4,N,N]),			% four NxN boards of booleans
        M[1..4,1..N,1..N] :: 0.0..1.0,

        term_variables(M,AllVars),	% all are integers
        integers(AllVars),
        
        MQ is M[1],			% queens constraints
        term_variables(MQ,VQ),
        sum(VQ) $= N,
        queens(N,MQ),
        
        MR is M[2],			% rooks constraints
        term_variables(MR,VR),
        sum(VR) $= N,
        rooks(N,MR),
        
        MB is M[3],			% bishops constraints
        term_variables(MB,VB),
        NBishops is 2*N-2,
        sum(VB) $= NBishops,
        bishops(N,MB),
        bishops_extra(N,MB),		% optional redundant constraint
        
        MK is M[4],			% knights constraints
        term_variables(MK,VK),
        sum(VK) $= NK,
        knights(N,MK),
        
        (for(I,1,N),			% only one piece on every field
         param(M,N) do
             (for(J,1,N),
              param(I,M) do
		sum(M[1..4,I,J]) $=< 1
             )
        ),

	integers([NK]),
        optimize(max(NK),_C),		% maximise using eplex

        writeln(knights=NK),
	print_board(M, N).


print_board(M, N) :-
        (for(I,1,N),
         param(M,N) do
             (for(J,1,N),
              param(I,M) do
                  ( M[1,I,J] =:= 1 -> write('Q ')
                  ; M[2,I,J] =:= 1 -> write('R ')
                  ; M[3,I,J] =:= 1 -> write('B ')
                  ; M[4,I,J] =:= 1 -> write('K ')
                  ;                   write('  ')
                  )
             ),
             nl
        ).


/* 
        Constrain all the diagonals to have at most one bishop.
 */
bishops(N,M) :-
        (for(I,1,N-1),
         param(M,N) do
            (for(J,1,I),
             foreach(C1,Diag1),
             foreach(C2,Diag2),
             param(I,M,N) do
                 C1 is M[I-J+1,J],	% south->west
                 C2 is M[I-J+1,N-J+1]	% north->west
            ),
            sum(Diag1) $=< 1,
            sum(Diag2) $=< 1,
            (for(J,1,N-I+1),
             foreach(C3,Diag3),
             foreach(C4,Diag4),
             param(I,M,N) do
                 C3 is M[J+I-1,J],	% south->east
                 C4 is M[J+I-1,N-J+1]	% north->east
            ),
            sum(Diag3) $=< 1,
            sum(Diag4) $=< 1
        ).


/* 
        Placing 2*N-1 bishops requires that exactly two bishops
        are placed in the corners corresponding to the two longest
        diagonals. We can fix the two corners and hereby avoid
        symmetries. 
 */
bishops_extra(N,M) :-
        M[N,N] + M[1,N] $= 2. 


/* 
        Instead of less than or equal 1 constraints, we can use equality
        constraints, since exactly one rook of N and one queen of N
        are placed in each row and column.
 */
rooks(N,M) :-
        (for(I,1,N),
         param(M,N) do
	     sum(M[I,1..N]) $= 1,
	     sum(M[1..N,I]) $= 1
	).


/* 
        A queen is just a rook and a bishop combined.
 */
queens(N,M) :-
        rooks(N,M),
        bishops(N,M).


/* 
        Any two fields which are a knight's move apart
	can have at most one knight
 */
knights(N,M) :-
        (for(I,1,N),
         param(M,N) do
             (for(J,1,N),
              param(M,N,I) do
                  add_if_on_board(N,M,I,J,I+1,J+2),
                  add_if_on_board(N,M,I,J,I-1,J+2),
                  add_if_on_board(N,M,I,J,I+2,J+1),
                  add_if_on_board(N,M,I,J,I+2,J-1)
             )
        ).
            
    add_if_on_board(N,M,I1,J1,I,J) :-
        (I >= 1, I =< N, J >= 1, J =< N ->
             M[I,J] + M[I1,J1] $=< 1
        ;
             true
        ).
