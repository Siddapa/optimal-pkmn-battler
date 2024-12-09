const std = @import("std");

pub fn build(b: *std.Build) !void {
    const wasm = b.option(bool, "wasm", "Enable WASM compilation") orelse false;
    const generation = b.option([]const u8, "generation", "Specify which generation") orelse "gen1";
    const showdown = b.option(bool, "showdown", "Enable Pokémon Showdown compatibility mode") orelse false;
    const log = b.option(bool, "log", "Enable protocol message logging") orelse false;
    var target = b.standardTargetOptions(.{});
    if (wasm) {
        target = b.resolveTargetQuery(.{
            .cpu_arch = .wasm32,
            .os_tag = .wasi,
        });
    }

    var filename_buf = [_]u8{undefined} ** 100;
    const exe = b.addExecutable(.{
        .name = generation,
        .root_source_file = b.path(try std.fmt.bufPrint(&filename_buf, "src/{s}/main.zig", .{generation})),
        .optimize = b.standardOptimizeOption(.{}),
        .target = target,
    });
    // exe.setOutputPath(try std.fmt.bufPrint(&filename_buf, "zig-out/{s}.wasm", .{generation}));

    // @pkmn/engine dependency
    const pkmn = b.dependency("pkmn", .{ .showdown = showdown, .log = log });
    exe.root_module.addImport("pkmn", pkmn.module("pkmn"));

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
