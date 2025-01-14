const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const pkmn = @import("pkmn");
const tools = @import("tools.zig");
const enemy_ai = @import("enemy_ai.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();

pub var box: std.ArrayList(pkmn.gen1.Pokemon) = undefined;
const MAX_TURNDEPTH: u16 = 40;
const MAX_LOOKAHEAD: u16 = 2;
const K_LARGEST: u16 = 5;

comptime {
    assert(MAX_LOOKAHEAD > 1);
    assert(K_LARGEST > 1);
}

/// Globalized creation of options for battle updates
// TODO Create issue on @pkmn/engine for not having to pass options with default values
const options = pkmn.battle.options(
    pkmn.protocol.NULL,
    pkmn.gen1.chance.NULL,
    pkmn.gen1.calc.NULL,
);

/// Structs for buliding decision tree
pub const DecisionNode = struct {
    battle: pkmn.gen1.Battle(pkmn.gen1.PRNG),
    team: [6]i8 = [_]i8{0} ** 6,
    result: pkmn.Result,
    score: u16 = 0,
    previous_node: ?*DecisionNode = null,
    next_turns: std.ArrayList(TurnChoices) = undefined,
};
pub const TurnChoices = struct { choices: [2]pkmn.Choice, next_node: ?*DecisionNode, box_switch: ?BoxSwitch };
pub const BoxSwitch = struct { added_pokemon: pkmn.gen1.Pokemon, order_slot: usize, box_id: usize };

pub fn optimal_decision_tree(starting_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), starting_result: pkmn.Result) ?*DecisionNode {
    const root = exhaustive_decision_tree(null, null, starting_battle, .{ 0, -1, -1, -1, -1, -1 }, starting_result, 0) orelse return null;
    var scoring_nodes = std.ArrayList(*DecisionNode).init(alloc);
    defer scoring_nodes.deinit();
    var depth: u16 = 0;

    scoring_nodes.append(root) catch return null;
    depth = MAX_LOOKAHEAD;

    while (depth < MAX_TURNDEPTH) {
        // Must be list of TurnChoices to be compatible with compare function for sorting by score
        var scored_nodes = std.ArrayList(*DecisionNode).init(alloc);
        defer scored_nodes.deinit();

        // Extend leaves of scoring_nodes to maximize depth for scoring
        for (scoring_nodes.items) |scoring_node| {
            if (scoring_node.previous_node) |previous_node| {
                _ = exhaustive_decision_tree(scoring_node, previous_node, scoring_node.battle, scoring_node.team, scoring_node.result, 0);
                const turn_choice_index = get_parent_turnchoice_index(previous_node, scoring_node) orelse return null;
                scoring_node.score = score(scoring_node, previous_node.next_turns.items[turn_choice_index].choices);
            } else {
                // Root node case with no previous node
                _ = exhaustive_decision_tree(scoring_node, null, scoring_node.battle, scoring_node.team, scoring_node.result, 0);
                scoring_node.score = score(scoring_node, .{ pkmn.Choice{}, pkmn.Choice{} });
            }

            scored_nodes.append(scoring_node) catch return null;
        }

        // Keep only the K_LARGEST nodes
        std.mem.sort(*DecisionNode, scored_nodes.items, {}, compare_score);
        const original_len = scored_nodes.items.len;
        if (original_len > K_LARGEST) {
            for (0..(original_len - K_LARGEST)) |_| {
                const delete_node = scored_nodes.swapRemove(K_LARGEST);
                const previous_node = delete_node.previous_node orelse continue;
                const turn_choice_index = get_parent_turnchoice_index(previous_node, delete_node) orelse return null;

                // Remove potential_node from parent's next_turns
                _ = previous_node.next_turns.swapRemove(turn_choice_index);
                free_tree(delete_node);
            }
        }

        scoring_nodes.clearAndFree();
        // Save chlidren of scored_nodes as next scoring_nodes
        for (scored_nodes.items) |scored_node| {
            for (scored_node.next_turns.items) |next_turn| {
                const next_node = next_turn.next_node orelse continue;
                scoring_nodes.append(next_node) catch continue;
            }
        }

        depth += 1;
    }
    return root;
}

// TODO Access leaves for extension without recursing from a root node
pub fn exhaustive_decision_tree(optional_curr_node: ?*DecisionNode, parent_node: ?*DecisionNode, curr_battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), curr_team: [6]i8, result: pkmn.Result, depth: u16) ?*DecisionNode {
    if (optional_curr_node) |curr_node| {
        for (curr_node.next_turns.items, 0..) |next_turn, i| {
            if (next_turn.next_node) |next_node| {
                // Traverse to already generated node
                _ = exhaustive_decision_tree(next_node, curr_node, curr_node.battle, curr_node.team, curr_node.result, depth + 1);
            } else {
                // Pass new battle and team since leaf reached
                var next_battle = curr_node.battle;
                var next_choice: pkmn.Choice = next_turn.choices[0];
                var next_team = curr_node.team;
                if (next_turn.box_switch) |box_switch| {
                    // Add new pokemon to team first before generating box switch
                    next_choice = add_to_team(&next_battle, box_switch.added_pokemon, box_switch.order_slot);
                    next_team[box_switch.order_slot] = @intCast(box_switch.box_id);
                }
                const new_result = next_battle.update(next_choice, next_turn.choices[1], &options) catch pkmn.Result{};
                curr_node.next_turns.items[i].next_node = exhaustive_decision_tree(null, curr_node, next_battle, next_team, new_result, depth + 1);
            }
        }
        return curr_node;
    } else {
        // Max possible depth to quickly generate is 6
        if (result.type != .None or depth == MAX_LOOKAHEAD) {
            return null;
        }

        // Copy to local variable for mutating with update
        var next_battle = curr_battle;

        // Generate a new node to contain children and also return as child to parent
        const new_node: ?*DecisionNode = alloc.create(DecisionNode) catch return null;

        new_node.?.* = .{
            .battle = curr_battle,
            .team = curr_team,
            .result = result,
            .previous_node = parent_node,
            .next_turns = std.ArrayList(TurnChoices).init(alloc),
        };

        var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
        const max1 = curr_battle.choices(tools.PLAYER_PID, result.p1, &choices);
        const engine_valid_choices = choices[0..max1];
        // Enemy only guaranteed to make one move
        // TODO Issue #6
        const enemy_choice = enemy_ai.pick_choice(curr_battle, result, 0);

        var new_team = curr_team;

        for (engine_valid_choices) |choice| {
            const new_result: pkmn.Result = next_battle.update(choice, enemy_choice, &options) catch pkmn.Result{};
            new_team = curr_team;
            const child_node = exhaustive_decision_tree(null, new_node, next_battle, new_team, new_result, depth + 1);
            next_battle = curr_battle;
            if (new_node) |valid_new_node| valid_new_node.next_turns.append(.{ .choices = .{ choice, enemy_choice }, .next_node = child_node, .box_switch = null }) catch continue;
        }

        // TODO Full team edge case
        var new_member_slot: usize = 0;
        for (curr_team, 0..) |box_id, i| {
            if (box_id == -1) {
                new_member_slot = i;
                break;
            }
        }
        // Still being zero means no new slot
        if (0 < new_member_slot) {
            for (box.items, 0..) |box_mon, box_index| {
                new_team = curr_team;
                var in_box: bool = false;
                for (curr_team) |team_index| { // Is box_mon already on team?
                    if (box_index == team_index) {
                        in_box = true;
                    }
                }
                if (!in_box) {
                    const switch_choice: pkmn.Choice = add_to_team(&next_battle, box_mon, new_member_slot);
                    const new_result: pkmn.Result = next_battle.update(switch_choice, enemy_choice, &options) catch pkmn.Result{};
                    new_team[new_member_slot] = @intCast(box_index);
                    const child_node = exhaustive_decision_tree(null, new_node, next_battle, new_team, new_result, depth + 1);
                    next_battle = curr_battle;
                    new_node.?.*.next_turns.append(.{ .choices = .{ switch_choice, enemy_choice }, .next_node = child_node, .box_switch = .{ .added_pokemon = box_mon, .order_slot = new_member_slot, .box_id = box_index } }) catch continue;
                }
            }
        }

        return new_node;
    }
}

fn score(scoring_node: *DecisionNode, choices_to_node: [2]pkmn.Choice) u16 {
    var sum: u16 = 0;

    const previous_node = scoring_node.previous_node orelse return 0;

    const previous_battle = previous_node.battle;
    const previous_player_active = previous_battle.side(tools.PLAYER_PID).active;
    const previous_player_stored = previous_battle.side(tools.PLAYER_PID).stored();
    const previous_enemy_active = previous_battle.side(tools.ENEMY_PID).active;
    // const previous_enemy_stored = previous_battle.side(tools.ENEMY_PID).stored();

    const scoring_battle = scoring_node.battle;
    // const scoring_player_active = scoring_battle.side(tools.PLAYER_PID).active;
    // const scoring_enemy_active  = scoring_battle.side(tools.ENEMY_PID).active;

    if (choices_to_node[0].type == pkmn.Choice.Type.Move) {
        // STAB
        const move_type = pkmn.gen1.Move.get(previous_player_stored.move(choices_to_node[0].data).id).type;
        if (move_type == previous_player_active.types.type1 or move_type == previous_player_active.types.type2) {
            sum += 10;
        }

        // Fast Kill
        if (previous_player_active.stats.spe > previous_enemy_active.stats.spe and scoring_battle.side(tools.ENEMY_PID).stored().hp == 0) {
            sum += 10;
        }
        // Fast MultiKill
        // TODO Create a damage calculator to tell if player T-HKO < enemy T-HKO
        if (previous_player_active.stats.spe > previous_enemy_active.stats.spe and scoring_battle.side(tools.ENEMY_PID).stored().hp == 0) {}
    } else if (choices_to_node[0].type == pkmn.Choice.Type.Switch) {
        sum += 1000;
    } else if (choices_to_node[0].type == pkmn.Choice.Type.Pass) {
        sum += 0;
    }

    return sum;
}

fn compare_score(_: void, n1: *DecisionNode, n2: *DecisionNode) bool {
    // TODO What to do when scores are equal
    if (n1.score > n2.score) {
        return true;
    } else {
        return false;
    }
}

fn add_to_team(battle: *pkmn.gen1.Battle(pkmn.gen1.PRNG), new_mon: pkmn.gen1.Pokemon, new_member_slot: usize) pkmn.Choice {
    battle.side(tools.PLAYER_PID).pokemon[new_member_slot] = new_mon;
    battle.side(tools.PLAYER_PID).order[new_member_slot] = @intCast(new_member_slot + 1);

    var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    const max = battle.choices(tools.PLAYER_PID, pkmn.Choice.Type.Switch, &choices); // Force result type to be a switch and not anything else
    const valid_choices = choices[0..max];

    var highest_switch = pkmn.Choice{ .type = pkmn.Choice.Type.Switch, .data = 0 };
    for (valid_choices) |choice| {
        if (choice.type == pkmn.Choice.Type.Switch and choice.data > highest_switch.data) {
            highest_switch = choice;
        }
    }
    return highest_switch;
}

// TODO Rewrite to traverse iteratively, not recursively
pub fn traverse_decision_tree(optional_start_node: ?*DecisionNode) !void {
    var optional_curr_node = optional_start_node;
    while (true) {
        if (optional_curr_node) |curr_node| {
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
            tools.print_battle(curr_node.battle, c1, c2);

            // Displays possible moves/switches as well as traversing to previous nodes/quitting
            print("Select one of the following choices: \n", .{});
            for (curr_node.next_turns.items, 0..) |next_turn, i| {
                if (next_turn.next_node) |next_node| {
                    if (next_turn.choices[0].type == pkmn.Choice.Type.Move) {
                        print("{}={s}/M ({}), ", .{ i + 1, @tagName(curr_node.battle.side(tools.PLAYER_PID).stored().move(next_turn.choices[0].data).id), next_node.score });
                    } else if (next_turn.choices[0].type == pkmn.Choice.Type.Switch and next_turn.choices[0].data != 42) {
                        if (next_turn.box_switch) |box_switch| {
                            print("{}={s}/S ({}), ", .{ i + 1, @tagName(box_switch.added_pokemon.species), next_node.score });
                        } else {
                            print("{}={s}/S ({}), ", .{ i + 1, @tagName(curr_node.battle.side(tools.PLAYER_PID).get(next_turn.choices[0].data).species), next_node.score });
                        }
                    } else if (next_turn.choices[0].type == pkmn.Choice.Type.Pass) {
                        print("c=continue, ", .{});
                    }
                }
            }
            print("p=previous turn, q=quit\n", .{});

            // Takes a single character (u8) for processing next node to follow
            var input_buf: [10]u8 = undefined;
            const reader = std.io.getStdIn().reader();
            if (try reader.readUntilDelimiterOrEof(input_buf[0..], '\n')) |user_input| {
                if (user_input.len == @as(usize, 0)) {
                    print("Invalid input!\n", .{});
                    break;
                } else if (49 <= user_input[0] and user_input[0] <= 57) { // ASCII range of integers from 1-9
                    const choice_id = try std.fmt.parseInt(u8, user_input, 10);
                    optional_curr_node = traverse_decision_tree(curr_node.next_turns.items[choice_id - 1].next_node);
                } else if (user_input[0] == 'c') {
                    optional_curr_node = traverse_decision_tree(curr_node.next_turns.items[0].next_node);
                } else if (user_input[0] == 'p') {
                    optional_curr_node = traverse_decision_tree(curr_node.previous_node);
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
}

// Returns the index of a turnchoice matching a given child
fn get_parent_turnchoice_index(parent_node: *DecisionNode, child_node: *DecisionNode) ?usize {
    for (parent_node.next_turns.items, 0..) |turn_choice, i| {
        if (turn_choice.next_node) |next_node| {
            if (next_node == child_node) {
                return i;
            }
        }
    }
    return null;
}

pub fn free_tree(optional_curr_node: ?*DecisionNode) void {
    if (optional_curr_node) |curr_node| {
        for (curr_node.next_turns.items) |next_turn| {
            if (next_turn.next_node != null) {
                free_tree(next_turn.next_node);
            }
        }
        curr_node.next_turns.deinit();
        alloc.destroy(curr_node);
    }
}
