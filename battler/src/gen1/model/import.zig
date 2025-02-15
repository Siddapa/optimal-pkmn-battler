const std = @import("std");
const pkmn = @import("pkmn");

const regressor = @import("regressor.zig");
const PokemonFeatures = regressor.PokemonFeatures;

pub fn collect_training_data(
    dir: std.fs.Dir,
    alloc: std.mem.Allocator,
) !struct {
    []regressor.TransitionFeatures,
    []regressor.ftype,
} {
    var walker = try dir.walk(alloc);
    defer walker.deinit();

    var entries = std.ArrayList(regressor.TransitionFeatures).init(alloc);
    var scores = std.ArrayList(regressor.ftype).init(alloc);
    defer entries.deinit();
    defer scores.deinit();

    while (try walker.next()) |file| {
        var data_file: std.fs.File = try dir.openFile(file.basename, .{});
        defer data_file.close();
        const datain = data_file.reader();

        const init_battle = try datain.readStruct(pkmn.gen1.Battle(pkmn.gen1.PRNG));

        const player_pre = convert_pokemon(init_battle.side(.P1));
        const enemy_pre = convert_pokemon(init_battle.side(.P2));

        // TODO Rewrite to handle EOF as an if condition rather than an error check
        while (convert_transition(init_battle, datain)) |converted| {
            var features, const score = converted;
            features.player_pre = player_pre;
            features.player_pre = enemy_pre;
            try entries.append(features);
            try scores.append(score);
        } else |err| {
            switch (err) {
                error.EndOfStream => continue,
                else => return err,
            }
        }
    }

    return .{
        try entries.toOwnedSlice(),
        try scores.toOwnedSlice(),
    };
}

fn convert_transition(init_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), datain: anytype) !struct { regressor.TransitionFeatures, regressor.ftype } {
    var features = regressor.TransitionFeatures{};

    const player_choice = try datain.readStruct(pkmn.Choice);
    const enemy_choice = try datain.readStruct(pkmn.Choice);
    const actions = try datain.readStruct(pkmn.gen1.chance.Actions);
    const durations = try datain.readStruct(pkmn.gen1.chance.Durations);
    const battle = try datain.readStruct(pkmn.gen1.Battle(pkmn.gen1.PRNG));

    var input_buf: [4]u8 = undefined;
    const score_input = try datain.readUntilDelimiterOrEof(input_buf[0..], '\n') orelse "";
    const raw_score = try std.fmt.parseInt(u16, score_input, 10);
    const score: regressor.ftype = @floatFromInt(raw_score);

    features.player_post = convert_pokemon(battle.side(.P1));
    features.enemy_post = convert_pokemon(battle.side(.P2));

    features.player_move = convert_move(init_battle.side(.P1), player_choice);
    features.player_options = convert_options(actions.p1, durations.p1);

    features.enemy_move = convert_move(init_battle.side(.P2), enemy_choice);
    features.enemy_options = convert_options(actions.p2, durations.p2);

    return .{ features, score };
}

fn convert_pokemon(side: *const pkmn.gen1.Side) regressor.PokemonFeatures {
    var features = regressor.PokemonFeatures{};

    const active = side.active;
    const stored = side.stored();

    features.curr_hp = @floatFromInt(stored.hp);
    features.base_hp = @floatFromInt(stored.stats.hp);
    features.atk = @floatFromInt(stored.stats.atk);
    features.def = @floatFromInt(stored.stats.def);
    features.spc = @floatFromInt(stored.stats.spc);
    features.spe = @floatFromInt(stored.stats.spe);
    features.type1 = @floatFromInt(@intFromEnum(stored.types.type1));
    features.type1 = @floatFromInt(@intFromEnum(stored.types.type2));
    features.atk_boost = @floatFromInt(active.boosts.atk);
    features.def_boost = @floatFromInt(active.boosts.def);
    features.spc_boost = @floatFromInt(active.boosts.spc);
    features.acc_boost = @floatFromInt(active.boosts.accuracy);
    features.eva_boost = @floatFromInt(active.boosts.evasion);
    features.status = @floatFromInt(stored.status); // Status has associated ids for its enum

    return features;
}

fn convert_move(side: *const pkmn.gen1.Side, choice: pkmn.Choice) regressor.MoveFeatures {
    var features = regressor.MoveFeatures{};

    if (choice.type == .Move) {
        const move_slot = side.stored().move(choice.data);
        const move = pkmn.gen1.Move.get(move_slot.id);

        features.bp = @floatFromInt(move.bp);
        features.acc = @floatFromInt(move.accuracy);
        features.type = @floatFromInt(@intFromEnum(move.type));
        features.effect = @floatFromInt(@intFromEnum(move.effect));
    }

    return features;
}

fn convert_options(actions: pkmn.gen1.chance.Action, durations: pkmn.gen1.chance.Duration) regressor.OptionFeatures {
    var features = regressor.OptionFeatures{};

    features.critical = convert_bool_optional(actions.critical_hit);
    features.secondary_chance = convert_bool_optional(actions.secondary_chance);
    features.speed_tie = convert_player_optional(actions.speed_tie);
    features.confused = convert_bool_optional(actions.confused);
    features.paralyzed = convert_bool_optional(actions.paralyzed);
    features.multi_hit = @floatFromInt(actions.multi_hit);
    features.psywave = @floatFromInt(actions.psywave);

    // Selects sleep turns for the lead pokemon
    features.sleeps = @floatFromInt((durations.sleeps & 0o100000) >> 15);
    features.confusion = @floatFromInt(durations.confusion);
    features.disable = @floatFromInt(durations.disable);
    features.attacking = @floatFromInt(durations.attacking);
    features.binding = @floatFromInt(durations.binding);

    return features;
}

fn convert_bool_optional(optional: pkmn.Optional(bool)) regressor.ftype {
    if (optional == .true) {
        return 1;
    } else if (optional == .false) {
        return 2;
    } else if (optional == .None) {
        return 3;
    }

    return 0;
}

fn convert_player_optional(optional: pkmn.Optional(pkmn.Player)) regressor.ftype {
    if (optional == .P1) {
        return 1;
    } else if (optional == .P2) {
        return 2;
    } else if (optional == .None) {
        return 3;
    }

    return 0;
}
