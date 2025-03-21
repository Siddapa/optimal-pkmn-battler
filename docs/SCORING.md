# Preface
Finding the most optimal route down a tree isn't a trivial task given the metrics for scoring and what is actually being scored make a large impact not only in finding that optimal route but also in efficiently growing the tree. So far, the below approaches are the ones on my mind:
1. Scoring transitions where a move (plus the actions that follow it) are weighted in the context of that node's battle scenario
2. Scoring leaf nodes of exhaustive extensions where the node represents the culmination of the transitions above it


# Approach 1
The idea behind scoring transitions is that they are far easier calculations to make and don't require exhaustion of a sub-tree to start pruning. If a transition receives below a score below a certain threshold, we discard its children and continue. The problem is that this doesn't account for multi-turn actions unless I can preemptively 
