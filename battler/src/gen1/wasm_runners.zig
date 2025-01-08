const std = @import("std");
const json = std.json;
const print = std.debug.print;

const String = @import("string").String;

const pkmn = @import("pkmn");
const tools = @import("tools.zig");
const player_ai = @import("player_ai.zig");
const enemy_ai = @import("enemy_ai.zig");
const import = @import("import.zig");

var import_arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);
var import_alloc: std.mem.Allocator = undefined;
var tree_gen_arena = std.heap.ArenaAllocator.init(std.heap.wasm_allocator);
var tree_gen_alloc: std.mem.Allocator = undefined;

const pkmn_options = pkmn.Options{ .internal = true };
var decision_tree_instance: ?*player_ai.DecisionNode = null;

export fn init() void {
    import_alloc = import_arena.allocator();
    player_ai.box = std.ArrayList(pkmn.gen1.Pokemon).init(std.heap.wasm_allocator);
    import.player_imports = std.ArrayList(import.PokemonImport).init(std.heap.wasm_allocator);
    import.enemy_imports = std.ArrayList(import.PokemonImport).init(std.heap.wasm_allocator);
}

export fn clear() void {
    import_arena.deinit();
    player_ai.box.clearAndFree();
    import.player_imports.clearAndFree();
    import.enemy_imports.clearAndFree();
    // while (player_ai.box.items.len > 0) {
    //     _ = player_ai.box.pop();
    // }
    // while (import.player_imports.items.len > 0) {
    //     _ = import.player_imports.pop();
    // }
    // while (import.enemy_imports.items.len > 0) {
    //     _ = import.enemy_imports.pop();
    // }
}

export fn generateOptimizedDecisionTree(lead: u8) ?*player_ai.DecisionNode {
    player_ai.free_tree(decision_tree_instance);
    player_ai.box.clearAndFree();
    tree_gen_arena.deinit();
    tree_gen_alloc = tree_gen_arena.allocator();
    // while (player_ai.box.items.len > 0) {
    //     _ = player_ai.box.pop();
    // }
    var lead_pokemon: pkmn.gen1.helpers.Pokemon = undefined;
    var enemy_helpers = std.ArrayList(pkmn.gen1.helpers.Pokemon).init(tree_gen_alloc); // Must enforce that enemy_imports is limited to 6 on frontend

    var b: u8 = 0;
    for (import.player_imports.items, 0..) |player_import, i| {
        var move_enums = std.ArrayList(pkmn.gen1.Move).init(tree_gen_alloc);
        for (player_import.moves) |move| {
            if (import.convert_move(move)) |valid_move| {
                move_enums.append(valid_move) catch continue;
            }
        }
        if (import.convert_species(player_import.species)) |valid_species| {
            const new_pokemon: pkmn.gen1.helpers.Pokemon = .{ .species = valid_species, .moves = move_enums.items, .dvs = pkmn.gen1.DVs{
                .atk = @intCast(player_import.dvs.atk),
                .def = @intCast(player_import.dvs.def),
                .spc = @intCast(player_import.dvs.spc),
                .spe = @intCast(player_import.dvs.spe),
            } };
            if (i == lead) {
                lead_pokemon = new_pokemon;
            }
            player_ai.box.append(pkmn.gen1.helpers.Pokemon.init(new_pokemon)) catch continue;
            b += 1;
        }
    }

    for (import.enemy_imports.items) |enemy_import| {
        // print("Enemy Import: {}\n", .{enemy_import});
        var move_enums = std.ArrayList(pkmn.gen1.Move).init(tree_gen_alloc);
        for (enemy_import.moves) |move| {
            if (import.convert_move(move)) |valid_move| {
                move_enums.append(valid_move) catch continue;
            }
        }
        if (import.convert_species(enemy_import.species)) |valid_species| {
            enemy_helpers.append(.{ .species = valid_species, .moves = move_enums.items, .dvs = pkmn.gen1.DVs{
                .atk = @intCast(enemy_import.dvs.atk),
                .def = @intCast(enemy_import.dvs.def),
                .spc = @intCast(enemy_import.dvs.spc),
                .spe = @intCast(enemy_import.dvs.spe),
            } }) catch continue;
        }
    }

    var prng = std.rand.DefaultPrng.init(1234);
    var battle = pkmn.gen1.helpers.Battle.init(prng.random().int(u64), &.{lead_pokemon}, enemy_helpers.items);

    var options = pkmn.battle.options(
        pkmn.protocol.NULL,
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    // Need an empty result and switch ins for generating tree
    const result = battle.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch pkmn.Result{};

    decision_tree_instance = player_ai.optimal_decision_tree(battle, result);

    // const starting_team = [_]i8{ 0, -1, -1, -1, -1, -1 };
    // decision_tree_instance = player_ai.exhaustive_decision_tree(null, null, battle, starting_team, result, 0);
    return decision_tree_instance;
}

export fn getNextNode(curr_node: ?*player_ai.DecisionNode, index: usize) ?*player_ai.DecisionNode {
    return curr_node.?.*.next_turns.items[index].turn orelse null;
}

export fn getNumOfNextTurns(curr_node: ?*player_ai.DecisionNode) usize {
    return if (curr_node) |valid_curr_node| valid_curr_node.*.next_turns.items.len else 0;
}

export fn getTransitionChoice(curr_node: ?*player_ai.DecisionNode, index: usize, player: bool, out: [*]u8) usize {
    const valid_curr_node = if (curr_node) |valid_curr_node| valid_curr_node else return 0;
    const turn_choice: player_ai.TurnChoices = valid_curr_node.next_turns.items[index];
    const choice: pkmn.Choice = turn_choice.choices[if (player) 0 else 1];
    const side = if (player) tools.PLAYER_PID else tools.ENEMY_PID;
    var details: []const u8 = undefined;

    if (player) {
        if (choice.type == pkmn.Choice.Type.Move) {
            details = std.fmt.allocPrint(tree_gen_alloc, "P_Move: {s}", .{@tagName(valid_curr_node.battle.side(side).stored().move(choice.data).id)}) catch "";
        } else if (choice.type == pkmn.Choice.Type.Switch and choice.data != 42) {
            if (turn_choice.box_switch) |valid_box_switch| {
                details = std.fmt.allocPrint(tree_gen_alloc, "P_Switch: {s}", .{@tagName(valid_box_switch.added_pokemon.species)}) catch "";
            } else {
                details = std.fmt.allocPrint(tree_gen_alloc, "P_Switch: {s}", .{@tagName(valid_curr_node.battle.side(side).get(choice.data).species)}) catch "";
            }
        } else if (choice.type == pkmn.Choice.Type.Pass) {
            details = std.fmt.allocPrint(tree_gen_alloc, "Pass", .{}) catch "";
        }
    } else {
        if (choice.type == pkmn.Choice.Type.Move) {
            details = std.fmt.allocPrint(tree_gen_alloc, "E_Move: {s}", .{@tagName(valid_curr_node.battle.side(side).stored().move(choice.data).id)}) catch "";
        } else if (choice.type == pkmn.Choice.Type.Switch and choice.data != 42) {
            if (turn_choice.box_switch) |valid_box_switch| {
                details = std.fmt.allocPrint(tree_gen_alloc, "E_Switch: {s}", .{@tagName(valid_box_switch.added_pokemon.species)}) catch "";
            } else {
                details = std.fmt.allocPrint(tree_gen_alloc, "E_Switch: {s}", .{@tagName(valid_curr_node.battle.side(side).get(choice.data).species)}) catch "";
            }
        } else if (choice.type == pkmn.Choice.Type.Pass) {
            details = std.fmt.allocPrint(tree_gen_alloc, "Pass", .{}) catch "";
        }
    }

    @memcpy(out, details);
    return details.len;
}

export fn getSpecies(curr_node: ?*player_ai.DecisionNode, player: bool, out: [*]u8) usize {
    const side = if (player) tools.PLAYER_PID else tools.ENEMY_PID;
    const species_str: []const u8 = if (curr_node) |valid_curr_node| @tagName(valid_curr_node.battle.side(side).stored().species) else "";
    @memcpy(out, species_str);
    return species_str.len;
}

export fn getHP(curr_node: ?*player_ai.DecisionNode, player: bool) usize {
    const side = if (player) tools.PLAYER_PID else tools.ENEMY_PID;
    return if (curr_node) |valid_curr_node| valid_curr_node.*.battle.side(side).stored().hp else 0;
}

export fn importPokemon(json_import: [*]u8, size: usize, player: u8) void {
    const json_str = json_import[0..size];
    const parsed = json.parseFromSlice(import.PokemonImport, import_alloc, json_str, .{ .allocate = .alloc_always }) catch null;
    if (parsed) |valid_parsed| {
        if (player == 1) {
            import.player_imports.append(valid_parsed.value) catch return void{};
        } else {
            import.enemy_imports.append(valid_parsed.value) catch return void{};
        }
    }
}

pub fn main() void {}
