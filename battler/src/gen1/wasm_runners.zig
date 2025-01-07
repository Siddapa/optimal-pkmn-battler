const std = @import("std");
const json = std.json;
const print = std.debug.print;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = std.heap.wasm_allocator;

const pkmn = @import("pkmn");
const tools = @import("tools.zig");
const player_ai = @import("player_ai.zig");
const enemy_ai = @import("enemy_ai.zig");
const import = @import("import.zig");

const pkmn_options = pkmn.Options{ .internal = true };
var decision_tree_instance: ?*player_ai.DecisionNode = undefined;
var player_imports: std.ArrayList(import.PokemonImport) = undefined;
var enemy_imports: std.ArrayList(import.PokemonImport) = undefined;

export fn init() void {
    player_ai.init(alloc);
    enemy_ai.init(alloc);
    player_imports = std.ArrayList(import.PokemonImport).init(alloc);
    enemy_imports = std.ArrayList(import.PokemonImport).init(alloc);
}

export fn clear() void {
    player_ai.clear();
    enemy_ai.clear();
    while (player_imports.items.len > 0) {
        _ = player_imports.pop();
    }
    while (enemy_imports.items.len > 0) {
        _ = enemy_imports.pop();
    }
}

export fn generateOptimizedDecisionTree(lead: u8) ?*player_ai.DecisionNode {
    player_ai.free_tree(decision_tree_instance);
    player_ai.clear();
    enemy_ai.clear();
    var lead_pokemon: pkmn.gen1.helpers.Pokemon = undefined;
    var enemy_helpers = [_]pkmn.gen1.helpers.Pokemon{undefined} ** 6; // Must enforce that enemy_imports is limited to 6 on frontend

    for (player_imports.items, 0..) |player_import, i| {
        print("Player Import: {}\n", .{player_import});
        var move_enums = [4]pkmn.gen1.Move{ .None, .None, .None, .None };
        for (player_import.moves, 0..) |move, j| {
            if (import.convert_move(move)) |valid_move| {
                move_enums[j] = valid_move;
            }
        }
        if (import.convert_species(player_import.species)) |valid_species| {
            const new_pokemon: pkmn.gen1.helpers.Pokemon = .{ .species = valid_species, .moves = &move_enums, .dvs = pkmn.gen1.DVs{
                .atk = @intCast(player_import.dvs.atk),
                .def = @intCast(player_import.dvs.def),
                .spc = @intCast(player_import.dvs.spc),
                .spe = @intCast(player_import.dvs.spe),
            } };
            if (i == lead) {
                lead_pokemon = new_pokemon;
            } else {
                player_ai.box.append(pkmn.gen1.helpers.Pokemon.init(new_pokemon)) catch continue;
            }
        }
    }

    for (enemy_imports.items, 0..) |enemy_import, i| {
        print("Enemy Import: {}\n", .{enemy_import});
        var move_enums = [4]pkmn.gen1.Move{ .None, .None, .None, .None };
        for (enemy_import.moves, 0..) |move, j| {
            if (import.convert_move(move)) |valid_move| {
                move_enums[j] = valid_move;
            }
        }
        if (import.convert_species(enemy_import.species)) |valid_species| {
            const new_pokemon: pkmn.gen1.helpers.Pokemon = .{ .species = valid_species, .moves = &move_enums, .dvs = pkmn.gen1.DVs{
                .atk = @intCast(enemy_import.dvs.atk),
                .def = @intCast(enemy_import.dvs.def),
                .spc = @intCast(enemy_import.dvs.spc),
                .spe = @intCast(enemy_import.dvs.spe),
            } };
            enemy_ai.team.append(pkmn.gen1.helpers.Pokemon.init(new_pokemon)) catch continue;
            enemy_helpers[i] = new_pokemon;
        }
    }

    print("Lead Pokemon: {s}\n", .{@tagName(lead_pokemon.species)});
    for (player_ai.box.items) |pokemon| {
        print("Player Box: {s}\n", .{@tagName(pokemon.species)});
    }
    for (enemy_ai.team.items) |pokemon| {
        print("Enemy Team: {s}\n", .{@tagName(pokemon.species)});
    }

    var prng = std.rand.DefaultPrng.init(1234);
    var battle = pkmn.gen1.helpers.Battle.init(prng.random().int(u64), &.{lead_pokemon}, &enemy_helpers);

    var options = pkmn.battle.options(
        pkmn.protocol.NULL,
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    // Need an empty result and switch ins for generating tree
    const result = battle.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch pkmn.Result{};

    decision_tree_instance = player_ai.optimal_decision_tree(battle, result);

    return decision_tree_instance;
}

export fn getNextNode(curr_node: ?*player_ai.DecisionNode, index: usize) ?*player_ai.DecisionNode {
    // TODO Check valid...index,
    if (curr_node) |valid_curr_node| {
        if (valid_curr_node.next_turns.items[index].turn) |valid_next_turn| {
            return valid_next_turn;
        }
        return null;
    }
    return null;
}

export fn getNumOfNextTurns(curr_node: ?*player_ai.DecisionNode) usize {
    if (curr_node) |valid_curr_node| {
        return valid_curr_node.*.next_turns.items.len;
    }
    return 0;
}

export fn getPlayerSpecies(curr_node: ?*player_ai.DecisionNode, out: [*]u8) usize {
    const species_str: [:0]const u8 = @tagName(curr_node.?.*.battle.side(tools.PLAYER_PID).stored().species);
    @memcpy(out, species_str);
    return species_str.len;
}

export fn getPlayerHP(curr_node: ?*player_ai.DecisionNode) usize {
    return curr_node.?.*.battle.side(tools.PLAYER_PID).stored().hp;
}

export fn getEnemySpecies(curr_node: ?*player_ai.DecisionNode, out: [*]u8) usize {
    const species_str: [:0]const u8 = @tagName(curr_node.?.*.battle.side(tools.ENEMY_PID).stored().species);
    @memcpy(out, species_str);
    return species_str.len;
}

export fn getEnemyHP(curr_node: ?*player_ai.DecisionNode) usize {
    return curr_node.?.*.battle.side(tools.ENEMY_PID).stored().hp;
}

export fn importPokemon(json_import: [*]u8, size: u32, player: u8) void {
    print("Import: {s}\n", .{json_import[0..size]});
    const parsed = json.parseFromSlice(import.PokemonImport, alloc, json_import[0..size], .{ .allocate = .alloc_always }) catch null;
    if (parsed) |valid_parsed| {
        if (player == 1) {
            player_imports.append(valid_parsed.value) catch {
                print("Player Failed to Import!\n", .{});
                return void{};
            };
        } else {
            enemy_imports.append(valid_parsed.value) catch {
                print("Enemy Failed to Import!\n", .{});
                return void{};
            };
        }
    }

    for (import.player_imports.items) |pokemon| {
        print("{}\n", .{pokemon});
    }
}

pub fn main() void {}
