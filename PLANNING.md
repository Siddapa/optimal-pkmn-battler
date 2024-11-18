# Branching Initialization
Eventually, potential mons for team generation will be selected from their respective .sav file along with available Items/TMs at that point in the game. Enemy team sets will be pasted in by the end user for whatever game they are playing.


# What are we simulating?
The goal is to create a tree containing every possible option from a starting choice. I was planning on brute forcing every possible outcome for a turn state but quickly reazlied that this is basically not feasible given the sheer quantity of variations. The starting algorithim will need to implement some optimization to ensure that I can test this in a timely manner. Below is a rough list of the potential changes that can occur after or during a turn:
1. Damage Roles (16 non-crit + 16 crit)
2. Status Effects (Tick damage, Move failure from paralysis/infatuation)
3. Dynamic Speed in Doubles (Prankster tailwind, Mid-turn paralysis)
4. Secondary Effects (Flinch, Status conditions, Stat boosts)
5. Weather/Terrain
6. Non-Damaging Moves (Taunt, Future Sight, Disable)


# Simulating Enemy AI
This is kinda difficult to do since it will require extensive research for the base games. ROM hacks like "Run and Bun" and "Emerald Kaizo" have either developer documentation or extensive community efforts, respectively, to understand what the opposing trainer will do given a turn state. In any case, we can work with a few assumptions at least for now:
1. AI never switches
2. AI will always replace a Pokemon with one it sees a kill with (slow or fast)
3. If AI doesn't have any Pokemon with a kill, it'll pick the one with the highest damaging move
4. AI will always go for a kill if it sees one currently
5. When no kills are available, damaging moves are given a higher priority of occuring while non-damaging ones less


# Difficulty in Team Generation
Ideally, the simulation of turns and considering the branches isn't going to be the hardest part of this algorithim. This process is going to very similar to Viterbi algorithim where we continue building the tree from whichever branch has the highest probability of occuring. I'm planning on adding a scoring system on top of this too since there will be a lot of options with equal probability (switching especially needs some metric). The actual hardest part will be backtracking through the tree to a point where we can continue from that won't lead to a dead-end/death. The below diagram somewhat depicts this with the assumption that the user has already chosen a pokemon to lead with on their team:

Enemy Team: Staraptor (Brave Bird), Crobat (Brave Bird, Giga Drain)
Trainer Box: Hitmonlee (Brick Break), Graveler (Rock Throw)

Turn 1: Staraptor vs Hitmonlee
**AI sees bad type match for you, switches**
Turn 2: Staraptor vs Graveler
**Staraptor dies to Rock Throw but you've know taken 2 brave birds**
Turn 3: Crobat vs Graveler
**Croabt now outspeeds and kills everthing else on your team, Graveler already took some chip damage**

Solution is to not lead with Hitmonlee but with Graveler. That way there's no chip damage and it can kill both birds (assuming that's actually feasible in a true Pokemon battle context)

This is a really shit demo but there are a lot of strategies similar to this where counters to enemy Pokemon need to be reserved for specific points in the fight. Below is an extensive list of common Nuzlocke strategies that would need to be implemented:
1. Pivoting to bring in counter Pokemon on a weaker enemy move
2. Pre-damaging to live in certain ranges and bait enemy pokemon in specific order
3. Pre-status to prevent statuses from hitting within the fight
4. Consideration of items (only 1 life orb, focus sash, choice band, etc.)
5. Optimizing for fewer single-use items which might be more useful later in the run
6. PP/Toxic stalling
7. Editing of movesets with Move Relearner or TMs


# Solution to Team Generation
Checks/Counters Guide: *https://www.smogon.com/smog/issue32/checks-and-counters*
We can actually simplify the considerations we need to make for team generation by thinking in terms of checks/counters rather than individual turns. At the end of the day, each matchup will either be a 1v1 or pivoted until a desirable 1v1 is reached. When implemnting this, we can consider for any given matchup 3 choices:
1. Able to 1v1 cleanly without a death
2. Safe switch to a check (with Volt Switch, Flip Turn, etc.)
3. Pivot to a counter

In any of these cases, there needs to be a consideration of whether or not the matchup is the most optimal one. Saving a specific counter for a later point in the fight is often the only way to win that fight.
