const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const pkmn = @import("pkmn");
const Move = pkmn.gen1.Move;
const effects = Move.Effect;

const tools = @import("tools.zig");

pub var team: std.ArrayList(pkmn.gen1.Pokemon) = undefined;

const ChoiceData = struct {
    choice: pkmn.Choice,
    priority: i8,
};

/// http://wiki.pokemonspeedruns.com/index.php/Pok%C3%A9mon_Red/Blue/Yellow_Trainer_AI
/// Provides categories for move selection
/// @arg(good_ai) should be enabled when facing certain trainers
/// TODO Track number of turns on field in main loop
pub fn pick_choice(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), result: pkmn.Result, turns_on_field: u8, out: []pkmn.Choice) usize {
    const alloc = gpa.allocator();
    var choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    const player_side = battle.side(tools.PLAYER_PID);
    const enemy_side = battle.side(tools.ENEMY_PID);

    const max_choice = battle.choices(tools.ENEMY_PID, result.p2, &choices);
    const valid_choices = choices[0..max_choice];
    assert(valid_choices.len > 0);

    // When no switches available and pokemon is restricted from moving
    if (valid_choices[0].type == pkmn.Choice.Type.Move and valid_choices[0].data == 0) {
        out[0] = valid_choices[0];
        return 1;
    }

    var choice_datas = std.ArrayList(ChoiceData).init(alloc);
    defer choice_datas.deinit();

    // Switches are only possible when enemy's active pokemon is dead
    if (player_side.stored().hp != 0) {
        var min_priority: i8 = 100; // Represents +inf since priority which reach that high
        for (valid_choices) |choice| {
            if (choice.type == pkmn.Choice.Type.Move and choice.data != 0) {
                var priority: i8 = 10;
                const move = enemy_side.active.move(choice.data).id;
                // Disfavor status-ing moves on status-ed pokemon
                if (pkmn.gen1.Status.any(player_side.stored().status) and is_status(move)) {
                    priority += 5;
                }
                // Encourage setup moves on turn 2
                if (turns_on_field == 2 and is_setup(move)) {
                    priority -= 1;
                }
                // Favor super_effective matchups
                priority += super_effective_matchup(Move.get(move).type, player_side.active.types);
                if (priority < min_priority) {
                    min_priority = priority;
                }
                choice_datas.append(.{
                    .choice = choice,
                    .priority = priority,
                }) catch continue;
            }
        }

        var min_priority_count: u8 = 0;
        for (choice_datas.items) |choice_data| {
            if (choice_data.priority == min_priority) {
                out[min_priority_count] = choice_data.choice;
                min_priority_count += 1;
            }
        }
        return min_priority_count;
    } else {
        // Find lowest current-order switch that matches original team order
        var lowest_switch = pkmn.Choice{};
        var lowest_index: u8 = 100;
        for (valid_choices) |choice| {
            if (choice.data < lowest_index) {
                lowest_switch = choice;
                lowest_index = choice.data;
            }
        }
        out[0] = lowest_switch;
        return 1;
    }
}

fn is_status(move: Move) bool {
    switch (Move.get(move).effect) {
        effects.Paralyze, effects.Poison, effects.Sleep => return true,
        else => return false,
    }
}

// Effect order follows online guides
fn is_setup(move: Move) bool {
    switch (Move.get(move).effect) {
        .AttackUp1, .DefenseUp1, .SpecialUp1, .EvasionUp1, .PayDay, .Swift, .AttackDown1, .DefenseDown1, .AccuracyDown1, .Conversion, .Haze, .AttackUp2, .DefenseUp2, .SpeedUp2, .SpecialUp2, .Heal, .Transform, .DefenseDown2, .LightScreen, .Reflect => return true,
        else => return false,
    }
}

fn check_types(check_type: pkmn.gen1.Type, player_types: pkmn.gen1.Types) bool {
    return (player_types.type1 == check_type or player_types.type2 == check_type);
}

fn super_effective_matchup(move_type: pkmn.gen1.Type, player_types: pkmn.gen1.Types) i8 {
    if (move_type == .Water and check_types(.Fire, player_types)) {
        return -1;
    } else if (move_type == .Fire and check_types(.Grass, player_types)) {
        return -1;
    } else if (move_type == .Fire and check_types(.Ice, player_types)) {
        return -1;
    } else if (move_type == .Grass and check_types(.Water, player_types)) {
        return -1;
    } else if (move_type == .Electric and check_types(.Water, player_types)) {
        return -1;
    } else if (move_type == .Water and check_types(.Rock, player_types)) {
        return -1;
    } else if (move_type == .Ground and check_types(.Flying, player_types)) {
        return 1;
    } else if (move_type == .Water and check_types(.Water, player_types)) {
        return 1;
    } else if (move_type == .Fire and check_types(.Fire, player_types)) {
        return 1;
    } else if (move_type == .Electric and check_types(.Electric, player_types)) {
        return 1;
    } else if (move_type == .Ice and check_types(.Ice, player_types)) {
        return 1;
    } else if (move_type == .Grass and check_types(.Grass, player_types)) {
        return 1;
    } else if (move_type == .Psychic and check_types(.Psychic, player_types)) {
        return 1;
    } else if (move_type == .Fire and check_types(.Water, player_types)) {
        return 1;
    } else if (move_type == .Grass and check_types(.Fire, player_types)) {
        return 1;
    } else if (move_type == .Water and check_types(.Grass, player_types)) {
        return 1;
    } else if (move_type == .Electric and check_types(.Grass, player_types)) {
        return 1;
    } else if (move_type == .Normal and check_types(.Rock, player_types)) {
        return 1;
    } else if (move_type == .Normal and check_types(.Ghost, player_types)) {
        return 1;
    } else if (move_type == .Ghost and check_types(.Ghost, player_types)) {
        return -1;
    } else if (move_type == .Fire and check_types(.Bug, player_types)) {
        return -1;
    } else if (move_type == .Fire and check_types(.Rock, player_types)) {
        return 1;
    } else if (move_type == .Water and check_types(.Ground, player_types)) {
        return -1;
    } else if (move_type == .Electric and check_types(.Ground, player_types)) {
        return 1;
    } else if (move_type == .Electric and check_types(.Flying, player_types)) {
        return -1;
    } else if (move_type == .Ground and check_types(.Ground, player_types)) {
        return -1;
    } else if (move_type == .Grass and check_types(.Bug, player_types)) {
        return 1;
    } else if (move_type == .Grass and check_types(.Poison, player_types)) {
        return 1;
    } else if (move_type == .Grass and check_types(.Rock, player_types)) {
        return -1;
    } else if (move_type == .Grass and check_types(.Flying, player_types)) {
        return 1;
    } else if (move_type == .Ice and check_types(.Water, player_types)) {
        return 1;
    } else if (move_type == .Ice and check_types(.Grass, player_types)) {
        return -1;
    } else if (move_type == .Ice and check_types(.Ground, player_types)) {
        return -1;
    } else if (move_type == .Ice and check_types(.Flying, player_types)) {
        return -1;
    } else if (move_type == .Fighting and check_types(.Normal, player_types)) {
        return -1;
    } else if (move_type == .Fighting and check_types(.Poison, player_types)) {
        return 1;
    } else if (move_type == .Fighting and check_types(.Flying, player_types)) {
        return 1;
    } else if (move_type == .Fighting and check_types(.Psychic, player_types)) {
        return 1;
    } else if (move_type == .Fighting and check_types(.Bug, player_types)) {
        return 1;
    } else if (move_type == .Fighting and check_types(.Rock, player_types)) {
        return -1;
    } else if (move_type == .Fighting and check_types(.Ice, player_types)) {
        return -1;
    } else if (move_type == .Fighting and check_types(.Ghost, player_types)) {
        return 1;
    } else if (move_type == .Poison and check_types(.Grass, player_types)) {
        return -1;
    } else if (move_type == .Poison and check_types(.Poison, player_types)) {
        return 1;
    } else if (move_type == .Poison and check_types(.Ground, player_types)) {
        return 1;
    } else if (move_type == .Poison and check_types(.Bug, player_types)) {
        return -1;
    } else if (move_type == .Poison and check_types(.Rock, player_types)) {
        return 1;
    } else if (move_type == .Poison and check_types(.Ghost, player_types)) {
        return 1;
    } else if (move_type == .Ground and check_types(.Fire, player_types)) {
        return -1;
    } else if (move_type == .Ground and check_types(.Electric, player_types)) {
        return -1;
    } else if (move_type == .Ground and check_types(.Grass, player_types)) {
        return 1;
    } else if (move_type == .Ground and check_types(.Bug, player_types)) {
        return 1;
    } else if (move_type == .Ground and check_types(.Rock, player_types)) {
        return -1;
    } else if (move_type == .Ground and check_types(.Poison, player_types)) {
        return -1;
    } else if (move_type == .Flying and check_types(.Electric, player_types)) {
        return 1;
    } else if (move_type == .Flying and check_types(.Fighting, player_types)) {
        return -1;
    } else if (move_type == .Flying and check_types(.Bug, player_types)) {
        return -1;
    } else if (move_type == .Flying and check_types(.Grass, player_types)) {
        return -1;
    } else if (move_type == .Flying and check_types(.Rock, player_types)) {
        return 1;
    } else if (move_type == .Psychic and check_types(.Fighting, player_types)) {
        return -1;
    } else if (move_type == .Psychic and check_types(.Poison, player_types)) {
        return -1;
    } else if (move_type == .Bug and check_types(.Fire, player_types)) {
        return 1;
    } else if (move_type == .Bug and check_types(.Grass, player_types)) {
        return -1;
    } else if (move_type == .Bug and check_types(.Fighting, player_types)) {
        return 1;
    } else if (move_type == .Bug and check_types(.Flying, player_types)) {
        return 1;
    } else if (move_type == .Bug and check_types(.Psychic, player_types)) {
        return -1;
    } else if (move_type == .Bug and check_types(.Ghost, player_types)) {
        return 1;
    } else if (move_type == .Bug and check_types(.Poison, player_types)) {
        return -1;
    } else if (move_type == .Rock and check_types(.Fire, player_types)) {
        return -1;
    } else if (move_type == .Rock and check_types(.Fighting, player_types)) {
        return 1;
    } else if (move_type == .Rock and check_types(.Ground, player_types)) {
        return 1;
    } else if (move_type == .Rock and check_types(.Flying, player_types)) {
        return -1;
    } else if (move_type == .Rock and check_types(.Bug, player_types)) {
        return -1;
    } else if (move_type == .Rock and check_types(.Ice, player_types)) {
        return -1;
    } else if (move_type == .Ghost and check_types(.Normal, player_types)) {
        return 1;
    } else if (move_type == .Ghost and check_types(.Psychic, player_types)) {
        return 1;
    } else if (move_type == .Fire and check_types(.Dragon, player_types)) {
        return 1;
    } else if (move_type == .Water and check_types(.Dragon, player_types)) {
        return 1;
    } else if (move_type == .Electric and check_types(.Dragon, player_types)) {
        return 1;
    } else if (move_type == .Grass and check_types(.Dragon, player_types)) {
        return 1;
    } else if (move_type == .Ice and check_types(.Dragon, player_types)) {
        return -1;
    } else if (move_type == .Dragon and check_types(.Dragon, player_types)) {
        return -1;
    }
    return 0;
}
