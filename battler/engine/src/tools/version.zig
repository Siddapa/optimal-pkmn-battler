const builtin = @import("builtin");
const std = @import("std");

pub fn main() !void {
    const version = try std.SemanticVersion.parse("0.12.0-dev.2036+fc79b22a9");
    const modern = builtin.zig_version.order(version) != .lt;
    try std.io.getStdOut().writer().writeAll(if (modern) "modern" else "legacy");
}
