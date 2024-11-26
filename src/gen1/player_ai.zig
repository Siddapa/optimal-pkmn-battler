const std = @import("std");
const print = std.debug.print;

const pkmn = @import("pkmn");

const tools = @import("tools.zig");
const enemy_ai = @import("enemy_ai.zig");

pub const MAX_LOOKAHEAD: u8 = 3;
pub const K_LARGEST: u8 = 4;

pub const TurnChoices = struct { choices: [2]pkmn.Choice, turn: ?*DecisionNode };

pub const DecisionNode = struct {
    battle: *pkmn.gen1.Battle(pkmn.gen1.PRNG) = undefined,
    result: pkmn.Result,
    score: u8 = 0,
    previous_turn: ?*DecisionNode = null,
    next_turns: std.ArrayList(TurnChoices),
};

pub fn optimal_decision_tree(starting_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), starting_result: pkmn.Result, alloc: std.mem.Allocator) !?*DecisionNode {
    var root: ?*DecisionNode = undefined;
    var scoring_nodes: [K_LARGEST]?*DecisionNode = undefined;
    var depth: u8 = 0;
    var i: u8 = undefined;
    var original_len: usize = undefined;

    root = try exhaustive_decision_tree(null, null, starting_battle, starting_result, alloc, 0);
    for (root.?.*.next_turns.items) |next_turn| {
        next_turn.turn.?.*.score = score(next_turn.turn);
    }
    std.mem.sort(TurnChoices, root.?.*.next_turns.items, {}, compare_score);
    i = K_LARGEST;
    original_len = root.?.*.next_turns.items.len;
    while (i < original_len) {
        const delete_node = root.?.*.next_turns.swapRemove(K_LARGEST);
        free_tree(delete_node.turn, alloc);
        i += 1;
    }
    for (root.?.*.next_turns.items, 0..) |next_turn, j| {
        scoring_nodes[j] = next_turn.turn;
    }
    depth = MAX_LOOKAHEAD;

    while (depth < 100) {
        print("Depth: {}\n", .{depth});
        // Must be list of TurnChoices to be compatible with compare function for sorting by score
        var potential_nodes = std.ArrayList(TurnChoices).init(alloc);
        defer potential_nodes.deinit();
        for (scoring_nodes) |scoring_node| {
            _ = try exhaustive_decision_tree(scoring_node, null, starting_battle, scoring_node.?.*.result, alloc, 0);
            scoring_node.?.*.score = score(scoring_node);
            for (scoring_node.?.*.next_turns.items) |potential_node| {
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
                if (delete_node.turn.?.*.previous_turn.?.*.next_turns.items[j].turn == delete_node.turn) {
                    _ = delete_node.turn.?.*.previous_turn.?.*.next_turns.swapRemove(j);
                    break;
                }
                j += 1;
            }
            free_tree(delete_node.turn, alloc);
            i += 1;
        }
        for (potential_nodes.items, 0..) |potential_node, j| {
            scoring_nodes[j] = potential_node.turn;
        }
    }
    return root;
}

// Assumes inital passes and leading pokemon has switched in
pub fn exhaustive_decision_tree(curr_node: ?*DecisionNode, parent_node: ?*DecisionNode, curr_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), result: pkmn.Result, alloc: std.mem.Allocator, depth: u16) !?*DecisionNode {
    if (curr_node == null) {
        // Max possible depth to quickly generate is 6
        if (result.type != .None or depth == MAX_LOOKAHEAD) {
            return null;
        }

        var next_battle = curr_battle;
        const new_node: ?*DecisionNode = alloc.create(DecisionNode) catch unreachable;
        new_node.?.* = .{
            .battle = try alloc.create(pkmn.gen1.Battle(pkmn.gen1.PRNG)),
            .result = result,
            .previous_turn = parent_node,
            .next_turns = std.ArrayList(TurnChoices).init(alloc),
        };
        new_node.?.*.battle.* = curr_battle;

        var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
        var buf: [pkmn.LOGS_SIZE]u8 = undefined;
        var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
        var options = pkmn.battle.options(
            pkmn.protocol.FixedLog{ .writer = stream.writer() },
            pkmn.gen1.chance.NULL,
            pkmn.gen1.calc.NULL,
        );

        const max1 = curr_battle.choices(tools.PLAYER_PID, result.p1, &choices);
        const player_valid_choices = choices[0..max1];

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
        for (curr_node.?.*.next_turns.items, 0..) |next_turn, i| {
            if (next_turn.turn == null) {
                curr_node.?.*.next_turns.items[i].turn = try exhaustive_decision_tree(next_turn.turn, curr_node, curr_node.?.*.battle.*, curr_node.?.*.result, alloc, depth + 1);
            } else {
                _ = try exhaustive_decision_tree(next_turn.turn, curr_node, curr_node.?.*.battle.*, curr_node.?.*.result, alloc, depth + 1);
            }
        }
        return curr_node;
    }
}

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
                print("{}={s}, ", .{ i + 1, @tagName(curr_node.?.*.battle.side(tools.PLAYER_PID).stored().move(next_turn.choices[0].data).id) });
            } else if (next_turn.choices[0].type == pkmn.Choice.Type.Switch and next_turn.choices[0].data != 42) {
                print("{}={s}, ", .{ i + 1, @tagName(curr_node.?.*.battle.side(tools.PLAYER_PID).get(next_turn.choices[0].data).species) });
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

pub fn score(scoring_node: ?*DecisionNode) u8 {
    return scoring_node.?.*.next_turns.items[0].choices[0].data;
}
