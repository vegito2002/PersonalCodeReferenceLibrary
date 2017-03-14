%
% ECLiPSe SAMPLE CODE
%
% AUTHOR:	Joachim Schimpf, IC-Parc
%
% PROBLEM STATEMENT (I don't recall the source...)
%
% Kalotan males always tell the truth.  Kalotan females never make two
% consecutive true or untrue statements (i.e., they lie and tell the
% truth in strict alteration).  An anthropologist who doesn't know
% Kalotan meets a Kalotan (heterosexual) couple and their child Kibi. 
% He asks Kibi:  "Are you a boy?".  Kibi answers in Kalotan, which the
% anthropologist does not get. 
% 
% The anthropologist turns to the parents for explanation.  One of them
% says:  "Kibi said, 'I am a boy'".  The other adds:  "Kibi is a girl. 
% Kibi lied."
% 
% Solve for the sex of the parents (i.e., which parent made which
% statement) and Kibi. 
% 

:- lib(ic).
:- lib(ic_symbolic).

:-local domain(sex(male, female)).

simple_statement(Sex, Truth) :-
        (Sex &= male) => Truth.             % males always tell truth

consecutive_statements(Sex, Truth1, Truth2) :-
        (Sex &= female) #= (Truth1 #\= Truth2).   % females, well ...

solve([KibiSex,P1Sex,P2Sex]) :-
        [KibiSex,P1Sex,P2Sex] &:: sex, % Our variables
        [KibiMaybeSays,KibiSays,P1Says,P2SaysFirst,P2SaysThen] :: 0..1,
        P1Sex &\= P2Sex,

        KibiMaybeSays  #=   (KibiSex &= male),   % What Kibi possibly said
            simple_statement(KibiSex, KibiMaybeSays),
        P1Says  #=  (KibiSays #= KibiMaybeSays), % What parent 1 said
            simple_statement(P1Sex, P1Says),
        P2SaysFirst   #=   (KibiSex &= female),  % What parent 2 said first
            simple_statement(P2Sex, P2SaysFirst),
        P2SaysThen   #=   (KibiSays #= 0),       % What parent 2 said then
            simple_statement(P2Sex, P2SaysThen),
            consecutive_statements(P2Sex, P2SaysFirst, P2SaysThen),

        ic_symbolic:indomain(KibiSex),
        ic_symbolic:indomain(P1Sex),
        ic_symbolic:indomain(P2Sex).   % find actual values




