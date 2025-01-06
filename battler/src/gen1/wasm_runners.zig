const std = @import("std");
const json = std.json;
const print = std.debug.print;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = gpa.allocator();

const pkmn = @import("pkmn");
const tools = @import("tools.zig");
const player_ai = @import("player_ai.zig");
const enemy_ai = @import("enemy_ai.zig");
const import = @import("import.zig");

const pkmn_options = pkmn.Options{ .internal = true };

export fn init() void {
    player_ai.init(alloc);
    enemy_ai.init(alloc);
    import.init(alloc);
}

export fn close() void {
    player_ai.close();
    enemy_ai.close();
    import.close();
}

export fn generateOptimizedDecisionTree(lead: usize) ?*player_ai.DecisionNode {
    var lead_pokemon: pkmn.gen1.helpers.Pokemon = undefined;
    for (import.player_imports.items, 0..) |player_import, i| {
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

    var enemy_helpers = [_]pkmn.gen1.helpers.Pokemon{undefined} ** 6; // Must enforce that enemy_imports is limited to 6 on frontend
    for (import.enemy_imports.items, 0..) |enemy_import, i| {
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

    var prng = std.rand.DefaultPrng.init(1234);
    var battle = pkmn.gen1.helpers.Battle.init(prng.random().int(u64), &.{lead_pokemon}, &enemy_helpers);

    var options = pkmn.battle.options(
        pkmn.protocol.NULL,
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    // Need an empty result and switch ins for generating tree
    const result = battle.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch pkmn.Result{};

    const root: ?*player_ai.DecisionNode = player_ai.optimal_decision_tree(battle, result);

    return root;
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

export fn importPokemon(json_import: [*]u8, size: u32, player: bool) void {
    const parsed = json.parseFromSlice(import.PokemonImport, alloc, json_import[0..size], .{}) catch null;
    if (parsed) |valid_parsed| {
        if (player) {
            import.player_imports.append(valid_parsed.value) catch void{};
        } else {
            import.enemy_imports.append(valid_parsed.value) catch void{};
        }
    }
}

pub fn main() void {}
