const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const pkmn = @import("pkmn");
const Pokemon = pkmn.gen1.helpers.Pokemon;
const ai = @import("ai.zig");

pub fn print_battle(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), c1: pkmn.Choice, c2: pkmn.Choice) void {
    const player_pkmn = battle.foe(ai.ENEMY_PID).stored();
    const enemy_pkmn = battle.side(ai.ENEMY_PID).stored();

    print("Player: {}, HP: {}/{}\n", .{ player_pkmn.species, player_pkmn.hp, player_pkmn.stats.hp });
    print("Player Choice: {}\n", .{c1});
    if (c1.type == pkmn.Choice.Type.Move and c1.data != 0) {
        print("Move Made: {}\n", .{player_pkmn.move(c1.data)});
    }

    print("\n", .{});

    print("AI: {}, HP: {}/{}\n", .{ enemy_pkmn.species, enemy_pkmn.hp, enemy_pkmn.stats.hp });
    print("AI Choice: {}\n", .{c2});
    if (c2.type == pkmn.Choice.Type.Move and c2.data != 0) {
        print("Move Made: {}\n", .{enemy_pkmn.move(c2.data)});
    }

    print("\n", .{});
    print("-" ** 50, .{});
    print("\n\n", .{});
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

pub fn calc_damage(pkmn1: *const Pokemon, pkmn2: *const Pokemon, mslot: u8) !?u16 {
    var battle = init_battle(&.{pkmn1.*}, &.{pkmn2.*});
    var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    var buf: [pkmn.LOGS_SIZE]u8 = undefined;
    var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
    var options = pkmn.battle.options(
        pkmn.protocol.FixedLog{ .writer = stream.writer() },
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    var result = try battle.update(pkmn.Choice{}, pkmn.Choice{}, &options);
    const max_choice = battle.choices(.P1, result.p1, &choices);
    const valid_choices = choices[0..max_choice];

    // for (choices) |choice| {
    //     print("{}\n", .{choice});
    // }
    // print("\n", .{});

    for (valid_choices) |choice| {
        if (choice.type == pkmn.Choice.Type.Move and choice.data == mslot) {
            print("{}\n", .{choice});
            result = try battle.update(choice, choice, &options);
            print("{}", .{result});
            return battle.last_damage;
        }
    }

    return null;
}
