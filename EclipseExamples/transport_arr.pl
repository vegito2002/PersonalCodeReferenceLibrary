%----------------------------------------------------------------------
% Example for basic use of ECLiPSe/CPLEX/XPRESS-MP interface
% This code uses array notation and requires ECLiPSe 4.0 or later.
%
% A tiny transportation problem: 3 plants with certain capacity,
% 4 clients with certain demands, transport costs between them.
% Organise the supply such that the transport costs are minimal.
%----------------------------------------------------------------------

:- lib(eplex).

main3(Cost, Supply) :-
	data(PlantCapacities, ClientDemands, TranspCosts),
	dim(TranspCosts, [NClients,NPlants]),		% get dimensions
	dim(Supply, [NClients,NPlants]),		% make variables
	Supply[1..NClients,1..NPlants] :: 0.0..inf,	% initial bounds

	( for(J,1,NClients), param(NPlants,ClientDemands,Supply) do
	    sum(Supply[J,1..NPlants]) $= ClientDemands[J]
	),

	( for(I,1,NPlants), param(NClients,PlantCapacities,Supply) do
	    sum(Supply[1..NClients,I]) $=< PlantCapacities[I]
	),

	% build objective function expression
	( for(I,1,NPlants), fromto(0, S0, S2, Objective),
	  param(TranspCosts,Supply,NClients)
	do
	    ( for(J,1,NClients), fromto(S0, S1, C+S1, S2),
	      param(TranspCosts,Supply,I)
	    do
		C = TranspCosts[J,I]*Supply[J,I]
	    )
	),
	optimize(min(Objective), Cost).		% solve

data(
	[](500, 300, 400),		% PlantCapacities
	[](200, 400, 300, 100),		% ClientDemands
	[]([](10, 7, 11),		% TranspCosts
	   []( 8, 5, 10),
	   []( 5, 5,  8),
	   []( 9, 3,  7))
).

