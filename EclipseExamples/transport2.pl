%----------------------------------------------------------------------
% Example for basic use of ECLiPSe/CPLEX/XPRESS-MP interface
%
% A tiny transportation problem: 3 plants with certain capacity,
% 4 clients with certain demands, transport costs between them.
% Organise the supply such that the transport costs are minimal.
%----------------------------------------------------------------------

:- lib(eplex).
:- lib(matrix_util).


% Version 2: more generic

main2(Cost, Vars) :-
	data(PlantCapacities, ClientDemands, TranspCosts),

	length(PlantCapacities, NPlants),
	length(ClientDemands, NClients),
	matrix(NPlants, NClients, Plants, Clients),	% make variables
	flatten(Clients, Vars),
	Vars :: 0.0..inf,

	( foreach(Client, Clients), foreach(Demand, ClientDemands) do
	    sum(Client) $= Demand
	),
	( foreach(Plant, Plants), foreach(Capacity, PlantCapacities) do
	    sum(Plant) $=< Capacity
	),

	optimize(min(TranspCosts*Vars), Cost).		% solve


data(
    	[500, 300, 400],	% PlantCapacities
	[200, 400, 300, 100],	% ClientDemands
	[ 10, 7, 11,		% TranspCosts
	   8, 5, 10,
	   5, 5,  8,
	   9, 3,  7]
).

