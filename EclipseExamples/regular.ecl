%
% Regular constraint
%
% by Chris Mears, Monash University
%

:- module(regular).

:- export regular/4.

:- lib(ic).
:- lib(propia).

:- tool(regular/4, regular/5).

% Transition is a ternary predicate describing a DFA transition
% function.  Its arguments are (Input,State,NextState).

% StartState is the initial state of the DFA; FinalStates is a list of
% final states of the DFA.

% Xs is a list/vector of input variables.  The collection itself
% should be instantiated to have the desired length.

regular(Transition, StartState, FinalStates, Xs, Module) :-
        % Qs is a list of state-transition variables.  Conceptually,
        % input variable Xi moves us from state Qi-1 to Qi.

        % Q0 is the start state.
        Qs = [StartState|_],

        % The last state (Qn) is one of the designated final states.
        Qn :: FinalStates,

        % Impose a table constraint (using propia) on each triple of
        % (Xi, Qi-1, Qi), according to the given transition function.
        ( foreacharg(X, Xs),
          fromto(Qs, [Qp,Qi|Qrest], [Qi|Qrest], [Qn]),
          param(Module, Transition) do
            Transition =.. Prefix,
            append(Prefix, [X, Qp, Qi], GoalList),
            Goal =.. GoalList,
            (Goal infers ac)@Module ).

