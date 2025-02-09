const std = @import("std");
const assert = std.debug.assert;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();

const pkmn = @import("pkmn");
const Pokemon = pkmn.gen1.helpers.Pokemon;

const builder = @import("builder.zig");
const enemy_ai = @import("enemy_ai.zig");

pub const DetailOptions = struct {
    player: ?bool = null,
    hp: bool = false,
    stats: bool = false,
    boosts: bool = false,
    status: bool = false,
    typing: bool = false,
    moves: bool = false,

    pub fn all() DetailOptions {
        return .{
            .hp = true,
            .stats = true,
            .boosts = true,
            .status = true,
            .typing = true,
            .moves = true,
        };
    }
    // TODO Volatiles
};

pub fn battle_details(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), options: DetailOptions, writer: anytype) !void {
    try side_details(battle.side(.P1), options, writer);
    try side_details(battle.side(.P2), options, writer);
    try writer.print("\n", .{});
}

pub fn side_details(side: *const pkmn.gen1.Side, options: DetailOptions, writer: anytype) !void {
    const active_p = side.active;
    const p = side.stored();

    try writer.print("Name: {s} ({})\n", .{
        @tagName(p.species),
        p.level,
    });

    if (options.hp) try writer.print("HP: {}/{}\n", .{
        p.hp,
        p.stats.hp,
    });

    if (options.stats) try writer.print("Stats  - Atk: {: >3}, Def: {: >3}, Spc: {: >3}, Spe: {: >3}\n", .{
        p.stats.atk,
        p.stats.def,
        p.stats.spc,
        p.stats.spe,
    });

    // TODO Modified stats from active

    if (options.boosts) try writer.print("Boosts - Atk: {: >3}, Def: {: >3}, Spc: {: >3}, Spe: {: >3}, Accuracy: {}, Evasion: {}\n", .{
        active_p.boosts.atk,
        active_p.boosts.def,
        active_p.boosts.spc,
        active_p.boosts.spe,
        active_p.boosts.accuracy,
        active_p.boosts.evasion,
    });

    if (options.status) try writer.print("Status - {s}\n", .{
        pkmn.gen1.Status.name(p.status),
    });

    // TODO Volatiles

    if (options.typing) {
        if (p.types.type1 == p.types.type2) {
            // Single Typing
            try writer.print("Typing - {s}\n", .{
                @tagName(p.types.type1),
            });
        } else {
            // Double Typing
            try writer.print("Typing - {s} {s}\n", .{
                @tagName(p.types.type1),
                @tagName(p.types.type2),
            });
        }
    }

    if (options.moves) {
        for (p.moves) |move| {
            const move_data = pkmn.gen1.Move.get(move.id);
            try writer.print("{s: <12} - {: >3}% - {s: <17} - {: >5}bp\n", .{
                @tagName(move.id),
                move_data.accuracy,
                @tagName(move_data.effect),
                move_data.bp,
            });
        }
    }

    try writer.print("\n", .{});
}

pub fn init_battle(team1: []const Pokemon, team2: []const Pokemon) pkmn.gen1.Battle(pkmn.gen1.PRNG) {
    assert(0 <= team1.len and team1.len <= 6);
    assert(0 <= team2.len and team2.len <= 6);

    var prng = (if (@hasDecl(std, "Random")) std.Random else std.rand).DefaultPrng.init(1234);
    var random = prng.random();

    const battle = pkmn.gen1.helpers.Battle.init(
        random.int(u64),
        team1,
        team2,
    );

    return battle;
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
            if (transition.choices[0].type == pkmn.Choice.Type.Move) {
                try writer.print("{}={s}/M ({}), ", .{ i + 1, @tagName(curr_node.battle.side(.P1).stored().move(transition.choices[0].data).id), next_node.score });
            } else if (transition.choices[0].type == pkmn.Choice.Type.Switch and transition.choices[0].data != 42) {
                if (transition.box_switch) |box_switch| {
                    try writer.print("{}={s}/S ({}), ", .{ i + 1, @tagName(box_switch.added_pokemon.species), next_node.score });
                } else {
                    try writer.print("{}={s}/S ({}), ", .{ i + 1, @tagName(curr_node.battle.side(.P1).get(transition.choices[0].data).species), next_node.score });
                }
            } else if (transition.choices[0].type == pkmn.Choice.Type.Pass) {
                try writer.print("c=continue, ", .{});
            }
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
