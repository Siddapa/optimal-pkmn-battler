# Inspiration
With the Pokemon universe ever-expanding both in the modding community as well as in the mainline games, I've sought to create an optimal pokemon battler that aims to reduce the complexity of calculating lines for pokemon battles. Many other battlers built by the community focus on the competitive scene where battles are done against other players. This battler, however, is targeted towards the actual games themselves meaning there's a clearly obvious mechanic to exploit: **Enemy AI**.


# Approach
The method I'll be utilizing for building the most optimal path is a combination of a decision tree builder along with some scoring function for selecting desirable nodes in the tree. MCTS (Monte Carlo Tree Search) is a quite similar approach used for a variety of other games that is available as a reference for how I'll be designing my algorithim. My process boils down to the following steps:

1. Exhaust the decision tree from the selected root up to a certain depth where child nodes are transitions from that selecte node (moves, switches, box switches, etc.)
2. Utilizing a scoring method that calculates a score for any 2-node pairs
3. Aggregte all scores for a sub-tree and prune any sub-trees that don't reach a high enough score
4. Repeat for the children as the new selected roots

This process is quite concise and doesn't provide a full scope into the technicalities behind some decision. Suffice it to say though, it should provide a general construct to my approach with deeper explanations coming later in documentation.


# Modules
The project is currently divided into 4 modules and 1 globally used dependency:
1. _Tree_ - Decision tree builder that handles generation and pruning of battle transitions
2. _Runners_ - WASM binary that ships with App and contains exported functions that generate and parse decision trees built by Tree
3. _Train/Generate_ - Random generation of training data for Linear Regression Model
4. _App_ - Svelte App that injects data/settings into Runners for display as an interactive graph
5. [_@engine/pkmn_](https://github.com/pkmn/engine) - Global engine used to handle all game mechanics

# Screenshot of Dashboard
![image](https://github.com/user-attachments/assets/27b7a847-ead5-472a-bb96-300839581dd9)
