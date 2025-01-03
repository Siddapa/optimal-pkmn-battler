const std = @import("std");
const print = std.debug.print;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const mvzr = @import("mvzr");

const pkmn = @import("pkmn");
const tools = @import("tools.zig");
const player_ai = @import("player_ai.zig");

pub const pkmn_options = pkmn.Options{ .internal = true };

export fn blah() u8 {
    return 10;
}

export fn generateOptimizedDecisionTree() ?*player_ai.DecisionNode {
    var battle = tools.init_battle(&.{
        .{ .species = .Pikachu, .moves = &.{ .Thunderbolt, .ThunderWave, .Surf, .SeismicToss } },
    }, &.{
        .{ .species = .Pidgey, .moves = &.{.Pound} },
        .{ .species = .Chansey, .moves = &.{ .Reflect, .SeismicToss, .SoftBoiled, .ThunderWave } },
        .{ .species = .Snorlax, .moves = &.{ .BodySlam, .Reflect, .Rest, .IceBeam } },
        .{ .species = .Exeggutor, .moves = &.{ .SleepPowder, .Psychic, .Explosion, .DoubleEdge } },
        .{ .species = .Starmie, .moves = &.{ .Recover, .ThunderWave, .Blizzard, .Thunderbolt } },
        .{ .species = .Alakazam, .moves = &.{ .Psychic, .SeismicToss, .ThunderWave, .Recover } },
    });

    var options = pkmn.battle.options(
        pkmn.protocol.NULL,
        pkmn.gen1.chance.NULL,
        pkmn.gen1.calc.NULL,
    );

    // Need an empty result and switch ins for generating tree
    const result = battle.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch pkmn.Result{};

    const allocator = gpa.allocator();
    var box_pokemon = std.ArrayList(pkmn.gen1.Pokemon).init(allocator);
    const box_pokemon_array = [_]pkmn.gen1.helpers.Pokemon{
        .{ .species = .Bulbasaur, .moves = &.{ .SleepPowder, .SwordsDance, .RazorLeaf, .BodySlam } },
        .{ .species = .Charmander, .moves = &.{ .FireBlast, .FireSpin, .Slash, .Counter } },
        .{ .species = .Squirtle, .moves = &.{ .Surf, .Blizzard, .BodySlam, .Rest } },
        .{ .species = .Rattata, .moves = &.{ .SuperFang, .BodySlam, .Blizzard, .Thunderbolt } },
        .{ .species = .Pidgey, .moves = &.{ .DoubleEdge, .QuickAttack, .WingAttack, .MirrorMove } },
    };
    for (box_pokemon_array) |mon| {
        box_pokemon.append(pkmn.gen1.helpers.Pokemon.init(mon)) catch continue;
    }
    player_ai.init(box_pokemon, allocator);

    const root: ?*player_ai.DecisionNode = player_ai.optimal_decision_tree(battle, result);

    player_ai.deinit();

    return root;
}

export fn importPlayerPokemon(imports: [*]u8, size: u32) void {
    var lines = std.mem.splitScalar(u8, imports[0..size], '\n');

    print("{}\n", .{lines});
    while (lines.next()) |line| {
        print("{s}\n", .{line});
    }
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

export fn getEnemySpecies(curr_node: ?*player_ai.DecisionNode, out: [*]u8) usize {
    const species_str: [:0]const u8 = @tagName(curr_node.?.*.battle.side(tools.ENEMY_PID).stored().species);
    @memcpy(out, species_str);
    return species_str.len;
}

pub fn main() void {}
