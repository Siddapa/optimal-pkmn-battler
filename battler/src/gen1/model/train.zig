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

    const learning_rate: regressor.ftype = 0.0000005;
    const threshold: regressor.ftype = 0.1;
    // Thetas will start with no influence on data
    var thetas = [_]regressor.ftype{0} ** (regressor.k);

    const dir = try std.fs.cwd().openDir(
        "training_data/",
        .{ .iterate = true },
    );

    const features: []regressor.TransitionFeatures, const scores: []regressor.ftype = try import.collect_training_data(dir, alloc);
    defer alloc.free(features);
    defer alloc.free(scores);

    var cost_diff: regressor.ftype = try regressor.calc_cost(features, scores, thetas, alloc);
    var i: usize = 0;
    while (cost_diff >= threshold) : (i += 1) {
        const inital_cost: regressor.ftype = try regressor.calc_cost(features, scores, thetas, alloc);

        const new_thetas: [regressor.k]regressor.ftype = try regressor.update_thetas(features, scores, thetas, learning_rate, alloc);
        @memcpy(&thetas, &new_thetas);

        const new_cost: regressor.ftype = try regressor.calc_cost(features, scores, thetas, alloc);

        cost_diff = new_cost - inital_cost;

        try stdout.print("Iteration: #{}\n", .{i});
        try stdout.print("Calculated Cost: {}\n", .{new_cost});
        try stdout.print("Cost Diff: {}\n", .{cost_diff});
        try stdout.print("\n", .{});
    }
}
