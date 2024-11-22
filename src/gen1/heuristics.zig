const std = @import("std");
const pkmn = @import("pkmn");
const print = std.debug.print;
const Pokemon = pkmn.gen1.Pokemon;

pub const TypeSynergy = struct {
    pkmn1: u8,
    pkmn2: u8,
};

// Scores the synergy of a pokemon's moveset (damaging moves only) against the enemy pokemon using:
// 1) Type Effectiveness
// 2) Base Power
// pub fn type_synergy(pkmn1: *const Pokemon, pkmn2: *const Pokemon) TypeSynergy {
//     const pkmn1_types = pkmn1.species.get().types;
//     const pkmn2_types = pkmn2.species.get().types;
//
//     for (pkmn1.moves) |move| {
//
//     }
//
//     for (pkmn2.moves) |move| {
//
//     }
//
//     // Same type for pkmn1
//     if (pkmn1_types.type1 == pkmn1_types.type2) {
//         // Same type for pkmn2
//         if (pkmn2_types.type1 == pkmn2_types.type2) {
//
//         } else {
//
//         }
//     } else {}
//
//     print("Types1: {}\nTypes2: {}\n", .{ pkmn1_types, pkmn2_types });
// }
