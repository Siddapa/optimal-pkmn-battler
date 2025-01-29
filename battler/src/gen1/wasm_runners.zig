const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var import_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var tree_prep_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const json = std.json;
const print = std.debug.print;

const String = @import("string").String;

const pkmn = @import("pkmn");
const tools = @import("tools.zig");
const player_ai = @import("player_ai.zig");
const enemy_ai = @import("enemy_ai.zig");
const import = @import("import.zig");

var tree_gen_alloc = gpa.allocator();
var import_alloc: std.mem.Allocator = undefined;
var tree_prep_alloc: std.mem.Allocator = undefined;

var decision_tree_instance: ?*player_ai.DecisionNode = null;
pub const pkmn_options = pkmn.Options{ .internal = true };

export fn init() void {
    import_alloc = import_arena.allocator();
    player_ai.box = std.ArrayList(pkmn.gen1.Pokemon).init(std.heap.page_allocator);
    import.player_imports = std.ArrayList(import.PokemonImport).init(std.heap.page_allocator);
    import.enemy_imports = std.ArrayList(import.PokemonImport).init(std.heap.page_allocator);
}

export fn clear() void {
    import_arena.deinit();
    player_ai.box.clearAndFree();
    import.player_imports.clearAndFree();
    import.enemy_imports.clearAndFree();
}

export fn generateOptimizedDecisionTree(lead: u8) ?*player_ai.DecisionNode {
    if (decision_tree_instance) |foo| player_ai.free_tree(foo, tree_gen_alloc);
    player_ai.box.clearAndFree();
    tree_prep_arena.deinit();
    tree_prep_alloc = tree_prep_arena.allocator();

    var lead_pokemon: pkmn.gen1.helpers.Pokemon = undefined;
    var enemy_helpers = std.ArrayList(pkmn.gen1.helpers.Pokemon).init(tree_prep_alloc); // Must enforce that enemy_imports is limited to 6 on frontend

    for (import.player_imports.items, 0..) |player_import, i| {
        var move_enums = std.ArrayList(pkmn.gen1.Move).init(tree_prep_alloc);

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
            player_ai.box.append(pkmn.gen1.helpers.Pokemon.init(new_pokemon)) catch continue;
        }
    }

    for (import.enemy_imports.items) |enemy_import| {
        var move_enums = std.ArrayList(pkmn.gen1.Move).init(tree_prep_alloc);

        for (enemy_import.moves) |move| {
            if (import.convert_move(move)) |valid_move| {
                move_enums.append(valid_move) catch continue;
            }
        }

        if (import.convert_species(enemy_import.species)) |valid_species| {
            enemy_helpers.append(.{ .species = valid_species, .moves = move_enums.toOwnedSlice() catch continue, .dvs = pkmn.gen1.DVs{
                .atk = @intCast(enemy_import.dvs.atk),
                .def = @intCast(enemy_import.dvs.def),
                .spc = @intCast(enemy_import.dvs.spc),
                .spe = @intCast(enemy_import.dvs.spe),
            } }) catch continue;
        }
    }

    var prng = std.rand.DefaultPrng.init(1234);
    var battle = pkmn.gen1.helpers.Battle.init(prng.random().int(u64), &.{lead_pokemon}, enemy_helpers.toOwnedSlice() catch return null);

    var options = pkmn.battle.options(
        pkmn.protocol.NULL,
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    // Need an empty result and switch ins for generating tree
    const result = battle.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch pkmn.Result{};

    // const starting_team = [_]i8{ 0, -1, -1, -1, -1, -1 };
    // decision_tree_instance = player_ai.exhaustive_decision_tree(null, null, battle, starting_team, result, 0) catch null;
    // return decision_tree_instance;

    if (player_ai.optimal_decision_tree(battle, result, tree_gen_alloc)) |decision_tree| {
        decision_tree_instance = decision_tree;
        return decision_tree_instance;
    } else |err| {
        print("Failed to Build Graph: {}\n", .{err});
        return null;
    }
}

export fn getNextNode(curr_node: *player_ai.DecisionNode, index: usize) *player_ai.DecisionNode {
    return curr_node.next_turns.items[index].next_node;
}

export fn getNumOfNextTurns(curr_node: *player_ai.DecisionNode) usize {
    return curr_node.next_turns.items.len;
}

export fn getResult(curr_node: *player_ai.DecisionNode) i8 {
    return if (curr_node.result.type == .None) 1 else 0;
}

export fn getTeam(curr_node: *player_ai.DecisionNode, out: [*]i8) u8 {
    for (0..6) |i| {
        out[i] = curr_node.team[i];
    }
    return 6;
}

export fn getTransitionChoice(curr_node: *player_ai.DecisionNode, index: usize, player: bool, out: [*]u8) usize {
    const turn_choice: player_ai.TurnChoices = curr_node.next_turns.items[index];
    const choice: pkmn.Choice = turn_choice.choices[if (player) 0 else 1];
    const side = if (player) tools.PLAYER_PID else tools.ENEMY_PID;
    var details: []const u8 = undefined;

    if (player) {
        if (choice.type == pkmn.Choice.Type.Move) {
            if (choice.data == 0) {
                details = std.fmt.allocPrint(tree_prep_alloc, "Stalled", .{}) catch "";
            } else {
                details = std.fmt.allocPrint(tree_prep_alloc, "P_Move: {s}", .{@tagName(curr_node.battle.side(side).stored().move(choice.data).id)}) catch "";
            }
        } else if (choice.type == pkmn.Choice.Type.Switch and choice.data != 42) {
            if (turn_choice.box_switch) |box_switch| {
                details = std.fmt.allocPrint(tree_prep_alloc, "P_BoxSwitch: {s}", .{@tagName(box_switch.added_pokemon.species)}) catch "";
            } else {
                details = std.fmt.allocPrint(tree_prep_alloc, "P_Switch: {s}", .{@tagName(curr_node.battle.side(side).get(choice.data).species)}) catch "";
            }
        } else {
            details = std.fmt.allocPrint(tree_prep_alloc, "Pass", .{}) catch "";
        }
    } else {
        if (choice.type == pkmn.Choice.Type.Move) {
            if (choice.data == 0) {
                details = std.fmt.allocPrint(tree_prep_alloc, "Stalled", .{}) catch "";
            } else {
                details = std.fmt.allocPrint(tree_prep_alloc, "E_Move: {s}", .{@tagName(curr_node.battle.side(side).stored().move(choice.data).id)}) catch "";
            }
        } else if (choice.type == pkmn.Choice.Type.Switch and choice.data != 42) {
            if (turn_choice.box_switch) |box_switch| {
                details = std.fmt.allocPrint(tree_prep_alloc, "E_BoxSwitch: {s}", .{@tagName(box_switch.added_pokemon.species)}) catch "";
            } else {
                details = std.fmt.allocPrint(tree_prep_alloc, "E_Switch: {s}", .{@tagName(curr_node.battle.side(side).get(choice.data).species)}) catch "";
            }
        } else {
            details = std.fmt.allocPrint(tree_prep_alloc, "Pass", .{}) catch "";
        }
    }

    @memcpy(out, details);
    return details.len;
}

export fn getSpecies(curr_node: *player_ai.DecisionNode, player: bool, out: [*]u8) usize {
    const side = if (player) tools.PLAYER_PID else tools.ENEMY_PID;
    const species_str: []const u8 = @tagName(curr_node.battle.side(side).stored().species);
    @memcpy(out, species_str);
    return species_str.len;
}

export fn getHP(curr_node: *player_ai.DecisionNode, player: bool) usize {
    const side = if (player) tools.PLAYER_PID else tools.ENEMY_PID;
    return curr_node.battle.side(side).stored().hp;
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

pub fn main() !void {
    // try tools.random_vs_enemy_ai();
    // const decision_tree = try tools.sample_optimized_decision_tree2();
    // print("Root Count: {}\n", .{player_ai.count_nodes(decision_tree)});
    // try tools.traverse_decision_tree(root);
    // init();
    // const player_imports = [3]import.PokemonImport{ .{ .species = "Articuno", .evs = .{}, .dvs = .{}, .moves = .{ "Ice Beam", "Growl", "Tackle", "Wrap" } }, .{ .species = "Kingler", .moves = &.{ "Sand Attack", "Headbutt", "Horn Attack", "Tail Whip" } }, .{ .species = "Rhyhorn", .moves = &.{ "Flamethrower", "Mist", "Water Gun", "Psybeam" } } };
    // const enemy_imports = [3]import.PokemonImport{ .{ .species = "Jynx", .moves = &.{ "Aurora Beam", "Hyper Beam", "Drill Peck", "Peck" } }, .{ .species = "Chansey", .moves = &.{ "Counter", "Seismic Toss", "Strength", "Absorb" } }, .{ .species = "Goldeen", .moves = &.{ "Razor Leaf", "Solarbeam", "Poison Powder", "Fire Spin" } } };

    // for (player_imports) |pokemon| {
    //     try import.player_imports.append(pokemon);
    // }
    // for (enemy_imports) |pokemon| {
    //     try import.enemy_imports.append(pokemon);
    // }
}
