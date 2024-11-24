# Heuristic Method
Generate a few heursitics that could be used the score the value of a switch/move
They would look at immediate features like type matchup, stats, etc.
Or perhaps even some played out scenarios (1v1s, pivoting, setups, etc.)

Advantages:
1. VERY efficient (not too much future looking)
2. Easy to adjust to reltaive scoring of heursitics
3. Good predictor of practical choices made by most nuzlockers

Disadvantages:
1. Difficult to code a lot of the relevant scenarios out
   (How far ahead to look?, What constitutes a good 1v1 (Setup vs OHKO)?)
2. Hard to know if played out scenarios account for best possible move


# Depth First Method
Traverse through the decision tree (with some depth *d*) looking through all possible moves/switches
Score each decision relevant in the context of that turn accounting for moves that weird previously as well
(i.e Setting up while Light Screen is up against a Special Attacker is favorable)

Advantages:
1. Accounts for TRULY every possible scenario
2. Optimizes for best outcome

Disadvantages:
1. Quite memory exhaustive, requiring n**d nodes in tree where *n* is the average number of choices per turn
2. Difficult to score current turn decision for later ones
   (i.e Using light screen for a current Pokemon for another one later to setup)


# Final Approach - Cascading Wave
This is a variation of the Depth First Method that I believe will be far more efficient and much more accurate.
The basic premise is the following:
1. Generate an exhaustive decision tree from a node at depth *d* with height *y* eliminating options that are clearly unwanted
   (i.e early deaths, terrible type matchups, wasted items (little more complex), etc.)
2. Cascade the decision tree back to the starting node, updating the scores at the starting node depending on possible futures
3. Repeat steps 1-2 for all nodes at depth *d*
4. Repeat steps 1-3 all the chlidren of the nodes with *k* highest scores at depth *d*
