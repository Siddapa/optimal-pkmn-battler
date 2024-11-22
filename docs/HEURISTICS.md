# Guessing 1v1 w/o Simulating
Ideally, it would be nice to check the capabilities of each 1v1 in its full potential by running every possibility of the 1v1 but his becomes highly computationaly expensive (just considering the tree branching when considering per turn per pokemon). Instead, we need to generate an arbitrary but meaningful heuristic for each 1v1 that is a decent enough marker to NOT consider bad matchups (different from choosing good matchups). There will always be a variety of choices in one's box but elimanting the clearly obvious ones is ideal (golem vs spearow, for example).


# Possible Switch-In Heuristics
Below are a list of possible metrics of a pokemon that could rate them against their matchup. This requires knowledge of not only the player's active pokemon but the opponent's as well. A different (set of/modified) heuristics will be needed depending on situation (opener, switch, move choosing, etc.)


**Type Synergy:**
Not just super effectiveness but resistance as well
    a) P1's attacks super effectiveness on P2
    b) P2's attacks resistance on P1
Could be simplified to assuming STAB moves based on type but checking actual moves is probably more accurate


**Stat Differences:**
Squared sums make the most sense here since it accentuates the differences in 70vs80=100 attack and 40vs80=1600 attack. We want to be retaining the signs of each stat in the sum to ensure that it's applying properly to each side

Stat_Heuristic = sign*(P1.hp - P2.hp)^2 + sign*(P1.atk - P2.atk)^2 + sign*(P1.def - P2.def)^2 + sign*(P1.spatk - P2.spatk)^2 + sign*(P1.spdef - P2.spdef)^2

We'll separate speed into its own category since it doesn't really play into account with survability like the other stats do


**Non-Damaging Moves**
This is a whole can of worms that can significantly change a consideration for a switch-in. Moves like encore, screens, etc. are VERY useful in nuzlockes but hard to account for in a scenario like this. Suffice it to say, we'll be skipping this until damaging moves are first accounted for.
