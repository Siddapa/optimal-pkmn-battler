const std = @import("std");

const expectEqual = std.testing.expectEqual;
const assert = std.debug.assert;

const Int = if (@hasField(std.builtin.Type, "int")) .int else .Int;
const Enum = if (@hasField(std.builtin.Type, "enum")) .@"enum" else .Enum;

/// Helpers for working with bit-packed arrays of non-powers-of-2 types.
/// NOTE: ziglang/zig#12547
pub fn Array(comptime n: comptime_int, comptime U: type) type {
    return struct {
        const size = @bitSizeOf(U);
        const options: std.builtin.Type.Int = .{ .signedness = .unsigned, .bits = size * n };
        pub const T = @Type(if (@hasField(std.builtin.Type, "int"))
            .{ .int = options }
        else
            .{ .Int = options });

        /// Returns the value stored at index `i` in the array `a`.
        pub fn get(a: T, i: usize) U {
            assert(i < n);
            const shift = i * size;
            const mask: T = (1 << size) - 1;
            const result = (a >> @intCast(shift)) & mask;
            return switch (@typeInfo(U)) {
                Enum => @enumFromInt(result),
                Int => @intCast(result),
                else => unreachable,
            };
        }

        /// Sets the value at index `i` to `val` in the array `a`.
        pub fn set(a: T, i: usize, val: U) T {
            assert(i < n);
            const v: T = switch (@typeInfo(U)) {
                Enum => @intFromEnum(val),
                Int => @intCast(val),
                else => unreachable,
            };
            const shift = i * size;
            const mask: T = @as(T, @intCast((1 << size) - 1)) << @intCast(shift);
            const result: T = a & ~mask;
            return result | (v << @intCast(shift));
        }
    };
}

test Array {
    const A = Array(5, u8);
    var a: A.T = 0;
    try expectEqual(u40, @TypeOf(a));

    a = A.set(a, 4, 241);
    try expectEqual(@as(u8, 241), A.get(a, 4));
    a = A.set(a, 4, 1);
    try expectEqual(@as(u8, 1), A.get(a, 4));

    for (0..5) |i| a = A.set(a, i, @intCast(i));
    for (0..5) |i| try expectEqual(@as(u8, @intCast(i)), A.get(a, i));

    const Optional = @import("optional.zig").Optional;

    const B = Array(4, Optional(bool));
    var b: B.T = 0;
    try expectEqual(u8, @TypeOf(b));

    b = B.set(b, 2, .true);
    try expectEqual(Optional(bool).None, B.get(b, 1));
    try expectEqual(Optional(bool).true, B.get(b, 2));
    try expectEqual(@as(u8, 0b00100000), b);
    b = B.set(b, 2, .None);
    b = B.set(b, 0, .false);
    try expectEqual(Optional(bool).None, B.get(b, 2));
    try expectEqual(Optional(bool).false, B.get(b, 0));
    try expectEqual(@as(u8, 0b0000001), b);
}
