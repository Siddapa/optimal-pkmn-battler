const std = @import("std");
const print = std.debug.print;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const pkmn = @import("pkmn");

const builder = @import("tree");
const enemy_ai = builder.enemy_ai;
const tools = builder.tools;

fn generate_battles(data_fn: []const u8) !void {
    const alloc = gpa.allocator();

    // Fetch file and setup close
    const cwd = std.fs.cwd();
    var test_file: std.fs.File = try cwd.createFile(data_fn, .{});
    defer test_file.close();

    // Generator wrtiers from file descriptors
    const dataout = test_file.writer();
    const stdout = std.io.getStdOut().writer();

    // High Entropy randomness from program timestamp
    var rng = pkmn.PSRNG.init(@as(u64, @bitCast(std.time.milliTimestamp())));

    var chance = pkmn.gen1.Chance(pkmn.Rational(u128)){ .probability = .{} };
    var calc = pkmn.gen1.Calc{};
    const options = pkmn.battle.options(
        pkmn.protocol.NULL,
        &chance,
        &calc,
    );

    var battle = pkmn.gen1.helpers.Battle.random(
        &rng,
        .{ .cleric = false, .block = false },
    );
    const result = try battle.update(pkmn.Choice{}, pkmn.Choice{}, &options);

    // Write and print inital battle state
    try dataout.writeStruct(battle);
    try tools.battle_details(battle, tools.DetailOptions.all(), stdout);

    // Copy of transitions progression in exhaust_decision_tree() from builder.zig
    var player_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    var enemy_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    const player_max = battle.choices(.P1, result.p1, &player_choices);
    const player_valid_choices = player_choices[0..player_max];

    const enemy_max = builder.enemy_ai.pick_choice(battle, result, 0, &enemy_choices);
    const enemy_valid_choices = enemy_choices[0..enemy_max];

    for (enemy_valid_choices) |enemy_choice| {
        for (player_valid_choices) |player_choice| {
            const new_updates = try builder.transitions(battle, player_choice, enemy_choice, options.chance.durations, alloc);
            for (new_updates) |new_update| {
                try dataout.writeStruct(new_update.battle);
            }

            alloc.free(new_updates);
        }
    }
}

fn read_battles(data_fn: []const u8) !void {
    const cwd = std.fs.cwd();
    var test_file: std.fs.File = try cwd.openFile(data_fn, .{});
    defer test_file.close();

    const datain = test_file.reader();
    const stdout = std.io.getStdOut().writer();

    const battle = try datain.readStruct(pkmn.gen1.Battle(pkmn.gen1.PRNG));
    const battle2 = try datain.readStruct(pkmn.gen1.Battle(pkmn.gen1.PRNG));

    try tools.battle_details(battle, tools.DetailOptions.all(), stdout);
    try tools.battle_details(battle2, tools.DetailOptions.all(), stdout);
}

pub fn main() !void {
    const args = std.os.argv;
    if (args.len == 1) {
        print("Provide a path for where training data is stored!\n", .{});
        return;
    }

    const data_fn = std.mem.span(args[1]);

    try generate_battles(data_fn);
    try read_battles(data_fn);
}
