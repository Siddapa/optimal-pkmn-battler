const std = @import("std");
const print = std.debug.print;
const json = std.json;
var da: std.heap.DebugAllocator(.{}) = .init;
var import_arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);
var tree_prep_arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);

const tree = @import("tree");
const pkmn = @import("pkmn");
const import = @import("import.zig");
const memory = @import("memory.zig");
const errors = @import("errors.zig");

var tree_gen_alloc = std.heap.wasm_allocator;
var import_alloc: std.mem.Allocator = undefined;
var tree_prep_alloc: std.mem.Allocator = tree_prep_arena.allocator();

var decision_tree_instance: ?*tree.DecisionNode = null;
var box: std.ArrayList(pkmn.gen1.Pokemon) = undefined;
var player_imports: std.ArrayList(import.PokemonImport) = undefined;
var enemy_imports: std.ArrayList(import.PokemonImport) = undefined;

const seed: usize = 1234;
pub const pkmn_options = pkmn.Options{ .internal = true };

// 0x0 is valid address as a function arguement in both Zig and JS
// however as a comptime global, Zig treats that memory location as
// special for optional pointers so ignore that address just to be safe.
// Start at 0x4 for 4 byte alignment for non-char types
const wasm_buf_u8: [*]u8 = @ptrFromInt(0x4);
const wasm_buf_u32: [*]u32 = @ptrFromInt(0x4);
const wasm_buf_u64: [*]u64 = @ptrFromInt(0x4);
const wasm_buf_i32: [*]i32 = @ptrFromInt(0x4);

export fn test_memory() errors.error_t {
    const arg_count: usize = 5;
    var load_args: [arg_count]memory.WASMArg = undefined;
    memory.load(arg_count, &load_args, .{
        .Int32,
        .Uint32,
        .string,
        .Int32Array,
        .Uint32Array,
    }, tree_prep_alloc) catch |err| return errors.e_to_v(err);

    for (load_args) |arg| {
        switch (arg) {
            .Int32 => |*int| print("{}\n", .{int.*}),
            .Uint32 => |*int| print("{}\n", .{int.*}),
            .string => |*str| print("{s}\n", .{str.*}),
            .Int32Array => |*arr| print("{any}\n", .{arr.*}),
            .Uint32Array => |*arr| print("{any}\n", .{arr.*}),
        }
    }

    const args: [5]memory.WASMArg = .{
        memory.WASMArg{ .Int32 = -2 },
        memory.WASMArg{ .Uint32 = 2 },
        memory.WASMArg{ .string = "returning" },
        memory.WASMArg{ .Int32Array = &.{ -2, -2, -2 } },
        memory.WASMArg{ .Uint32Array = &.{ 2, 2, 2 } },
    };
    memory.store(&args);

    for (args) |arg| {
        switch (arg) {
            .Int32 => |*int| print("{}\n", .{int.*}),
            .Uint32 => |*int| print("{}\n", .{int.*}),
            .string => |*str| print("{s}\n", .{str.*}),
            .Int32Array => |*arr| print("{any}\n", .{arr.*}),
            .Uint32Array => |*arr| print("{any}\n", .{arr.*}),
        }
    }

    return 0;
}

export fn test_memory_load() errors.error_t {
    return 0;
}

export fn init() errors.error_t {
    import_alloc = import_arena.allocator();
    box = std.ArrayList(pkmn.gen1.Pokemon).init(std.heap.wasm_allocator);
    player_imports = std.ArrayList(import.PokemonImport).init(std.heap.wasm_allocator);
    enemy_imports = std.ArrayList(import.PokemonImport).init(std.heap.wasm_allocator);
    return 0;
}

export fn clear() errors.error_t {
    _ = import_arena.reset(.free_all);
    box.clearAndFree();
    player_imports.clearAndFree();
    enemy_imports.clearAndFree();
    return 0;
}

export fn generateOptimizedDecisionTree(lead: u8) errors.error_t {
    if (decision_tree_instance) |foo| tree.free_tree(foo, tree_gen_alloc);
    box.clearAndFree();
    _ = tree_prep_arena.reset(.free_all);
    tree_prep_alloc = tree_prep_arena.allocator();

    var lead_pokemon: pkmn.gen1.helpers.Pokemon = undefined;
    var enemy_team = std.ArrayList(pkmn.gen1.helpers.Pokemon).init(tree_prep_alloc);

    var all_moves = std.ArrayList(pkmn.gen1.Move).init(tree_prep_alloc);

    var move_end_index: usize = 0;
    for (player_imports.items, 0..) |player_import, i| {
        if (import.convert_species(player_import.species)) |valid_species| {
            const move_start_index: usize = move_end_index;
            for (player_import.moves) |move_str| {
                if (import.convert_move(move_str)) |move| {
                    all_moves.append(move) catch |err| return errors.e_to_v(err);
                    move_end_index += 1;
                }
            }

            if (i == lead) {
                lead_pokemon = .{
                    .species = valid_species,
                    .moves = all_moves.items[move_start_index..move_end_index],
                    .dvs = pkmn.gen1.DVs{
                        .atk = @intCast(player_import.dvs.atk),
                        .def = @intCast(player_import.dvs.def),
                        .spc = @intCast(player_import.dvs.spc),
                        .spe = @intCast(player_import.dvs.spe),
                    },
                };
            } else {
                box.append(pkmn.gen1.helpers.Pokemon.init(.{
                    .species = valid_species,
                    .moves = all_moves.items[move_start_index..move_end_index],
                    .dvs = pkmn.gen1.DVs{
                        .atk = @intCast(player_import.dvs.atk),
                        .def = @intCast(player_import.dvs.def),
                        .spc = @intCast(player_import.dvs.spc),
                        .spe = @intCast(player_import.dvs.spe),
                    },
                })) catch |err| return errors.e_to_v(err);
            }
        }
    }

    for (enemy_imports.items) |enemy_import| {
        if (import.convert_species(enemy_import.species)) |valid_species| {
            const move_start_index: usize = move_end_index;
            for (enemy_import.moves) |move_str| {
                if (import.convert_move(move_str)) |move| {
                    all_moves.append(move) catch |err| return errors.e_to_v(err);
                    move_end_index += 1;
                }
            }

            enemy_team.append(.{
                .species = valid_species,
                .moves = all_moves.items[move_start_index..move_end_index],
                .dvs = pkmn.gen1.DVs{
                    .atk = @intCast(enemy_import.dvs.atk),
                    .def = @intCast(enemy_import.dvs.def),
                    .spc = @intCast(enemy_import.dvs.spc),
                    .spe = @intCast(enemy_import.dvs.spe),
                },
            }) catch |err| return errors.e_to_v(err);
        }
    }

    if (enemy_imports.items.len > 6) {
        return errors.e_to_v(errors.Errors.TooManyEnemies);
    }

    var prng = std.Random.DefaultPrng.init(seed);
    var battle = pkmn.gen1.helpers.Battle.init(prng.random().int(u64), &.{lead_pokemon}, enemy_team.toOwnedSlice() catch |err| return errors.e_to_v(err));

    var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
    var calc = pkmn.gen1.Calc{};
    const options = pkmn.battle.options(
        pkmn.protocol.NULL,
        &chance,
        &calc,
    );

    const result = battle.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch |err| return errors.e_to_v(err);

    const imm_box: []const pkmn.gen1.Pokemon = box.items;

    decision_tree_instance = tree.optimal_decision_tree(battle, result, imm_box, true, tree_gen_alloc) catch |err| return errors.e_to_v(err);

    return 0;
}

export fn getNextNode(curr_node: *tree.DecisionNode, index: usize) *tree.DecisionNode {
    return curr_node.transitions.items[index];
}

export fn getNumOfNextTurns(curr_node: *tree.DecisionNode) usize {
    return curr_node.transitions.items.len;
}

export fn getScore(curr_node: *tree.DecisionNode) usize {
    return @intFromFloat(curr_node.score);
}

export fn getResult(curr_node: *tree.DecisionNode) i8 {
    return if (curr_node.result.type == .None) 1 else 0;
}

// export fn getTeam(curr_node: *tree.DecisionNode) u8 {
//     for (0..6) |i| {
//         switch (curr_node.team[i]) {
//             .Empty => wasm_buf_i32[i] = -1,
//             .Lead => wasm_buf_i32[i] = -2,
//             .Filled => |box_id| wasm_buf_i32[i] = @bitCast(box_id),
//         }
//     }
//     return 6;
// }

// TODO Refactor for no TurnChoices
// export fn getTransitionChoice(curr_node: *tree.DecisionNode, index: usize, player: bool, out: [*]u8) usize {
//     const turn_choice: tree.Transition = curr_node.transitions.items[index];
//     const choice: pkmn.Choice = turn_choice.choices[if (player) 0 else 1];
//     const side: pkmn.Player = if (player) .P1 else .P2;
//     var details: []const u8 = undefined;
//
//     if (player) {
//         if (choice.type == pkmn.Choice.Type.Move) {
//             if (choice.data == 0) {
//                 details = std.fmt.allocPrint(tree_prep_alloc, "Stalled", .{}) catch "";
//             } else {
//                 details = std.fmt.allocPrint(tree_prep_alloc, "P_Move: {s}", .{@tagName(curr_node.battle.side(side).stored().move(choice.data).id)}) catch "";
//             }
//         } else if (choice.type == pkmn.Choice.Type.Switch and choice.data != 42) {
//             if (turn_choice.box_switch) |box_switch| {
//                 details = std.fmt.allocPrint(tree_prep_alloc, "P_BoxSwitch: {s}", .{@tagName(box_switch.added_pokemon.species)}) catch "";
//             } else {
//                 details = std.fmt.allocPrint(tree_prep_alloc, "P_Switch: {s}", .{@tagName(curr_node.battle.side(side).get(choice.data).species)}) catch "";
//             }
//         } else {
//             details = std.fmt.allocPrint(tree_prep_alloc, "Pass", .{}) catch "";
//         }
//     } else {
//         if (choice.type == pkmn.Choice.Type.Move) {
//             if (choice.data == 0) {
//                 details = std.fmt.allocPrint(tree_prep_alloc, "Stalled", .{}) catch "";
//             } else {
//                 details = std.fmt.allocPrint(tree_prep_alloc, "E_Move: {s}", .{@tagName(curr_node.battle.side(side).stored().move(choice.data).id)}) catch "";
//             }
//         } else if (choice.type == pkmn.Choice.Type.Switch and choice.data != 42) {
//             details = std.fmt.allocPrint(tree_prep_alloc, "E_Switch: {s}", .{@tagName(curr_node.battle.side(side).get(choice.data).species)}) catch "";
//         } else {
//             details = std.fmt.allocPrint(tree_prep_alloc, "Pass", .{}) catch "";
//         }
//     }
//
//     @memcpy(out, details);
//     return details.len;
// }

export fn getSpecies(curr_node: *tree.DecisionNode, player: bool) usize {
    const side: pkmn.Player = if (player) .P1 else .P2;
    const species_str: []const u8 = @tagName(curr_node.battle.side(side).stored().species);
    @memcpy(wasm_buf_u8, species_str);
    return species_str.len;
}

export fn getHP(curr_node: *tree.DecisionNode, player: bool) usize {
    const side: pkmn.Player = if (player) .P1 else .P2;
    return curr_node.battle.side(side).stored().hp;
}

// Player Encoding:
// 1 = Player
// 0 = Enemy
// Error Encoding:
// 0 = Success
// 1 = Failed to parse JSON into struct
// 2,3 = Failed to append memory
export fn importPokemon(import_len: usize, player: u8) errors.error_t {
    const json_str = wasm_buf_u8[0..import_len];
    const parsed = json.parseFromSlice(import.PokemonImport, import_alloc, json_str, .{ .allocate = .alloc_always }) catch return 1;
    if (player == 1) {
        player_imports.append(parsed.value) catch |err| return errors.e_to_v(err);
    } else if (player == 0) {
        enemy_imports.append(parsed.value) catch |err| return errors.e_to_v(err);
    }
    for (player_imports.items) |player_import| {
        print("player: {s}\n", .{player_import.species});
    }
    for (enemy_imports.items) |enemy_import| {
        print("enemy: {s}\n", .{enemy_import.species});
    }
    print("\n\n", .{});
    return 0;
}

// export fn main() void {
//     const alloc = std.heap.wasm_allocator;
//     // const battle = tree.tools.init_battle(&.{
//     //     .{ .species = .Pikachu, .moves = &.{ .Thunderbolt, .ThunderWave, .Surf, .SeismicToss } },
//     //     .{ .species = .Bulbasaur, .moves = &.{ .SleepPowder, .SwordsDance, .RazorLeaf, .BodySlam } },
//     // }, &.{
//     //     .{ .species = .Pidgey, .moves = &.{.Pound} },
//     //     .{ .species = .Chansey, .moves = &.{ .Reflect, .SeismicToss, .SoftBoiled, .ThunderWave } },
//     //     .{ .species = .Snorlax, .moves = &.{ .BodySlam, .Reflect, .Rest, .IceBeam } },
//     //     .{ .species = .Exeggutor, .moves = &.{ .SleepPowder, .Psychic, .Explosion, .DoubleEdge } },
//     //     .{ .species = .Starmie, .moves = &.{ .Recover, .ThunderWave, .Blizzard, .Thunderbolt } },
//     //     .{ .species = .Alakazam, .moves = &.{ .Psychic, .SeismicToss, .ThunderWave, .Recover } },
//     // });
//     // const box_pokemon = [_]pkmn.gen1.helpers.Pokemon{
//     //     .{ .species = .Charmander, .moves = &.{ .FireBlast, .FireSpin, .Slash, .Counter } },
//     //     .{ .species = .Squirtle, .moves = &.{ .Surf, .Blizzard, .BodySlam, .Rest } },
//     //     .{ .species = .Rattata, .moves = &.{ .SuperFang, .BodySlam, .Blizzard, .Thunderbolt } },
//     //     .{ .species = .Pidgey, .moves = &.{ .DoubleEdge, .QuickAttack, .WingAttack, .MirrorMove } },
//     // };
//
//     const battle = tree.tools.init_battle(&.{
//         .{ .species = .Articuno, .moves = &.{ .IceBeam, .Growl, .Tackle, .Wrap } },
//     }, &.{
//         .{ .species = .Jynx, .moves = &.{ .AuroraBeam, .HyperBeam, .DrillPeck, .Peck } },
//         .{ .species = .Chansey, .moves = &.{ .Counter, .SeismicToss, .Strength, .Absorb } },
//         .{ .species = .Goldeen, .moves = &.{ .RazorLeaf, .SolarBeam, .PoisonPowder, .FireSpin } },
//     });
//
//     const box_pokemon = [_]pkmn.gen1.helpers.Pokemon{
//         .{ .species = .Kingler, .moves = &.{ .SandAttack, .Headbutt, .HornAttack, .TailWhip } },
//         .{ .species = .Rhyhorn, .moves = &.{ .RockThrow, .Mist, .WaterGun, .Psybeam } },
//     };
//
//     var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
//     var options = pkmn.battle.options(
//         pkmn.protocol.NULL,
//         &chance,
//         pkmn.gen1.Calc{},
//     );
//
//     var test_box = std.ArrayList(pkmn.gen1.Pokemon).init(alloc);
//     defer test_box.deinit();
//     for (box_pokemon) |mon| {
//         test_box.append(pkmn.gen1.helpers.Pokemon.init(mon)) catch unreachable;
//     }
//
//     var b = battle;
//     const result = b.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch unreachable;
//
//     const start_time = @as(u64, @bitCast(std.time.milliTimestamp()));
//     const root: *tree.DecisionNode = tree.optimal_decision_tree(b, result, box.items, false, alloc) catch unreachable;
//     const end_time = @as(u64, @bitCast(std.time.milliTimestamp()));
//
//     tree.tools.traverse_decision_tree(root, test_box.items, std.io.getStdOut().writer(), alloc) catch unreachable;
//
//     const num_of_nodes = tree.count_nodes(root);

//     std.debug.print("Num Of Nodes: {}\n", .{num_of_nodes});
//     tree.free_tree(root, alloc);
//
//     std.debug.print("Optimal1: {d} ms\n", .{end_time - start_time});
// }

// WASIWorkerHost requires _start export
// export fn _start() void {
//     const stdin = std.io.getStdIn().reader();
//     var buf: [128]u8 = undefined;
//
//     while (true) {
//         const length: usize = stdin.read(&buf) catch return;
//         _ = length;
//         print("{s}\n", .{buf});
//     }
// }
