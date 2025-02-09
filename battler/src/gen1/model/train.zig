const std = @import("std");
const print = std.debug.print;

const pkmn = @import("pkmn");

const builder = @import("tree");
const enemy_ai = builder.enemy_ai;
const tools = builder.tools;

fn generate_battles(sample_size: u16, alloc: std.mem.Allocator) !void {

    // High Entropy randomness from program timestamp
    const curr_time = @as(u64, @bitCast(std.time.milliTimestamp()));
    var rng = pkmn.PSRNG.init(curr_time);

    // Fetch file and setup close
    const cwd = std.fs.cwd();
    const data_fn = try std.fmt.allocPrint(alloc, "training_data/{}.txt", .{curr_time});
    var data_file: std.fs.File = try cwd.createFile(data_fn, .{});
    defer alloc.free(data_fn);
    defer data_file.close();

    // Generator wrtiers from file descriptors
    const dataout = data_file.writer();
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

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

    // Write inital battle state
    try dataout.writeStruct(battle);

    // Copy of transitions progression in exhaust_decision_tree() from builder.zig
    var player_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;
    var enemy_choices: [pkmn.CHOICES_SIZE]pkmn.Choice = undefined;

    const player_max = battle.choices(.P1, result.p1, &player_choices);
    const player_valid_choices = player_choices[0..player_max];

    const enemy_max = builder.enemy_ai.pick_choice(battle, result, 0, &enemy_choices);
    const enemy_valid_choices = enemy_choices[0..enemy_max];

    var total_updates = std.ArrayList(pkmn.gen1.Battle(pkmn.gen1.PRNG)).init(alloc);
    defer total_updates.deinit();

    for (enemy_valid_choices) |enemy_choice| {
        for (player_valid_choices) |player_choice| {
            const new_updates = try builder.transitions(battle, player_choice, enemy_choice, options.chance.durations, alloc);
            for (new_updates) |new_update| {
                try total_updates.append(new_update.battle);
            }

            alloc.free(new_updates);
        }
    }

    var i: u16 = 0;
    const total_updates_len: usize = total_updates.items.len;
    while (i < sample_size) : (i += 1) {
        const index = rng.range(usize, 0, total_updates_len - 1);
        const chosen_transition = total_updates.items[index];

        try tools.battle_details(battle, tools.DetailOptions.all(), stdout);
        try tools.battle_details(chosen_transition, tools.DetailOptions.all(), stdout);
        try stdout.writeAll("Score: ");

        var input_buf: [4]u8 = undefined;
        if (try stdin.readUntilDelimiterOrEof(input_buf[0..], '\n')) |input| {
            const score = try std.fmt.parseInt(u16, input, 10);

            try dataout.writeStruct(chosen_transition);
            try dataout.print("{}\n", .{score});
            try stdout.writeAll("-" ** 100);
            try stdout.writeAll("\n\n");
        } else {
            try stdout.writeAll("Failed to Read Score!");
        }
    }

    try stdout.print("Total Updates: {}\n", .{total_updates_len});
}

fn read_battles(dir: std.fs.Dir, data_fn: []const u8) !void {
    var data_file: std.fs.File = try dir.openFile(data_fn, .{});
    defer data_file.close();

    const datain = data_file.reader();
    const stdout = std.io.getStdOut().writer();

    const battle = try datain.readStruct(pkmn.gen1.Battle(pkmn.gen1.PRNG));
    try tools.battle_details(battle, tools.DetailOptions.all(), stdout);

    var input_buf: [4]u8 = undefined;
    while (datain.readStruct(pkmn.gen1.Battle(pkmn.gen1.PRNG))) |transition| {
        if (try datain.readUntilDelimiterOrEof(input_buf[0..], '\n')) |input| {
            const score = try std.fmt.parseInt(u16, input, 10);

            try tools.battle_details(battle, tools.DetailOptions.all(), stdout);
            try tools.battle_details(transition, tools.DetailOptions.all(), stdout);
            try stdout.print("Score: {}\n", .{score});
        }
    } else |err| {
        try stdout.print("EOF: {any}\n", .{err});
        return;
    }
}

fn parse_training_data(alloc: std.mem.Allocator) !void {
    const dir = try std.fs.cwd().openDir(
        "training_data/",
        .{ .iterate = true },
    );

    var walker = try dir.walk(alloc);
    defer walker.deinit();

    while (try walker.next()) |file| {
        print("{s}\n", .{file.basename});
        try read_battles(dir, file.basename);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    try generate_battles(3, alloc);

    try parse_training_data(alloc);
}
