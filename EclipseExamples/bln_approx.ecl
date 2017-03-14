%
% Job-Shop Scheduling with ECLiPSe
%
% Author: Joachim Schimpf, IC-Parc, 2005
%
% This code follows closely the techniques described in
%
% [BLN] Baptiste, LePape, Nuijten:
%	Constraint-Based Optimization and Approximation for JSS
%	AAAI SIGMAN workshop on Int.Man.Systems, IJCAI95, Montreal
%	Available from http://citeseer.ist.psu.edu/499726.html
%
% This file implements the _approximate_algorithms_ described in the
% paper, for the exact algorithms, see the file bln_exact.ecl.
%
% To run a particular benchmark, call e.g.
%	?- go(ft10, End).
%
% To run the benchmark set from the paper, call
%	?- bench.
%


:- use_module(fd_jobshop).
%:- use_module(ic_jobshop).
:- lib(branch_and_bound).
:- lib(lists).


%----------------------------------------------------------------------
% Top level program
%----------------------------------------------------------------------

bench :-
	printf("%-8s%8s%8s%8s%8s%8s%8s%n", [name,best,'#sol',optBT,optCPU,totBT,totCPU]),
	member(Name, [ft10,la02,la19,la21,la24,la25,la27,la29,la36,la37,la38,la39,la40]),
	get_stream(log_output, OldLog),
	set_stream(log_output, null),
	once go(Name, Opt),
	set_stream(log_output, OldLog),
	saved_statistics(stat(_,OptT,_OptBT,_OptSBT)),
	current_statistics(stat(Sol,T,_BT,_SBT)),
	printf("%-8s%8d%8d%8d%8.1f%8d%8.1f%n", [Name,Opt,Sol,_OptSBT,OptT,_SBT,T]),
	fail.


go(Name, EndDate) :-
	init_statistics,

	% Read the data
	get_bench(Name, Tasks, NRes, EndDate),

	% Make start time variables
	init_start_times(Tasks),

	% Setup precedence constraints
	precedence_setup(Tasks),

	% Setup resource descriptors
	make_resource_descriptors(Tasks, NRes, Resources),
	setup_disjunctive(Resources),

	% Search

	% The parameters given in [BLN]
	NB = 100, N = 10,
	P = 0.6, PFactor = 0.6, PLimit is 1/(2*functor(Resources,[])),
	Heuristics = [c,d,e,f],
	PostOptimize = false,

	writeln(log_output, nb=NB; n=N; p=P->PFactor->PLimit),

	init_memory(Memory),
	bb_min((
		( no_remembered_values(Memory) ->
		    % find a first solution
		    once (
			bln_labeling(c, Resources),
			assign_min_starts(Tasks),
			incval(solutions), save_statistics, report_statistics
		    ),
		    remember_values(Memory, Resources, P)
		;
		    scale_down(P, PLimit, PFactor, Probability),
			writeln(log_output, p=Probability),
		    member(Heuristic, Heuristics),
			writeln(log_output, h=Heuristic),
		    repeat(N),
%			writeln(log_output, random_restart),
		    install_some_remembered_values(Memory, Resources, Probability),
%		    limit_backtracks(deep, NB),
		    limit_backtracks(shallow, NB),
		    bb_min((
			    bln_labeling(Heuristic, Resources),
			    assign_min_starts(Tasks),
			    incval(solutions), save_statistics, report_statistics
			),
			EndDate,
%			bb_options{strategy:continue,report_failure:true/0}
			bb_options{strategy:dichotomic,report_failure:true/0}
		    ),
		    remember_values(Memory, Resources, Probability)
		)
	    ),
	    EndDate,
	    Tasks,
	    TasksSol,
	    EndApprox,
	    bb_options{strategy:restart,report_success:true/0}
	),

	( PostOptimize == true ->

	    UpperBound is EndApprox-1,
	    unlimit_backtracks(deep),
	    unlimit_backtracks(shallow),
	    bb_min((
		    bln_labeling(c, Resources),
		    assign_min_starts(Tasks),
		    incval(solutions), save_statistics, report_statistics
		),
		EndDate,
		bb_options{strategy:continue,to:UpperBound}
	    )
	;
	    EndDate = EndApprox,
	    Tasks = TasksSol
	),

	report_statistics,
	make_viewable(Name, Tasks).	% display Gantt chart


%----------------------------------------------------------------------
% Search auxiliaries
%----------------------------------------------------------------------

% Succeed N times
repeat(N) :-
	between(1, N, 1, _).


% Succeed several times, reducing X from From to To by Factor
scale_down(From, To, Factor, X) :-
	From >= To,
	(
	    X = From
	;
	    From > To,
	    Next is From*Factor,
	    scale_down(Next, To, Factor, X)
	).


%----------------------------------------------------------------------
% Saving/restoring (parts of) a solution
%----------------------------------------------------------------------

init_memory(Memory) :-
	shelf_create(memory([]), Memory).

no_remembered_values(Memory) :-
	shelf_get(Memory, 1, []).

remember_values(_Memory, _Resources, 0.0) :- !.
remember_values(Memory, Resources, _Probability) :-
	(
	    foreacharg(resource{tasks:Tasks}, Resources),
	    foreach(OrderedPairs, AllOrderedPairs)
	do
	    sort(start of task, =<, Tasks, OrderedTasks),
	    (
		fromto(OrderedTasks, [task{use_index:I}|Ts], Ts, [_]),
		foreach(I-J, OrderedPairs)
	    do
		Ts = [task{use_index:J}|_]
	    )
	),
	shelf_set(Memory, 1, AllOrderedPairs).

install_some_remembered_values(_Memory, _Resources, 0.0) :- !.
install_some_remembered_values(Memory, Resources, Probability) :-
	shelf_get(Memory, 1, AllOrderedPairs),
	(
	    foreacharg(Resource, Resources),
	    foreach(OrderedPairs, AllOrderedPairs),
	    param(Probability)
	do
	    (
		foreach(I-J, OrderedPairs),
		param(Resource,Probability)
	    do
		( frandom =< Probability ->
		    order_tasks(Resource, I, J, 1)
		;
		    true
		)
	    )
	).


%----------------------------------------------------------------------
% The following implements the labeling strategies described in [BLN]
% This is the same as in the exact solution, plus heuristics d, e, f.
%----------------------------------------------------------------------

:- local struct(unscheduled(
    	res,			% resource descriptor
	min_slack,		% smallest slack of all task intervals
	global_slack,		% slack largest task interval
	utasks
    )).


bln_labeling(Strategy, Resources) :-
	% initialise the unscheduled{} structures
	(
	    foreacharg(R, Resources),
	    foreach(unscheduled{res:R,min_slack:0,global_slack:0,utasks:UTasks}, UnschedRes)
	do
	    R = resource{tasks:UTasks}
	),

	% Schedule each resource
	(
	    fromto(UnschedRes, UnschedRes0, UnschedRes3, []),
	    param(Strategy)
	do
	    % find the new slacks for each resource
	    (
		foreach(unscheduled{res:R,utasks:UTasks}, UnschedRes0),
		foreach(unscheduled{res:R,min_slack:MinSlack,global_slack:GlobalSlack,utasks:UTasks}, UnschedRes1)
	    do
		current_task_intervals(UTasks, TIs, LargestTI),
		LargestTI = task_interval{slack:GlobalSlack},
		(
		    foreach(task_interval{slack:Slack},TIs),
		    fromto(10000000, MinSlack0, MinSlack1, MinSlack)
		do
		    MinSlack1 is min(MinSlack0,Slack)
		)
	    ),

	    % pick the resource with smallest (min_slack,global_slack)
	    sort(global_slack of unscheduled, =<, UnschedRes1, UnschedRes2),
	    sort(min_slack of unscheduled, =<, UnschedRes2, UnschedResOrdered),
	    UnschedResOrdered = [unscheduled{res:R,utasks:UTasks}|UnschedRes3],

	    schedule_resource(Strategy, R, UTasks)
	).


schedule_resource(Strategy, R, UnscheduledTasks) :-
	(
	    fromto(UnscheduledTasks, UTasks, RestTasks, []),
	    fromto(0, Indent, Indent1, _),
	    param(Strategy, R)
	do

	    order_tasks_heuristically(Strategy, R, UTasks, SortedUTasks, First),

	    % make the choice
	    count_backtracks(deep),
	    delete(T, SortedUTasks, RestTasks),
	    count_backtracks(shallow),

	    % schedule the chosen task first/last by setting the booleans
	    schedule_task(R, T, RestTasks, First),

	    % T = task with [name:TN],
	    % printf("%*c%*c%4s%n%b", [ResIndent,0'R,Indent,0'.,TN]),
	    Indent1 is Indent+4
	).


order_tasks_heuristically(a, _R, UTasks, SortedUTasks, 1) :-
	order_tasks_est_lst(UTasks, SortedUTasks, _).
order_tasks_heuristically(b, _R, UTasks, SortedUTasks, 0) :-
	order_tasks_lct_ect(UTasks, SortedUTasks, _).
order_tasks_heuristically(c, R, UTasks, SortedUTasks, First) :-
	possible_firsts_and_lasts(R, UTasks, NFirsts, NLasts),
	order_tasks_est_lst(UTasks, AscFirsts, FDiff),
	order_tasks_lct_ect(UTasks, DescLasts, LDiff),
	(  NFirsts < NLasts ->
	    SortedUTasks = AscFirsts, First = 1
	;  NFirsts > NLasts ->
	    SortedUTasks = DescLasts, First = 0
	; FDiff @> LDiff ->
	    SortedUTasks = AscFirsts, First = 1
	;
	    SortedUTasks = DescLasts, First = 0
	).
order_tasks_heuristically(d, R, UTasks, SortedUTasks, First) :-
	possible_firsts_and_lasts(R, UTasks, NFirsts, NLasts),
	order_tasks_edd_est(UTasks, AscFirsts, FDiff),
	order_tasks_lrd_lct(UTasks, DescLasts, LDiff),
	(  NFirsts < NLasts ->
	    SortedUTasks = AscFirsts, First = 1
	;  NFirsts > NLasts ->
	    SortedUTasks = DescLasts, First = 0
	; FDiff @> LDiff ->
	    SortedUTasks = AscFirsts, First = 1
	;
	    SortedUTasks = DescLasts, First = 0
	).
order_tasks_heuristically(e, R, UTasks, SortedUTasks, 1) :-
	possible_firsts_list(R, UTasks, Firsts, Rest),
	shuffle(Firsts, FirstsShuffled),
	append(FirstsShuffled, Rest, SortedUTasks).
order_tasks_heuristically(f, R, UTasks, SortedUTasks, 0) :-
	possible_lasts_list(R, UTasks, Lasts, Rest),
	shuffle(Lasts, LastsShuffled),
	append(LastsShuffled, Rest, SortedUTasks).


%----------------------------------------------------------------------
% Statistics, visualisation, debugging
%----------------------------------------------------------------------

:- local
	variable(start_time),
	variable(solutions).


init_statistics :-
	init_backtrack_count(deep),
	init_backtrack_count(shallow),
	setval(solutions,0),
	cputime(T0),
	setval(start_time,T0).

save_statistics :-
	current_statistics(Stat),
	setval(saved_statistics, Stat).

saved_statistics(S) :-
	getval(saved_statistics, S).

current_statistics(stat(SOL,T,BT,SBT)) :-
	getval(solutions, SOL),
	T is cputime-getval(start_time),
	get_backtracks(deep, BT),
	get_backtracks(shallow, SBT).

report_statistics :-
	T is cputime-getval(start_time),
	get_backtracks(deep, BT),
	get_backtracks(shallow, SBT),
	getval(solutions, SOL),
	writeln(log_output,solutions=SOL;deep_backtracks=BT;s_backtracks=SBT;cputime=T).


%----------------------------------------------------------------------
% Counting and controlling backtracks
%----------------------------------------------------------------------

init_backtrack_count(Name) :-
	Init = bt(shallow,0,1.0Inf,cont),
	local(shelf(Name,Init)),
	shelf_set(Name, 0, Init).

limit_backtracks(Name, Max) :-
	Limit is shelf_get(Name, 2) + Max,
	shelf_set(Name, 3, Limit),
	shelf_set(Name, 4, cont).

unlimit_backtracks(Name) :-
	shelf_set(Name, 3, 1.0Inf).

get_backtracks(Name, Count) :-
	shelf_get(Name, 2, Count).

count_backtracks(Name) :-
	shelf_get(Name, 3, Limit),
	( shelf_get(Name, 2) =< Limit ->
	    shelf_set(Name, 1, shallow)
	;
	    shelf_get(Name, 4, cont),	% fail if already stopped
%	    printf(log_output, "Backtrack limit exceeded: %w (%d)%n", [Name,Limit]),
	    shelf_set(Name, 4, stop),	% print only one message!
	    fail
	).
count_backtracks(Name) :-
	shelf_get(Name, 1, shallow),	% may fail
	shelf_set(Name, 1, deep),
	shelf_inc(Name, 2),
	fail.

/* This is build-in since ECLiPSe 5.9
shelf_inc(Shelf, Index) :-
	shelf_get(Shelf, Index, Count),
	Count1 is Count + 1,
	shelf_set(Shelf, Index, Count1).
*/
