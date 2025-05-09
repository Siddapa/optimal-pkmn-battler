const std = @import("std");
const assert = std.debug.assert;

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

    pub fn only_hp() DetailOptions {
        return .{ .hp = true };
    }

    pub fn no_moves() DetailOptions {
        return .{ .hp = true, .typing = true, .stats = true, .boosts = true, .status = true, .volatiles = true, .moves = false };
    }
};

pub fn init_battle(team1: []const Pokemon, team2: []const Pokemon) pkmn.gen1.Battle(pkmn.gen1.PRNG) {
    assert(0 <= team1.len and team1.len <= 6);
    assert(0 <= team2.len and team2.len <= 6);

    // const curr_time = @as(u64, @bitCast(std.time.milliTimestamp()));
    // TODO Deterministic transitions still influenced by seed
    var prng = std.Random.DefaultPrng.init(1234);
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

    // for (side.pokemon) |team_mem| {
    //     try writer.print("{any}\n", .{team_mem});
    // }

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
    try writer.print("Name: {s} ({}) ", .{
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
                if (value > 0) try writer.print("{s}: {}, ", .{ v.name, value });
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

pub fn fetch_choice(node: *const builder.DecisionNode, comptime player: usize) []const u8 {
    const choice = node.choices[player];
    const side = if (player == 0) .P1 else .P2;
    switch (choice.type) {
        .Move => {
            if (choice.data != 0) return @tagName(node.battle.side(side).stored().move(choice.data).id);
        },
        .Switch => {
            if (choice.data != 42) {
                return @tagName(node.battle.side(side).stored().species);
            }
        },
        .Pass => return "Pass",
    }
    return "";
}

pub fn traverse_decision_tree(
    start_node: *builder.DecisionNode,
    box: []const pkmn.gen1.Pokemon,
    writer: anytype,
    alloc: std.mem.Allocator,
) !void {
    var curr_node = start_node;
    while (true) {
        // Spacing between node selections
        try writer.writeAll("-" ** 30);
        try writer.writeAll("\n");

        for (curr_node.team) |team_mem| {
            switch (team_mem) {
                .Empty => try writer.writeAll("-1 "),
                .Filled => |box_id| try writer.print("{s} ", .{@tagName(box[box_id].species)}),
                .Lead => try writer.writeAll("_ "),
            }
        }

        try writer.writeAll("\n");
        try battle_details(curr_node.battle, DetailOptions.all(), writer);
        try writer.print("Last Damage: {}\n", .{curr_node.battle.last_damage});

        // Displays possible moves/switches as well as traversing to previous nodes/quitting
        try writer.writeAll("Select one of the following choices: \n");
        try writer.writeAll("T ID |         P Choice |         E Choice |       Score |         Probability | Next # of Transitions | Actions\n");
        try writer.writeAll("-" ** 100);
        try writer.writeAll("\n");

        std.mem.sort(*builder.DecisionNode, curr_node.transitions.items, {}, builder.compare_score);
        for (curr_node.transitions.items, 0..) |next_node, i| {
            const next_node_transitions = next_node.transitions.items.len;

            try writer.print("{:>04}   ", .{
                i + 1,
            });

            try writer.print("{s: >16}   ", .{fetch_choice(next_node, 0)});
            try writer.print("{s: >16}   ", .{fetch_choice(next_node, 1)});

            try writer.print("{d: >11.4}   ", .{next_node.score});

            try writer.print("{d: >16}   ", .{next_node.probability});

            try writer.print("{: >21}   ", .{next_node_transitions});

            try writer.print("{}", .{next_node.chance.actions});

            try writer.writeAll("\n");
        }

        if (curr_node.prev_node) |_| {
            try writer.writeAll("p=previous turn, ");
        }
        try writer.writeAll("e=exhaust_node, r=back_to_root, q=quit\n");

        // Takes a single character (u8) for processing next node to follow
        var input_buf: [10]u8 = undefined;
        const reader = std.io.getStdIn().reader();
        if (try reader.readUntilDelimiterOrEof(input_buf[0..], '\n')) |user_input| {
            if (user_input.len == @as(usize, 0)) {
                try writer.writeAll("Invalid input!\n");
                break;
            } else if (49 <= user_input[0] and user_input[0] <= 57) { // ASCII range of integers from 1-9
                const choice_id = try std.fmt.parseInt(u16, user_input, 10);
                if (0 <= choice_id - 1 and choice_id - 1 <= curr_node.transitions.items.len) {
                    curr_node = curr_node.transitions.items[choice_id - 1];
                } else {
                    try writer.writeAll("Move selection out of range!\n");
                    break;
                }
            } else if (user_input[0] == 'c') {
                curr_node = curr_node.transitions.items[0];
            } else if (user_input[0] == 'r') {
                curr_node = start_node;
            } else if (user_input[0] == 'p') {
                curr_node = curr_node.prev_node.?;
            } else if (user_input[0] == 'e') {
                builder.PRUNING = false;
                _ = try builder.exhaustive_decision_tree(curr_node, box, 0, 0, 0, alloc);
                builder.PRUNING = true;
            } else if (user_input[0] == 'q') {
                break;
            } else {
                try writer.writeAll("Invalid input, try again!\n");
            }
        } else {
            try writer.writeAll("Failed to read line!\n");
        }

        try writer.writeAll("\x1B[2J\x1B[H");
    }
}

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = struct { next: ?*Node, data: T };

        head: ?*Node,
        inner_alloc: std.mem.Allocator,

        pub fn init(alloc: std.mem.Allocator) Self {
            return Self{
                .head = null,
                .inner_alloc = alloc,
            };
        }

        pub fn deinit(self: *Self) void {
            var curr_node = self.head;
            while (curr_node) |valid_node| {
                curr_node = valid_node.next;
                self.inner_alloc.destroy(valid_node);
            }
        }

        // Add an element to the beginning of the list
        pub fn prepend(self: *Self, new: T) !void {
            const new_node: ?*Node = try self.inner_alloc.create(Node);
            new_node.?.* = .{
                .next = self.head,
                .data = new,
            };
            self.head = new_node;
        }

        // Add an element to the end of the list
        pub fn insert(self: *Self, new: T) !void {
            var curr_node = self.head;
            var prev_node = curr_node;
            while (curr_node) |valid_node| {
                prev_node = curr_node;
                curr_node = valid_node.next;
            } else {
                if (prev_node == self.head) {
                    // New node becomes head node
                    self.head = try self.inner_alloc.create(Node);
                    self.head.?.* = .{
                        .next = null,
                        .data = new,
                    };
                } else {
                    // New node after last non-null node
                    prev_node.?.next = try self.inner_alloc.create(Node);
                    prev_node.?.next.?.* = .{
                        .next = null,
                        .data = new,
                    };
                }
            }
        }

        // Remove a node that evaluates to true when
        // using the comparison function against a check item
        pub fn remove(self: *Self, item: T, cmp: fn (T, T) bool) void {
            var curr_node = self.head;
            var prev_node = curr_node;
            while (curr_node) |valid_node| {
                if (cmp(valid_node.data, item)) {
                    if (curr_node == self.head) {
                        self.head = prev_node.?.next;
                        self.inner_alloc.destroy(prev_node.?);
                    } else {
                        prev_node.?.next = valid_node.next;
                        self.inner_alloc.destroy(valid_node);
                        break;
                    }
                }
                prev_node = curr_node;
                curr_node = valid_node.next;
            }
        }

        pub fn count(self: *Self) usize {
            var curr_node = self.head;
            var c: usize = 0;
            while (curr_node) |valid_node| {
                curr_node = valid_node.next;
                c += 1;
            }
            return c;
        }

        pub fn print_nodes(self: *Self, writer: anytype) !void {
            var curr_node = self.head;
            while (curr_node) |valid_node| {
                curr_node = valid_node.next;
                try writer.print("{}\n", .{valid_node.data});
            }
        }
    };
}

fn cmp_int(x: i8, y: i8) bool {
    return x == y;
}

test "linked list ops" {
    var list = LinkedList(i8).init(std.testing.allocator);

    try list.insert(20);
    try list.prepend(10);
    try list.insert(30);
    try list.insert(40);
    try list.prepend(0);
    assert(list.count() == 5);

    list.remove(10, cmp_int);
    list.remove(0, cmp_int);
    list.remove(40, cmp_int);
    assert(list.count() == 2);

    try list.insert(50);
    try list.prepend(-10);
    assert(list.count() == 4);

    try list.print_nodes(std.io.getStdErr().writer());

    list.deinit();
}
