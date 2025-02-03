const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();

pub fn build(b: *std.Build) !void {
    const test_filters = b.option([]const []const u8, "test-filters", "Skip tests that do not match any filter") orelse &[0][]const u8{};
    const generation = b.option([]const u8, "generation", "Specify which generation") orelse "gen1";

    const default_options = b.standardTargetOptions(.{});

    const wasm = b.addExecutable(.{
        .name = generation,
        .root_source_file = b.path(try std.fmt.allocPrint(alloc, "src/{s}/wasm_runners.zig", .{generation})),
        .optimize = .Debug,
        .target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .wasi }),
    });
    wasm.rdynamic = true;
    wasm.entry = .disabled;

    const train = b.addExecutable(.{
        .name = try std.fmt.allocPrint(alloc, "{s}_train", .{generation}),
        .root_source_file = b.path(try std.fmt.allocPrint(alloc, "src/{s}/model/train.zig", .{generation})),
        .optimize = .Debug,
        .target = default_options,
    });

    const tests = b.addTest(.{
        .name = try std.fmt.allocPrint(alloc, "{s}_tests", .{generation}),
        .root_source_file = b.path(try std.fmt.allocPrint(alloc, "src/{s}/tree/tests.zig", .{generation})),
        .filters = test_filters,
    });

    // Modules
    const pkmn = b.dependency("pkmn", .{ .showdown = false, .log = false, .chance = true, .calc = true });
    wasm.root_module.addImport("pkmn", pkmn.module("pkmn"));
    train.root_module.addImport("pkmn", pkmn.module("pkmn"));
    tests.root_module.addImport("pkmn", pkmn.module("pkmn"));

    b.installArtifact(wasm);
    b.installArtifact(train);
    b.installArtifact(tests);

    const train_step = b.step("train", "Run train.zig");
    const tests_step = b.step("test", "Run tests.zig");

    const run_train = b.addRunArtifact(train);
    const run_tests = b.addRunArtifact(tests);
    run_tests.has_side_effects = true;

    train_step.dependOn(&run_train.step);
    tests_step.dependOn(&run_tests.step);
}
