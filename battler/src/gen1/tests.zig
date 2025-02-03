const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const alloc = std.testing.allocator;

const pkmn = @import("pkmn");

const builder = @import("tree");
const enemy_ai = builder.enemy_ai;
const tools = builder.tools;

var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
var options = pkmn.battle.options(
    pkmn.protocol.NULL,
    &chance,
    pkmn.gen1.Calc{},
);

test "BaseTransitions" {
    print("Transitions\n", .{});

    var battle = tools.init_battle(&.{
        .{ .species = .Bulbasaur, .moves = &.{ .Flamethrower, .Growl, .PoisonPowder, .Reflect } },
        .{ .species = .Goldeen, .moves = &.{ .RazorLeaf, .SolarBeam, .PoisonPowder, .FireSpin } },
    }, &.{
        .{ .species = .Jynx, .moves = &.{ .AuroraBeam, .HyperBeam, .Blizzard, .Peck } },
        .{ .species = .Rhyhorn, .moves = &.{ .Thunderbolt, .Mist, .WaterGun, .Psybeam } },
    });

    const result = battle.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch pkmn.Result{};

    const total_updates = try run_transitions(battle, result);

    print("# of Updates: {}\n", .{total_updates});
}

test "EnemySwitchTransitions" {
    print("EnemySwitchTransitions\n", .{});

    var battle = tools.init_battle(&.{
        .{ .species = .Articuno, .moves = &.{ .Flamethrower, .Growl, .PoisonPowder, .Reflect } },
        .{ .species = .Goldeen, .moves = &.{ .RazorLeaf, .SolarBeam, .PoisonPowder, .FireSpin } },
    }, &.{
        .{ .species = .Jynx, .moves = &.{ .AuroraBeam, .Flamethrower, .Blizzard, .Peck }, .hp = 1 },
        .{ .species = .Rhyhorn, .moves = &.{ .Thunderbolt, .Mist, .WaterGun, .Psybeam } },
    });

    var result = try battle.update(pkmn.Choice{}, pkmn.Choice{}, &options);

    var player_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    var enemy_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    const player_max = battle.choices(.P1, result.p1, &player_choices);
    const player_valid_choices = player_choices[0..player_max];

    const enemy_max = enemy_ai.pick_choice(battle, result, 0, &enemy_choices);
    const enemy_valid_choices = enemy_choices[0..enemy_max];

    // Moves are harcoded so changing initial conditions could break test
    result = try battle.update(player_valid_choices[1], enemy_valid_choices[0], &options);

    tools.battle_details(battle, true, true);

    const total_updates = try run_transitions(battle, result);

    print("# of Updates: {}\n", .{total_updates});
}

test "BoxSwitchTransitions" {
    print("BoxSwitchTransitions\n", .{});

    var battle = tools.init_battle(&.{
        .{ .species = .Articuno, .moves = &.{ .Flamethrower, .Growl, .PoisonPowder, .Reflect } },
    }, &.{
        .{ .species = .Jynx, .moves = &.{ .AuroraBeam, .Flamethrower, .Blizzard, .Peck } },
        .{ .species = .Rhyhorn, .moves = &.{ .Thunderbolt, .Mist, .WaterGun, .Psybeam } },
    });

    //

    const result = try battle.update(pkmn.Choice{}, pkmn.Choice{}, &options);

    const switch_mon = pkmn.gen1.helpers.Pokemon.init(.{ .species = .Goldeen, .moves = &.{ .RazorLeaf, .SolarBeam, .PoisonPowder, .FireSpin } });
    _ = builder.add_to_team(&battle, switch_mon, 2);

    const total_updates = try run_transitions(battle, result);

    print("# of Updates: {}\n", .{total_updates});
}

test "OptimalWASM" {
    print("OptimalWASM\n", .{});
    const battle = tools.init_battle(&.{
        .{ .species = .Articuno, .moves = &.{ .IceBeam, .Growl, .Tackle, .Wrap } },
    }, &.{
        .{ .species = .Jynx, .moves = &.{ .AuroraBeam, .HyperBeam, .DrillPeck, .Peck } },
        .{ .species = .Chansey, .moves = &.{ .Counter, .SeismicToss, .Strength, .Absorb } },
        .{ .species = .Goldeen, .moves = &.{ .RazorLeaf, .SolarBeam, .PoisonPowder, .FireSpin } },
    });

    const box_pokemon = [_]pkmn.gen1.helpers.Pokemon{
        .{ .species = .Kingler, .moves = &.{ .SandAttack, .Headbutt, .HornAttack, .TailWhip } },
        .{ .species = .Rhyhorn, .moves = &.{ .Flamethrower, .Mist, .WaterGun, .Psybeam } },
    };

    try run_optimal(battle, &box_pokemon);
}

test "Exhaust1" {
    print("Exhaust1\n", .{});
    const battle = tools.init_battle(&.{
        .{ .species = .Pikachu, .moves = &.{ .Thunderbolt, .ThunderWave, .Surf, .SeismicToss } },
    }, &.{
        .{ .species = .Pidgey, .moves = &.{.Pound} },
        .{ .species = .Chansey, .moves = &.{ .Reflect, .SeismicToss, .SoftBoiled, .ThunderWave } },
        .{ .species = .Snorlax, .moves = &.{ .BodySlam, .Reflect, .Rest, .IceBeam } },
        .{ .species = .Exeggutor, .moves = &.{ .SleepPowder, .Psychic, .Explosion, .DoubleEdge } },
        .{ .species = .Starmie, .moves = &.{ .Recover, .ThunderWave, .Blizzard, .Thunderbolt } },
        .{ .species = .Alakazam, .moves = &.{ .Psychic, .SeismicToss, .ThunderWave, .Recover } },
    });

    const box_pokemon = [_]pkmn.gen1.helpers.Pokemon{
        .{ .species = .Bulbasaur, .moves = &.{ .SleepPowder, .SwordsDance, .RazorLeaf, .BodySlam } },
        .{ .species = .Charmander, .moves = &.{ .FireBlast, .FireSpin, .Slash, .Counter } },
        .{ .species = .Squirtle, .moves = &.{ .Surf, .Blizzard, .BodySlam, .Rest } },
        .{ .species = .Rattata, .moves = &.{ .SuperFang, .BodySlam, .Blizzard, .Thunderbolt } },
        .{ .species = .Pidgey, .moves = &.{ .DoubleEdge, .QuickAttack, .WingAttack, .MirrorMove } },
    };

    try run_exhaust(battle, &box_pokemon);
}

test "Optimal1" {
    print("Optimal1\n", .{});
    const battle = tools.init_battle(&.{
        .{ .species = .Pikachu, .moves = &.{ .Thunderbolt, .ThunderWave, .Surf, .SeismicToss } },
    }, &.{
        .{ .species = .Pidgey, .moves = &.{.Pound} },
        .{ .species = .Chansey, .moves = &.{ .Reflect, .SeismicToss, .SoftBoiled, .ThunderWave } },
        .{ .species = .Snorlax, .moves = &.{ .BodySlam, .Reflect, .Rest, .IceBeam } },
        .{ .species = .Exeggutor, .moves = &.{ .SleepPowder, .Psychic, .Explosion, .DoubleEdge } },
        .{ .species = .Starmie, .moves = &.{ .Recover, .ThunderWave, .Blizzard, .Thunderbolt } },
        .{ .species = .Alakazam, .moves = &.{ .Psychic, .SeismicToss, .ThunderWave, .Recover } },
    });
    const box_pokemon = [_]pkmn.gen1.helpers.Pokemon{
        .{ .species = .Bulbasaur, .moves = &.{ .SleepPowder, .SwordsDance, .RazorLeaf, .BodySlam } },
        .{ .species = .Charmander, .moves = &.{ .FireBlast, .FireSpin, .Slash, .Counter } },
        .{ .species = .Squirtle, .moves = &.{ .Surf, .Blizzard, .BodySlam, .Rest } },
        .{ .species = .Rattata, .moves = &.{ .SuperFang, .BodySlam, .Blizzard, .Thunderbolt } },
        .{ .species = .Pidgey, .moves = &.{ .DoubleEdge, .QuickAttack, .WingAttack, .MirrorMove } },
    };

    try run_optimal(battle, &box_pokemon);
}

test "Random" {
    print("Random\n", .{});
    var battle = tools.init_battle(&.{
        .{ .species = .Bulbasaur, .moves = &.{.BodySlam} },
    }, &.{
        .{ .species = .Pidgey, .moves = &.{.Pound} },
    });

    var prng = std.Random.DefaultPrng.init(0);
    var random = prng.random();

    var player_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    var enemy_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    var c1 = pkmn.Choice{};
    var c2 = pkmn.Choice{};
    var result = battle.update(c1, c2, &options) catch pkmn.Result{};
    while (result.type == .None) {
        const max1 = battle.choices(.P1, result.p1, &player_choices);
        const n1 = random.uintLessThan(u8, max1);
        c1 = player_choices[n1];

        const max2: u8 = @intCast(enemy_ai.pick_choice(battle, result, 0, &enemy_choices));
        const n2 = random.uintLessThan(u8, max2);
        c2 = enemy_choices[n2];

        tools.print_battle(battle, c1, c2);
        print("\n\n", .{});

        result = battle.update(c1, c2, &options) catch pkmn.Result{};
    }
    print("{}\n", .{result.type});
}

fn run_transitions(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), result: pkmn.Result) !usize {
    var player_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    var enemy_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    const player_max = battle.choices(.P1, result.p1, &player_choices);
    const player_valid_choices = player_choices[0..player_max];

    const enemy_max = enemy_ai.pick_choice(battle, result, 0, &enemy_choices);
    const enemy_valid_choices = enemy_choices[0..enemy_max];

    print("Enemy Valid Choices: {any}\n", .{enemy_valid_choices});

    var total_updates: usize = 0;
    for (player_valid_choices) |player_choice| {
        for (enemy_valid_choices) |enemy_choice| {
            tools.print_battle(battle, player_choice, enemy_choice);
            print("\n", .{});

            const updates: []builder.Update = try builder.transitions(
                battle,
                player_choice,
                enemy_choice,
                options.chance.durations,
                alloc,
            );
            defer std.testing.allocator.free(updates);
            total_updates += updates.len;

            for (updates) |update| {
                print("Actions: {}\n", .{update.actions});
                print("P1: {} {}\n", .{ update.actions.p1.hit, update.actions.p1.critical_hit });
                print("P2: {} {}\n", .{ update.actions.p2.hit, update.actions.p2.critical_hit });
                tools.battle_details(update.battle, true, false);
                print("\n", .{});
            }
            print("\n", .{});
        }
    }

    return total_updates;
}

fn run_exhaust(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), box_pokemon: []const pkmn.gen1.helpers.Pokemon) !void {
    var box = std.ArrayList(pkmn.gen1.Pokemon).init(alloc);
    defer box.deinit();
    for (box_pokemon) |mon| {
        try box.append(pkmn.gen1.helpers.Pokemon.init(mon));
    }

    var b = battle;
    const result = try b.update(pkmn.Choice{}, pkmn.Choice{}, &options);

    const root: *builder.DecisionNode = try alloc.create(builder.DecisionNode);
    root.* = .{
        .battle = b,
        .team = .{ 0, -1, -1, -1, -1, -1 },
        .result = result,
        .previous_node = null,
        .next_turns = std.ArrayList(builder.TurnChoices).init(alloc),
    };
    _ = builder.exhaustive_decision_tree(root, &box, 1, alloc) catch null;
    assert(builder.count_nodes(root) != 0);

    builder.free_tree(root, alloc);
}

fn run_optimal(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), box_pokemon: []const pkmn.gen1.helpers.Pokemon) !void {
    var box = std.ArrayList(pkmn.gen1.Pokemon).init(alloc);
    defer box.deinit();
    for (box_pokemon) |mon| {
        try box.append(pkmn.gen1.helpers.Pokemon.init(mon));
    }

    var b = battle;
    const result = try b.update(pkmn.Choice{}, pkmn.Choice{}, &options);

    const root: *builder.DecisionNode = try builder.optimal_decision_tree(b, result, &box, alloc);

    const num_of_nodes = builder.count_nodes(root);
    print("Num Of Nodes: {}\n", .{num_of_nodes});

    builder.free_tree(root, alloc);
}
