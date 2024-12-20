const std = @import("std");
const print = std.debug.print;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const pkmn = @import("pkmn");

const tools = @import("tools.zig");
const player_ai = @import("player_ai.zig");
const enemy_ai = @import("enemy_ai.zig");

pub fn main() !void {
    var battle = tools.init_battle(&.{
        .{ .species = .Pikachu, .moves = &.{ .Thunderbolt, .ThunderWave, .Surf, .SeismicToss } },
    }, &.{
        .{ .species = .Pidgey, .moves = &.{.Pound} },
        .{ .species = .Chansey, .moves = &.{ .Reflect, .SeismicToss, .SoftBoiled, .ThunderWave } },
        .{ .species = .Snorlax, .moves = &.{ .BodySlam, .Reflect, .Rest, .IceBeam } },
        .{ .species = .Exeggutor, .moves = &.{ .SleepPowder, .Psychic, .Explosion, .DoubleEdge } },
        .{ .species = .Starmie, .moves = &.{ .Recover, .ThunderWave, .Blizzard, .Thunderbolt } },
        .{ .species = .Alakazam, .moves = &.{ .Psychic, .SeismicToss, .ThunderWave, .Recover } },
    });
    var buf: [pkmn.LOGS_SIZE]u8 = undefined;
    var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
    var options = pkmn.battle.options(
        pkmn.protocol.FixedLog{ .writer = stream.writer() },
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    // Need an empty result and switch ins for generating tree
    const result = try battle.update(pkmn.Choice{}, pkmn.Choice{}, &options);

    const allocator = gpa.allocator();
    var box_pokemon = std.ArrayList(pkmn.gen1.Pokemon).init(allocator);
    const box_pokemon_array = [_]pkmn.gen1.helpers.Pokemon{
        .{ .species = .Pikachu, .moves = &.{ .Thunderbolt, .ThunderWave, .Surf, .SeismicToss } },
        .{ .species = .Bulbasaur, .moves = &.{ .SleepPowder, .SwordsDance, .RazorLeaf, .BodySlam } },
        .{ .species = .Charmander, .moves = &.{ .FireBlast, .FireSpin, .Slash, .Counter } },
        .{ .species = .Squirtle, .moves = &.{ .Surf, .Blizzard, .BodySlam, .Rest } },
        .{ .species = .Rattata, .moves = &.{ .SuperFang, .BodySlam, .Blizzard, .Thunderbolt } },
        .{ .species = .Pidgey, .moves = &.{ .DoubleEdge, .QuickAttack, .WingAttack, .MirrorMove } },
    };
    for (box_pokemon_array) |mon| {
        try box_pokemon.append(pkmn.gen1.helpers.Pokemon.init(mon));
    }
    player_ai.init(box_pokemon, allocator);

    const root: ?*player_ai.DecisionNode = try player_ai.optimal_decision_tree(battle, result);
    try player_ai.traverse_decision_tree(root);

    player_ai.deinit();

    // try random_vs_enemy_ai();
}

pub fn random_vs_enemy_ai() !void {
    var battle = tools.init_battle(&.{
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

        c2 = try enemy_ai.pick_choice(battle, result, 0);

        if (result.p1 == pkmn.Choice.Type.Switch) {
            tools.print_battle(battle, c1, c2);
            print("\n\n", .{});
        }
        result = try battle.update(c1, c2, &options);
    }
    print("{}\n", .{result.type});
}
