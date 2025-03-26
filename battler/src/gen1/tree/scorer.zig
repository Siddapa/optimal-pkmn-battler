const std = @import("std");
const print = std.debug.print;

const pkmn = @import("pkmn");
const builder = @import("builder.zig");
const score_type = builder.score_type;

pub const NTN = struct {};

pub const Side = struct {};

pub fn score_node(scoring_node: *builder.DecisionNode, probability: builder.score_type) !score_type {
    const battle = &scoring_node.battle;
    const player_side = battle.side(.P1);
    const enemy_side = battle.side(.P2);

    var score: score_type = 0;
    switch (scoring_node.result.type) {
        .None => {
            score -= damage_per_turn(player_side, battle.turn);
            score += damage_per_turn(enemy_side, battle.turn);

            score += probability * 10000000;
        },
        .Win => {
            score += 100;
        },
        else => {},
    }

    // print("Probability: {}\n\n", .{scoring_node.probability});
    // print("Score: {}\n", .{score});
    return score;
}

pub fn damage_per_turn(side: *pkmn.gen1.Side, turn: u16) score_type {
    var total_damage: score_type = 0;
    for (side.pokemon) |mon| {
        total_damage += @as(score_type, @floatFromInt(mon.stats.hp - mon.hp));
    }
    total_damage *= 1 / @as(score_type, @floatFromInt(turn));
    return total_damage;
}

pub fn score_move(scoring_node: *builder.DecisionNode, turn_choice: builder.TurnChoice) u16 {
    var sum: f32 = 0;

    const previous_node = scoring_node.previous_node orelse return 0;

    const previous_battle = previous_node.battle;
    // const previous_player_active = previous_battle.side(.P1).active;
    const previous_player_stored = previous_battle.side(.P1).stored();
    // const previous_enemy_active = previous_battle.side(.P2).active;
    const previous_enemy_stored = previous_battle.side(.P2).stored();

    const scoring_battle = scoring_node.battle;
    // const scoring_player_active = scoring_battle.side(.P1).active;
    const scoring_player_stored = scoring_battle.side(.P1).stored();
    // const scoring_enemy_active = scoring_battle.side(.P2).active;
    const scoring_enemy_stored = scoring_battle.side(.P2).stored();

    _ = turn_choice.choices;

    // Damage Dealt
    sum += 0.01 * (previous_enemy_stored - scoring_enemy_stored);
    // Damage Taken
    sum -= 0.01 * (previous_player_stored - scoring_player_stored);

    return sum;
}
