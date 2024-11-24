const std = @import("std");
const print = std.debug.print;

const pkmn = @import("pkmn");

const tools = @import("tools.zig");
const enemy_ai = @import("enemy_ai.zig");

const MAX_LOOKAHEAD: u8 = 5;

pub const DecisionNode = struct {
    battle: *pkmn.gen1.Battle(pkmn.gen1.PRNG) = undefined,
    choices: std.ArrayList([2]pkmn.Choice),
    // TODO Definetly need a better breakdown of the various scoring methods
    score: u8 = 0,
    previous_turn: ?*DecisionNode = null,
    next_turns: std.ArrayList(?*DecisionNode),
};

pub const DecisionTree = struct {
    root: ?*DecisionNode = null,
    alloc: std.mem.Allocator,
};

// Assumes inital passes and leading pokemon has switched in
pub fn exhaustive_decision_tree(parent_node: ?*DecisionNode, curr_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), result: pkmn.Result, alloc: std.mem.Allocator, depth: u16) !?*DecisionNode {
    // Max possible depth to quickly generate is 6
    if (result.type != .None or depth == MAX_LOOKAHEAD) {
        return null;
    }

    var next_battle = curr_battle;
    const curr_node: ?*DecisionNode = alloc.create(DecisionNode) catch unreachable;
    curr_node.?.* = .{
        .battle = try alloc.create(pkmn.gen1.Battle(pkmn.gen1.PRNG)),
        .choices = std.ArrayList([2]pkmn.Choice).init(alloc),
        .next_turns = std.ArrayList(?*DecisionNode).init(alloc),
        .previous_turn = parent_node,
    };
    curr_node.?.*.battle.* = curr_battle;

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
        const child_node = try exhaustive_decision_tree(curr_node, next_battle, new_result, alloc, depth + 1);
        next_battle = curr_battle;
        try curr_node.?.*.next_turns.append(child_node);
        try curr_node.?.*.choices.append(.{ choice, c2 });
    }
    return curr_node;
}

pub fn traverse_decision_tree(curr_node: ?*DecisionNode) !void {
    if (curr_node != null) {
        print("-" ** 30, .{});
        print("\n", .{});
        var buf: [10]u8 = undefined;
        var traversing: bool = true;

        var c1 = pkmn.Choice{};
        var c2 = pkmn.Choice{};
        if (curr_node.?.*.previous_turn != null) {
            for (curr_node.?.*.previous_turn.?.*.next_turns.items, 0..) |next_turn, i| {
                if (next_turn == curr_node) {
                    c1 = curr_node.?.*.previous_turn.?.*.choices.items[i][0];
                    c2 = curr_node.?.*.previous_turn.?.*.choices.items[i][1];
                }
            }
        }
        tools.print_battle(curr_node.?.*.battle.*, c1, c2);
        print("\n", .{});

        print("Select one of the following choices: \n", .{});
        for (curr_node.?.*.choices.items, 0..) |choice, i| {
            if (choice[0].type == pkmn.Choice.Type.Move) {
                print("{}={s}, ", .{ i + 1, @tagName(curr_node.?.*.battle.side(tools.PLAYER_PID).stored().move(choice[0].data).id) });
            } else if (choice[0].type == pkmn.Choice.Type.Switch) {
                print("{}={s}, ", .{ i + 1, @tagName(curr_node.?.*.battle.side(tools.PLAYER_PID).get(choice[0].data).species) });
            } else if (choice[0].type == pkmn.Choice.Type.Pass) {
                print("c=continue, ", .{});
            }
        }
        print("p=previous turn, q=quit\n", .{});

        const reader = std.io.getStdIn().reader();
        if (try reader.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            if (49 <= user_input[0] and user_input[0] <= 57) {
                const choice_id = try std.fmt.parseInt(u8, user_input, 10);
                try traverse_decision_tree(curr_node.?.*.next_turns.items[choice_id - 1]);
            } else if (user_input[0] == 'c') {
                try traverse_decision_tree(curr_node.?.*.next_turns.items[0]);
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
