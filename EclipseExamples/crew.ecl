% 
% From: mekly <mekly at email.com>
% Subject: Re: Crew scheduling/rostering problem, Some questions
% Date: Wed, 09 Apr 2008 20:18:11 -0400
% User-Agent: Pan/0.14.2.91 (As She Crawled Across the Table)
% Message-Id: <pan.2008.04.10.00.18.07.957917@email.com>
% 
% Here is an example of "crew scheduling problem" in Alice ML:
% 
% http://www.ps.uni-sb.de/alice/manual/cptutorial/node56.html
% 
% Solving it in eclipse:
% 

/*
Crew Allocation
A small air-line has to assign their 20 flight attendants to 10 flights.
Each flight has to be accompanied by a certain number of cabin crew
that has to meet a couple of constraints. First, to serve the needs of
international clients the cabin crew has to be able to speak German,
Spanish, and French. Further, a minimal number of stewardesses (resp.
stewards) have to attend a flight. Finally, every cabin crew member
has two flights off after an attended flight. (see given flights and
attendants data below).
*/

:- lib(ic).
:- lib(ic_sets).
:- import subset/2 from ic_sets.

flights(
  [flight( 1,crew:4,stewards:1,stewardesses:1,french:1,spanish:1,german:1),
   flight( 2,crew:5,stewards:1,stewardesses:1,french:1,spanish:1,german:1),
   flight( 3,crew:5,stewards:1,stewardesses:1,french:1,spanish:1,german:1),
   flight( 4,crew:6,stewards:2,stewardesses:2,french:1,spanish:1,german:1),
   flight( 5,crew:7,stewards:3,stewardesses:3,french:1,spanish:1,german:1),
   flight( 6,crew:4,stewards:1,stewardesses:1,french:1,spanish:1,german:1),
   flight( 7,crew:5,stewards:1,stewardesses:1,french:1,spanish:1,german:1),
   flight( 8,crew:6,stewards:1,stewardesses:1,french:1,spanish:1,german:1),
   flight( 9,crew:6,stewards:2,stewardesses:2,french:1,spanish:1,german:1),
   flight(10,crew:7,stewards:3,stewardesses:3,french:1,spanish:1,german:1)]
).

attendants(
     stewards:[tom,david,jeremy,ron,joe,bill,fred,bob,mario,ed],
     stewardesses:[carol,janet,tracy,marilyn,carolyn,cathy,inez,jean,heather,juliet],
     french:[inez,bill,jean,juliet],
     german:[tom,jeremy,mario,cathy,juliet],
     spanish:[bill,fred,joe,mario,marilyn,inez,heather]
).

crew :-
  attendants( stewards:Stewards,
              stewardesses:Stewardesses,
              french:French,
              german:German,
              spanish:Spanish),

  append(Stewards,Stewardesses,Attendants),
  length(Stewards,Nmales),
  length(Stewardesses,Nfemales),
  Nattendants is Nmales + Nfemales,

  % map all symbolic sets to integer sets
  ( foreach(A,Attendants), count(I,1,Nattendants),
    foreach(I,SetAttendants),
    fromto(FrenchSet,FrIn,FrOut,[]),
    fromto(GermanSet,GrIn,GrOut,[]),
    fromto(SpanishSet,SpIn,SpOut,[]),
    param(French,German,Spanish)
  do
    (member(A,French) -> FrIn = [I|FrOut] ; FrOut=FrIn ),
    (member(A,German) -> GrIn = [I|GrOut] ; GrOut=GrIn ),
    (member(A,Spanish) -> SpIn = [I|SpOut] ; SpOut=SpIn )
  ),

  StartFemales is Nmales + 1,
  ( for(I,1,Nmales), foreach(I,SetMales) do true ),
  ( for(I,StartFemales,Nattendants), foreach(I,SetFemales) do true ),

  flights(Flights),

  ( foreach(F,Flights),
    foreach(Crew,Crews),
    param(SetAttendants,SetMales,SetFemales,FrenchSet,GermanSet,SpanishSet)
  do
    F=flight(_,crew:C,stewards:Nwards,stewardesses:Ndesses,french:NFr,spanish:NSp,german:NGr),
    Crew subset SetAttendants,
    #(Crew,C),
    #(Crew /\ SetMales,Cmales), Cmales #>= Nwards,
    #(Crew /\ SetFemales,Cfemales), Cfemales #>= Ndesses,
    #(Crew /\ FrenchSet,CFr), CFr #>= NFr,
    #(Crew /\ GermanSet,CGr), CGr #>= NGr,
    #(Crew /\ SpanishSet,CSp), CSp #>= NSp
  ),

  Crews = [Crew1,Crew2|_RestCrews],     % in case of circular assignments assure
  append(Crews,[Crew1,Crew2],AppCrews), % two days off for crews of the last two flights
  two_days_off(AppCrews, Nattendants),

  ( foreach(Cr,Crews) do insetdomain(Cr,_,_,_) ),

  Att =.. [names|Attendants],

  ( foreach(Cr,Crews), param(Att)
  do
    ( foreach(X,Cr), param(Att)
    do
        arg(X,Att,Name),
        write(Name), write(' ')
    ),
    nl
  ).

two_days_off([X,Y,Z|Rest], Nattendants) :- !,
  all_disjoint([X,Y,Z]),
  #(X)+ #(Y)+ #(Z) #=< Nattendants,	% redundant constraint
  two_days_off([Y,Z|Rest], Nattendants).
two_days_off(_Rest, _Nattendants).

