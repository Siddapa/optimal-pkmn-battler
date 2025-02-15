const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const pkmn = @import("pkmn");

const builder = @import("tree");
const enemy_ai = builder.enemy_ai;
const tools = builder.tools;

const regressor = @import("regressor.zig");
const import = @import("import.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const stdout = std.io.getStdOut().writer();

    const args = std.os.argv;
    if (args.len < 2) {
        try stdout.writeAll("Learning rate not specified!\n");
        return;
    }
    if (args.len < 3) {
        try stdout.writeAll("Training data percentage not specified!\n");
        return;
    }
    const lr_input = args[1];
    const ds_input = args[2];

    const learning_rate = try std.fmt.parseFloat(regressor.ftype, std.mem.span(lr_input));
    const threshold: regressor.ftype = 0.001;
    // Thetas will start with no influence on data
    var thetas = [_]regressor.ftype{5} ** (regressor.k);

    // Create an walkable directory to access valid training_data
    var dir = try std.fs.cwd().openDir(
        "training_data/good_data/",
        .{ .iterate = true },
    );
    defer dir.close();

    var features: []regressor.TransitionFeatures, const scores: []regressor.ftype = try import.collect_training_data(dir, alloc);
    defer alloc.free(features);
    defer alloc.free(scores);

    const m: usize = features.len;
    try stdout.print("# of Features: {}\n\n", .{m});

    const dataset_split = try std.fmt.parseFloat(regressor.ftype, std.mem.span(ds_input));
    const float_of_m = @as(regressor.ftype, @floatFromInt(m));
    const split_index: usize = @intFromFloat(dataset_split * float_of_m);

    var training_features = features[0..split_index];
    const training_scores = scores[0..split_index];
    const testing_features = features[split_index..];
    const testing_scores = scores[split_index..];
    assert((training_features.len + testing_features.len) == m);
    assert((training_scores.len + testing_scores.len) == m);

    try regressor.normalize(&training_features, alloc);

    var cost_diff: regressor.ftype = try regressor.calc_cost(training_features, training_scores, thetas, alloc);
    var i: u32 = 0;
    while (cost_diff >= threshold) : (i += 1) {
        const inital_cost: regressor.ftype = try regressor.calc_cost(training_features, training_scores, thetas, alloc);

        const new_thetas: [regressor.k]regressor.ftype = try regressor.update_thetas(training_features, training_scores, thetas, learning_rate, alloc);
        @memcpy(&thetas, &new_thetas);

        const new_cost: regressor.ftype = try regressor.calc_cost(training_features, training_scores, thetas, alloc);

        cost_diff = inital_cost - new_cost;

        try stdout.print("Iteration: #{}\n", .{i});
        try stdout.print("Prior Cost: {d}\n", .{inital_cost});
        try stdout.print("Calculated Cost: {d}\n", .{new_cost});
        try stdout.print("Cost Diff: {d}\n", .{cost_diff});
        try stdout.writeAll("\n");
    }
    try stdout.writeAll("\n");

    const testing_predictions: []regressor.ftype = try regressor.predict(testing_features, thetas, alloc);

    for (testing_predictions, 0..) |prediction, j| {
        try stdout.print("Testing Case #{}\n", .{j});
        try stdout.print("Actual Score: {d}\n", .{testing_scores[j]});
        try stdout.print("Predcited Score: {d}\n", .{prediction});
        try stdout.writeAll("\n");
    }
}
