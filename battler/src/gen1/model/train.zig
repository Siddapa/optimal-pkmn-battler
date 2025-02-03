const std = @import("std");
const print = std.debug.print;

const pkmn = @import("pkmn");

const builder = @import("tree");
const tools = builder.tools;

pub fn main() !void {
    var rng = pkmn.PSRNG.init(@as(u64, @bitCast(std.time.milliTimestamp())));

    const battle = pkmn.gen1.helpers.Battle.random(
        &rng,
        .{ .cleric = false, .block = false },
    );

    tools.battle_details(battle, true, true);

    print("{}\n", .{battle});
}
