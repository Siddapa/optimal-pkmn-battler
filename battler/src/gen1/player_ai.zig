const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const pkmn = @import("pkmn");
const tools = @import("tools.zig");
const enemy_ai = @import("enemy_ai.zig");

var alloc: std.mem.Allocator = undefined;
var box: std.ArrayList(pkmn.gen1.Pokemon) = undefined;
const MAX_TURNDEPTH: u16 = 10;
const MAX_LOOKAHEAD: u16 = 2;
const K_LARGEST: u16 = 3;

comptime {
    assert(MAX_LOOKAHEAD > 1);
}

/// Globalized creationg of options for battle updates
var buf: [pkmn.LOGS_SIZE]u8 = undefined;
var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
// TODO Create issue on @pkmn/engine for not having to pass options with default values
var options = pkmn.battle.options(
    pkmn.protocol.FixedLog{ .writer = stream.writer() },
    pkmn.gen1.chance.NULL,
    pkmn.gen1.calc.NULL,
);

/// Setup
pub fn init(box_pokemon: std.ArrayList(pkmn.gen1.Pokemon), allocator: std.mem.Allocator) void {
    box = box_pokemon; // TODO Get box to own the slice of box_pokemon
    alloc = allocator;
}
pub fn deinit() void {
    box.deinit();
}

/// Structs for buliding decision tree
pub const DecisionNode = struct {
    battle: pkmn.gen1.Battle(pkmn.gen1.PRNG),
    team_pokemon: [6]i8 = [_]i8{0} ** 6,
    result: pkmn.Result,
    score: u16 = 0,
    previous_turn: ?*DecisionNode = null,
    next_turns: std.ArrayList(TurnChoices) = undefined,
};
pub const TurnChoices = struct { choices: [2]pkmn.Choice, turn: ?*DecisionNode, box_switch: ?BoxSwitch };
pub const BoxSwitch = struct {
    added_pokemon: pkmn.gen1.Pokemon,
    order_slot: usize,
};

pub fn optimal_decision_tree(starting_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), starting_result: pkmn.Result) ?*DecisionNode {
    var root: ?*DecisionNode = undefined;
    var scoring_nodes: [K_LARGEST]?*DecisionNode = undefined;
    var depth: u16 = 0;
    var i: u8 = undefined;
    var original_len: usize = undefined;

    // Generates inital starting node to iteratively expand upon
    const starting_team = [_]i8{ 0, -1, -1, -1, -1, -1 };
    root = exhaustive_decision_tree(null, null, starting_battle, starting_team, starting_result, 0);
    for (root.?.*.next_turns.items) |next_turn| {
        next_turn.turn.?.*.score = score(next_turn.turn, next_turn.choices);
    }
    std.mem.sort(TurnChoices, root.?.*.next_turns.items, {}, compare_score);
    i = K_LARGEST;
    original_len = root.?.*.next_turns.items.len;
    while (i < original_len) {
        free_tree(root.?.*.next_turns.swapRemove(K_LARGEST).turn);
        i += 1;
    }
    for (root.?.*.next_turns.items, 0..) |next_turn, j| {
        scoring_nodes[j] = next_turn.turn;
    }
    depth = MAX_LOOKAHEAD;

    while (depth < MAX_TURNDEPTH) {
        print("Depth: {}\n", .{depth});
        // Must be list of TurnChoices to be compatible with compare function for sorting by score
        var potential_nodes = std.ArrayList(TurnChoices).init(alloc);
        defer potential_nodes.deinit();

        // Extend leaves of scoring_nodes to maximize depth for scoring
        for (scoring_nodes) |scoring_node| {
            _ = exhaustive_decision_tree(scoring_node, null, starting_battle, scoring_node.?.*.team_pokemon, scoring_node.?.*.result, 0);
            // Actually scoring children of scoring_node, not the scoring_node itself
            for (scoring_node.?.*.next_turns.items) |potential_node| {
                if (potential_node.turn != null) { // Checks for scoring_node not extened (losing or winning turn)
                    potential_node.turn.?.*.score = score(potential_node.turn, get_parent_turnchoice(potential_node.turn).choices);
                    potential_nodes.append(potential_node) catch continue;
                }
            }
        }
        depth += 1;

        std.mem.sort(TurnChoices, potential_nodes.items, {}, compare_score);
        i = K_LARGEST;
        original_len = potential_nodes.items.len;
        while (i < original_len) {
            // Remove potential node from parents potential turns
            const delete_node = potential_nodes.swapRemove(K_LARGEST);
            const parent_next_turns_len = delete_node.turn.?.*.previous_turn.?.*.next_turns.items.len;
            var j: u8 = 0;
            while (j < parent_next_turns_len) {
                // Checks which of parent's child pointers leads to the deleted potential node
                if (delete_node.turn.?.*.previous_turn.?.*.next_turns.items[j].turn == delete_node.turn) {
                    _ = delete_node.turn.?.*.previous_turn.?.*.next_turns.swapRemove(j);
                    break;
                }
                j += 1;
            }
            free_tree(delete_node.turn);
            i += 1;
        }
        // Save potential_nodes for next turn's scoring
        for (potential_nodes.items, 0..) |potential_node, j| {
            scoring_nodes[j] = potential_node.turn;
        }
    }
    return root;
}

// TODO Access leaves for extension without recursing from a root node
fn exhaustive_decision_tree(curr_node: ?*DecisionNode, parent_node: ?*DecisionNode, curr_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), curr_team: [6]i8, result: pkmn.Result, depth: u16) ?*DecisionNode {
    if (curr_node == null) {
        // Max possible depth to quickly generate is 6
        if (result.type != .None or depth == MAX_LOOKAHEAD) {
            return null;
        }

        // Copy to local variable for mutating with update
        var next_battle = curr_battle;

        // Generate a new node to contain children and also return as child to parent
        const new_node: ?*DecisionNode = alloc.create(DecisionNode) catch unreachable;

        new_node.?.* = .{
            .battle = curr_battle, // TODO No need to dynamically allocate
            .team_pokemon = curr_team,
            .result = result,
            .previous_turn = parent_node,
            .next_turns = std.ArrayList(TurnChoices).init(alloc),
        };

        var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
        const max1 = curr_battle.choices(tools.PLAYER_PID, result.p1, &choices);
        const engine_valid_choices = choices[0..max1];
        // Enemy only guaranteed to make one move
        // TODO Issue #6
        const enemy_choice = enemy_ai.pick_choice(curr_battle, result, 0);

        for (engine_valid_choices) |choice| {
            const new_result: pkmn.Result = next_battle.update(choice, enemy_choice, &options) catch pkmn.Result{};
            const child_node = exhaustive_decision_tree(null, new_node, next_battle, curr_team, new_result, depth + 1);
            next_battle = curr_battle;
            new_node.?.*.next_turns.append(.{ .choices = .{ choice, enemy_choice }, .turn = child_node, .box_switch = null }) catch continue;
        }

        var team_size: u8 = 0;
        var new_member_slot: usize = 0;
        for (curr_team, 0..) |team_member, i| { // Counts the non-negative, valid indexes within the curr_team
            if (team_member != -1) { // Increment when referencing a valid team member
                team_size += 1;
            } else { // When first invalid is found, replace with a valid switch
                new_member_slot = i;
                break;
            }
        }
        if (0 <= team_size and team_size < 6) {
            for (box.items, 0..) |box_mon, box_index| {
                var new_team = curr_team;
                var in_box: bool = false;
                for (curr_team) |team_index| { // Is box_mon already on team?
                    if (box_index == team_index) {
                        in_box = true;
                    }
                }
                if (!in_box) {
                    const switch_choice: pkmn.Choice = add_to_team(&next_battle, box_mon, new_member_slot);
                    const new_result: pkmn.Result = next_battle.update(switch_choice, enemy_choice, &options) catch pkmn.Result{};
                    new_team[new_member_slot] = @intCast(box_index);
                    const child_node = exhaustive_decision_tree(null, new_node, next_battle, new_team, new_result, depth + 1);
                    next_battle = curr_battle;
                    new_node.?.*.next_turns.append(.{ .choices = .{ switch_choice, enemy_choice }, .turn = child_node, .box_switch = .{ .added_pokemon = box_mon, .order_slot = new_member_slot } }) catch continue;
                }
            }
        }

        return new_node;
    } else {
        // Skips past previously generated nodes and reaches null leaves
        for (curr_node.?.*.next_turns.items, 0..) |next_turn, i| {
            if (next_turn.turn == null) {
                var next_battle = curr_node.?.*.battle;
                var next_choice: pkmn.Choice = next_turn.choices[0];
                if (next_turn.box_switch != null) {
                    const box_switch = next_turn.box_switch.?;
                    // Add new pokemon to team first before generating switch
                    next_choice = add_to_team(&next_battle, box_switch.added_pokemon, box_switch.order_slot);
                }
                const new_result = next_battle.update(next_choice, next_turn.choices[1], &options) catch pkmn.Result{};
                curr_node.?.*.next_turns.items[i].turn = exhaustive_decision_tree(null, curr_node, next_battle, curr_node.?.*.team_pokemon, new_result, depth + 1);
            } else {
                _ = exhaustive_decision_tree(next_turn.turn, curr_node, curr_node.?.*.battle, curr_node.?.*.team_pokemon, curr_node.?.*.result, depth + 1);
            }
        }
        return curr_node;
    }
}

fn score(scoring_node: ?*DecisionNode, choices_to_node: [2]pkmn.Choice) u16 {
    var sum: u16 = 0;

    const previous_battle = scoring_node.?.*.previous_turn.?.*.battle;
    const previous_player_active = previous_battle.side(tools.PLAYER_PID).active;
    const previous_player_stored = previous_battle.side(tools.PLAYER_PID).stored();
    const previous_enemy_active = previous_battle.side(tools.ENEMY_PID).active;
    // const previous_enemy_stored = previous_battle.side(tools.ENEMY_PID).stored();

    const scoring_battle = scoring_node.?.*.battle;
    // const scoring_player_active = scoring_battle.side(tools.PLAYER_PID).active;
    // const scoring_enemy_active  = scoring_battle.side(tools.ENEMY_PID).active;

    if (choices_to_node[0].type == pkmn.Choice.Type.Move) {
        // STAB
        const move_type = pkmn.gen1.Move.get(previous_player_stored.move(choices_to_node[0].data).id).type;
        // const move_name = @tagName(previous_player_stored.move(choices_to_node[0].data).id);
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
        sum += 1000;
    } else if (choices_to_node[0].type == pkmn.Choice.Type.Pass) {
        sum += 0;
    }

    return sum;
}

fn compare_score(_: void, n1: TurnChoices, n2: TurnChoices) bool {
    const n1_score = n1.turn.?.*.score;
    const n2_score = n2.turn.?.*.score;
    // TODO What to do when scores are equal
    if (n1_score > n2_score) {
        return true;
    } else {
        return false;
    }
}

fn add_to_team(battle: *pkmn.gen1.Battle(pkmn.gen1.PRNG), new_mon: pkmn.gen1.Pokemon, new_member_slot: usize) pkmn.Choice {
    // Things that need to be modified:
    // 1) Adding to player's side
    // 2) Updating team order
    // 3) Returning new choice for battle update

    battle.*.side(tools.PLAYER_PID).pokemon[new_member_slot] = new_mon;
    battle.*.side(tools.PLAYER_PID).order[new_member_slot] = @intCast(new_member_slot + 1);

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

// TODO Rewrite to traverse iteratively, not recursively
pub fn traverse_decision_tree(curr_node: ?*DecisionNode) !void {
    if (curr_node != null) {
        // Spacing between node selections
        print("-" ** 30, .{});
        print("\n", .{});
        var input_buf: [10]u8 = undefined;
        var traversing: bool = true;

        // Selects choices made to get to the current turn
        var c1 = pkmn.Choice{};
        var c2 = pkmn.Choice{};
        if (curr_node.?.*.previous_turn != null) {
            for (curr_node.?.*.previous_turn.?.*.next_turns.items, 0..) |next_turn, i| {
                if (next_turn.turn == curr_node) {
                    c1 = curr_node.?.*.previous_turn.?.*.next_turns.items[i].choices[0];
                    c2 = curr_node.?.*.previous_turn.?.*.next_turns.items[i].choices[1];
                }
            }
        }
        tools.print_battle(curr_node.?.*.battle, c1, c2);

        // Displays possible moves/switches as well as traversing to previous nodes/quitting
        print("Select one of the following choices: \n", .{});
        for (curr_node.?.*.next_turns.items, 0..) |next_turn, i| {
            if (next_turn.turn != null) {
                if (next_turn.choices[0].type == pkmn.Choice.Type.Move) {
                    print("{}={s}/M ({}), ", .{ i + 1, @tagName(curr_node.?.*.battle.side(tools.PLAYER_PID).stored().move(next_turn.choices[0].data).id), next_turn.turn.?.*.score });
                } else if (next_turn.choices[0].type == pkmn.Choice.Type.Switch and next_turn.choices[0].data != 42) {
                    if (next_turn.box_switch != null) {
                        print("{}={s}/S ({}), ", .{ i + 1, @tagName(next_turn.box_switch.?.added_pokemon.species), next_turn.turn.?.*.score });
                    } else {
                        print("{}={s}/S ({}), ", .{ i + 1, @tagName(curr_node.?.*.battle.side(tools.PLAYER_PID).get(next_turn.choices[0].data).species), next_turn.turn.?.*.score });
                    }
                } else if (next_turn.choices[0].type == pkmn.Choice.Type.Pass) {
                    print("c=continue, ", .{});
                }
            }
        }
        print("p=previous turn, q=quit\n", .{});

        // Takes a single character (u8) for processing next node to follow
        const reader = std.io.getStdIn().reader();
        if (try reader.readUntilDelimiterOrEof(input_buf[0..], '\n')) |user_input| {
            if (user_input.len == @as(usize, 0)) {
                print("Invalid input!\n", .{});
                traversing = false;
            } else if (49 <= user_input[0] and user_input[0] <= 57) { // ASCII range of integers from 1-9
                const choice_id = try std.fmt.parseInt(u8, user_input, 10);
                try traverse_decision_tree(curr_node.?.*.next_turns.items[choice_id - 1].turn);
            } else if (user_input[0] == 'c') {
                try traverse_decision_tree(curr_node.?.*.next_turns.items[0].turn);
            } else if (user_input[0] == 'p') {
                try traverse_decision_tree(curr_node.?.*.previous_turn);
            } else if (user_input[0] == 'q') {
                traversing = false;
            } else {
                print("Invalid input!\n", .{});
                traversing = false;
            }
        } else {
            print("Failed to Read Line!\n", .{});
        }
    }
}

// Returns the turnchoice matching a given child
fn get_parent_turnchoice(child_node: ?*DecisionNode) TurnChoices {
    if (child_node.?.*.previous_turn != null) {
        for (child_node.?.*.previous_turn.?.*.next_turns.items) |turn_choice| {
            if (turn_choice.turn == child_node) {
                return turn_choice;
            }
        }
    }
    return .{
        .choices = .{ pkmn.Choice{}, pkmn.Choice{} },
        .turn = undefined,
        .box_switch = null,
    };
}

fn free_tree(curr_node: ?*DecisionNode) void {
    for (curr_node.?.*.next_turns.items) |next_turn| {
        if (next_turn.turn != null) {
            free_tree(next_turn.turn);
        }
    }
    curr_node.?.*.next_turns.deinit();
    alloc.destroy(curr_node.?);
}
