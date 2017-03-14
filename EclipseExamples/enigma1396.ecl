%
% Enigma 1396 - Magic planets
% New Scientist magazine, 17 June 2006.
% by W. Haigh.
% 
% I have allocated distinct positive
% integers to the letters of the alphabet.
% By adding up the values of the letters
% in their names, I have obtained the
% following scores for some members of the
% solar system:
% PLUTO 40, URANUS 36, NEPTUNE 29,
% SATURN 33, JUPITER 50, MARS 32, EARTH 31,
% MOON 36, VENUS 39, MERCURY 33, SUN 18.
% 
% Please send in the value of PLANETS.
%
%
% (ECLiPSe solution by Joachim Schimpf)
%
 

:- lib(ic).
:- lib(ic_search).

enigma1396(Vars, Sum) :-
	Vars = [A,C,E,H,I,J,L,M,N,O,P,R,S,T,U,V,Y],
	Vars :: 1..inf,
	alldifferent(Vars),
	sum([P,L,U,T,O]) #= 40,
	sum([U,R,A,N,U,S]) #= 36,
	sum([N,E,P,T,U,N,E]) #= 29,
	sum([S,A,T,U,R,N]) #= 33,
	sum([J,U,P,I,T,E,R]) #= 50,
	sum([M,A,R,S]) #= 32,
	sum([E,A,R,T,H]) #= 31,
	sum([M,O,O,N]) #= 36,
	sum([V,E,N,U,S]) #= 39,
	sum([M,E,R,C,U,R,Y]) #= 33,
	sum([S,U,N]) #= 18,
	sum([P,L,A,N,E,T,S]) #= Sum,

	search(Vars, 0, first_fail, indomain, complete, []).

