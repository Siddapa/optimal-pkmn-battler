const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();

const pkmn = @import("pkmn");
const Pokemon = pkmn.gen1.helpers.Pokemon;

const player_ai = @import("player_ai.zig");
const enemy_ai = @import("enemy_ai.zig");

pub fn battle_details(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), hp: bool, moves: bool) void {
    const player_pkmn = battle.side(.P1).stored();
    const enemy_pkmn = battle.side(.P2).stored();

    if (hp) print("Player: {s}, HP: {}/{}, HP Taken: {}\n", .{ @tagName(player_pkmn.species), player_pkmn.hp, player_pkmn.stats.hp, player_pkmn.stats.hp - player_pkmn.hp });
    if (moves) {
        for (player_pkmn.moves, 0..) |move, i| {
            print("Move {}: {}\n", .{ i, move });
        }
    }

    print("\n", .{});

    if (hp) print("Enemy: {s}, HP: {}/{}, HP Taken: {}\n", .{ @tagName(enemy_pkmn.species), enemy_pkmn.hp, enemy_pkmn.stats.hp, enemy_pkmn.stats.hp - enemy_pkmn.hp });
    if (moves) {
        for (enemy_pkmn.moves, 0..) |move, i| {
            print("Move {}: {}\n", .{ i, move });
        }
    }

    print("\n", .{});
}

pub fn print_battle(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), c1: pkmn.Choice, c2: pkmn.Choice) void {
    const player_pkmn = battle.side(.P1).stored();
    const enemy_pkmn = battle.side(.P2).stored();

    print("Player: {s}, HP: {}/{}\n", .{ @tagName(player_pkmn.species), player_pkmn.hp, player_pkmn.stats.hp });
    print("Player Choice: {s}, {}\n", .{ @tagName(c1.type), c1.data });
    if (c1.type == pkmn.Choice.Type.Move and c1.data != 0) {
        print("Move Made: {s}\n", .{@tagName(player_pkmn.move(c1.data).id)});
    }

    print("AI: {s}, HP: {}/{}\n", .{ @tagName(enemy_pkmn.species), enemy_pkmn.hp, enemy_pkmn.stats.hp });
    print("AI Choice: {s}, {}\n", .{ @tagName(c2.type), c2.data });
    if (c2.type == pkmn.Choice.Type.Move and c2.data != 0) {
        print("Move Made: {s}\n", .{@tagName(enemy_pkmn.move(c2.data).id)});
    }
}

pub fn init_battle(team1: []const Pokemon, team2: []const Pokemon) pkmn.gen1.Battle(pkmn.gen1.PRNG) {
    assert(0 <= team1.len and team1.len <= 6);
    assert(0 <= team2.len and team2.len <= 6);

    var prng = (if (@hasDecl(std, "Random")) std.Random else std.rand).DefaultPrng.init(1234);
    var random = prng.random();

    const battle = pkmn.gen1.helpers.Battle.init(
        random.int(u64),
        team1,
        team2,
    );

    return battle;
}

pub fn random_vs_enemy_ai() !void {}

pub fn traverse_decision_tree(start_node: *player_ai.DecisionNode) !void {
    var curr_node = start_node;
    while (true) {
        // Spacing between node selections
        print("-" ** 30, .{});
        print("\n", .{});

        // Selects choices made to get to the current turn
        var c1 = pkmn.Choice{};
        var c2 = pkmn.Choice{};
        if (curr_node.previous_node) |previous_node| {
            for (previous_node.next_turns.items, 0..) |next_turn, i| {
                if (next_turn.next_node == curr_node) {
                    c1 = previous_node.next_turns.items[i].choices[0];
                    c2 = previous_node.next_turns.items[i].choices[1];
                }
            }
        }
        print_battle(curr_node.battle, c1, c2);
        print("Last Damage: {}\n", .{curr_node.battle.last_damage});

        // Displays possible moves/switches as well as traversing to previous nodes/quitting
        print("Select one of the following choices: \n", .{});
        for (curr_node.next_turns.items, 0..) |next_turn, i| {
            const next_node = next_turn.next_node;
            if (next_turn.choices[0].type == pkmn.Choice.Type.Move) {
                print("{}={s}/M ({}), ", .{ i + 1, @tagName(curr_node.battle.side(.P1).stored().move(next_turn.choices[0].data).id), next_node.score });
            } else if (next_turn.choices[0].type == pkmn.Choice.Type.Switch and next_turn.choices[0].data != 42) {
                if (next_turn.box_switch) |box_switch| {
                    print("{}={s}/S ({}), ", .{ i + 1, @tagName(box_switch.added_pokemon.species), next_node.score });
                } else {
                    print("{}={s}/S ({}), ", .{ i + 1, @tagName(curr_node.battle.side(.P1).get(next_turn.choices[0].data).species), next_node.score });
                }
            } else if (next_turn.choices[0].type == pkmn.Choice.Type.Pass) {
                print("c=continue, ", .{});
            }
        }
        if (curr_node.previous_node) |_| {
            print("p=previous turn, q=quit\n", .{});
        } else {
            print("q=quit\n", .{});
        }

        // Takes a single character (u8) for processing next node to follow
        var input_buf: [10]u8 = undefined;
        const reader = std.io.getStdIn().reader();
        if (try reader.readUntilDelimiterOrEof(input_buf[0..], '\n')) |user_input| {
            if (user_input.len == @as(usize, 0)) {
                print("Invalid input!\n", .{});
                break;
            } else if (49 <= user_input[0] and user_input[0] <= 57) { // ASCII range of integers from 1-9
                const choice_id = try std.fmt.parseInt(u8, user_input, 10);
                curr_node = curr_node.next_turns.items[choice_id - 1].next_node;
            } else if (user_input[0] == 'c') {
                curr_node = curr_node.next_turns.items[0].next_node;
            } else if (user_input[0] == 'p') {
                curr_node = curr_node.previous_node orelse break;
            } else if (user_input[0] == 'q') {
                break;
            } else {
                print("Invalid input!\n", .{});
                break;
            }
        } else {
            print("Failed to Read Line!\n", .{});
        }
    }
}
