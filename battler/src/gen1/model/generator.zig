const std = @import("std");
const assert = std.debug.assert;

const pkmn = @import("pkmn");
const builder = @import("tree");
const tools = builder.tools;

fn generate_battles(data_file: std.fs.File, seed: u64, sample_size: u16, alloc: std.mem.Allocator) !void {
    var rng = pkmn.PSRNG.init(seed);

    // Fetch file and setup close;
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

    var init_battle = pkmn.gen1.helpers.Battle.random(
        &rng,
        .{ .cleric = false, .block = false },
    );
    const init_result = try init_battle.update(pkmn.Choice{}, pkmn.Choice{}, &options);

    // Write inital battle state
    try dataout.writeStruct(init_battle);

    const init_node: *builder.DecisionNode = try alloc.create(builder.DecisionNode);
    init_node.* = .{
        .battle = init_battle,
        .team = .{ .Lead, .Empty, .Empty, .Empty, .Empty, .Empty }, // Technically should represent random team but irrelevant
        .result = init_result,
        .prev_node = null,
        .transitions = std.ArrayList(builder.Transition).init(alloc),
    };
    var empty_box = std.ArrayList(pkmn.gen1.Pokemon).init(alloc);
    defer empty_box.deinit();

    builder.exhaustive_decision_tree(init_node, &empty_box, 0, alloc);

    var i: u16 = 0;
    const total_transitions: usize = init_node.transitions.items.len;
    assert(total_transitions > 0);

    while (i < sample_size) : (i += 1) {
        const index = rng.range(usize, 0, total_transitions - 1);
        const transition = init_node.transitions.items[index];
        const chosen_battle = transition.next_node.battle;

        try tools.side_details(init_battle.side(.P1), tools.DetailOptions.no_moves(), stdout);
        try tools.move_details(&init_battle.side(.P1).active, transition.choices[0], stdout);
        try stdout.writeAll("\n");

        try tools.side_details(init_battle.side(.P2), tools.DetailOptions.no_moves(), stdout);
        try tools.move_details(&init_battle.side(.P2).active, transition.choices[1], stdout);
        try stdout.writeAll("\n\n");

        try stdout.print("{}\n", .{transition.actions});
        try stdout.writeAll("\n");

        try tools.battle_details(chosen_battle, tools.DetailOptions.no_moves(), stdout);
        try stdout.writeAll("\n\n");

        try stdout.writeAll("Score: ");

        var input_buf: [4]u8 = undefined;
        if (try stdin.readUntilDelimiterOrEof(input_buf[0..], '\n')) |input| {
            const score = try std.fmt.parseInt(u16, input, 10);

            try dataout.writeStruct(transition.choices[0]);
            try dataout.writeStruct(transition.choices[1]);
            try dataout.writeStruct(transition.actions);
            try dataout.writeStruct(transition.durations);
            try dataout.writeStruct(chosen_battle);
            try dataout.print("{}\n", .{score});

            try stdout.writeAll("-" ** 100);
            try stdout.writeAll("\n\n");
        } else {
            try stdout.writeAll("Failed to Read Score!");
        }
    }

    try stdout.print("Total Updates: {}\n", .{total_transitions});
}

fn parse_training_data(dir: std.fs.Dir, alloc: std.mem.Allocator) !void {
    var walker = try dir.walk(alloc);
    defer walker.deinit();

    const stdout = std.io.getStdOut().writer();

    while (try walker.next()) |file| {
        try stdout.print("{s}\n", .{file.basename});
        try read_battles(dir, file.basename);
    }
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

pub fn main() !void {
    var da: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const alloc = da.allocator();

    const args = std.os.argv;
    assert(args.len == 2);

    const input = args[1];
    const sample_size = try std.fmt.parseInt(u16, std.mem.span(input), 10);

    // High Entropy randomness from program timestamp
    const curr_time = @as(u64, @bitCast(std.time.milliTimestamp()));

    // Create a file with the name being the RNG seed
    const training_data = try std.fs.cwd().openDir("training_data/", .{});
    const data_fn = try std.fmt.allocPrint(alloc, "{}.txt", .{curr_time});
    const data_file: std.fs.File = try training_data.createFile(data_fn, .{});

    try generate_battles(data_file, curr_time, sample_size, alloc);

    // If program doesn't error or get interrupted, copy to a safe directory
    const good_dir = try training_data.openDir("good_data/", .{});
    try std.fs.Dir.copyFile(training_data, data_fn, good_dir, data_fn, .{});
}
