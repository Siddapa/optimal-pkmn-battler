const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub const ftype: type = f32;

// Includes bias as one of the features
pub const k: u32 = count_features(TransitionFeatures) + 1;

pub const TransitionFeatures = packed struct {
    player_pre: PokemonFeatures = .{},
    enemy_pre: PokemonFeatures = .{},

    player_post: PokemonFeatures = .{},
    enemy_post: PokemonFeatures = .{},

    player_move: MoveFeatures = .{},
    player_options: OptionFeatures = .{},

    enemy_move: MoveFeatures = .{},
    enemy_options: OptionFeatures = .{},
};

pub const PokemonFeatures = packed struct {
    curr_hp: ftype = 0,
    base_hp: ftype = 0,
    atk: ftype = 0,
    def: ftype = 0,
    spc: ftype = 0,
    spe: ftype = 0,
    type1: ftype = 0,
    type2: ftype = 0,
    atk_boost: ftype = 0,
    def_boost: ftype = 0,
    spc_boost: ftype = 0,
    spe_boost: ftype = 0,
    acc_boost: ftype = 0,
    eva_boost: ftype = 0,
    status: ftype = 0,
};

pub const MoveFeatures = packed struct {
    bp: ftype = 0,
    acc: ftype = 0,
    type: ftype = 0,
    effect: ftype = 0,
};

pub const OptionFeatures = packed struct {
    critical: ftype = 0,
    secondary_chance: ftype = 0,
    // True if player won, false if enemy won
    speed_tie: ftype = 0,
    confused: ftype = 0,
    paralyzed: ftype = 0,
    multi_hit: ftype = 0,
    psywave: ftype = 0,
    // Techncially there are sleep turns for every pokemon, but we can
    // ignore all other party members but the lead's since we score
    // switches which will account for that
    sleeps: ftype = 0,
    confusion: ftype = 0,
    disable: ftype = 0,
    attacking: ftype = 0,
    binding: ftype = 0,
};

fn count_features(curr_struct: anytype) u32 {
    var count = 0;
    for (std.meta.fields(curr_struct)) |field| {
        switch (@typeInfo(field.type)) {
            .@"struct" => count += count_features(field.type),
            else => count += 1,
        }
    }
    return count;
}

// predictions (m x 1) = X (m x k+1) * thetas (k+1 x 1)
pub fn predict(X: []TransitionFeatures, thetas: [k]ftype, alloc: std.mem.Allocator) ![]ftype {
    var predictions = std.ArrayList(ftype).init(alloc);
    errdefer predictions.deinit();

    for (X) |transition| {
        var linear_comb: ftype = thetas[0];
        var theta_index: usize = 1;

        inline for (std.meta.fields(TransitionFeatures)) |transition_field| {
            const sub_feature = @field(transition, transition_field.name);

            inline for (std.meta.fields(@TypeOf(sub_feature))) |feature_field| {
                const value: ftype = @field(sub_feature, feature_field.name);
                const theta = thetas[@as(usize, theta_index)];

                linear_comb += value * theta;
                theta_index += 1;
            }
        }

        try predictions.append(linear_comb);
    }

    return predictions.toOwnedSlice();
}

// cost (k+1 x 1) =  sum([[X (m x k+1) * theta (k+1 x 1)] - y (m x 1)] ** 2, (m x 1)) (1 x 1)
pub fn calc_cost(X: []TransitionFeatures, y: []ftype, thetas: [k]ftype, alloc: std.mem.Allocator) !ftype {
    const m = @as(ftype, @floatFromInt(X.len));

    const normalizer: ftype = 1 / (2 * m);

    const predictions: []ftype = try predict(X, thetas, alloc);
    defer alloc.free(predictions);

    assert(predictions.len == y.len);

    var cost: ftype = 0;
    for (0..predictions.len) |i| {
        // Find error per prediction and square it
        const p_error = predictions[i] - y[i];
        cost += p_error * p_error;
    }

    return cost * normalizer;
}

// gradients (k+1 x 1) =  X^T (k+1 x m) * [[X (m x k+1) * theta (k+1 x 1)] - y (m x 1)]
pub fn update_thetas(X: []TransitionFeatures, y: []ftype, thetas: [k]ftype, alpha: ftype, alloc: std.mem.Allocator) ![k]ftype {
    const m = X.len;
    const normalizer: ftype = alpha / @as(ftype, @floatFromInt(m));
    assert(m == y.len);

    const predictions = try predict(X, thetas, alloc);
    defer alloc.free(predictions);
    assert(predictions.len == y.len);

    var errors = std.ArrayList(ftype).init(alloc);
    defer errors.deinit();
    for (0..m) |i| {
        try errors.append(predictions[i] - y[i]);
    }

    // Can't really transpose a list of structs so entire gradients array
    // is update per TransitionFeature
    var gradients = [_]ftype{0} ** k;
    for (errors.items) |f_error| {
        for (X) |transition| {
            var i: usize = 0;
            inline for (std.meta.fields(TransitionFeatures)) |transition_field| {
                const sub_feature = @field(transition, transition_field.name);

                inline for (std.meta.fields(@TypeOf(sub_feature))) |feature_field| {
                    const value = @as(ftype, @field(sub_feature, feature_field.name));

                    gradients[i] += f_error * value;
                    i += 1;
                }
            }
        }
    }

    for (0..k) |i| {
        gradients[i] = thetas[i] - (normalizer * gradients[i]);
    }

    return gradients;
}
