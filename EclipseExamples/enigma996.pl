/*

>From New Scientist, 12 September 1998, No 2151, p51

---------------------------------------------------
Enigma 996: Change of Weight - by Richard England
---------------------------------------------------


          T W O
      T H R E E
      T H R E E
      ---------
      E I G H T

YOU may think you have seen this puzzle before but the solution
this time is different. Just as before, each letter stands for
a different digit, the same letter represents the same digit 
wherever it appears and no number starts with zero. But this 
time THREE is an even number.

Once again, if you wish to compete for the prize send in details
for your WEIGHT.

*/

% File:         enigma996.pl
% Author(s):    Vassilis Liatsos <vl@icparc.ic.ac.uk>
%
% Description:  Solution for "Enigma 996: Change of Weight" 
%               in the ECLiPSe constraint programming language
%               Enigma 998 appeared in:
%               "New Scientist, 12 September 1998, No 2151, p51"
%               See description above
%
% Use:          start eclipse:  eclipse
%               load file by:   [enigma996].
%               get solution:   solve(Weight).
%
% Date:         8 October 1998
% Copyright     IC-Parc, Imperial College, UK

/*

Solution to cryptarethmetic puzzle is:


          3 9 1
      3 2 0 6 6
      3 2 0 6 6
      ---------
      6 4 5 2 3

*/

:- lib(ic).

solve([W,E,I,G,H,T]):-
	[C1,C2,C3,C4]::0..2,
	[W,I,G,H,T,R,O,E]::0..9,
	T #> 0,E #> 0,
	% E is even
	E :: [2,4,6,8],
	O + E + E #= C1*10 + T,
	W + E + E + C1 #= C2*10 + H,
	T + R + R + C2 #= C3*10 + G,
	H + H + C3 #= C4*10 + I,
	T + T + C4 #= E,
	alldifferent([W,I,G,H,T,R,O,E]),
	labeling([W,I,G,H,T,R,O,E]).



% Alternative model without carries

solve1([W,E,I,G,H,T]):-
	Letters = [T,W,O,H,R,E,I,G],
	Letters :: 0..9,
	E :: [0,2,4,6,8],
	T #\= 0, E #\= 0,
	alldifferent(Letters),

	                      100*T + 10*W + O
	 + 10000*T + 1000*H + 100*R + 10*E + E
	 + 10000*T + 1000*H + 100*R + 10*E + E
	#= 10000*E + 1000*I + 100*G + 10*H + T,

	labeling(Letters).
