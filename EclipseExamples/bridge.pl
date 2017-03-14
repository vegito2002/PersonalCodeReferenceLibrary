/**********************************************************************

This is the bridge scheduling problem as described in
Pascal van Hentenryck: Constraint Satisfaction in Logic Programming

**********************************************************************/

:- lib(ic).
:- lib(branch_and_bound).

:- local struct(task(start,duration,need,use)).

solve(End_date) :-
	Tasks = [
	    L, T1, T2, T3, T4, T5, M1, M2, M3, M4, M5, M6,
	    S1, S2, S3, S4, S5, S6, A1, A2, A3, A4, A5, A6, P1, P2,
	    B1, B2, B3, B4, B5, B6, V1, V2,
	    AB1, AB2, AB3, AB4, AB5, AB6, UA, UE, PA, PE
	],
	PA = task{duration : 0, need : []},
	A1 = task{duration : 4, need : [PA], use : excavator},
	A2 = task{duration : 2, need : [PA], use : excavator},
	A3 = task{duration : 2, need : [PA], use : excavator},
	A4 = task{duration : 2, need : [PA], use : excavator},
	A5 = task{duration : 2, need : [PA], use : excavator},
	A6 = task{duration : 5, need : [PA], use : excavator},
	P1 = task{duration : 20, need : [A3], use : pile-driver},
	P2 = task{duration : 13, need : [A4], use : pile-driver},
	UE = task{duration : 10, need : [PA]},
	Start_of_F = task{duration : 0, need : []},
	S1 = task{duration : 8, need : [A1,Start_of_F], use : carpentry},
	S2 = task{duration : 4, need : [A2,Start_of_F], use : carpentry},
	S3 = task{duration : 4, need : [P1,Start_of_F], use : carpentry},
	S4 = task{duration : 4, need : [P2,Start_of_F], use : carpentry},
	S5 = task{duration : 4, need : [A5,Start_of_F], use : carpentry},
	S6 = task{duration : 10, need : [A6,Start_of_F], use : carpentry},
	B1 = task{duration : 1, need : [S1], use : concrete-mixer},
	B2 = task{duration : 1, need : [S2], use : concrete-mixer},
	B3 = task{duration : 1, need : [S3], use : concrete-mixer},
	B4 = task{duration : 1, need : [S4], use : concrete-mixer},
	B5 = task{duration : 1, need : [S5], use : concrete-mixer},
	B6 = task{duration : 1, need : [S6], use : concrete-mixer},
	AB1 = task{duration : 1, need : [B1]},
	AB2 = task{duration : 1, need : [B2]},
	AB3 = task{duration : 1, need : [B3]},
	AB4 = task{duration : 1, need : [B4]},
	AB5 = task{duration : 1, need : [B5]},
	AB6 = task{duration : 1, need : [B6]},
	M1 = task{duration : 16, need : [AB1], use : bricklaying},
	M2 = task{duration : 8, need : [AB2], use : bricklaying},
	M3 = task{duration : 8, need : [AB3], use : bricklaying},
	M4 = task{duration : 8, need : [AB4], use : bricklaying},
	M5 = task{duration : 8, need : [AB5], use : bricklaying},
	M6 = task{duration : 20, need : [AB6], use : bricklaying},
	End_of_M = task{duration : 0, need : [M1,M2,M3,M4,M5,M6]},
	L = task{start : 30, duration : 2, need : [], use : crane},
	T1 = task{duration : 12, need : [M1,M2,L], use : crane},
	T2 = task{duration : 12, need : [M2,M3,L], use : crane},
	T3 = task{duration : 12, need : [M3,M4,L], use : crane},
	T4 = task{duration : 12, need : [M4,M5,L], use : crane},
	T5 = task{duration : 12, need : [M5,M6,L], use : crane},
	UA = task{duration : 10, need : [UE]},
	V1 = task{duration : 15, need : [T1], use : caterpillar},
	V2 = task{duration : 10, need : [T5], use : caterpillar},
	PE = task{duration : 0, need : [T2,T3,T4,UA,V1,V2], start:End_date},

	% Distance constraints  -------------------
	end_to_end_max(S6, B6, 4),
	end_to_end_max(S5, B5, 4),
	end_to_end_max(S4, B4, 4),
	end_to_end_max(S3, B3, 4),
	end_to_end_max(S2, B2, 4),
	end_to_end_max(S1, B1, 4),
	end_to_start_max(A6, S6, 3),
	end_to_start_max(A5, S5, 3),
	end_to_start_max(P2, S4, 3),
	end_to_start_max(P2, S4, 3),
	end_to_start_max(P1, S3, 3),
	end_to_start_max(A2, S2, 3),
	end_to_start_max(A1, S1, 3),
	start_to_start_min(UE, Start_of_F, 6),
	end_to_start_min(End_of_M, UA, -2),

	% Precedence constraints  -------------------
	( foreach(task{start:Si,need:NeededTasks}, Tasks) do
	    Si #>= 0,
	    ( foreach(task{start:Sj,duration:Dj}, NeededTasks), param(Si) do
		Si #>= Sj+Dj
	    )
	),

	( foreach(task{start:S},Tasks), foreach(S,Starts) do true ),

	% Search and optimisation -------------------

        
	bb_min((
                   no_overlaps(Tasks),	% disjunctions
                   labeling(Starts)
               ), End_date, bb_options{strategy:step}).


% some auxliliary definitions

start_to_start_min(task{start:S1}, task{start:S2} , Min) :-
	S1+Min #=< S2.

end_to_end_max(task{start:S1,duration:D1}, task{start:S2,duration:D2}, Max) :-
	S1+D1+Max #>= S2+D2.

end_to_start_max(task{start:S1,duration:D1}, task{start:S2}, Max) :-
	S1+D1+Max #>= S2.

end_to_start_min(task{start:S1,duration:D1}, task{start:S2}, Min) :-
	S1+D1+Min #=< S2.


% tasks can't overlap if they use the same resource
% this is where the disjunctions are

no_overlaps(Tasks) :-
	( fromto(Tasks, [Task0|Tasks0], Tasks0, []) do
	    ( foreach(Task1,Tasks0), param(Task0) do
		Task0 = task{start:S0, duration:D0, use:R0},
		Task1 = task{start:S1, duration:D1, use:R1},
		( R0 == R1 ->
		    no_overlap(S0, D0, S1, D1)
		;
		    true
		)
	    )
	).

no_overlap(Si,Di,Sj,_Dj) :-
	Sj #>= Si+Di.
no_overlap(Si,_Di,Sj,Dj) :-
	Si #>= Sj+Dj.
