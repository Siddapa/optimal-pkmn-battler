const std = @import("std");
const assert = std.debug.assert;

const TransitionFeatures = packed struct {
    player_pre: PokemonFeatures,
    enemy_pre: PokemonFeatures,
    player_post: PokemonFeatures,
    enemy_post: PokemonFeatures,
};

const PokemonFeatures = packed struct {
    hp: u16,
    atk: u16,
    def: u16,
    spc: u16,
    spe: u16,
    type1: u4,
    type2: u4,
    atk_boost: i4,
    def_boost: i4,
    spc_boost: i4,
    spe_boost: i4,
    acc_boost: i4,
    eva_boost: i4,
    status: u8,
    move1_bp: u8,
    move1_acc: u8,
    move1_type: u4,
    move1_effect: u8,
    move2_bp: u8,
    move2_acc: u8,
    move2_type: u4,
    move2_effect: u8,
    move3_bp: u8,
    move3_acc: u8,
    move3_type: u4,
    move3_effect: u8,
    move4_bp: u8,
    move4_acc: u8,
    move4_type: u4,
    move4_effect: u8,
};

// predictions (m x 1) = X (m x k) * thetas (k x 1)
pub fn predict(X: []TransitionFeatures, thetas: []f64) []f64 {
    assert(std.meta.fields(PokemonFeatures) * 4, thetas.len);

    var predictions = [X.len]f64 ** 1;

    const pfeature_len = std.meta.fields(PokemonFeatures).len;
    var linear_comb: f64 = 0;
    for (X, 0..) |transition, i| {
        linear_comb = thetas[0];

        inline for (std.meta.fields(TransitionFeatures), 0..) |side_field, j| {
            const side: PokemonFeatures = @field(transition, side_field.name);

            inline for (std.meta.fields(PokemonFeatures), 0..) |player_field, h| {
                const value = @as(f64, @field(side, player_field.name));
                const theta = thetas[@as(usize, (j * pfeature_len) + h) + 1];

                linear_comb += value * theta;
            }
        }

        predictions[i] = linear_comb;
        linear_comb = 0;
    }

    return predictions;
}

// cost (k x 1) =  sum([[X (m x k) * theta (k x 1)] - y (m x 1)] ** 2, (m x 1)) (1 x 1)
pub fn calc_cost(X: []TransitionFeatures, y: []u16, thetas: []f64) f64 {
    const normalizer: f64 = 1 / (2 * X.len);

    const predictions = predict(X, thetas);
    assert(predictions.len == y.len);

    var cost: f64 = 0;
    for (0..predictions.len) |i| {
        // Find error per prediction and square it
        const p_error = predictions[i] - y[i];
        cost += p_error * p_error;
    }

    return cost * normalizer;
}

// gradients (k x 1) =  X^T (k x m) * [[X (m x k) * theta (k x 1)] - y (m x 1)]
pub fn gradient(X: []TransitionFeatures, y: []u16, thetas: []f64, alpha: f64) []f64 {
    const m = X.len;
    const k = thetas.len;
    const pokemonfeatures_len = std.meta.fields(PokemonFeatures).len;

    const normalizer: f64 = alpha / X.len;

    const predictions = predict(X, thetas);
    assert(m == y.len);

    var errors: [m]f64 = undefined;
    for (0..m) |i| {
        errors[i] = predictions[i] - y[i];
    }

    // Can't really transpose a list of structs so entire gradients array
    // is update per TransitionFeature
    var gradients = [k]f64 ** 0;
    for (errors) |f_error| {
        for (X) |transition| {
            inline for (std.meta.fields(TransitionFeatures), 0..) |side_field, i| {
                const side: PokemonFeatures = @field(transition, side_field.name);

                inline for (std.meta.fields(PokemonFeatures), 0..) |player_field, j| {
                    const value = @as(f64, @field(side, player_field.name));

                    gradients[@as(usize, (i * pokemonfeatures_len) + j)] += f_error * value;
                }
            }
        }
    }

    for (0..k) |i| {
        gradients[i] = thetas[i] - (normalizer * gradients[i]);
    }

    return gradients;
}
