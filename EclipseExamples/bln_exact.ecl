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
% This file implements the _exact_algorithms_ described in the paper,
% for the approximate algorithms, see the file bln_approx.ecl.
%
% To run a particular benchmark with given strategies, call e.g.
%	?- go(abz6, dichotomic, a, End).
%	?- go(ft10, continue, c, End).
%
% To run the benchmark set from the paper, call
%	?- bench.
% This takes a while...
%


:- use_module(fd_jobshop).
%:- use_module(ic_jobshop).
:- lib(branch_and_bound).


%----------------------------------------------------------------------
% Top level goals
%----------------------------------------------------------------------

bench :-
	printf("%-8s%8s%8s%2s%8s%8s%8s%8s%8s%n", [name,opt,'b&b',h,'#sol',optBT,optCPU,totBT,totCPU]),
	% the branch-and-bound technique
	member(BBStrategy, [continue,dichotomic,restart]),
	% the branching heuristics from [BLN]
	member(Heuristics, [a,b,c]),
	% the benchmarks used in [BLN]
	member(Name, [ft10,abz5,abz6,la19,la20,orb01,orb02,orb03,orb04,orb05]),
%	writeln(bench(Name, BBStrategy, Heuristics)),
	once bench(Name, BBStrategy, Heuristics),
	fail.

bench(Name, BBStrategy, Heuristics) :-
	get_stream(log_output, OldLog),
	set_stream(log_output, null),
	go(Name, BBStrategy, Heuristics, Opt),
	saved_statistics(stat(_,OptT,_OptBT,_OptSBT)),
	current_statistics(stat(Sol,T,_BT,_SBT)),
	atom_string(BBStrategy, StratString),
	substring(StratString, 0, 7, _, StratName),
%	printf("%-8s%8d%8s%2s%8d%8d%8.1f%8d%8.1f%n", [Name,Opt,StratName,Heuristics,Sol,_OptBT,OptT,_BT,T]),
	printf("%-8s%8d%8s%2s%8d%8d%8.1f%8d%8.1f%n", [Name,Opt,StratName,Heuristics,Sol,_OptSBT,OptT,_SBT,T]),
	set_stream(log_output, OldLog).


go(Name, BBStrategy, Heuristics, EndDate) :-
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
	bb_min((
	    	bln_labeling(Heuristics, Resources),
		assign_min_starts(Tasks),
		incval(solutions),
		save_statistics,
		report_statistics
	    ),
	    EndDate,
	    bb_options{strategy:BBStrategy}
	),

	report_statistics,
	make_viewable(Name, Tasks).	% display Gantt chart


%----------------------------------------------------------------------
% The following implements the labeling strategies described in [BLN]
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
