# Goal
The final optimized decision tree should be a branching tree that shows the most optimal line with minmal risks. However, there should ideally be lines that branch off the optimal line that account for a some amount of variation. Therefore, 2 metrics are required to generate such a tree:
1. What makes a line optimal/minimally risky?
2. What threshold must non-optimal lines qualify for in order to be worthy of consideration?

# Optimal Lines
Starting with the easiest aspect, minimizing risk is quite easy since risk is just the cluminated probability of any side effects occuring during a `Choice` (rolls, crits, secondary effects, etc.). These events are more unlikely than the base event of min rolling on moves (switches are guaranteed, barring no field conditions) which is why we don't want to rely on them being optimal. 
