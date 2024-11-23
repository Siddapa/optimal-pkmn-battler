const std = @import("std");
const print = std.debug.print;
const pkmn = @import("pkmn");
const heuristics = @import("heuristics.zig");
const helper = @import("helper.zig");
const ai = @import("ai.zig");

pub fn main() !void {
    // const pkmn1: pkmn.gen1.helpers.Pokemon = .{ .species = .Bulbasaur, .moves = &.{  } };
    // const pkmn2: pkmn.gen1.helpers.Pokemon = .{ .species = .Tauros, .moves = &.{ .BodySlam, .HyperBeam, .Pound, .Earthquake } };
    var battle = helper.init_battle(&.{
        .{ .species = .Bulbasaur, .moves = &.{ .SleepPowder, .SwordsDance, .RazorLeaf, .BodySlam } },
        .{ .species = .Charmander, .moves = &.{ .FireBlast, .FireSpin, .Slash, .Counter } },
        .{ .species = .Squirtle, .moves = &.{ .Surf, .Blizzard, .BodySlam, .Rest } },
        .{ .species = .Pikachu, .moves = &.{ .Thunderbolt, .ThunderWave, .Surf, .SeismicToss } },
        .{ .species = .Rattata, .moves = &.{ .SuperFang, .BodySlam, .Blizzard, .Thunderbolt } },
        .{ .species = .Pidgey, .moves = &.{ .DoubleEdge, .QuickAttack, .WingAttack, .MirrorMove } },
    }, &.{
        .{ .species = .Pidgey, .moves = &.{.Pound} },
        .{ .species = .Chansey, .moves = &.{ .Reflect, .SeismicToss, .SoftBoiled, .ThunderWave } },
        .{ .species = .Snorlax, .moves = &.{ .BodySlam, .Reflect, .Rest, .IceBeam } },
        .{ .species = .Exeggutor, .moves = &.{ .SleepPowder, .Psychic, .Explosion, .DoubleEdge } },
        .{ .species = .Starmie, .moves = &.{ .Recover, .ThunderWave, .Blizzard, .Thunderbolt } },
        .{ .species = .Alakazam, .moves = &.{ .Psychic, .SeismicToss, .ThunderWave, .Recover } },
    });

    var prng = std.Random.DefaultPrng.init(2);
    var random = prng.random();

    var buf: [pkmn.LOGS_SIZE]u8 = undefined;
    var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
    var options = pkmn.battle.options(
        pkmn.protocol.FixedLog{ .writer = stream.writer() },
        pkmn.gen1.chance.NULL,
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

        c2 = try ai.pick_choice(battle, result, 0);

        helper.print_battle(battle, c1, c2);
        result = try battle.update(c1, c2, &options);
    }
    print("{}\n", .{result.type});
}
