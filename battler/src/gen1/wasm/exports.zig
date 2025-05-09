const std = @import("std");
const print = std.debug.print;
const json = std.json;
var da: std.heap.DebugAllocator(.{}) = .init;
var import_arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);
var tree_prep_arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);

const builder = @import("builder");
const tools = builder.tools;

const pkmn = @import("pkmn");

const import = @import("import.zig");
const errors = @import("errors.zig");
const memory = @import("memory.zig");
const WASMArg = memory.WASMArg;

var tree_gen_alloc = std.heap.wasm_allocator;
var import_alloc: std.mem.Allocator = undefined;
var tree_prep_alloc: std.mem.Allocator = undefined;

var decision_tree_instance: ?*builder.DecisionNode = null;
var box: std.ArrayList(pkmn.gen1.Pokemon) = undefined;
var player_imports: std.ArrayList(import.PokemonImport) = undefined;
var enemy_imports: std.ArrayList(import.PokemonImport) = undefined;

const seed: usize = 1234;

comptime {
    // WASI should have 32bit (4 byte) pointers
    std.debug.assert(@sizeOf(usize) == 4);
}

export fn test_memory() errors.error_t {
    var arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();

    var args: [5]WASMArg = undefined;
    memory.load(&args, &.{
        .Int32,
        .Uint32,
        .string,
        .Int32Array,
        .Uint32Array,
    }, alloc) catch |err| return errors.to_value(err);

    for (args) |arg| {
        switch (arg) {
            .Int32 => |*int| print("{}\n", .{int.*}),
            .Uint32 => |*int| print("{}\n", .{int.*}),
            .string => |*str| print("{s}\n", .{str.*}),
            .Int32Array => |*arr| print("{any}\n", .{arr.*}),
            .Uint32Array => |*arr| print("{any}\n", .{arr.*}),
            .Tree => {},
        }
    }

    const ret_vals: [5]WASMArg = .{
        WASMArg{ .Int32 = -2 },
        WASMArg{ .Uint32 = 2 },
        WASMArg{ .string = "returning" },
        WASMArg{ .Int32Array = &.{ -2, -4, -6 } },
        WASMArg{ .Uint32Array = &.{ 2, 4, 6 } },
    };
    memory.store(&ret_vals) catch |err| return errors.to_value(err);

    // for (ret_vals) |val| {
    //     switch (val) {
    //         .Int32 => |*int| print("{}\n", .{int.*}),
    //         .Uint32 => |*int| print("{}\n", .{int.*}),
    //         .string => |*str| print("{s}\n", .{str.*}),
    //         .Int32Array => |*arr| print("{any}\n", .{arr.*}),
    //         .Uint32Array => |*arr| print("{any}\n", .{arr.*}),
    //         .Tree => {},
    //     }
    // }

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

export fn generateOptimizedDecisionTree() errors.error_t {
    var arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();

    var args: [1]WASMArg = undefined;
    memory.load(&args, &.{.Uint32}, alloc) catch |err| return errors.to_value(err);
    const lead: u8 = @intCast(args[0].Uint32);

    if (decision_tree_instance) |foo| builder.free_tree(foo, tree_gen_alloc);
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
                    all_moves.append(move) catch |err| return errors.to_value(err);
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
                })) catch |err| return errors.to_value(err);
            }
        }
    }

    for (enemy_imports.items) |enemy_import| {
        if (import.convert_species(enemy_import.species)) |valid_species| {
            const move_start_index: usize = move_end_index;
            for (enemy_import.moves) |move_str| {
                if (import.convert_move(move_str)) |move| {
                    all_moves.append(move) catch |err| return errors.to_value(err);
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
            }) catch |err| return errors.to_value(err);
        }
    }

    if (enemy_imports.items.len > 6) {
        return errors.to_value(errors.Errors.TooManyEnemies);
    }

    var prng = std.Random.DefaultPrng.init(seed);
    var battle = pkmn.gen1.helpers.Battle.init(prng.random().int(u64), &.{lead_pokemon}, enemy_team.toOwnedSlice() catch |err| return errors.to_value(err));

    var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
    var calc = pkmn.gen1.Calc{};
    const options = pkmn.battle.options(
        pkmn.protocol.NULL,
        &chance,
        &calc,
    );

    const result = battle.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch |err| return errors.to_value(err);

    const imm_box: []const pkmn.gen1.Pokemon = box.items;

    decision_tree_instance = builder.optimal_decision_tree(battle, result, imm_box, true, tree_gen_alloc) catch |err| return errors.to_value(err);

    const ret_vals = [_]WASMArg{WASMArg{
        .Uint32 = @intFromPtr(decision_tree_instance),
    }};
    memory.store(&ret_vals) catch |err| return errors.to_value(err);

    return 0;
}

export fn getTreeData() errors.error_t {
    var arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();

    var args: [1]WASMArg = undefined;
    _ = memory.load(&args, &.{.Uint32}, alloc) catch |err| return errors.to_value(err);
    const curr_node: *builder.DecisionNode = @ptrFromInt(args[0].Uint32);

    const ret_vals = [_]WASMArg{
        WASMArg{ .Tree = .{
            .root = curr_node,
            .data_gen = fetch_tree_data,
        } },
    };
    memory.store(&ret_vals) catch |err| return errors.to_value(err);
    return 0;
}

fn fetch_tree_data(node: *const builder.DecisionNode, alloc: std.mem.Allocator) ![]WASMArg {
    var ret_vals = std.ArrayList(memory.WASMArg).init(alloc);
    // Score
    try ret_vals.append(WASMArg{ .Int32 = node.score });
    // Result
    try ret_vals.append(WASMArg{ .string = @tagName(node.result.type) });
    // Player Lead Name
    try ret_vals.append(WASMArg{ .string = @tagName(node.battle.side(.P1).stored().species) });
    // Player Lead HP
    try ret_vals.append(WASMArg{ .Uint32 = node.battle.side(.P1).stored().hp });
    // Player Choice
    try ret_vals.append(WASMArg{ .string = tools.fetch_choice(node, 0) });
    // Enemy Lead Name
    try ret_vals.append(WASMArg{ .string = @tagName(node.battle.side(.P2).stored().species) });
    // Enemy Lead HP
    try ret_vals.append(WASMArg{ .Uint32 = node.battle.side(.P2).stored().hp });
    // Enemy Choice
    try ret_vals.append(WASMArg{ .string = tools.fetch_choice(node, 1) });
    return ret_vals.toOwnedSlice();
}

// Player Encoding:
// 1 = Player
// 0 = Enemy
export fn importPokemon() errors.error_t {
    var args: [2]WASMArg = undefined;
    memory.load(&args, &.{ .string, .Uint32 }, import_alloc) catch |err| return errors.to_value(err);
    const json_str = args[0].string;
    const player = args[1].Uint32;

    const parsed = json.parseFromSlice(
        import.PokemonImport,
        import_alloc,
        json_str,
        .{ .allocate = .alloc_always },
    ) catch |err| return errors.to_value(err);
    if (player == 1) {
        player_imports.append(parsed.value) catch |err| return errors.to_value(err);
    } else if (player == 0) {
        enemy_imports.append(parsed.value) catch |err| return errors.to_value(err);
    }
    return 0;
}
