%----------------------------------------------------------------------
% Example for basic use of ECLiPSe/CPLEX/XPRESS-MP interface
%
% A tiny transportation problem: 3 plants with certain capacity,
% 4 clients with certain demands, transport costs between them.
% Organise the supply such that the transport costs are minimal.
%----------------------------------------------------------------------

:- lib(eplex).


% Version 1: model and data mixed

main1(Cost, Vars) :-
	Vars = [A1, A2, A3, B1, B2, B3, C1, C2, C3, D1, D2, D3],
	Vars :: 0.0..inf,			% variables

	A1 + A2 + A3 $= 200,			% demand constraints
	B1 + B2 + B3 $= 400,
	C1 + C2 + C3 $= 300,
	D1 + D2 + D3 $= 100,

	A1 + B1 + C1 + D1 $=< 500,		% capacity constraints
	A2 + B2 + C2 + D2 $=< 300,
	A3 + B3 + C3 + D3 $=< 400,

	optimize(min(				% solve
	    10*A1 + 7*A2 + 11*A3 +
	     8*B1 + 5*B2 + 10*B3 +
	     5*C1 + 5*C2 +  8*C3 +
	     9*D1 + 3*D2 +  7*D3), Cost).
