const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var filename_alloc = gpa.allocator();

pub fn build(b: *std.Build) !void {
    const wasm = b.option(bool, "wasm", "Enable WASM compilation") orelse false;
    const test_filters = b.option([]const []const u8, "test-filters", "Skip tests that do not match any filter") orelse &[0][]const u8{};
    const generation = b.option([]const u8, "generation", "Specify which generation") orelse "gen1";
    const showdown = b.option(bool, "showdown", "Enable Pokémon Showdown compatibility mode") orelse false;
    const log = b.option(bool, "log", "Enable protocol message logging") orelse false;

    const default_target = b.standardTargetOptions(.{});

    const main_source = try std.fmt.allocPrint(filename_alloc, "src/{s}/wasm_runners.zig", .{generation});
    defer filename_alloc.free(main_source);
    const main = b.addExecutable(.{
        .name = generation,
        .root_source_file = b.path(main_source),
        .optimize = .Debug,
        .target = if (wasm) b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .wasi }) else default_target,
    });

    const test_name = try std.fmt.allocPrint(filename_alloc, "{s}_tests", .{generation});
    const test_source = try std.fmt.allocPrint(filename_alloc, "src/{s}/tests.zig", .{generation});
    defer filename_alloc.free(test_name);
    defer filename_alloc.free(test_source);
    const tests = b.addTest(.{
        .name = test_name,
        .root_source_file = b.path(test_source),
        .filters = test_filters,
    });

    if (wasm) {
        main.rdynamic = true;
        main.entry = .disabled;
    }

    // @pkmn/engine
    const pkmn = b.dependency("pkmn", .{ .showdown = showdown, .log = log, .chance = true, .calc = true });
    main.root_module.addImport("pkmn", pkmn.module("pkmn"));
    tests.root_module.addImport("pkmn", pkmn.module("pkmn"));

    b.installArtifact(main);
    b.installArtifact(tests);

    const main_step = b.step("run", "Run main() in wasm_runners");
    const tests_step = b.step("test", "Run tests.zig");

    const run_main = b.addRunArtifact(main);
    const run_tests = b.addRunArtifact(tests);
    run_tests.has_side_effects = true;

    main_step.dependOn(&run_main.step);
    tests_step.dependOn(&run_tests.step);
}
