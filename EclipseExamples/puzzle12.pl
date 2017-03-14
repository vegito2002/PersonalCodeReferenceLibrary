/*
     A B C D E 
     F G H I J 
     K L M N O 
     P Q R S T 
     U V W X Y 

    Each of the squares in the above grid can be in one of two states,
    lit(white) or unlit(red).  If the player clicks on a square then that
    square and each orthogonal neighbour will toggle between the two
    states.  Each mouse click constitutes one move and the objective of
    the puzzle is to light all 25 squares in the least number of moves. 
*/

:- lib(ic).
:- lib(branch_and_bound).

solve(SquaresClicked) :-
	data(Grid, Neighbours),

	flatten(Grid, SquaresClicked),
	SquaresClicked :: 0..1,

	% To toggle a square's state, an odd number
	% of neighbours must be clicked
	( foreach(SquareNeighbours, Neighbours) do
	    sum(SquareNeighbours) #= 2*_ + 1
	),

	NClicks #= sum(SquaresClicked),
        bb_min(labeling(SquaresClicked), NClicks, bb_options{strategy:step}),
	
	( foreach(Row, Grid) do
	    writeln(Row)
	).


data(
    [			% Grid: Variables are 1 for clicked, 0 otherwise
	[A,B,C,D,E],
	[F,G,H,I,J],
	[K,L,M,N,O],
	[P,Q,R,S,T],
	[U,V,W,X,Y]
    ],
    [			% Neighbours: [left,center,right,above,below]
	[  A,B,   F],
	[A,B,C,   G],
	[B,C,D,   H],
	[C,D,E,   I],
	[D,E,     J],

	[  F,G, A,K],
	[F,G,H, B,L],
	[G,H,I, C,M],
	[H,I,J, D,N],
	[I,J,   E,O],

	[  K,L, F,P],
	[K,L,M, G,Q],
	[L,M,N, H,R],
	[M,N,O, I,S],
	[N,O,   J,T],

	[  P,Q, K,U],
	[P,Q,R, L,V],
	[Q,R,S, M,W],
	[R,S,T, N,X],
	[S,T,   O,Y],

	[  U,V, P  ],
	[U,V,W, Q  ],
	[V,W,X, R  ],
	[W,X,Y, S  ],
	[X,Y,   T  ]
    ]
).
