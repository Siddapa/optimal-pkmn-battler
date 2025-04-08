const std = @import("std");
const print = std.debug.print;

const pkmn = @import("pkmn");
const builder = @import("builder.zig");
const score_t = builder.score_t;

pub const NTN = struct {};

pub const Side = struct {};

pub fn score_node(scoring_node: *const builder.DecisionNode, probability: builder.score_t) !score_t {
    const battle = scoring_node.battle;
    const player_side = battle.side(.P1);
    const enemy_side = battle.side(.P2);

    var score: score_t = 0;
    switch (scoring_node.result.type) {
        .None => {
            score += 500 * dead(enemy_side);
            score -= 500 * dead(player_side);

            score += 2 * damage_per_turn(enemy_side, battle.turn, false);
            score -= 1 * damage_per_turn(player_side, battle.turn, true);

            score += status(enemy_side);
            score -= status(player_side);

            score += status(enemy_side);
            score -= status(player_side);

            var prob_mul: score_t = 0;
            // Switches are high probability events that should be weighed separately
            if (probability < 1e-3) {
                prob_mul = 1000000;
            } else {
                prob_mul = 100;
            }
            score += prob_mul * probability;
        },
        .Win => {
            score += std.math.floatMax(score_t);
        },
        else => {},
    }

    // print("Probability: {}\n\n", .{scoring_node.probability});
    // print("Score: {}\n", .{score});
    return score;
}

fn dead(side: *const pkmn.gen1.Side) score_t {
    var count: score_t = 0;
    for (side.pokemon) |mon| {
        if (mon.hp == 0) {
            count += 1;
        }
    }
    return count;
}

fn damage_per_turn(side: *const pkmn.gen1.Side, turn: u16, player: bool) score_t {
    var total_damage: score_t = 0;
    for (side.pokemon) |mon| {
        total_damage += @as(score_t, @floatFromInt(mon.stats.hp - mon.hp));
    }
    total_damage *= 1 / @as(score_t, @floatFromInt(turn));
    if (total_damage == 0 and player) {
        // Ensure damage taken on player side is scored heavily
        return 10000;
    }
    return total_damage;
}

// TODO Account for pre-statusing strategies
fn status(side: *const pkmn.gen1.Side) score_t {
    const active = side.active;
    const stored = side.stored();
    const sleep_score = 500;

    if (pkmn.gen1.Status.is(stored.status, .SLP)) {
        return sleep_score;
    } else if (pkmn.gen1.Status.is(stored.status, .PSN)) {
        return 100;
    } else if (pkmn.gen1.Status.is(stored.status, .BRN)) {
        return 100;
    } else if (pkmn.gen1.Status.is(stored.status, .FRZ)) {
        return 500;
    } else if (pkmn.gen1.Status.is(stored.status, .PAR)) {
        return @floatFromInt(active.stats.spe);
    } else if (pkmn.gen1.Status.is(stored.status, .EXT)) {
        // .EXT identifies BADLY TOXIC or self-inflicted sleep
        // depending on the encoding
        if (stored.status == pkmn.gen1.Status.TOX) return 100 else return sleep_score;
    }
    // Techniclly unnecessary since if's are exhaustive
    return 0;
}

fn volatiles(side: *const pkmn.gen1.Side) score_t {
    const active = side.active;
    // const stored = side.stored();

    const volatile_map = std.StaticStringMap(type).initComptime(.{
        .{ "Bide", .Bide },
    });

    inline for (std.meta.fields(pkmn.gen1.Volatiles)) |v| {
        switch (@FieldType(pkmn.gen1.Volatiles, v.name)) {
            bool => {
                const value: bool = @field(active.volatiles, v.name);
                switch (volatile_map.get(value)) {
                    .Bide => return 10,
                }
            },
            else => {
                // Cast all non-bool fields to u16 (largest integer field)
                const value: u16 = @intCast(@field(active.volatiles, v.name));
                _ = value;
            },
        }
    }
}
