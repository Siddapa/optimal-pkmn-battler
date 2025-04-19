const std = @import("std");
const print = std.debug.print;

const pkmn = @import("pkmn");
const builder = @import("builder.zig");
const score_t = builder.score_t;

pub const NTN = struct {};

pub const Side = struct {};

pub fn score_node(scoring_node: *const builder.DecisionNode, box: []const pkmn.gen1.Pokemon, probability: builder.score_t) !score_t {
    _ = box;
    const battle = scoring_node.battle;
    const player_side = battle.side(.P1);
    const enemy_side = battle.side(.P2);

    var score: score_t = 0;
    switch (scoring_node.result.type) {
        .None => {
            score += 500 * dead(enemy_side);
            score -= 500 * dead(player_side);

            score += 1 * damage_per_turn(enemy_side, battle.turn, false);
            score -= 1 * damage_per_turn(player_side, battle.turn, true);

            score += 2 * status(enemy_side);
            score -= 2 * status(player_side);

            // score += 1 * volatiles(&battle, box, false);
            // score += 1 * volatiles(&battle, box, true);

            if (probability < 1e-3) {
                score += 1000000 * probability;
            } else {
                score += 100 * probability;
            }
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

const Volatiles = enum(u16) {
    Bide,
    Thrashing,
    MultiHit,
    Flinch,
    Charging,
    Binding,
    Invulnerable,
    Confusion,
    Mist,
    FocusEnergy,
    Substitute,
    Recharging,
    Rage,
    LeechSeed,
    Toxic,
    LightScreen,
    Reflect,
    Transform,
    confusion,
    attacks,
    state,
    substitute,
    transform,
    disable_duration,
    disable_move,
    toxic,
};

fn volatiles(battle: *const pkmn.gen1.Battle(pkmn.gen1.PRNG), box: []const pkmn.gen1.Pokemon, player: bool) score_t {
    const player_side = battle.side(.P1);
    const enemy_side = battle.side(.P1);
    const active = if (player) player_side.active else enemy_side.active;

    const volatile_map = std.StaticStringMap(Volatiles).initComptime(.{
        // bools
        .{ "Bide", .Bide },
        .{ "Thrashing", .Thrashing },
        .{ "MultiHit", .MultiHit },
        .{ "Flinch", .Flinch },
        .{ "Charging", .Charging },
        .{ "Binding", .Binding },
        .{ "Invulnerable", .Invulnerable },
        .{ "Confusion", .Confusion },
        .{ "Mist", .Mist },
        .{ "FocusEnergy", .FocusEnergy },
        .{ "Substitute", .Substitute },
        .{ "Recharging", .Recharging },
        .{ "Rage", .Rage },
        .{ "LeechSeed", .LeechSeed },
        .{ "Toxic", .Toxic },
        .{ "LightScreen", .LightScreen },
        .{ "Reflect", .Reflect },
        .{ "Transform", .Transform },
        // ints
        .{ "confusion", .confusion },
        .{ "attacks", .attacks },
        .{ "state", .state },
        .{ "substitute", .substitute },
        .{ "transform", .transform },
        .{ "disable_duration", .disable_duration },
        .{ "disable_move", .disable_move },
        .{ "toxic", .toxic },
    });

    var score_sum: score_t = 0;

    for (std.meta.fields(pkmn.gen1.Volatiles)) |v| {
        switch (@FieldType(pkmn.gen1.Volatiles, v.name)) {
            bool => {
                const value: bool = @field(active.volatiles, v.name);
                if (!value) continue;
                if (player) {
                    switch (volatile_map.get(v.name)) {
                        .Bide => score_sum += -100,
                        .Thrashing => score_sum += -500,
                        .MultiHit => score_sum += 0,
                        .Flinch => score_sum += -200,
                        .Charging => score_sum += -500,
                        .Binding => score_sum += -100,
                        .Invulnerable => score_sum += 0,
                        .Confusion => score_sum += -100,
                        .Mist => score_sum += 0, // Check if setup moves available
                        .FocusEnergy => score_sum += 0,
                        .Substitute => score_sum += 10, // Check if stall type
                        .Recharging => score_sum += -500,
                        .Rage => score_sum += -1000,
                        .LeechSeed => score_sum += 0,
                        .Toxic => score_sum += 0, // Check if sweeper
                        .LightScreen => score_sum += bp_per_move(enemy_side.pokemon, true),
                        .Reflect => score_sum += bp_per_move(enemy_side.pokemon, false),
                        .Transform => score_sum += 0,
                    }
                } else {
                    switch (volatile_map.get(v.name)) {
                        .Bide => score_sum += 500,
                        .Thrashing => score_sum += 100, // Depends on the move its thrashing on
                        .MultiHit => score_sum += 0,
                        .Flinch => score_sum += 100,
                        .Charging => score_sum += 400,
                        .Binding => score_sum += 500,
                        .Invulnerable => score_sum += 0,
                        .Confusion => score_sum += 200,
                        .Mist => score_sum += 0,
                        .FocusEnergy => score_sum += 200,
                        .Substitute => score_sum += -100,
                        .Recharging => score_sum += 300,
                        .Rage => score_sum += 400, // Switch and go for one shot moves
                        .LeechSeed => score_sum += 500,
                        .Toxic => score_sum += 500,
                        .LightScreen => score_sum += bp_per_move(player_side.pokemon, true) + bp_per_move(box, true),
                        .Reflect => score_sum += bp_per_move(player_side.pokemon, false) + bp_per_move(box, false),
                        .Transform => score_sum += 0, // Ignore ditto
                    }
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

fn bp_per_move(mons: []const pkmn.gen1.Pokemon, special: bool) score_t {
    var bp_sum: usize = 0;
    var moves_count: usize = 0;

    for (mons) |mon| {
        for (mon.moves) |move_slot| {
            if (move_slot.id != .None) {
                const move = pkmn.gen1.Move.get(move_slot.id);
                if (pkmn.gen1.Type.isSpecial(move) and special) {
                    if (move.bp > 0) {
                        bp_sum += move.bp;
                        moves_count += 1;
                    }
                }
            }
        }
    }

    return bp_sum / moves_count;
}
