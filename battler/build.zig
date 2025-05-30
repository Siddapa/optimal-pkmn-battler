const std = @import("std");
var da: std.heap.DebugAllocator(.{}) = .init;
var alloc = da.allocator();

pub fn build(b: *std.Build) !void {
    const generation = b.option([]const u8, "generation", "Specify which generation") orelse "gen1";
    // const test_filters = b.option([]const []const u8, "test-filters", "Skip tests that do not match any filter") orelse &[0][]const u8{};

    const default_options = b.standardTargetOptions(.{});

    const wasm_source = try std.fmt.allocPrint(alloc, "src/{s}/wasm/exports.zig", .{generation});
    defer alloc.free(wasm_source);
    const wasm = b.addExecutable(.{
        .name = generation,
        .root_source_file = b.path(wasm_source),
        .optimize = .ReleaseFast,
        .target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .wasi }),
    });
    wasm.rdynamic = true;
    wasm.entry = .disabled;

    const tests_name = try std.fmt.allocPrint(alloc, "{s}_tests", .{generation});
    const tests_source = try std.fmt.allocPrint(alloc, "src/{s}/tests.zig", .{generation});
    defer alloc.free(tests_name);
    defer alloc.free(tests_source);
    const tests = b.addExecutable(.{
        .name = tests_name,
        .root_source_file = b.path(tests_source),
        .optimize = .Debug,
        .target = default_options,
    });

    const pkmn = b.dependency("pkmn", .{ .showdown = false, .log = false, .chance = true, .calc = true });
    wasm.root_module.addImport("pkmn", pkmn.module("pkmn"));
    tests.root_module.addImport("pkmn", pkmn.module("pkmn"));

    const tree_source = try std.fmt.allocPrint(alloc, "src/{s}/tree/builder.zig", .{generation});
    defer alloc.free(tree_source);
    const tree_import = [1]std.Build.Module.Import{.{ .name = "pkmn", .module = pkmn.module("pkmn") }};
    wasm.root_module.addAnonymousImport("builder", .{
        .root_source_file = b.path(tree_source),
        .imports = &tree_import,
    });
    tests.root_module.addAnonymousImport("builder", .{
        .root_source_file = b.path(tree_source),
        .imports = &tree_import,
    });

    b.installArtifact(wasm);
    b.installArtifact(tests);

    const tests_step = b.step("test", "Run tests.zig");

    const run_tests = b.addRunArtifact(tests);
    run_tests.has_side_effects = true;

    tests_step.dependOn(&run_tests.step);
}
