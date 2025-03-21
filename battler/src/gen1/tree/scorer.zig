const builder = @import("builder.zig");
const pkmn = @import("pkmn");

pub const NTN = struct {};

pub const Side = struct {};

pub fn score_node(scoring_node: *builder.DecisionNode) f16 {
    const battle = &scoring_node.battle;
    const player_side = battle.side(.P1);
    const enemy_side = battle.side(.P2);

    switch (scoring_node.result.type) {
        .None => {
            var score: f16 = 0;

            score -= (damage_per_turn(player_side, battle.turn));
            score += (damage_per_turn(enemy_side, battle.turn));

            return score;
        },
        .Win => return 100,
        else => return 0,
    }
}

pub fn damage_per_turn(side: *pkmn.gen1.Side, turn: u16) f16 {
    var total_damage: u16 = 0;
    for (side.pokemon) |mon| {
        total_damage += mon.stats.hp - mon.hp;
    }
    return @as(f16, @floatFromInt(total_damage)) / @as(f16, @floatFromInt(turn));
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
