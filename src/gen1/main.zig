const std = @import("std");
const print = std.debug.print;
const pkmn = @import("pkmn");
const heuristics = @import("heuristics.zig");
const helper = @import("helper.zig");
const ai = @import("ai.zig");

pub fn main() !void {
    const pkmn1: pkmn.gen1.helpers.Pokemon = .{ .species = .Bulbasaur, .moves = &.{ .SleepPowder, .SwordsDance, .RazorLeaf, .BodySlam } };
    const pkmn2: pkmn.gen1.helpers.Pokemon = .{ .species = .Tauros, .moves = &.{ .BodySlam, .HyperBeam, .Blizzard, .Earthquake } };

    var battle = helper.init_battle(&.{pkmn1}, &.{pkmn2});
    var buf: [pkmn.LOGS_SIZE]u8 = undefined;
    var stream = pkmn.protocol.ByteStream{ .buffer = &buf };
    var options = pkmn.battle.options(
        pkmn.protocol.FixedLog{ .writer = stream.writer() },
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    const result = try battle.update(pkmn.Choice{}, pkmn.Choice{}, &options);
    const choice = try ai.pick_choice(battle, result, 0);
    _ = choice;
}
