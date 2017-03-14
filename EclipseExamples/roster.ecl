%
% ECLiPSe SAMPLE CODE: Rostering Problem Benchmark
%
% This code was developed in 1999 in the context of
%
%	ESPRIT PROJECT 22165 CHIC-2, www.icparc.ic.ac.uk/chic2
%
% and contains contributions from
%
% 	IC-Parc, Imperial College, London, www.icparc.ic.ac.uk
% 	Bouygues research, Paris, www.bouygues.fr
% 	EuroDecision, Paris, www.eurodecision.fr
%
% The results were reported in CHIC-2 deliverable D 4.3.2 and
% are to appear in an article in the Constraints Journal.
%
% For the problem definition see roster.txt
%
% The code below contains a problem model formulated with finite
% domain constraints, and the three alternative search strategies
% that were originally developed in ECLiPSe (IC2), Claire (BY1)
% and OPL (ED1), and later all ported to ECLiPSe for comparison.
%

:- nodbgcomp.
:- lib(lists).
:- lib(ic).
:- lib(ic_global).
:- lib(branch_and_bound).

%----------------------------------------------------------------------
% Model
%----------------------------------------------------------------------

:- local struct(shift(r,m,e,j,k)).

go(Strategy, Name, Cost) :-
	cputime(StartTime),

	% Data -----------------
	data(Name, NWeeks, NLabels, NDays, Data),

	% Model -----------------
	dim(Roster, [NWeeks,NDays]),		% Make both a matrix and ...
	Rows is Roster[1..NWeeks,1..NDays],
	flatten(Rows, Vars),			% a flat list of the variables
	length(Vars, NVars),
	Vars :: 1..NLabels,			% They range over the labels

	% Debugging support
	make_display_matrix(Roster, roster),

	% Constraints for the required number of labels on each day
	( for(Label,1,NLabels), param(Data,Roster,NDays,NWeeks) do
	    ( for(Day, 1, NDays), param(Data,Roster,Label,NWeeks) do
		Required is Data[Label,Day],
		Days is Roster[1..NWeeks,Day],
		occurrences(Label, Days, Required)
	    )
	),

	% Append the variables-list to a copy of itself
	% to make it easier to set up the cyclic constraints
	append(Vars, Vars, VarsWithOverlap),

	% Set up constraints on sub-sequences of days
	(
	    for(I,1,NVars),
	    fromto(VarsWithOverlap, RestVars, RestVars1, _),
	    fromto(AllViolations, [Viol1,Viol2|Violations], Violations, [])

	do
	    RestVars = [_|RestVars1],

	    % In every 7 days there must be at least 1 day off
	    first_n(7, RestVars, Consec7),
	    occurrences(r of shift, Consec7, DaysOffIn7),
	    DaysOffIn7 :: 1..6,

	    % No more than 3 consecutive days off
	    first_n(4, RestVars, Consec4),
	    occurrences(r of shift, Consec4, DaysOffIn4),
	    DaysOffIn4 :: 0..3,

	    % SOFT: No m after e
	    RestVars = [SomeDay,NextDay|_],
	    Viol1  #=  (SomeDay #= e of shift  and  NextDay #= m of shift),

	    % SOFT: No isolated day off
	    RestVars = [Before,Off,After|_],
	    Viol2  #=  (Off #= r of shift
	    	and Before #\= r of shift
		and  After #\= r of shift)
	),
	Cost #= sum(AllViolations),

	% Search -----------------
	bb_min((
    	    my_search(Strategy, NDays, NWeeks, Data, Roster),
	    search(Vars, 0, first_fail, indomain, complete, [])
	    ),
	    Cost,
            bb_options{strategy:step,
                             from:0, to:1000,  % initial cost bounds
                             delta:0.01,       % minimum percentage improvement
                             timeout:60,       % seconds timeout
			     report_success:print_success(StartTime),
			     report_failure:print_failure(StartTime)
                            }),
	% Print the results -----------------
%	print_roster(Roster),
	true.


my_search(ic,_NDays,_NWeeks, Data, Roster) :-
	ic_col_labeling(Data, Roster).
my_search(by, NDays, NWeeks, Data, Roster) :-
	bouygues_labeling(NDays, NWeeks, Data, Roster).
my_search(ed, NDays, NWeeks, Data, Roster) :-
	ed_labeling(NDays, NWeeks, Data, Roster).


%----------------------------------------------------------------------
% Utilities
%----------------------------------------------------------------------

    % get the first N elements of a list
    first_n(N, List, FirstN) :-
    	length(FirstN, N),
	append(FirstN, _, List).


    print_roster(Roster) :- 
	dim(Roster, [NWeeks,NDays]),
	( for(Week,1,NWeeks), param(Roster,NDays) do
	    ( for(Day, 1, NDays), param(Roster,Week) do
		Table = shift{r:'R',m:'M',e:'E',j:'J',k:'K'},
		Post is Roster[Week,Day],
		( var(Post) -> Symbol= ? ; Symbol is Table[Roster[Week,Day]]),
		printf(" %w ", [Symbol])
	    ), nl
	), nl.


    try_day_off(X) :- eval(X) #= r of shift.
    try_day_off(X) :- eval(X) #\= r of shift.



%----------------------------------------------------------------------
% IC2 Search strategy
%----------------------------------------------------------------------

   ic_col_labeling(Data, Roster) :-
	dim(Roster, [NWeeks,NDays]),
	% find the column with the smallest number of Days off
	(
	    for(I,1,NDays),
	    fromto(1,OldMinCol,NewMinCol,MinCol),
	    param(Data)
	do
	    ( Data[r of shift, I] < Data[r of shift, OldMinCol] ->
	    	NewMinCol = I
	    ;
		NewMinCol = OldMinCol
	    )
	),
	DailyShift is NWeeks//NDays,
	(
	    for(I,MinCol,MinCol+NDays-1),
	    fromto(0, Offset1, Offset2, _),
	    param(DailyShift,Roster,NWeeks,NDays)
	do
	    Offset2 is Offset1+DailyShift,
	    (
	    	for(J,Offset1,Offset1+NWeeks-1), param(Roster,I,NWeeks,NDays)
	    do
	    	try_day_off(Roster[J mod NWeeks + 1, (I-1) mod NDays + 1])
	    )
	).



%----------------------------------------------------------------------
% BY1 search strategy
%----------------------------------------------------------------------

    bouygues_labeling(NDays, NWeeks, Data, Roster) :-
	place_days_off(NDays, NWeeks, Data, Roster),
	place_remaining(NDays, NWeeks, Data, Roster).

    place_days_off(NDays, NWeeks, Data, Roster) :-
    	( best_column(Roster, NWeeks, Data, NDays, BestWD) ->
	    place_day_off(NDays, NWeeks, Data, Roster, BestWD)
	;
%	    ( printf("End heuristics%n%b",[])
%	    ; printf("Back to heuristics%n%b",[]),fail )
	    true
	).

    place_day_off(NDays, NWeeks, Data, Roster, BestWD) :-
	best_week(NDays, NWeeks, Roster, BestWD, BestW), % may fail
%	printf("Trying [%d,%d]%n%b",[BestW,BestWD]),
	(
	    Roster[BestW,BestWD] #= r of shift,
	    place_days_off(NDays, NWeeks, Data, Roster)
	;
	    Roster[BestW,BestWD] #\= r of shift,
	    place_day_off(NDays, NWeeks, Data, Roster, BestWD)
	).

    % find the column with max unassigned rest days (>=2) or fail
    best_column(Roster, NWeeks, Data, NDays, BestWD) :-
    	(
	    for(Day, 1, NDays),
	    fromto(2, MaxReq0,  MaxReq1,  _),
	    fromto(_, BestWD0, BestWD1, BestWD),
	    param(Data,Roster,NWeeks)
	do
	    Req is Data[r of shift, Day] - sure_coverage(Roster, r of shift, Day, NWeeks),
	    ( Req >= MaxReq0 ->
	    	MaxReq1 = Req, BestWD1 = Day
	    ;
	    	MaxReq1 = MaxReq0, BestWD1 = BestWD0
	    )
	),
	nonvar(BestWD).	% fail if none found

    % find the row/week with min assigned rest days
    best_week(NDays, NWeeks, Roster, BestWD, BestW) :-
    	(
	    for(I,1,NWeeks),
	    fromto(_,     BestW0,     BestW1,     BestW),
	    fromto(10000, MinAssign0, MinAssign1, _),
	    param(NDays,Roster,BestWD)
	do
	    Candidate is Roster[I,BestWD],
	    ( % only consider weeks where BestWD is a choice for rest day
		var(Candidate),
                is_in_domain(r of shift, Candidate)
	    ->
		( % count already assigned rest days in this week 
		    for(J,1,NDays),
		    fromto(0, NAssign0, NAssign1, NAssign),
		    param(Roster,I)
		do
		    D is Roster[I,J],
		    ( D == r of shift ->
		    	NAssign1 is NAssign0+1
		    ;
		    	NAssign1 = NAssign0
		    )
		),
		( NAssign < MinAssign0 ->
		    BestW1 = I, MinAssign1 = NAssign
		;
		    BestW1 = BestW0, MinAssign1 = MinAssign0
		)
	    ;
	    	BestW1 = BestW0, MinAssign1 = MinAssign0
	    )
	),
	nonvar(BestW).	% fail if none found


% place_remanining

place_remaining(NDays, NWeeks, Data, Roster) :-
	worst_week_day(Roster, NDays, NWeeks, WD),
	( nonvar(WD) ->
	    place_on_wd(NDays, NWeeks, Data, Roster, WD)
	;
	    true
	).
	
% place_on_wd corresponds to while(true) in Claire code
place_on_wd(NDays, NWeeks, Data, Roster, WD) :-
	worst_needed_activity(Data, Roster, NWeeks, WD, Act),
	nonvar(Act),
	worst_week(Roster, NDays, NWeeks, Act, WD, W),
	nonvar(W),
	X is Roster[W,WD],
	(
	    X = Act,
	    place_remaining(NDays, NWeeks, Data, Roster)
	;
	    X #\= Act,
	    place_on_wd(NDays, NWeeks, Data, Roster, WD)
	).

count_occupied(Roster, NWeeks, WD, Count) :-
	( for(W,1,NWeeks), fromto(0,C0,C1,Count), param(Roster,WD) do
	    X is Roster[W,WD],
	    ( nonvar(X) -> C1 is C0+1 ; C1=C0 )
	).

worst_week_day(Roster, NDays, NWeeks, WorstWD) :-
	(
	    for(WD, 1, NDays),
	    fromto(NWeeks, WorstOcc0,  WorstOcc1,  _),
	    fromto(_,      WorstWD0, WorstWD1, WorstWD),
	    param(Roster, NWeeks)
	do
	    count_occupied(Roster, NWeeks, WD, Count),
	    ( Count < WorstOcc0 ->
	    	WorstOcc1=Count, WorstWD1=WD
	    ;
	    	WorstOcc1=WorstOcc0, WorstWD1=WorstWD0
	    )
	).

worst_week(Roster, NDays, NWeeks, A, WD, BestW) :-
	(
	    for(W, 1, NWeeks),
	    fromto(_, BestW0, BestW1, BestW),
	    fromto(0, WorstA0, WorstA1, _),
	    param(Roster, NDays, A, WD)
	do
	    Candidate is Roster[W,WD],
	    (
		var(Candidate),
                is_in_domain(A, Candidate)
	    ->
	        ( for(WD2,1,NDays), fromto(0,C0,C1,NumUnAss), param(Roster,W) do
		    X is Roster[W,WD2],
		    ( var(X) -> C1 is C0+1 ; C1=C0 )
		),
		( NumUnAss > WorstA0 ->
		    WorstA1=NumUnAss, BestW1=W
		;
		    WorstA1=WorstA0, BestW1=BestW0
		)
	    ;
		WorstA1=WorstA0, BestW1=BestW0
	    )
	).

worst_needed_activity(Data, Roster, NWeeks, WD, WorstA) :-
	NAct is functor(shift{}, _),
	(
	    for(A, 1, NAct),
	    fromto(_, WorstA0, WorstA1, WorstA),
	    fromto(0, WorstNeed0, WorstNeed1, _),
	    param(Roster, Data, WD, NWeeks)
	do
	    Need is Data[A, WD] - sure_coverage(Roster, A, WD, NWeeks),
	    ( Need > WorstNeed0 ->
	    	WorstNeed1=Need, WorstA1=A
	    ;
	    	WorstNeed1=WorstNeed0, WorstA1=WorstA0
	    )
	).


    sure_coverage(Roster, Act, WD, NWeeks, Sure) :-
    	(
	    for(W,1,NWeeks),
	    fromto(0, C0, C1, Sure),
	    param(Roster,Act,WD)
	do
	    X is Roster[W,WD],
 	    ( X == Act -> C1 is C0+1 ; C1=C0 )
	).


 
%----------------------------------------------------------------------
% ED1 search strategy
%----------------------------------------------------------------------

    ed_labeling(NDays, NWeeks, Data, Roster) :-
	A = 5,
	( for(I,2,NWeeks), param(Roster,NDays,A) do
	    try_day_off(Roster[I, NDays - (I*NDays) mod (A+1)])
	),
	( for(I,2,NWeeks), param(Roster,NDays,A) do
	    ( (I*NDays) mod (A+1) < NDays-A-1  ->
		try_day_off(Roster[I, NDays - A - (I*NDays) mod (A+1)])
	    ;
		true
	    )
	),
	Data=_,
	once (
	    between(1,NDays,1,J),
	    Roster[1,J] #= r of shift
	),
	( for(I,2,NWeeks), param(Roster,NDays) do
	    ( for(J,1,NDays), param(I,Roster) do
		try_day_off(Roster[I,J])
	    )
	),
	( for(I,1,NWeeks), param(Roster,NDays) do
	    ( for(J,2,NDays-1), param(I,Roster) do
		Z is Roster[I,J],
		( Z == r of shift ->
		    ( Roster[I,J-1] #=  r of shift
		    ; Roster[I,J+1] #=  r of shift
		    ; Roster[I,J-1] #\= r of shift
		    )
		;
		    true
		)
	    )
	).



%----------------------------------------------------------------------
% Data sets
%----------------------------------------------------------------------

data(i5, 5, 5, 7, shift{
	    r: week(3,2,1,0,1,1,5),	% Day-off
	    m: week(1,0,1,0,1,2,0),	% Morning
	    e: week(1,2,0,1,1,1,0),	% Evening
	    j: week(0,1,2,2,2,1,0),	% Mid-day
	    k: week(0,0,1,2,0,0,0)	% Joker
	}).

data(i7, 7, 5, 7, shift{
	    r: week(2,2,2,2,2,2,2),	% Day-off
	    m: week(0,0,0,0,0,0,2),	% Morning
	    e: week(0,0,0,0,0,0,0),	% Evening
	    j: week(3,3,3,3,3,2,0),	% Mid-day
	    k: week(2,2,2,2,2,3,3)	% Joker
	}).

data(i9, 9, 5, 7, shift{
	    r: week(5,5,4,7,4,7,5),	% Day-off
	    m: week(0,0,0,0,0,0,0),	% Morning
	    e: week(2,0,2,0,2,0,3),	% Evening
	    j: week(1,3,0,1,2,1,0),	% Mid-day
	    k: week(1,1,3,1,1,1,1)	% Joker
	}).

data(i9a, 9, 5, 7, shift{
	    r: week(6,7,5,4,3,8,4),	% Day-off
	    m: week(0,0,0,0,0,0,0),	% Morning
	    e: week(0,0,0,0,0,0,0),	% Evening
	    j: week(3,2,4,5,6,1,5),	% Mid-day
	    k: week(0,0,0,0,0,0,0)	% Joker
	}).

data(i10, 10, 5, 7, shift{
	    r: week(3,4,2,3,3,3,2),	% Day-off
	    m: week(0,0,0,0,0,0,0),	% Morning
	    e: week(2,2,2,2,2,0,3),	% Evening
	    j: week(2,1,3,2,2,4,2),	% Mid-day
	    k: week(3,3,3,3,3,3,3)	% Joker
	}).

data(i12, 12, 5, 7, shift{
            r: week(4,6,5,6,6,6,6),     % Day-off
            m: week(3,2,2,3,2,4,2),     % Morning
            e: week(4,2,2,1,1,0,1),     % Evening
            j: week(0,1,1,0,1,0,1),     % Mid-day
            k: week(1,1,2,2,2,2,2)      % Joker
        }).

data(i12a, 12, 5, 7, shift{
	    r: week(7,4,5,7,6,4,4),	% Day-off
	    m: week(0,0,0,0,0,0,1),	% Morning
	    e: week(0,4,2,3,3,1,1),	% Evening
	    j: week(4,2,3,0,1,5,3),	% Mid-day
	    k: week(1,2,2,2,2,2,3)	% Joker
	}).

data(i12b, 12, 5, 7, shift{
	    r: week(3,3,3,3,4,3,3),	% Day-off
	    m: week(0,0,0,0,0,0,0),	% Morning
	    e: week(0,3,1,2,2,1,2),	% Evening
	    j: week(5,2,5,3,3,4,3),	% Mid-day
	    k: week(4,4,3,4,3,4,4)	% Joker
	}).

data(i16, 16, 5, 7, shift{
	    r: week(7,7,8,6,7,7,7),	% Day-off
	    m: week(0,0,0,0,2,0,0),	% Morning
	    e: week(5,6,3,6,3,1,4),	% Evening
	    j: week(2,0,2,1,1,5,2),	% Mid-day
	    k: week(2,3,3,3,3,3,3)	% Joker
	}).

data(i18, 18, 5, 7, shift{
	    r: week(8,5,6,6,6,5,4),	% Day-off
	    m: week(0,4,5,2,2,5,4),	% Morning
	    e: week(2,2,2,2,2,1,2),	% Evening
	    j: week(3,2,0,3,2,1,2),	% Mid-day
	    k: week(5,5,5,5,6,6,6)	% Joker
	}).

data(i20, 20, 5, 7, shift{
	    r: week(9,10,8,9,9,9,8),	% Day-off
	    m: week(0,0,0,0,1,0,0),	% Morning
	    e: week(2,5,4,5,6,3,4),	% Evening
	    j: week(5,2,4,2,1,5,4),	% Mid-day
	    k: week(4,3,4,4,3,3,4)	% Joker
	}).

data(i21, 21, 5, 7, shift{
	    r: week(9,9,9,10,10,10,10),	% Day-off
	    m: week(0,0,0,0,0,0,0),	% Morning
	    e: week(0,1,0,0,1,0,3),	% Evening
	    j: week(9,8,8,8,7,8,6),	% Mid-day
	    k: week(3,3,4,3,3,3,2)	% Joker
	}).

data(i23, 23, 5, 7, shift{
	    r: week(5,5,6,6,6,6,6),	% Day-off
	    m: week(0,0,0,0,0,0,0),	% Morning
	    e: week(3,6,2,5,7,3,5),	% Evening
	    j: week(8,5,8,4,3,7,5),	% Mid-day
	    k: week(7,7,7,8,7,7,7)	% Joker
	}).

data(i23a, 23, 5, 7, shift{
	    r: week(7,8,7,4,5,17,7),	% Day-off
	    m: week(5,6,5,7,6,2,2),	% Morning
	    e: week(0,4,0,1,0,0,0),	% Evening
	    j: week(11,5,11,11,12,4,14), % Mid-day
	    k: week(0,0,0,0,0,0,0)	% Joker
	}).

data(i24, 24, 5, 7, shift{
            r: week(8,9,5,7,9,8,3),     % Day-off
            m: week(4,3,4,3,2,0,3),     % Morning
            e: week(6,5,8,7,5,7,5),     % Evening
            j: week(2,3,2,3,4,5,8),     % Mid-Day
            k: week(4,4,5,4,4,4,5)      % Joker
        }).

data(i24a, 24, 5, 7, shift{
	    r: week(9,9,5,7,9,8,3),	% Day-off
	    m: week(3,3,4,3,2,0,3),	% Morning
	    e: week(6,5,8,7,5,7,5),	% Evening
	    j: week(2,3,2,3,4,5,8),	% Mid-Day
	    k: week(4,4,5,4,4,4,5)	% Joker
        }).

data(i24b, 24, 5, 7, shift{
	    r: week(10,8,10,10,10,9,10),	% Day-off
	    m: week( 0,3, 0, 2, 1,1, 2),	% Morning
	    e: week( 3,4, 4, 1, 3,2, 2),	% Evening
	    j: week( 7,5, 6, 8, 6,8, 7),	% Mid-Day
	    k: week( 4,4, 4, 3, 4,4, 3)		% Joker
        }).

data(i26, 26, 5, 7, shift{
	    r: week( 8, 7, 7, 3, 8, 9, 7),	% Day-off
	    m: week( 5, 2, 3, 5, 5, 2, 4),	% Morning
	    e: week( 1, 2, 1, 3, 1, 0, 2),	% Evening
	    j: week( 5, 7, 7, 7, 4, 7, 6),	% Mid-Day
	    k: week( 7, 8, 8, 8, 8, 8, 7)	% Joker
        }).

data(i30, 30, 5, 7, shift{
	    r: week( 9, 9,10, 9,10,14,10),	% Day-off
	    m: week( 0, 0, 0, 0, 0, 0, 0),	% Morning
	    e: week(10, 9, 8, 8, 7, 4,10),	% Evening
	    j: week(10,12,12,13,13,12,10),	% Mid-Day
	    k: week( 1, 0, 0, 0, 0, 0, 0)	% Joker
        }).

data(i60, 60, 5, 7, shift{
	    r: week( 18, 18,20, 18,20,28,20),	% Day-off
	    m: week(0, 0, 0, 0, 0, 0,0),	% Morning
	    e: week(20, 18, 16, 16, 14, 8,20),	% Evening
	    j: week(20,24,24,26,26,24,20),	% Mid-Day
	    k: week(2, 0, 0, 0, 0, 0, 0)	% Joker
        }).

data(i120, 120, 5, 7, shift{
	    r: week( 36, 36,40, 36,40,56,40),	% Day-off
	    m: week(0, 0, 0, 0, 0, 0,0),	% Morning
	    e: week(40, 36, 32, 32, 28, 16,40),	% Evening
	    j: week(40,48,48,52,52,48,40),	% Mid-Day
	    k: week(4, 0, 0, 0, 0, 0, 0)	% Joker
        }).

data(i240, 240, 5, 7, shift{
	    r: week( 72, 72,80, 72,80,112,80),	% Day-off
	    m: week(0, 0, 0, 0, 0, 0,0),	% Morning
	    e: week(80, 72, 64, 64,56,32,80),	% Evening
	    j: week(80,96,96,104,104,96,80),	% Mid-Day
	    k: week(8, 0, 0, 0, 0, 0, 0)	% Joker
        }).


%----------------------------------------------------------------------
% Test toplevel
%----------------------------------------------------------------------

% The list of problem instances reported in the comparative study.
% (additional data sets above were added after the study was made)

problem_instance(i5).
problem_instance(i7).
problem_instance(i9).
problem_instance(i10).
problem_instance(i12).
problem_instance(i12a).
problem_instance(i12b).
problem_instance(i16).
problem_instance(i18).
problem_instance(i20).
problem_instance(i21).
problem_instance(i23).
problem_instance(i24).
problem_instance(i26).
problem_instance(i30).

strategy(ic).
strategy(ed).
strategy(by).

go :-
	strategy(Strategy),
	printf("-------- strategy: %w ---------%n", [Strategy]),
	problem_instance(Name),
	printf("%w%n", [Name]),
	/*
	cputime(T0),
	setval(best_time, T0),
	( go(Strategy, Name, Cost) ->
	    T is cputime-T0,
	    Tbest is getval(best_time)-T0,
	    printf("	%.2fs	best cost %d after %.2fs%n", [T,Cost,Tbest])
	;
	    T is cputime-T0,
	    printf("	%.2f	no sol%n", [T])
	),
	fail.
	*/
	go(Strategy, Name, Cost),
	fail.
go.


% change branch-and-bound messages
print_success(StartTime, Cost, _, _) :-
	T is cputime - StartTime,
	printf(log_output, "Found a solution with cost %q after %.2fs%n", [Cost,T]).

print_failure(StartTime, Cost, _, _) :-
	T is cputime - StartTime,
	printf(log_output, "Proved no solution with cost %q after %.2fs%n", [Cost,T]).

