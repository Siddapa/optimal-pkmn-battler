const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const pkmn = @import("pkmn");

pub const tools = @import("tools.zig");
pub const enemy_ai = @import("enemy_ai.zig");
pub const scorer = @import("scorer.zig");

pub const score_t = f32;

// Maximum number of levels to build tree to
const MAX_TURNLEVEL: u16 = 50;

// Number of levels to extend tree by at some node
const LOOKAHEAD: u4 = 1;

// Maximum number of nodes to optimize for at a given level
const K_LARGEST: u16 = 3;

// floatMin() provides smallest POSITIVE float which messes with @min()
// Arbitrary min value that could fail
pub const ALPHA_MIN: score_t = -1e30;
pub var PRUNING: bool = true;

// Binary mask for which of the 16 rolls to generate
const ROLL_INTERVALS: u16 = 0b1000000000000000;

comptime {
    assert(LOOKAHEAD > 0);
    assert(K_LARGEST > 0);
    assert(ROLL_INTERVALS != 0);
}

var node_count: usize = 0;

/// Structs for buliding decision tree
pub const DecisionNode = struct {
    id: usize = 0,
    prev_node: ?*DecisionNode = null,
    battle: pkmn.gen1.Battle(pkmn.gen1.PRNG),
    team: [6]TeamSlotState,
    result: pkmn.Result,
    score: score_t = 0,
    transitions: std.ArrayList(*DecisionNode),
    // Below fields represent options for arriving at the current node
    // from a previous node
    choices: [2]pkmn.Choice = .{ pkmn.Choice{}, pkmn.Choice{} },
    chance: struct {
        actions: pkmn.gen1.chance.Actions = pkmn.gen1.chance.Actions{},
        durations: pkmn.gen1.chance.Durations = pkmn.gen1.chance.Durations{},
    } = .{},
};
const TeamSlotState = union(enum) {
    Empty,
    Lead,
    Filled: usize,
};
const Update = struct {
    battle: pkmn.gen1.Battle(pkmn.gen1.PRNG),
    actions: pkmn.gen1.chance.Actions,
    durations: pkmn.gen1.chance.Durations,
    probability: score_t,
    result: pkmn.Result,
};

pub fn optimal_decision_tree(
    starting_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG),
    starting_result: pkmn.Result,
    box: []const pkmn.gen1.Pokemon,
    threaded: bool,
    alloc: std.mem.Allocator,
) !*DecisionNode {
    node_count = 0;
    const root: *DecisionNode = try alloc.create(DecisionNode);
    root.* = .{
        .battle = starting_battle,
        .team = .{ .Lead, .Empty, .Empty, .Empty, .Empty, .Empty },
        .result = starting_result,
        .transitions = std.ArrayList(*DecisionNode).init(alloc),
    };
    var scoring_nodes = std.ArrayList(*DecisionNode).init(alloc);
    var scored_nodes = std.ArrayList(*DecisionNode).init(alloc);
    defer scoring_nodes.deinit();
    defer scored_nodes.deinit();

    try scoring_nodes.append(root);

    var level: u16 = 1;
    print("Level | # of Nodes\n", .{});
    while (level < MAX_TURNLEVEL) {
        print("{:>5}   {:>10}\n", .{ level, count_nodes(root) });
        if (threaded) {
            var pool: std.Thread.Pool = undefined;
            var wg = std.Thread.WaitGroup{};
            try pool.init(std.Thread.Pool.Options{ .allocator = alloc, .n_jobs = 5 });
            defer pool.deinit();

            // Extend leaves of scoring_nodes to maximize level for scoring
            for (scoring_nodes.items) |scoring_node| {
                if (scoring_node.result.type == .None) {
                    pool.spawnWg(&wg, ts_exhaustive_decision_tree, .{
                        scoring_node,
                        box,
                        alloc,
                    });
                }

                try scored_nodes.append(scoring_node);
            }
            pool.waitAndWork(&wg);
        } else {
            const scoring_nodes_len = scoring_nodes.items.len;
            for (scoring_nodes.items, 0..) |scoring_node, i| {
                if (scoring_node.result.type == .None) {
                    const data = try exhaustive_decision_tree(
                        scoring_node,
                        box,
                        0,
                        ALPHA_MIN,
                        std.math.floatMax(score_t),
                        alloc,
                    );
                    _ = data;
                    _ = i;
                    _ = scoring_nodes_len;
                    // print("# of Nodes: {?d}, Branches Skipped: {?d}, ({}/{})\r", .{ data[2], data[3], i, scoring_nodes_len });
                }

                try scored_nodes.append(scoring_node);
            }
            print("\n", .{});
        }

        // Keep only the K_LARGEST nodes
        std.mem.sort(*DecisionNode, scored_nodes.items, {}, compare_score);
        const scored_len = scored_nodes.items.len;
        if (scored_len > K_LARGEST) {
            var i: usize = 0;
            while (i < (scored_len - K_LARGEST)) : (i += 1) {
                const delete_node = scored_nodes.swapRemove(K_LARGEST);
                if (delete_node.prev_node) |prev_node| {
                    // Fetch index of transition
                    for (prev_node.transitions.items, 0..) |check_node, index| {
                        if (check_node == delete_node) {
                            _ = prev_node.transitions.swapRemove(index);
                            break;
                        }
                    }
                    free_tree(delete_node, alloc);
                }
            }
            // TODO Could shrink capacity of each transitions to match length to save on space
            // If adding new nodes to tree however, must realloc for those
        }

        scoring_nodes.clearRetainingCapacity();
        // Save chlidren of scored_nodes as next scoring_nodes
        for (scored_nodes.items) |scored_node| {
            for (scored_node.transitions.items) |next_node| {
                try scoring_nodes.append(next_node);
            }
        }
        scored_nodes.clearRetainingCapacity();

        // print("Scorable Nodes: {}\n", .{scoring_nodes.items.len});

        if (scoring_nodes.items.len == 0) {
            break;
        }

        level += 1;
    }
    print("Finished: {} nodes!\n", .{count_nodes(root)});
    return root;
}

fn ts_exhaustive_decision_tree(
    curr_node: *DecisionNode,
    box: []const pkmn.gen1.Pokemon,
    alloc: std.mem.Allocator,
) void {
    _ = exhaustive_decision_tree(curr_node, box, 0, ALPHA_MIN, std.math.floatMax(score_t), alloc) catch unreachable;
}

pub fn exhaustive_decision_tree(
    curr_node: *DecisionNode,
    box: []const pkmn.gen1.Pokemon,
    level: u16,
    alpha_: score_t,
    beta_: score_t,
    alloc: std.mem.Allocator,
) ![4]?score_t {
    // TODO Prevent leaves from making extra recursive call to check LOOKAHEAD
    var alpha = alpha_;
    var beta = beta_;
    if (level < LOOKAHEAD) {
        var count: u32 = 0;
        var skipped: u32 = 0;
        // for (curr_node.transitions.items) |transition| {
        //     free_tree(transition, alloc);
        // }
        // curr_node.transitions.clearAndFree();

        var player_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
        var enemy_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

        const player_max = curr_node.battle.choices(.P1, curr_node.result.p1, &player_choices);
        const player_valid_choices = player_choices[0..player_max];

        const enemy_max = enemy_ai.pick_choice(curr_node, 0, &enemy_choices, alloc);
        const enemy_valid_choices = enemy_choices[0..enemy_max];

        for (enemy_valid_choices) |enemy_choice| {
            for (player_valid_choices) |player_choice| {
                // TODO Check alpha/beta prior to transition creation to optimize further
                const new_updates = try transitions(curr_node.battle, player_choice, enemy_choice, curr_node.chance.durations, alloc);
                try curr_node.transitions.ensureTotalCapacity(new_updates.len);
                for (new_updates) |new_update| {
                    if (alpha < beta or !PRUNING) {
                        const child_node: *DecisionNode = try alloc.create(DecisionNode);
                        child_node.* = .{
                            .id = node_count,
                            .prev_node = curr_node,
                            .battle = new_update.battle,
                            .team = curr_node.team,
                            .result = new_update.result,
                            .score = try scorer.score_node(child_node, box, new_update.probability),
                            .transitions = std.ArrayList(*DecisionNode).init(alloc),
                            .choices = .{ player_choice, enemy_choice },
                            .chance = .{
                                .actions = new_update.actions,
                                .durations = new_update.durations,
                            },
                        };
                        node_count += 1;
                        try curr_node.transitions.append(child_node);
                        const candidates = try exhaustive_decision_tree(
                            child_node,
                            box,
                            level + 1,
                            alpha,
                            beta,
                            alloc,
                        );
                        count += 1 + @as(u32, @intFromFloat(candidates[2] orelse 0));
                        skipped += @as(u32, @intFromFloat(candidates[3] orelse 0));
                        update_alpha_beta(level, &alpha, &beta, candidates);
                    } else {
                        skipped += 1;
                    }
                }

                alloc.free(new_updates);
            }

            assert(player_max > 0);
            // TODO Proper validation of whether box switch is legal (Block, etc.)
            // TODO .Pass used for death switches which box switches should be valid for
            if (player_valid_choices[0].type != .Pass) { // Can't force box switch when not able to select a switch
                if (find_empty_slot(&curr_node.team)) |new_member_slot| {
                    for (box, 0..) |box_mon, box_index| {
                        var in_box: bool = false;
                        for (curr_node.team) |box_state| {
                            switch (box_state) {
                                .Filled => |team_index| in_box = box_index == team_index,
                                else => continue,
                            }
                        }
                        // Only box_switch if box_mon isn't already on the team
                        if (!in_box) {
                            var next_battle = curr_node.battle;
                            const switch_choice: pkmn.Choice = add_to_team(&next_battle, box_mon, new_member_slot);
                            var new_team = curr_node.team;
                            new_team[new_member_slot] = TeamSlotState{ .Filled = @intCast(box_index) };

                            const new_updates = try transitions(next_battle, switch_choice, enemy_choice, curr_node.chance.durations, alloc);
                            try curr_node.transitions.ensureTotalCapacity(new_updates.len);
                            for (new_updates) |new_update| {
                                if (alpha < beta or !PRUNING) {
                                    const child_node: *DecisionNode = try alloc.create(DecisionNode);
                                    child_node.* = .{
                                        .id = node_count,
                                        .prev_node = curr_node,
                                        .battle = new_update.battle,
                                        .team = new_team,
                                        .result = new_update.result,
                                        .score = try scorer.score_node(child_node, box, new_update.probability),
                                        .transitions = std.ArrayList(*DecisionNode).init(alloc),
                                        .choices = .{ switch_choice, enemy_choice },
                                        .chance = .{
                                            .actions = new_update.actions,
                                            .durations = new_update.durations,
                                        },
                                    };
                                    node_count += 1;
                                    try curr_node.transitions.append(child_node);
                                    const candidates = try exhaustive_decision_tree(
                                        child_node,
                                        box,
                                        level + 1,
                                        alpha,
                                        beta,
                                        alloc,
                                    );
                                    count += 1 + @as(u32, @intFromFloat(candidates[2] orelse 0));
                                    skipped += @as(u32, @intFromFloat(candidates[3] orelse 0));
                                    update_alpha_beta(level, &alpha, &beta, candidates);
                                } else {
                                    skipped += 1;
                                }
                            }

                            alloc.free(new_updates);
                        }
                    }
                }
            }
        }
        return .{ alpha, beta, @as(score_t, @floatFromInt(count)), @as(score_t, @floatFromInt(skipped)) };
    } else {
        return .{ curr_node.score, null, 0, 0 };
    }
}

fn update_alpha_beta(level: u16, alpha: *score_t, beta: *score_t, candidates: [4]?score_t) void {
    // print("Level: {}\n", .{level});
    // print("Pre: {} {}\n", .{ alpha.*, beta.* });
    // print("Candidates: {?} {?}\n", .{ candidates[0], candidates[1] });
    if (level % 2 == 0) {
        for (candidates, 0..) |candidate, i| {
            if (i < 2) alpha.* = @max(alpha.*, candidate orelse ALPHA_MIN);
        }
    } else {
        for (candidates, 0..) |candidate, i| {
            if (i < 2) beta.* = @min(beta.*, candidate orelse std.math.floatMax(score_t));
        }
    }
    // print("Post: {} {}\n\n", .{ alpha.*, beta.* });
}

pub fn transitions(
    battle: pkmn.gen1.Battle(pkmn.gen1.PRNG),
    c1: pkmn.Choice,
    c2: pkmn.Choice,
    durations: pkmn.gen1.chance.Durations,
    alloc: std.mem.Allocator,
) ![]Update {
    const Rolls = pkmn.gen1.calc.Rolls;

    var updates = std.ArrayList(Update).init(alloc);
    var frontier = std.ArrayList(pkmn.gen1.chance.Actions).init(alloc);
    errdefer updates.deinit();
    defer frontier.deinit();

    var opts = pkmn.battle.options(
        pkmn.protocol.NULL,
        pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{}, .durations = durations },
        pkmn.gen1.Calc{},
    );

    var b = battle;
    _ = try b.update(c1, c2, &opts);

    const p1 = b.side(.P1);
    const p2 = b.side(.P2);

    var p: pkmn.Rational(u256) = .{ .p = 0, .q = 1 };
    try frontier.append(opts.chance.actions);

    // Hash actions to remove duplicates
    var actions_map = std.AutoHashMap(pkmn.gen1.chance.Actions, u1).init(alloc);
    defer actions_map.deinit();

    // zig fmt: off
    for (Rolls.metronome(frontier.items[0].p1)) |p1_move| {
    for (Rolls.metronome(frontier.items[0].p2)) |p2_move| {

    if (p1_move != .None or p2_move != .None) return error.UnableToUpdate;

    var i: usize = 0;
    assert(frontier.items.len == 1);
    while (i < frontier.items.len) : (i += 1) {
        const f = frontier.items[i];

        var a: pkmn.gen1.chance.Actions = .{
            .p1 = .{ .metronome = p1_move, .pp = f.p1.pp, .duration = f.p1.duration },
            .p2 = .{ .metronome = p2_move, .pp = f.p2.pp, .duration = f.p2.duration },
        };

        for (Rolls.speedTie(f.p1)) |tie| { a.p1.speed_tie = tie; a.p2.speed_tie = tie;
        for (Rolls.sleep(f.p1, durations.p1)) |p1_slp| { a.p1.sleep = p1_slp;
        for (Rolls.sleep(f.p2, durations.p2)) |p2_slp| { a.p2.sleep = p2_slp;
        for (Rolls.disable(f.p1, durations.p1, p1_slp)) |p1_dis| { a.p1.disable = p1_dis;
        for (Rolls.disable(f.p2, durations.p2, p2_slp)) |p2_dis| { a.p2.disable = p2_dis;
        for (Rolls.attacking(f.p1, durations.p1, p1_slp)) |p1_atk| { a.p1.attacking = p1_atk;
        for (Rolls.attacking(f.p2, durations.p2, p2_slp)) |p2_atk| { a.p2.attacking = p2_atk;
        for (Rolls.confusion(f.p1, durations.p1, tie, p1_atk, p1_slp)) |p1_cfz| { a.p1.confusion = p1_cfz;
        for (Rolls.confusion(f.p2, durations.p2, tie, p2_atk, p2_slp)) |p2_cfz| { a.p2.confusion = p2_cfz;
        for (Rolls.confused(f.p1, p1_cfz)) |p1_cfzd| { a.p1.confused = p1_cfzd;
        for (Rolls.confused(f.p2, p2_cfz)) |p2_cfzd| { a.p2.confused = p2_cfzd;
        for (Rolls.paralyzed(f.p1, p1_cfzd)) |p1_par| { a.p1.paralyzed = p1_par;
        for (Rolls.paralyzed(f.p2, p2_cfzd)) |p2_par| { a.p2.paralyzed = p2_par;
        for (Rolls.binding(f.p1, durations.p1, p1_par)) |p1_bind| { a.p1.binding = p1_bind;
        for (Rolls.binding(f.p2, durations.p2, p2_par)) |p2_bind| { a.p2.binding = p2_bind;
        for (Rolls.hit(f.p1, p1_par)) |p1_hit| { a.p1.hit = p1_hit;
        for (Rolls.hit(f.p2, p2_par)) |p2_hit| { a.p2.hit = p2_hit;
        for (Rolls.psywave(f.p1, p1, p1_hit)) |p1_psywave| { a.p1.psywave = p1_psywave;
        for (Rolls.psywave(f.p2, p2, p2_hit)) |p2_psywave| { a.p2.psywave = p2_psywave;
        for (Rolls.moveSlot(f.p1, p1_hit)) |p1_slot| { a.p1.move_slot = p1_slot;
        for (Rolls.moveSlot(f.p2, p2_hit)) |p2_slot| { a.p2.move_slot = p2_slot;
        for (Rolls.multiHit(f.p1, p1_hit)) |p1_multi| { a.p1.multi_hit = p1_multi;
        for (Rolls.multiHit(f.p2, p2_hit)) |p2_multi| { a.p2.multi_hit = p2_multi;
        for (Rolls.secondaryChance(f.p1, p1_hit)) |p1_sec| { a.p1.secondary_chance = p1_sec;
        for (Rolls.secondaryChance(f.p2, p2_hit)) |p2_sec| { a.p2.secondary_chance = p2_sec;
        for (Rolls.criticalHit(f.p1, p1_hit)) |p1_crit| { a.p1.critical_hit = p1_crit;
        for (Rolls.criticalHit(f.p2, p2_hit)) |p2_crit| { a.p2.critical_hit = p2_crit;

        var player_mask: u16 = 0b1000000000000000;
        var enemy_mask: u16 = 0b1000000000000000;
        var p1_dmg = Rolls.damage(f.p1, p1_hit);

        if (p1_hit == .true and p1_dmg.min == 0) continue;

        while (p1_dmg.min < p1_dmg.max) : ({p1_dmg.min += 1; player_mask >>= 1;}) {
            if ((ROLL_INTERVALS & player_mask) == 0) continue;

            a.p1.damage = @intCast(p1_dmg.min);
            
            var p2_dmg = Rolls.damage(f.p2, p2_hit);
            const p2_min: u9 = p2_dmg.min;

            if (p2_hit == .true and p2_dmg.min == 0) continue;

            while (p2_dmg.min < p2_dmg.max) : ({p2_dmg.min += 1; enemy_mask >>= 1;}) {
                if ((ROLL_INTERVALS & enemy_mask) == 0) continue;

                a.p2.damage = @intCast(p2_dmg.min);

                opts.calc.overrides = a;
                opts.calc.summaries = .{};
                opts.chance = .{ .probability = .{}, .durations = durations };
                const q = &opts.chance.probability;

                b = battle;
                const result = try b.update(c1, c2, &opts);
                const summaries = &opts.calc.summaries;

                if (try actions_map.fetchPut(a, 1)) |old| {
                    _ = old;
                } else {
                    const prob = @as(score_t, @floatFromInt(q.p)) / @as(score_t, @floatFromInt(q.q,));
                    try updates.append(.{
                        .battle = b,
                        .actions = a,
                        .durations = opts.chance.durations,
                        .probability = prob,
                        .result = result,
                    });
                }

                try p.add(&opts.chance.probability);

                const p1_max: u9 = if (p2_dmg.min != p2_min)
                    p1_dmg.min
                else
                    Rolls.coalesce(.P1, @as(u8, @intCast(p1_dmg.min)), summaries, true);
                const p2_max: u9 =
                    Rolls.coalesce(.P2, @as(u8, @intCast(p2_dmg.min)), summaries, true);

                if (opts.chance.actions.matches(f)) {
                    if (!opts.chance.actions.relax().eql(a)) {
                        p1_dmg.min = p1_max;
                        p2_dmg.min = p2_max;
                        continue;
                    }
                } else {
                    if (!opts.chance.actions.matchesAny(frontier.items, i)) {
                        try frontier.append(opts.chance.actions);
                    }
                }

                p1_dmg.min = p1_max;
                p2_dmg.min = p2_max;
            }
        }
        }}}}}}}}}}}}}}}}}}}}}}}}}}}
    }

    frontier.shrinkRetainingCapacity(1);

    }}
    
    p.reduce();

    return updates.toOwnedSlice();
}

pub fn find_empty_slot(team: []TeamSlotState) ?usize {
    var empty_slot: ?usize = null;
    // Iterate through team to find if empty slot available
    // Can ignore lead position
    for (team[1..], 1..) |box_state, i| {
        switch (box_state) {
            .Empty => {
                empty_slot = i;
                break;
            },
            else => continue,
        }
    }
    return empty_slot;
}

pub fn compare_score(_: void, n1: *DecisionNode, n2: *DecisionNode) bool {
    // TODO Improper comparison
    if (n1.score > n2.score) {
        return true;
    } else {
        return false;
    }
}

pub fn add_to_team(battle: *pkmn.gen1.Battle(pkmn.gen1.PRNG), new_mon: pkmn.gen1.Pokemon, new_member_slot: usize) pkmn.Choice {
    battle.side(.P1).pokemon[new_member_slot] = new_mon;
    battle.side(.P1).order[new_member_slot] = @intCast(new_member_slot + 1);

    var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    const max = battle.choices(.P1, .Switch, &choices); // Force result type to be a switch and not anything else
    const valid_choices = choices[0..max];

    var highest_switch = pkmn.Choice{ .type = .Switch, .data = 0 };
    for (valid_choices) |choice| {
        if (choice.type == .Switch and choice.data > highest_switch.data) {
            highest_switch = choice;
        }
    }
    return highest_switch;
}

pub fn count_nodes(curr_node: *DecisionNode) u32 {
    var sum: u32 = 1;
    for (curr_node.transitions.items) |next_node| {
        sum += count_nodes(next_node);
    }
    return sum;
}

pub fn free_tree(curr_node: *DecisionNode, alloc: std.mem.Allocator) void {
    for (curr_node.transitions.items) |next_node| {
        free_tree(next_node, alloc);
    }
    curr_node.transitions.deinit();
    alloc.destroy(curr_node);
}
