const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const pkmn = @import("pkmn");
const Pokemon = pkmn.gen1.helpers.Pokemon;

const enemy_ai = @import("enemy_ai.zig");

pub const PLAYER_PID: pkmn.Player = .P1;
pub const ENEMY_PID: pkmn.Player = .P2;

pub fn print_battle(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), c1: pkmn.Choice, c2: pkmn.Choice) void {
    const player_pkmn = battle.side(PLAYER_PID).stored();
    const enemy_pkmn = battle.side(ENEMY_PID).stored();

    print("Player: {s}, HP: {}/{}\n", .{ @tagName(player_pkmn.species), player_pkmn.hp, player_pkmn.stats.hp });
    print("Player Choice: {s}, {}\n", .{ @tagName(c1.type), c1.data });
    if (c1.type == pkmn.Choice.Type.Move and c1.data != 0) {
        print("Move Made: {s}\n", .{@tagName(player_pkmn.move(c1.data).id)});
    }

    print("\n", .{});

    print("AI: {s}, HP: {}/{}\n", .{ @tagName(enemy_pkmn.species), enemy_pkmn.hp, enemy_pkmn.stats.hp });
    print("AI Choice: {s}, {}\n", .{ @tagName(c2.type), c2.data });
    if (c2.type == pkmn.Choice.Type.Move and c2.data != 0) {
        print("Move Made: {s}\n", .{@tagName(enemy_pkmn.move(c2.data).id)});
    }

    // print("\n", .{});
    // print("-" ** 50, .{});
    // print("\n\n", .{});
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

pub fn random_vs_enemy_ai() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var battle = init_battle(&.{
        .{ .species = .Bulbasaur, .moves = &.{.BodySlam} },
    }, &.{
        .{ .species = .Pidgey, .moves = &.{.Pound} },
    });

    var prng = std.Random.DefaultPrng.init(2);
    var random = prng.random();

    var buf: [pkmn.LOGS_SIZE]u8 = undefined;
    var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
    var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
    var options = pkmn.battle.options(
        pkmn.protocol.FixedLog{ .writer = stream.writer() },
        &chance,
        pkmn.gen1.calc.NULL,
    );
    var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    var c1 = pkmn.Choice{};
    var c2 = pkmn.Choice{};
    var result = try battle.update(c1, c2, &options);
    while (result.type == .None) {
        const max1 = battle.choices(.P1, result.p1, &choices);
        const n1 = random.uintLessThan(u8, max1);
        c1 = choices[n1];

        c2 = try enemy_ai.pick_choice(battle, result, 0);

        // tools.print_battle(battle, c1, c2);
        // print("\n\n", .{});

        const out = std.io.getStdOut().writer();
        const stats = try pkmn.gen1.calc.transitions(battle, c1, c2, gpa.allocator(), out, .{
            .durations = options.chance.durations,
            .cap = true,
            .seed = 123,
        });
        try out.print("{}\n", .{stats.?});

        result = try battle.update(c1, c2, &options);
    }
    print("{}\n", .{result.type});
}
