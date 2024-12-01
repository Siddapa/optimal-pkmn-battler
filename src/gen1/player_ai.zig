const std = @import("std");
const print = std.debug.print;

const pkmn = @import("pkmn");

const tools = @import("tools.zig");
const enemy_ai = @import("enemy_ai.zig");

const MAX_TURNDEPTH: u16 = 10;
const MAX_LOOKAHEAD: u16 = 3;
const K_LARGEST: u16 = 4;

pub const TurnChoices = struct { choices: [2]pkmn.Choice, turn: ?*DecisionNode };

pub const DecisionNode = struct {
    battle: *pkmn.gen1.Battle(pkmn.gen1.PRNG) = undefined,
    result: pkmn.Result,
    score: u16 = 0,
    previous_turn: ?*DecisionNode = null,
    next_turns: std.ArrayList(TurnChoices),
};

pub fn optimal_decision_tree(starting_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), starting_result: pkmn.Result, alloc: std.mem.Allocator) !?*DecisionNode {
    var root: ?*DecisionNode = undefined;
    var scoring_nodes: [K_LARGEST]?*DecisionNode = undefined;
    var depth: u16 = 0;
    var i: u8 = undefined;
    var original_len: usize = undefined;

    // Generates inital starting node to iteratively expand upon
    root = try exhaustive_decision_tree(null, null, starting_battle, starting_result, alloc, 0);
    for (root.?.*.next_turns.items) |next_turn| {
        next_turn.turn.?.*.score = score(next_turn.turn, next_turn.choices[0]);
    }
    std.mem.sort(TurnChoices, root.?.*.next_turns.items, {}, compare_score);
    i = K_LARGEST;
    original_len = root.?.*.next_turns.items.len;
    while (i < original_len) {
        // Could've broke
        free_tree(root.?.*.next_turns.swapRemove(K_LARGEST).turn, alloc);
        i += 1;
    }
    for (root.?.*.next_turns.items, 0..) |next_turn, j| {
        scoring_nodes[j] = next_turn.turn;
    }
    depth = MAX_LOOKAHEAD;

    while (depth < MAX_TURNDEPTH) {
        print("Depth: {}\n", .{depth});
        // try traverse_decision_tree(root);
        // Must be list of TurnChoices to be compatible with compare function for sorting by score
        var potential_nodes = std.ArrayList(TurnChoices).init(alloc);
        defer potential_nodes.deinit();

        // Extend leaves of scoring_nodes to maximize depth for scoring
        for (scoring_nodes) |scoring_node| {
            _ = try exhaustive_decision_tree(scoring_node, null, starting_battle, scoring_node.?.*.result, alloc, 0);
            for (scoring_node.?.*.next_turns.items) |potential_node| {
                potential_node.turn.?.*.score = score(potential_node.turn, get_parent_turnchoice(potential_node.turn).choices[0]);
                if (potential_node.turn != null) {
                    try potential_nodes.append(potential_node);
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
            free_tree(delete_node.turn, alloc);
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
fn exhaustive_decision_tree(curr_node: ?*DecisionNode, parent_node: ?*DecisionNode, curr_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), result: pkmn.Result, alloc: std.mem.Allocator, depth: u16) !?*DecisionNode {
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
            .battle = try alloc.create(pkmn.gen1.Battle(pkmn.gen1.PRNG)),
            .result = result,
            .previous_turn = parent_node,
            .next_turns = std.ArrayList(TurnChoices).init(alloc),
        };
        new_node.?.*.battle.* = next_battle;

        var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
        var buf: [pkmn.LOGS_SIZE]u8 = undefined;
        var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
        // TODO Create issue on @pkmn/engine for not having to pass options with default values
        var options = pkmn.battle.options(
            pkmn.protocol.FixedLog{ .writer = stream.writer() },
            pkmn.gen1.chance.NULL,
            pkmn.gen1.calc.NULL,
        );

        // Create list of possible choices for player to choose from
        const max1 = curr_battle.choices(tools.PLAYER_PID, result.p1, &choices);
        const player_valid_choices = choices[0..max1];
        // Enemy only guaranteed to make one move
        const c2 = try enemy_ai.pick_choice(curr_battle, result, 0);

        var new_result: pkmn.Result = undefined;
        for (player_valid_choices) |choice| {
            new_result = try next_battle.update(choice, c2, &options);
            const child_node = try exhaustive_decision_tree(null, new_node, next_battle, new_result, alloc, depth + 1);
            next_battle = curr_battle;
            try new_node.?.*.next_turns.append(.{
                .choices = .{ choice, c2 },
                .turn = child_node,
            });
        }
        return new_node;
    } else {
        // Skips past previously generated nodes and reaching null leaves
        for (curr_node.?.*.next_turns.items, 0..) |next_turn, i| {
            if (next_turn.turn == null) {
                var buf: [pkmn.LOGS_SIZE]u8 = undefined;
                var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
                // TODO Create issue on @pkmn/engine for not having to pass options with default values
                var options = pkmn.battle.options(
                    pkmn.protocol.FixedLog{ .writer = stream.writer() },
                    pkmn.gen1.chance.NULL,
                    pkmn.gen1.calc.NULL,
                );
                var next_battle = curr_node.?.*.battle.*;
                const new_result = try next_battle.update(next_turn.choices[0], next_turn.choices[1], &options);
                curr_node.?.*.next_turns.items[i].turn = try exhaustive_decision_tree(null, curr_node, next_battle, new_result, alloc, depth + 1);
            } else {
                _ = try exhaustive_decision_tree(next_turn.turn, curr_node, curr_node.?.*.battle.*, curr_node.?.*.result, alloc, depth + 1);
            }
        }
        return curr_node;
    }
}

// TODO Rewrite to traverse iteratively, not recursively
pub fn traverse_decision_tree(curr_node: ?*DecisionNode) !void {
    if (curr_node != null) {
        // Spacing between node selections
        print("-" ** 30, .{});
        print("\n", .{});
        var buf: [10]u8 = undefined;
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
        tools.print_battle(curr_node.?.*.battle.*, c1, c2);
        print("\n", .{});

        // Displays possible moves/switches as well as traversing to previous nodes/quitting
        print("Select one of the following choices: \n", .{});
        for (curr_node.?.*.next_turns.items, 0..) |next_turn, i| {
            if (next_turn.choices[0].type == pkmn.Choice.Type.Move) {
                print("{}={s} ({}), ", .{ i + 1, @tagName(curr_node.?.*.battle.side(tools.PLAYER_PID).stored().move(next_turn.choices[0].data).id), next_turn.turn.?.*.score });
            } else if (next_turn.choices[0].type == pkmn.Choice.Type.Switch and next_turn.choices[0].data != 42) {
                print("{}={s} ({}), ", .{ i + 1, @tagName(curr_node.?.*.battle.side(tools.PLAYER_PID).get(next_turn.choices[0].data).species), next_turn.turn.?.*.score });
            } else if (next_turn.choices[0].type == pkmn.Choice.Type.Pass) {
                print("c=continue, ", .{});
            }
        }
        print("p=previous turn, q=quit\n", .{});

        // Takes a single character (u8) for processing next node to follow
        const reader = std.io.getStdIn().reader();
        if (try reader.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            // ASCII range of integers from 1-9
            if (49 <= user_input[0] and user_input[0] <= 57) {
                const choice_id = try std.fmt.parseInt(u8, user_input, 10);
                try traverse_decision_tree(curr_node.?.*.next_turns.items[choice_id - 1].turn);
            } else if (user_input[0] == 'c') {
                try traverse_decision_tree(curr_node.?.*.next_turns.items[0].turn);
            } else if (user_input[0] == 'p') {
                try traverse_decision_tree(curr_node.?.*.previous_turn);
            } else if (user_input[0] != 'q') {
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
    };
}

fn free_tree(curr_node: ?*DecisionNode, alloc: std.mem.Allocator) void {
    for (curr_node.?.*.next_turns.items) |next_turn| {
        if (next_turn.turn != null) {
            free_tree(next_turn.turn, alloc);
        }
    }
    curr_node.?.*.next_turns.deinit();
    alloc.destroy(curr_node.?.*.battle);
    alloc.destroy(curr_node.?);
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

fn score(scoring_node: ?*DecisionNode, choice_to_node: pkmn.Choice) u16 {
    var sum: u16 = 0;

    const previous_battle = scoring_node.?.*.previous_turn.?.*.battle.*;
    const previous_player_active = previous_battle.side(tools.PLAYER_PID).active;
    const previous_enemy_active = previous_battle.side(tools.ENEMY_PID).active;

    const scoring_battle = scoring_node.?.*.battle.*;
    // const scoring_player_active = scoring_battle.side(tools.PLAYER_PID).active;
    // const scoring_enemy_active  = scoring_battle.side(tools.ENEMY_PID).active;

    if (choice_to_node.type == pkmn.Choice.Type.Move) {
        sum += 20;
        // Fast Kill
        if (previous_player_active.stats.spe > previous_enemy_active.stats.spe and scoring_battle.side(tools.ENEMY_PID).stored().hp == 0) {
            sum += 10;
            // Fast MultiKill
            // TODO Create a damage calculator to tell if player T-HKO < enemy T-HKO
        } else if (previous_player_active.stats.spe > previous_enemy_active.stats.spe and scoring_battle.side(tools.ENEMY_PID).stored().hp == 0) {}
    } else if (choice_to_node.type == pkmn.Choice.Type.Switch) {} else if (choice_to_node.type == pkmn.Choice.Type.Pass) {
        sum += 100;
    }

    return sum;
}
