const std = @import("std");
const print = std.debug.print;
const json = std.json;
var da: std.heap.DebugAllocator(.{}) = .init;
var import_arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);
var tree_prep_arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);

const tree = @import("tree");
const pkmn = @import("pkmn");
const import = @import("import.zig");

var tree_gen_alloc = std.heap.wasm_allocator;
var import_alloc: std.mem.Allocator = undefined;
var tree_prep_alloc: std.mem.Allocator = undefined;

var decision_tree_instance: ?*tree.DecisionNode = null;
var box: std.ArrayList(pkmn.gen1.Pokemon) = undefined;
var player_imports: std.ArrayList(import.PokemonImport) = undefined;
var enemy_imports: std.ArrayList(import.PokemonImport) = undefined;

pub const pkmn_options = pkmn.Options{ .internal = true };

export fn test_int() usize {
    return @as(usize, 11239);
}

export fn init() void {
    import_alloc = import_arena.allocator();
    box = std.ArrayList(pkmn.gen1.Pokemon).init(std.heap.wasm_allocator);
    player_imports = std.ArrayList(import.PokemonImport).init(std.heap.wasm_allocator);
    enemy_imports = std.ArrayList(import.PokemonImport).init(std.heap.wasm_allocator);
}

export fn clear() void {
    _ = import_arena.reset(.free_all);
    box.clearAndFree();
    player_imports.clearAndFree();
    enemy_imports.clearAndFree();
}

export fn generateOptimizedDecisionTree(lead: u8) ?*tree.DecisionNode {
    if (decision_tree_instance) |foo| tree.free_tree(foo, tree_gen_alloc);
    box.clearAndFree();
    _ = tree_prep_arena.reset(.free_all);
    tree_prep_alloc = tree_prep_arena.allocator();

    var lead_pokemon: pkmn.gen1.helpers.Pokemon = undefined;
    var enemy_team = std.ArrayList(pkmn.gen1.helpers.Pokemon).init(tree_prep_alloc);

    for (player_imports.items, 0..) |player_import, i| {
        var move_enums = std.ArrayList(pkmn.gen1.Move).init(tree_prep_alloc);
        defer move_enums.deinit();

        for (player_import.moves) |move| {
            if (import.convert_move(move)) |valid_move| {
                move_enums.append(valid_move) catch continue;
            }
        }
        if (import.convert_species(player_import.species)) |valid_species| {
            const new_pokemon: pkmn.gen1.helpers.Pokemon = .{ .species = valid_species, .moves = move_enums.toOwnedSlice() catch continue, .dvs = pkmn.gen1.DVs{
                .atk = @intCast(player_import.dvs.atk),
                .def = @intCast(player_import.dvs.def),
                .spc = @intCast(player_import.dvs.spc),
                .spe = @intCast(player_import.dvs.spe),
            } };
            if (i == lead) {
                lead_pokemon = new_pokemon;
            }
            box.append(pkmn.gen1.helpers.Pokemon.init(new_pokemon)) catch continue;
        }
    }

    for (enemy_imports.items) |enemy_import| {
        var move_enums = std.ArrayList(pkmn.gen1.Move).init(tree_prep_alloc);
        defer move_enums.deinit();

        for (enemy_import.moves) |move| {
            if (import.convert_move(move)) |valid_move| {
                move_enums.append(valid_move) catch continue;
            }
        }

        if (import.convert_species(enemy_import.species)) |valid_species| {
            enemy_team.append(.{ .species = valid_species, .moves = move_enums.toOwnedSlice() catch continue, .dvs = pkmn.gen1.DVs{
                .atk = @intCast(enemy_import.dvs.atk),
                .def = @intCast(enemy_import.dvs.def),
                .spc = @intCast(enemy_import.dvs.spc),
                .spe = @intCast(enemy_import.dvs.spe),
            } }) catch continue;
        }
    }

    if (enemy_imports.items.len > 6) {
        return null;
    }

    var prng = std.Random.DefaultPrng.init(1234);
    var battle = pkmn.gen1.helpers.Battle.init(prng.random().int(u64), &.{lead_pokemon}, enemy_team.toOwnedSlice() catch return null);

    var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
    var calc = pkmn.gen1.Calc{};
    const options = pkmn.battle.options(
        pkmn.protocol.NULL,
        &chance,
        &calc,
    );

    // Need an empty result and switch ins for generating tree
    const result = battle.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch return null;

    // const root: *tree.DecisionNode = tree_gen_alloc.create(tree.DecisionNode) catch return null;
    // root.* = .{
    //     .battle = battle,
    //     .team = .{ 0, -1, -1, -1, -1, -1 },
    //     .result = result,
    //     .previous_node = null,
    //     .transitions = std.ArrayList(tree.Transition).init(tree_gen_alloc),
    // };
    // tree.exhaustive_decision_tree(root, 1, tree_gen_alloc) catch return null;
    // return root;

    const imm_box: []const pkmn.gen1.Pokemon = box.items;
    if (tree.optimal_decision_tree(battle, result, imm_box, true, tree_gen_alloc)) |decision_tree| {
        decision_tree_instance = decision_tree;
        return decision_tree_instance;
    } else |err| {
        print("Failed to Build Graph: {}\n", .{err});
        return null;
    }
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

export fn getTeam(curr_node: *tree.DecisionNode, out: [*]i32) u8 {
    for (0..6) |i| {
        switch (curr_node.team[i]) {
            .Empty => out[i] = -1,
            .Lead => out[i] = -2,
            .Filled => |box_id| out[i] = @bitCast(box_id),
        }
    }
    return 6;
}

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

export fn getSpecies(curr_node: *tree.DecisionNode, player: bool, out: [*]u8) usize {
    const side: pkmn.Player = if (player) .P1 else .P2;
    const species_str: []const u8 = @tagName(curr_node.battle.side(side).stored().species);
    @memcpy(out, species_str);
    return species_str.len;
}

export fn getHP(curr_node: *tree.DecisionNode, player: bool) usize {
    const side: pkmn.Player = if (player) .P1 else .P2;
    return curr_node.battle.side(side).stored().hp;
}

export fn importPokemon(json_import: [*]u8, size: usize, player: u8) void {
    const json_str = json_import[0..size];
    const optional_parsed = json.parseFromSlice(import.PokemonImport, import_alloc, json_str, .{ .allocate = .alloc_always }) catch null;
    if (optional_parsed) |parsed| {
        if (player == 1) {
            player_imports.append(parsed.value) catch return void{};
        } else {
            enemy_imports.append(parsed.value) catch return void{};
        }
    }
}

export fn main() void {
    const alloc = std.heap.wasm_allocator;
    const battle = tree.tools.init_battle(&.{
        .{ .species = .Pikachu, .moves = &.{ .Thunderbolt, .ThunderWave, .Surf, .SeismicToss } },
        .{ .species = .Bulbasaur, .moves = &.{ .SleepPowder, .SwordsDance, .RazorLeaf, .BodySlam } },
    }, &.{
        .{ .species = .Pidgey, .moves = &.{.Pound} },
        .{ .species = .Chansey, .moves = &.{ .Reflect, .SeismicToss, .SoftBoiled, .ThunderWave } },
        .{ .species = .Snorlax, .moves = &.{ .BodySlam, .Reflect, .Rest, .IceBeam } },
        .{ .species = .Exeggutor, .moves = &.{ .SleepPowder, .Psychic, .Explosion, .DoubleEdge } },
        .{ .species = .Starmie, .moves = &.{ .Recover, .ThunderWave, .Blizzard, .Thunderbolt } },
        .{ .species = .Alakazam, .moves = &.{ .Psychic, .SeismicToss, .ThunderWave, .Recover } },
    });
    const box_pokemon = [_]pkmn.gen1.helpers.Pokemon{
        .{ .species = .Charmander, .moves = &.{ .FireBlast, .FireSpin, .Slash, .Counter } },
        .{ .species = .Squirtle, .moves = &.{ .Surf, .Blizzard, .BodySlam, .Rest } },
        .{ .species = .Rattata, .moves = &.{ .SuperFang, .BodySlam, .Blizzard, .Thunderbolt } },
        .{ .species = .Pidgey, .moves = &.{ .DoubleEdge, .QuickAttack, .WingAttack, .MirrorMove } },
    };
    var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
    var options = pkmn.battle.options(
        pkmn.protocol.NULL,
        &chance,
        pkmn.gen1.Calc{},
    );

    var test_box = std.ArrayList(pkmn.gen1.Pokemon).init(alloc);
    defer test_box.deinit();
    for (box_pokemon) |mon| {
        test_box.append(pkmn.gen1.helpers.Pokemon.init(mon)) catch unreachable;
    }

    var b = battle;
    const result = b.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch unreachable;

    const start_time = @as(u64, @bitCast(std.time.milliTimestamp()));
    const root: *tree.DecisionNode = tree.optimal_decision_tree(b, result, box.items, false, alloc) catch unreachable;
    const end_time = @as(u64, @bitCast(std.time.milliTimestamp()));

    const num_of_nodes = tree.count_nodes(root);
    std.debug.print("Num Of Nodes: {}\n", .{num_of_nodes});
    tree.free_tree(root, alloc);

    std.debug.print("Optimal1: {d} ms\n", .{end_time - start_time});
}

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
