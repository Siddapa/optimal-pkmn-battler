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

// const TransitionFeatures = packed struct {
//     player_pre: PokemonFeatures,
//     enemy_pre: PokemonFeatures,
//     player_post: PokemonFeatures,
//     enemy_post: PokemonFeatures,
// };
//
// fn Model(comptime T: type) T {
//     return struct {
//         const Self = @This();
//
//         coefficients: []f64,
//         intercept: f64,
//
//         pub fn predict(X: [TransitionFeatures], theta: []f64) {
//             var predictions: []
//         }
//
//         pub fn cost(X: [_]TransitionFeatures, y: u16, theta) void {
//
//         }
//     };
// }
