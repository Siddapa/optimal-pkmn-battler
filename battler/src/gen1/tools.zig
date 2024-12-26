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
