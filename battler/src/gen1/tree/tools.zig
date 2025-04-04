const std = @import("std");
const assert = std.debug.assert;
var gpa = std.heap.GeneralPurposeAllocator(.{}).init();
var alloc = gpa.allocator();

const pkmn = @import("pkmn");
const Pokemon = pkmn.gen1.helpers.Pokemon;

const builder = @import("builder.zig");
const enemy_ai = @import("enemy_ai.zig");

pub const DetailOptions = struct {
    hp: bool = false,
    typing: bool = false,
    stats: bool = false,
    boosts: bool = false,
    status: bool = false,
    volatiles: bool = false,
    moves: bool = false,

    pub fn all() DetailOptions {
        return .{ .hp = true, .typing = true, .stats = true, .boosts = true, .status = true, .volatiles = true, .moves = true };
    }

    pub fn no_moves() DetailOptions {
        return .{ .hp = true, .typing = true, .stats = true, .boosts = true, .status = true, .volatiles = true, .moves = false };
    }
};

pub fn init_battle(team1: []const Pokemon, team2: []const Pokemon) pkmn.gen1.Battle(pkmn.gen1.PRNG) {
    assert(0 <= team1.len and team1.len <= 6);
    assert(0 <= team2.len and team2.len <= 6);

    const curr_time = @as(u64, @bitCast(std.time.milliTimestamp()));
    var prng = (if (@hasDecl(std, "Random")) std.Random else std.rand).DefaultPrng.init(curr_time);
    var random = prng.random();

    const battle = pkmn.gen1.helpers.Battle.init(
        random.int(u64),
        team1,
        team2,
    );

    return battle;
}

pub fn battle_details(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), options: DetailOptions, writer: anytype) !void {
    try side_details(battle.side(.P1), options, writer);
    try writer.writeAll("\n");
    try side_details(battle.side(.P2), options, writer);
}

pub fn side_details(side: *const pkmn.gen1.Side, options: DetailOptions, writer: anytype) !void {
    const active = &side.active;
    const stored = side.stored();

    try name_details(stored, writer);
    if (options.hp) {
        try hp_details(stored, writer);
        try writer.writeAll("\n");
    }
    if (options.stats) {
        try stat_details(stored, writer);
        try writer.writeAll("\n");
    }
    // TODO Modified stats from active
    if (options.boosts) {
        try boost_details(active, writer);
        try writer.writeAll("\n");
    }
    if (options.status) {
        try status_details(stored, writer);
        try writer.writeAll("\n");
    }
    if (options.volatiles) {
        try volatile_details(active, writer);
        try writer.writeAll("\n");
    }
    if (options.typing) {
        try type_details(stored, writer);
        try writer.writeAll("\n");
    }
    if (options.moves) {
        for (active.moves, 1..) |move, i| {
            if (move.id != .None) {
                try move_details(active, .{ .type = .Move, .data = @intCast(i) }, writer);
                try writer.writeAll("\n");
            }
        }
    }
}

pub fn name_details(mon: *const pkmn.gen1.Pokemon, writer: anytype) !void {
    try writer.print("Name: {s} ({})", .{
        @tagName(mon.species),
        mon.level,
    });
}

pub fn type_details(mon: *const pkmn.gen1.Pokemon, writer: anytype) !void {
    if (mon.types.type1 == mon.types.type2) {
        // Single Typing
        try writer.print("Typing - {s}", .{
            @tagName(mon.types.type1),
        });
    } else {
        // Double Typing
        try writer.print("Typing - {s} {s}", .{
            @tagName(mon.types.type1),
            @tagName(mon.types.type2),
        });
    }
}

pub fn hp_details(mon: *const pkmn.gen1.Pokemon, writer: anytype) !void {
    try writer.print("HP: {:3}/{:3}", .{
        mon.hp,
        mon.stats.hp,
    });
}

pub fn stat_details(mon: *const pkmn.gen1.Pokemon, writer: anytype) !void {
    try writer.print("Stats  - Atk: {: >3}, Def: {: >3}, Spc: {: >3}, Spe: {: >3}", .{
        mon.stats.atk,
        mon.stats.def,
        mon.stats.spc,
        mon.stats.spe,
    });
}

pub fn boost_details(mon: *const pkmn.gen1.ActivePokemon, writer: anytype) !void {
    try writer.print("Boosts - Atk: {: >3}, Def: {: >3}, Spc: {: >3}, Spe: {: >3}, Accuracy: {}, Evasion: {}", .{
        mon.boosts.atk,
        mon.boosts.def,
        mon.boosts.spc,
        mon.boosts.spe,
        mon.boosts.accuracy,
        mon.boosts.evasion,
    });
}

pub fn status_details(mon: *const pkmn.gen1.Pokemon, writer: anytype) !void {
    try writer.print("Status - {s}", .{
        pkmn.gen1.Status.name(mon.status),
    });
}

pub fn volatile_details(mon: *const pkmn.gen1.ActivePokemon, writer: anytype) !void {
    try writer.writeAll("Volatiles - ");
    inline for (std.meta.fields(pkmn.gen1.Volatiles)) |v| {
        switch (@FieldType(pkmn.gen1.Volatiles, v.name)) {
            bool => {
                const value: bool = @field(mon.volatiles, v.name);
                if (value) try writer.print("{s}, ", .{v.name});
            },
            else => {
                const value: u16 = @intCast(@field(mon.volatiles, v.name));
                if (value > 0) try writer.print("{s}, ", .{v.name});
            },
        }
    }
}

pub fn move_details(mon: *const pkmn.gen1.ActivePokemon, choice: pkmn.Choice, writer: anytype) !void {
    assert(choice.type == .Move);
    const move_slot = mon.move(choice.data);
    const move_data = pkmn.gen1.Move.get(move_slot.id);
    try writer.print("{s: <12} - {: >3}% - {s: <17} - {: >5}bp", .{
        @tagName(move_slot.id),
        move_data.accuracy,
        @tagName(move_data.effect),
        move_data.bp,
    });
}

pub fn display_choice(curr_node: *builder.DecisionNode, transition: builder.Transition, comptime player: usize, writer: anytype) !void {
    const choice = transition.choices[player];
    const side = if (player == 0) .P1 else .P2;
    switch (choice.type) {
        .Move => {
            try writer.print("{s: <12}", .{@tagName(curr_node.battle.side(side).stored().move(choice.data).id)});
        },
        .Switch => {
            if (choice.data != 42) {
                if (transition.box_switch) |box_switch| {
                    try writer.print("{s: <12}", .{@tagName(box_switch.added_pokemon.species)});
                } else {
                    try writer.print("{s: <12}", .{@tagName(curr_node.battle.side(side).get(choice.data).species)});
                }
            }
        },
        else => {},
    }
    try writer.writeAll(" ");
}

pub fn traverse_decision_tree(start_node: *builder.DecisionNode, writer: anytype) !void {
    var curr_node = start_node;
    while (true) {
        // Spacing between node selections
        try writer.print("-" ** 30, .{});
        try writer.print("\n", .{});

        // Selects choices made to get to the current turn
        var c1 = pkmn.Choice{};
        var c2 = pkmn.Choice{};
        if (curr_node.previous_node) |previous_node| {
            for (previous_node.transitions.items, 0..) |transition, i| {
                if (transition.next_node == curr_node) {
                    c1 = previous_node.transitions.items[i].choices[0];
                    c2 = previous_node.transitions.items[i].choices[1];
                }
            }
        }
        try battle_details(curr_node.battle, DetailOptions.all(), writer);
        // TODO Print transitions as well
        try writer.print("Last Damage: {}\n", .{curr_node.battle.last_damage});

        // Displays possible moves/switches as well as traversing to previous nodes/quitting
        try writer.print("Select one of the following choices: \n", .{});
        for (curr_node.transitions.items, 0..) |transition, i| {
            const next_node = transition.next_node;
            const next_node_transitions = next_node.transitions.items.len;

            try writer.print("{:02}=", .{
                i + 1,
            });

            try display_choice(curr_node, transition, 0, writer);
            try display_choice(curr_node, transition, 1, writer);

            try writer.print("{d:05}, {d:.9}, {:02}, ", .{
                next_node.score,
                next_node.probability,
                next_node_transitions,
            });

            try writer.print("    {}, ", .{transition.actions});

            try writer.writeAll("\n");
        }

        if (curr_node.previous_node) |_| {
            try writer.print("p=previous turn, q=quit\n", .{});
        } else {
            try writer.print("q=quit\n", .{});
        }

        // Takes a single character (u8) for processing next node to follow
        // TODO Could reduce buf to 1 character and print "Failed to Read Line!" on failed read/no input
        var input_buf: [10]u8 = undefined;
        const reader = std.io.getStdIn().reader();
        if (try reader.readUntilDelimiterOrEof(input_buf[0..], '\n')) |user_input| {
            if (user_input.len == @as(usize, 0)) {
                try writer.print("Invalid input!\n", .{});
                break;
            } else if (49 <= user_input[0] and user_input[0] <= 57) { // ASCII range of integers from 1-9
                const choice_id = try std.fmt.parseInt(u8, user_input, 10);
                curr_node = curr_node.transitions.items[choice_id - 1].next_node;
            } else if (user_input[0] == 'c') {
                curr_node = curr_node.transitions.items[0].next_node;
            } else if (user_input[0] == 'p') {
                curr_node = curr_node.previous_node orelse break;
            } else if (user_input[0] == 'q') {
                break;
            } else {
                try writer.print("Invalid input!\n", .{});
                break;
            }
        } else {
            try writer.print("Failed to Read Line!\n", .{});
        }
    }
}
