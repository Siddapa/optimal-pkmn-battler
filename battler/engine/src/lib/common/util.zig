const std = @import("std");

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

const Pointer = if (@hasField(std.builtin.Type, "pointer")) .pointer else .Pointer;

pub fn PointerType(comptime P: type, comptime C: type) type {
    return if (@field(@typeInfo(P), @tagName(Pointer)).is_const) *const C else *C;
}

test PointerType {
    try expectEqual(*bool, PointerType(*u8, bool));
    try expectEqual(*const f64, PointerType(*const i32, f64));
}

pub fn isPointerTo(p: anytype, comptime P: type) bool {
    const info = @typeInfo(@TypeOf(p));
    return switch (info) {
        Pointer => @field(info, @tagName(Pointer)).child == P,
        else => false,
    };
}

test isPointerTo {
    const S = struct {};
    const s: S = .{};
    try expect(!isPointerTo(s, S));
    try expect(isPointerTo(&s, S));
}

// NOTE: std.mem.bytesAsValue backported from ziglang/zig#18061
pub fn bytesAsValue(comptime T: type, bytes: anytype) BytesAsValueReturnType(T, @TypeOf(bytes)) {
    return @as(BytesAsValueReturnType(T, @TypeOf(bytes)), @ptrCast(bytes));
}

fn BytesAsValueReturnType(comptime T: type, comptime B: type) type {
    return CopyPtrAttrs(B, .One, T);
}

fn CopyPtrAttrs(
    comptime source: type,
    comptime size: std.builtin.Type.Pointer.Size,
    comptime child: type,
) type {
    const info = @field(@typeInfo(source), @tagName(Pointer));
    const args: std.builtin.Type.Pointer = .{
        .size = size,
        .is_const = info.is_const,
        .is_volatile = info.is_volatile,
        .is_allowzero = info.is_allowzero,
        .alignment = info.alignment,
        .address_space = info.address_space,
        .child = child,
        .sentinel = null,
    };
    return @Type(if (@hasField(std.builtin.Type, "pointer"))
        .{ .pointer = args }
    else
        .{ .Pointer = args });
}
