const std = @import("std");
const assert = std.debug.assert;
var da: std.heap.DebugAllocator(.{}) = .init;
var alloc = da.allocator();

const pkmn = @import("pkmn");

const builder = @import("tree");
const enemy_ai = builder.enemy_ai;
const tools = builder.tools;

var stdout = std.io.getStdOut().writer();

var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
var options = pkmn.battle.options(
    pkmn.protocol.NULL,
    &chance,
    pkmn.gen1.Calc{},
);

pub fn main() !void {
    try optimalWASM();
    try optimal1();
    // try exhaust();
    // try exhaust1();
    // try exhaust2();
}

fn base_transitions() !void {
    try stdout.print("Transitions\n", .{});

    var battle = builder.tools.init_battle(&.{
        .{ .species = .Bulbasaur, .moves = &.{ .Flamethrower, .Growl, .PoisonPowder, .Reflect } },
        .{ .species = .Goldeen, .moves = &.{ .RazorLeaf, .SolarBeam, .PoisonPowder, .FireSpin } },
    }, &.{
        .{ .species = .Jynx, .moves = &.{ .IceBeam, .HyperBeam, .Blizzard, .Peck } },
        .{ .species = .Rhyhorn, .moves = &.{ .Thunderbolt, .Mist, .WaterGun, .Psybeam } },
    });

    const result = battle.update(pkmn.Choice{}, pkmn.Choice{}, &options) catch pkmn.Result{};

    try run_transitions(battle, result);
}

fn enemy_switch_transitions() !void {
    try stdout.print("EnemySwitchTransitions\n", .{});

    var battle = builder.tools.init_battle(&.{
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

    try builder.tools.battle_details(battle, builder.tools.DetailOptions.all(), stdout);

    try run_transitions(battle, result);
}

fn box_switch_transitions() !void {
    try stdout.print("BoxSwitchTransitions\n", .{});

    var battle = builder.tools.init_battle(&.{
        .{ .species = .Articuno, .moves = &.{ .Flamethrower, .Growl, .PoisonPowder, .Reflect } },
    }, &.{
        .{ .species = .Jynx, .moves = &.{ .AuroraBeam, .Flamethrower, .Blizzard, .Peck } },
        .{ .species = .Rhyhorn, .moves = &.{ .Thunderbolt, .Mist, .WaterGun, .Psybeam } },
    });

    const result = try battle.update(pkmn.Choice{}, pkmn.Choice{}, &options);

    const switch_mon = pkmn.gen1.helpers.Pokemon.init(.{ .species = .Goldeen, .moves = &.{ .RazorLeaf, .SolarBeam, .PoisonPowder, .FireSpin } });
    _ = builder.add_to_team(&battle, switch_mon, 2);

    try run_transitions(battle, result);
}

fn exhaust() !void {
    const random_setup = try random_battle(@as(u64, @bitCast(std.time.milliTimestamp())));
    const runtime = try run_exhaust(random_setup.battle, random_setup.box);
    try stdout.print("Exhaust1: {d} ms\n\n", .{runtime});
}

fn exhaust1() !void {
    const battle = builder.tools.init_battle(&.{
        .{ .species = .Pikachu, .moves = &.{ .Thunderbolt, .ThunderWave, .Surf, .SeismicToss } },
    }, &.{
        .{ .species = .Pidgey, .moves = &.{ .Pound, .QuickAttack } },
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

    var box = std.ArrayList(pkmn.gen1.Pokemon).init(alloc);
    defer box.deinit();
    for (box_pokemon) |mon| {
        try box.append(pkmn.gen1.helpers.Pokemon.init(mon));
    }

    const runtime = try run_exhaust(battle, box);

    try stdout.print("Exhaust1: {d} ms\n\n", .{runtime});
}

fn exhaust2() !void {
    const battle = builder.tools.init_battle(&.{
        .{ .species = .Articuno, .moves = &.{ .IceBeam, .Growl, .Tackle, .Wrap } },
    }, &.{
        .{ .species = .Jynx, .moves = &.{ .AuroraBeam, .HyperBeam, .DrillPeck, .Peck } },
        .{ .species = .Chansey, .moves = &.{ .Counter, .SeismicToss, .Strength, .Absorb } },
        .{ .species = .Goldeen, .moves = &.{ .RazorLeaf, .SolarBeam, .PoisonPowder, .FireSpin } },
    });

    const box_pokemon = [_]pkmn.gen1.helpers.Pokemon{
        .{ .species = .Kingler, .moves = &.{ .SandAttack, .Headbutt, .HornAttack, .TailWhip } },
        .{ .species = .Rhyhorn, .moves = &.{ .RockThrow, .Mist, .WaterGun, .Psybeam } },
    };

    var box = std.ArrayList(pkmn.gen1.Pokemon).init(alloc);
    defer box.deinit();
    for (box_pokemon) |mon| {
        try box.append(pkmn.gen1.helpers.Pokemon.init(mon));
    }

    const runtime = try run_exhaust(battle, box);

    try stdout.print("Exhaust2: {d} ms\n\n", .{runtime});
}

fn optimalWASM() !void {
    const battle = builder.tools.init_battle(&.{
        .{ .species = .Articuno, .moves = &.{ .IceBeam, .Growl, .Tackle, .Wrap } },
    }, &.{
        .{ .species = .Jynx, .moves = &.{ .AuroraBeam, .HyperBeam, .DrillPeck, .Peck } },
        .{ .species = .Chansey, .moves = &.{ .Counter, .SeismicToss, .Strength, .Absorb } },
        .{ .species = .Goldeen, .moves = &.{ .RazorLeaf, .SolarBeam, .PoisonPowder, .FireSpin } },
    });

    const box_pokemon = [_]pkmn.gen1.helpers.Pokemon{
        .{ .species = .Kingler, .moves = &.{ .SandAttack, .Headbutt, .HornAttack, .TailWhip } },
        .{ .species = .Rhyhorn, .moves = &.{ .RockThrow, .Mist, .WaterGun, .Psybeam } },
    };

    const runtime = try run_optimal(battle, &box_pokemon);

    try stdout.print("OptimalWASM: {d} ms\n", .{runtime});
}

fn optimal1() !void {
    const battle = builder.tools.init_battle(&.{
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

    const runtime = try run_optimal(battle, &box_pokemon);

    try stdout.print("Optimal1: {d} ms\n", .{runtime});
}

fn random() !void {
    try stdout.print("Random\n", .{});
    var battle = builder.tools.init_battle(&.{
        .{ .species = .Bulbasaur, .moves = &.{.BodySlam} },
    }, &.{
        .{ .species = .Pidgey, .moves = &.{.Pound} },
    });

    var prng = std.Random.DefaultPrng.init(0);
    var rand = prng.random();

    var player_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    var enemy_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    var c1 = pkmn.Choice{};
    var c2 = pkmn.Choice{};
    var result = battle.update(c1, c2, &options) catch pkmn.Result{};
    while (result.type == .None) {
        const max1 = battle.choices(.P1, result.p1, &player_choices);
        const n1 = rand.uintLessThan(u8, max1);
        c1 = player_choices[n1];

        const max2: u8 = @intCast(enemy_ai.pick_choice(battle, result, 0, &enemy_choices));
        const n2 = rand.uintLessThan(u8, max2);
        c2 = enemy_choices[n2];

        try builder.tools.battle_details(battle, builder.tools.DetailOptions.all(), stdout);
        // TODO Also display transition
        try stdout.print("\n\n", .{});

        result = battle.update(c1, c2, &options) catch pkmn.Result{};
    }
    try stdout.print("{}\n", .{result.type});
}

fn run_transitions(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), result: pkmn.Result) !void {
    var player_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    var enemy_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    const player_max = battle.choices(.P1, result.p1, &player_choices);
    const player_valid_choices = player_choices[0..player_max];

    const enemy_max = enemy_ai.pick_choice(battle, result, 0, &enemy_choices);
    const enemy_valid_choices = enemy_choices[0..enemy_max];

    var total_updates: usize = 0;
    for (player_valid_choices) |player_choice| {
        for (enemy_valid_choices) |enemy_choice| {
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
                try stdout.print("Actions: {}\n", .{update.actions});
                try stdout.writeAll("\n");

                try builder.tools.side_details(battle.side(.P1), builder.tools.DetailOptions.no_moves(), stdout);
                if (player_choice.type == .Move) try builder.tools.move_details(battle.side(.P1).active, player_choice, stdout);
                try stdout.writeAll("\n");

                try builder.tools.side_details(battle.side(.P2), builder.tools.DetailOptions.no_moves(), stdout);
                if (enemy_choice.type == .Move) try builder.tools.move_details(battle.side(.P2).active, enemy_choice, stdout);
                try stdout.writeAll("\n");

                try builder.tools.battle_details(update.battle, builder.tools.DetailOptions.no_moves(), stdout);

                try stdout.writeAll("\n\n\n\n");
            }
            try stdout.print("\n", .{});
        }
    }

    try stdout.print("# of Updates: {}\n", .{total_updates});
    try stdout.print("Player Choices: {}\n", .{player_valid_choices.len});
    try stdout.print("Enemy Choices: {}\n", .{enemy_valid_choices.len});
}

fn random_battle(seed: u64) !struct {
    battle: pkmn.gen1.Battle(pkmn.gen1.PRNG),
    box: std.ArrayList(pkmn.gen1.Pokemon),
} {
    var rng = pkmn.PSRNG.init(seed);
    const rand_opts = pkmn.gen1.helpers.Options{
        .cleric = false,
        .block = false,
    };

    const battle = pkmn.gen1.helpers.Battle.random(&rng, rand_opts);

    var box = std.ArrayList(pkmn.gen1.Pokemon).init(alloc);
    const box_size = rng.range(usize, 1, 10);
    for (0..box_size) |_| {
        try box.append(pkmn.gen1.helpers.Pokemon.random(&rng, rand_opts));
    }

    return .{ .battle = battle, .box = box };
}

fn run_exhaust(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), box: std.ArrayList(pkmn.gen1.Pokemon)) !u128 {
    var b = battle;
    const result = try b.update(pkmn.Choice{}, pkmn.Choice{}, &options);
    var edit_box = box;

    const root: *builder.DecisionNode = try alloc.create(builder.DecisionNode);
    root.* = .{
        .battle = b,
        .team = .{ 0, -1, -1, -1, -1, -1 },
        .result = result,
        .previous_node = null,
        .transitions = std.ArrayList(builder.Transition).init(alloc),
    };

    const start_time = @as(u64, @bitCast(std.time.milliTimestamp()));

    try builder.exhaustive_decision_tree(root, &edit_box, 0, alloc);

    const end_time = @as(u64, @bitCast(std.time.milliTimestamp()));

    try tools.battle_details(b, tools.DetailOptions.all(), stdout);
    try stdout.writeAll("\n");

    try stdout.writeAll("Score Sorted\n");
    std.mem.sort(builder.Transition, root.transitions.items, {}, compare_score);
    for (root.transitions.items) |transition| {
        try tools.display_choice(root, transition, 0, stdout);
        try tools.hp_details(transition.next_node.battle.side(.P1).stored(), stdout);
        try stdout.writeAll(" | ");

        try tools.display_choice(root, transition, 1, stdout);
        try tools.hp_details(transition.next_node.battle.side(.P2).stored(), stdout);
        try stdout.writeAll(" | ");

        try stdout.print("{d:10.2} {d:.8} {s: <100} {s: <100}\n", .{
            transition.next_node.score,
            transition.next_node.probability,
            transition.actions.p1,
            transition.actions.p2,
        });

        try stdout.writeAll("----------------------------------------------------------------------------------------\n");
    }

    // try stdout.writeAll("\nProbability Sorted\n");

    // std.mem.sort(builder.Transition, root.transitions.items, {}, compare_prob);
    // for (root.transitions.items) |transition| {
    //     try tools.display_choice(root, transition, 0, stdout);
    //     try tools.display_choice(root, transition, 1, stdout);
    //     try stdout.print("{d:10.2} {d:.8} {s:100} {s:100}\n", .{
    //         transition.next_node.score,
    //         transition.next_node.probability,
    //         transition.actions.p1,
    //         transition.actions.p2,
    //     });
    // }

    builder.free_tree(root, alloc);

    return end_time - start_time;
}

fn compare_score(_: void, t1: builder.Transition, t2: builder.Transition) bool {
    if (t1.next_node.score > t2.next_node.score) {
        return true;
    }
    return false;
}

fn compare_prob(_: void, t1: builder.Transition, t2: builder.Transition) bool {
    if (t1.next_node.probability > t2.next_node.probability) {
        return true;
    }
    return false;
}

fn run_optimal(battle: pkmn.gen1.Battle(pkmn.gen1.PRNG), box_pokemon: []const pkmn.gen1.helpers.Pokemon) !u64 {
    var box = std.ArrayList(pkmn.gen1.Pokemon).init(alloc);
    defer box.deinit();
    for (box_pokemon) |mon| {
        try box.append(pkmn.gen1.helpers.Pokemon.init(mon));
    }

    var b = battle;
    const result = try b.update(pkmn.Choice{}, pkmn.Choice{}, &options);

    const start_time = @as(u64, @bitCast(std.time.milliTimestamp()));

    const imm_box: []const pkmn.gen1.Pokemon = box.items;
    const root: *builder.DecisionNode = try builder.optimal_decision_tree(b, result, imm_box, alloc);

    const end_time = @as(u64, @bitCast(std.time.milliTimestamp()));

    try builder.tools.traverse_decision_tree(root, stdout);

    const num_of_nodes = builder.count_nodes(root);
    try stdout.print("Num Of Nodes: {}\n", .{num_of_nodes});

    builder.free_tree(root, alloc);

    return end_time - start_time;
}
