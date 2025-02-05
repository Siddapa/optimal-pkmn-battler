const std = @import("std");
const print = std.debug.print;

const pkmn = @import("pkmn");

const builder = @import("tree");
const tools = builder.tools;

fn battle_scenario() void {}

pub fn main() !void {
    const writer = std.io.getStdOut().writer();

    var rng = pkmn.PSRNG.init(@as(u64, @bitCast(std.time.milliTimestamp())));

    const battle = pkmn.gen1.helpers.Battle.random(
        &rng,
        .{ .cleric = false, .block = false },
    );

    try tools.battle_details(battle, tools.DetailOptions, writer);

    print("{}\n", .{battle});
}
