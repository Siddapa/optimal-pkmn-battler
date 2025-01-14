const std = @import("std");
const json = std.json;
const print = std.debug.print;

const String = @import("string").String;

const pkmn = @import("pkmn");
const tools = @import("tools.zig");
const player_ai = @import("player_ai.zig");
const enemy_ai = @import("enemy_ai.zig");
const import = @import("import.zig");

var import_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var import_alloc: std.mem.Allocator = undefined;
var tree_gen_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var tree_gen_alloc: std.mem.Allocator = undefined;

const pkmn_options = pkmn.Options{ .internal = true };
var decision_tree_instance: ?*player_ai.DecisionNode = null;

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
    player_ai.free_tree(decision_tree_instance);
    player_ai.box.clearAndFree();
    tree_gen_arena.deinit();
    tree_gen_alloc = tree_gen_arena.allocator();

    var lead_pokemon: pkmn.gen1.helpers.Pokemon = undefined;
    var enemy_helpers = std.ArrayList(pkmn.gen1.helpers.Pokemon).init(tree_gen_alloc); // Must enforce that enemy_imports is limited to 6 on frontend

    for (import.player_imports.items, 0..) |player_import, i| {
        var move_enums = std.ArrayList(pkmn.gen1.Move).init(tree_gen_alloc);

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
        var move_enums = std.ArrayList(pkmn.gen1.Move).init(tree_gen_alloc);

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

    decision_tree_instance = player_ai.optimal_decision_tree(battle, result);

    // const starting_team = [_]i8{ 0, -1, -1, -1, -1, -1 };
    // decision_tree_instance = player_ai.exhaustive_decision_tree(null, null, battle, starting_team, result, 0);
    return decision_tree_instance;
}

export fn getNextNode(optional_curr_node: ?*player_ai.DecisionNode, index: usize) ?*player_ai.DecisionNode {
    const curr_node = optional_curr_node orelse return null;
    return curr_node.next_turns.items[index].next_node orelse null;
}

export fn getNumOfNextTurns(optional_curr_node: ?*player_ai.DecisionNode) usize {
    const curr_node = optional_curr_node orelse return 0;
    return curr_node.next_turns.items.len;
}

export fn getResult(optional_curr_node: ?*player_ai.DecisionNode) i8 {
    const curr_node = optional_curr_node orelse return -1;
    return if (curr_node.result.type == .None) 1 else 0;
}

export fn getTeam(optional_curr_node: ?*player_ai.DecisionNode, out: [*]i8) u8 {
    const curr_node = optional_curr_node orelse return 0;
    for (0..6) |i| {
        out[i] = curr_node.team[i];
    }
    return 6;
}

export fn getTransitionChoice(optional_curr_node: ?*player_ai.DecisionNode, index: usize, player: bool, out: [*]u8) usize {
    const curr_node = optional_curr_node orelse return 0;
    const turn_choice: player_ai.TurnChoices = curr_node.next_turns.items[index];
    const choice: pkmn.Choice = turn_choice.choices[if (player) 0 else 1];
    const side = if (player) tools.PLAYER_PID else tools.ENEMY_PID;
    var details: []const u8 = undefined;

    if (player) {
        if (choice.type == pkmn.Choice.Type.Move) {
            if (choice.data == 0) {
                details = std.fmt.allocPrint(tree_gen_alloc, "Stalled", .{}) catch "";
            } else {
                details = std.fmt.allocPrint(tree_gen_alloc, "P_Move: {s}", .{@tagName(curr_node.battle.side(side).stored().move(choice.data).id)}) catch "";
            }
        } else if (choice.type == pkmn.Choice.Type.Switch and choice.data != 42) {
            if (turn_choice.box_switch) |box_switch| {
                details = std.fmt.allocPrint(tree_gen_alloc, "P_BoxSwitch: {s}", .{@tagName(box_switch.added_pokemon.species)}) catch "";
            } else {
                details = std.fmt.allocPrint(tree_gen_alloc, "P_Switch: {s}", .{@tagName(curr_node.battle.side(side).get(choice.data).species)}) catch "";
            }
        } else {
            details = std.fmt.allocPrint(tree_gen_alloc, "Pass", .{}) catch "";
        }
    } else {
        if (choice.type == pkmn.Choice.Type.Move) {
            if (choice.data == 0) {
                details = std.fmt.allocPrint(tree_gen_alloc, "Stalled", .{}) catch "";
            } else {
                details = std.fmt.allocPrint(tree_gen_alloc, "E_Move: {s}", .{@tagName(curr_node.battle.side(side).stored().move(choice.data).id)}) catch "";
            }
        } else if (choice.type == pkmn.Choice.Type.Switch and choice.data != 42) {
            if (turn_choice.box_switch) |box_switch| {
                details = std.fmt.allocPrint(tree_gen_alloc, "E_BoxSwitch: {s}", .{@tagName(box_switch.added_pokemon.species)}) catch "";
            } else {
                details = std.fmt.allocPrint(tree_gen_alloc, "E_Switch: {s}", .{@tagName(curr_node.battle.side(side).get(choice.data).species)}) catch "";
            }
        } else {
            details = std.fmt.allocPrint(tree_gen_alloc, "Pass", .{}) catch "";
        }
    }

    @memcpy(out, details);
    return details.len;
}

export fn getSpecies(optional_curr_node: ?*player_ai.DecisionNode, player: bool, out: [*]u8) usize {
    const side = if (player) tools.PLAYER_PID else tools.ENEMY_PID;
    const species_str: []const u8 = if (optional_curr_node) |curr_node| @tagName(curr_node.battle.side(side).stored().species) else "";
    @memcpy(out, species_str);
    return species_str.len;
}

export fn getHP(optional_curr_node: ?*player_ai.DecisionNode, player: bool) usize {
    const curr_node = optional_curr_node orelse return 0;
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

pub fn main() void {
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
