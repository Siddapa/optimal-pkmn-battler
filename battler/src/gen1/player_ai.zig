const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const pkmn = @import("pkmn");
const tools = @import("tools.zig");
const enemy_ai = @import("enemy_ai.zig");

pub var box: std.ArrayList(pkmn.gen1.Pokemon) = undefined;

// Maximum number of levels to build tree to
const MAX_TURNLEVEL: u16 = 10;

// Number of levels to extend tree by at some node
const LOOKAHEAD: u16 = 1;

// Maximum number of nodes to optimize for at a given level
const K_LARGEST: u16 = 1;

// Binary mask for which of the 16 rolls to generate (always keep min/max roll)
const ROLL_INTERVALS: u16 = 0b1000000000000001;

comptime {
    assert(LOOKAHEAD > 0);
    assert(K_LARGEST > 0);

    const min_max = ROLL_INTERVALS == 0b1000000000000001;
    const seconds = ROLL_INTERVALS == 0b1001001001001001;
    const fourths = ROLL_INTERVALS == 0b1000010000100001;
    assert(min_max or
        seconds or
        fourths);
}

/// Globalized creation of options for battle updates
// TODO Create issue on @pkmn/engine for not having to pass options with default values
var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
var calc = pkmn.gen1.Calc{};
const options = pkmn.battle.options(
    pkmn.protocol.NULL,
    &chance,
    &calc,
);

/// Structs for buliding decision tree
pub const DecisionNode = struct {
    battle: pkmn.gen1.Battle(pkmn.gen1.PRNG),
    team: [6]i8 = [_]i8{0} ** 6,
    result: pkmn.Result,
    score: u16 = 0,
    previous_node: ?*DecisionNode = null,
    next_turns: std.ArrayList(TurnChoices) = undefined,
};
pub const TurnChoices = struct { choices: [2]pkmn.Choice, next_node: *DecisionNode, box_switch: ?BoxSwitch };
pub const BoxSwitch = struct { added_pokemon: pkmn.gen1.Pokemon, order_slot: usize, box_id: usize };
pub const Update = struct { battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), actions: pkmn.gen1.chance.Actions, result: pkmn.Result };

pub fn optimal_decision_tree(starting_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), starting_result: pkmn.Result, alloc: std.mem.Allocator) !*DecisionNode {
    const root: *DecisionNode = try alloc.create(DecisionNode);
    root.* = .{
        .battle = starting_battle,
        .team = .{ 0, -1, -1, -1, -1, -1 },
        .result = starting_result,
        .previous_node = null,
        .next_turns = std.ArrayList(TurnChoices).init(alloc),
    };
    var scoring_nodes = std.ArrayList(*DecisionNode).init(alloc);
    defer scoring_nodes.deinit();

    try scoring_nodes.append(root);

    var level: u16 = 1;
    while (level < MAX_TURNLEVEL) {
        print("Level: {}\n", .{level});
        // Must be list of TurnChoices to be compatible with compare function for sorting by score
        var scored_nodes = std.ArrayList(*DecisionNode).init(alloc);
        defer scored_nodes.deinit();

        // Extend leaves of scoring_nodes to maximize level for scoring
        for (scoring_nodes.items) |scoring_node| {
            // _ = tools.traverse_decision_tree(scoring_node) catch void{};
            try exhaustive_decision_tree(scoring_node, 1, alloc);
            if (scoring_node.previous_node) |previous_node| {
                const turn_choice_index = get_parent_turnchoice_index(previous_node, scoring_node) orelse return error.NoParent;
                scoring_node.score = score(scoring_node, previous_node.next_turns.items[turn_choice_index].choices);
            }

            try scored_nodes.append(scoring_node);
        }

        // Keep only the K_LARGEST nodes
        std.mem.sort(*DecisionNode, scored_nodes.items, {}, compare_score);
        const scored_len = scored_nodes.items.len;
        if (scored_len > K_LARGEST) {
            var i: usize = 0;
            while (i < (scored_len - K_LARGEST)) : (i += 1) {
                const delete_node = scored_nodes.swapRemove(K_LARGEST);
                // print("Delete Node: {*}\n", .{delete_node});
                const previous_node = delete_node.previous_node orelse continue;
                const turn_choice_index = get_parent_turnchoice_index(previous_node, delete_node) orelse return error.NoParent;

                // Remove potential_node from parent's next_turns
                _ = previous_node.next_turns.swapRemove(turn_choice_index);
                free_tree(delete_node, alloc);
            }
        }

        scoring_nodes.clearAndFree();
        // Save chlidren of scored_nodes as next scoring_nodes
        for (scored_nodes.items) |scored_node| {
            for (scored_node.next_turns.items) |next_turn| {
                try scoring_nodes.append(next_turn.next_node);
            }
        }

        level += 1;
    }
    return root;
}

// TODO Access leaves for extension without recursing from a root node
pub fn exhaustive_decision_tree(curr_node: *DecisionNode, level: u16, alloc: std.mem.Allocator) !void {
    if (curr_node.next_turns.items.len == 0 and level < LOOKAHEAD + 1) {
        var player_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
        var enemy_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

        const player_max = curr_node.battle.choices(tools.PLAYER_PID, curr_node.result.p1, &player_choices);
        const player_valid_choices = player_choices[0..player_max];

        const enemy_max = enemy_ai.pick_choice(curr_node.battle, curr_node.result, 0, &enemy_choices);
        const enemy_valid_choices = enemy_choices[0..enemy_max];

        var new_team = curr_node.team;

        for (enemy_valid_choices) |enemy_choice| {
            for (player_valid_choices) |player_choice| {
                const new_updates = try transitions(curr_node.battle, player_choice, enemy_choice, options.chance.durations, alloc);
                for (new_updates) |new_update| {
                    const child_node: *DecisionNode = try alloc.create(DecisionNode);
                    child_node.* = .{
                        .battle = new_update.battle,
                        .team = curr_node.team,
                        .result = new_update.result,
                        .previous_node = curr_node,
                        .next_turns = std.ArrayList(TurnChoices).init(alloc),
                    };
                    try curr_node.next_turns.append(.{ .choices = .{ player_choice, enemy_choice }, .next_node = child_node, .box_switch = null });
                    try exhaustive_decision_tree(child_node, level + 1, alloc);
                }
            }

            // TODO Full team edge case
            var new_member_slot: usize = 0;
            inline for (curr_node.team, 0..) |box_id, i| {
                if (box_id == -1) {
                    new_member_slot = i;
                    break;
                }
            }
            // Still being zero means no new slot
            if (0 < new_member_slot) {
                for (box.items, 0..) |box_mon, box_index| {
                    var in_box: bool = false;
                    for (curr_node.team) |team_index| { // Is box_mon already on team?
                        if (box_index == team_index) {
                            in_box = true;
                        }
                    }
                    if (!in_box) {
                        var next_battle = curr_node.battle;
                        const switch_choice: pkmn.Choice = add_to_team(&next_battle, box_mon, new_member_slot);
                        new_team = curr_node.team;
                        new_team[new_member_slot] = @intCast(box_index);

                        const new_updates = try transitions(next_battle, switch_choice, enemy_choice, options.chance.durations, alloc);
                        for (new_updates) |new_update| {
                            const child_node: *DecisionNode = try alloc.create(DecisionNode);
                            child_node.* = .{
                                .battle = new_update.battle,
                                .team = curr_node.team,
                                .result = new_update.result,
                                .previous_node = curr_node,
                                .next_turns = std.ArrayList(TurnChoices).init(alloc),
                            };
                            try curr_node.next_turns.append(.{ .choices = .{ switch_choice, enemy_choice }, .next_node = child_node, .box_switch = .{ .added_pokemon = box_mon, .order_slot = new_member_slot, .box_id = box_index } });
                            try exhaustive_decision_tree(child_node, level + 1, alloc);
                        }
                    }
                }
            }
        }
    }
}

pub fn transitions(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), c1: pkmn.Choice, c2: pkmn.Choice, durations: pkmn.gen1.chance.Durations, alloc: std.mem.Allocator) ![]Update {
    const Rolls = pkmn.gen1.calc.Rolls;

    var updates = std.ArrayList(Update).init(alloc);
    var seen = std.AutoHashMap(pkmn.gen1.chance.Actions, void).init(alloc);
    var frontier = std.ArrayList(pkmn.gen1.chance.Actions).init(alloc);
    errdefer updates.deinit();
    defer seen.deinit();
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

    try frontier.append(opts.chance.actions);

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
        for (Rolls.confusion(f.p1, durations.p1, p1_atk, p1_slp)) |p1_cfz| { a.p1.confusion = p1_cfz;
        for (Rolls.confusion(f.p2, durations.p2, p2_atk, p2_slp)) |p2_cfz| { a.p2.confusion = p2_cfz;
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

        while (p1_dmg.min < p1_dmg.max) : ({p1_dmg.min += 1; player_mask >>= 1;}) {
            if (ROLL_INTERVALS & player_mask == 0) continue;

            a.p1.damage = @intCast(p1_dmg.min);
            
            var p2_dmg = Rolls.damage(f.p2, p2_hit);
            const p2_min: u9 = p2_dmg.min;

            while (p2_dmg.min < p2_dmg.max) : ({p2_dmg.min += 1; enemy_mask >>= 1;}) {
                if ((ROLL_INTERVALS & enemy_mask) == 0) continue;

                a.p2.damage = @intCast(p2_dmg.min);

                opts.calc.overrides = a;
                opts.calc.summaries = .{};
                opts.chance = .{ .probability = .{}, .durations = durations };
                const summaries = &opts.calc.summaries;

                b = battle;
                const result = try b.update(c1, c2, &opts);
                try updates.append(.{
                    .battle = b,
                    .actions = a,
                    .result = result,
                });

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

    return updates.toOwnedSlice();
}

fn score(scoring_node: *DecisionNode, choices_to_node: [2]pkmn.Choice) u16 {
    var sum: u16 = 0;

    const previous_node = scoring_node.previous_node orelse return 0;

    const previous_battle = previous_node.battle;
    const previous_player_active = previous_battle.side(tools.PLAYER_PID).active;
    const previous_player_stored = previous_battle.side(tools.PLAYER_PID).stored();
    const previous_enemy_active = previous_battle.side(tools.ENEMY_PID).active;
    // const previous_enemy_stored = previous_battle.side(tools.ENEMY_PID).stored();

    const scoring_battle = scoring_node.battle;
    // const scoring_player_active = scoring_battle.side(tools.PLAYER_PID).active;
    // const scoring_enemy_active  = scoring_battle.side(tools.ENEMY_PID).active;

    if (choices_to_node[0].type == pkmn.Choice.Type.Move) {
        sum += 100;
        // STAB
        const move_type = pkmn.gen1.Move.get(previous_player_stored.move(choices_to_node[0].data).id).type;
        if (move_type == previous_player_active.types.type1 or move_type == previous_player_active.types.type2) {
            sum += 10;
        }

        // Fast Kill
        if (previous_player_active.stats.spe > previous_enemy_active.stats.spe and scoring_battle.side(tools.ENEMY_PID).stored().hp == 0) {
            sum += 10;
        }
        // Fast MultiKill
        // TODO Create a damage calculator to tell if player T-HKO < enemy T-HKO
        if (previous_player_active.stats.spe > previous_enemy_active.stats.spe and scoring_battle.side(tools.ENEMY_PID).stored().hp == 0) {}
    } else if (choices_to_node[0].type == pkmn.Choice.Type.Switch) {
        sum += 50;
    } else if (choices_to_node[0].type == pkmn.Choice.Type.Pass) {
        sum += 0;
    }

    return sum;
}

fn compare_score(_: void, n1: *DecisionNode, n2: *DecisionNode) bool {
    // TODO What to do when scores are equal
    if (n1.score > n2.score) {
        return true;
    } else {
        return false;
    }
}

fn add_to_team(battle: *pkmn.gen1.Battle(pkmn.gen1.PRNG), new_mon: pkmn.gen1.Pokemon, new_member_slot: usize) pkmn.Choice {
    battle.side(tools.PLAYER_PID).pokemon[new_member_slot] = new_mon;
    battle.side(tools.PLAYER_PID).order[new_member_slot] = @intCast(new_member_slot + 1);

    var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    const max = battle.choices(tools.PLAYER_PID, pkmn.Choice.Type.Switch, &choices); // Force result type to be a switch and not anything else
    const valid_choices = choices[0..max];

    var highest_switch = pkmn.Choice{ .type = pkmn.Choice.Type.Switch, .data = 0 };
    for (valid_choices) |choice| {
        if (choice.type == pkmn.Choice.Type.Switch and choice.data > highest_switch.data) {
            highest_switch = choice;
        }
    }
    return highest_switch;
}


// Returns the index of a turnchoice matching a given child
fn get_parent_turnchoice_index(parent_node: *DecisionNode, child_node: *DecisionNode) ?usize {
    for (parent_node.next_turns.items, 0..) |next_turn, i| {
        if (next_turn.next_node == child_node) {
            return i;
        }
    }
    return null;
}

pub fn count_nodes(curr_node: *DecisionNode) u32 {
    var sum: u32 = 1;
    for (curr_node.next_turns.items) |next_turn| {
        sum += count_nodes(next_turn.next_node);
    }
    return sum;
}

pub fn free_tree(curr_node: *DecisionNode, alloc: std.mem.Allocator) void {
    for (curr_node.next_turns.items) |next_turn| {
        free_tree(next_turn.next_node, alloc);
    }
    curr_node.next_turns.deinit();
    alloc.destroy(curr_node);
}
