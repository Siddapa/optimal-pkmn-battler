const std = @import("std");
const print = std.debug.print;

const Errors = @import("errors.zig").Errors;

// 0x0 is valid address as a function arguement in both Zig and JS
// however as a comptime global, Zig treats that memory location as
// special for optional pointers so ignore that address just to be safe.
// Start at 0x8 for 8 byte alignment for largest type (u64)
const buf_beg: usize = 0x8;
const wasm_buf: [*]u8 = @ptrFromInt(buf_beg);
const wasm_buf_i8: [*]i8 = @ptrFromInt(buf_beg);

const tag_t = i8;

pub const WASM_t = enum(u8) {
    Int32 = 1,
    Uint32 = 2,
    string = 3,
    Int32Array = 4,
    Uint32Array = 5,
};

pub const WASMArg = union(WASM_t) {
    Int32: i32,
    Uint32: u32,
    string: []const u8,
    Int32Array: []const i32,
    Uint32Array: []const u32,
};

pub fn load(
    args: []WASMArg,
    types: []const WASM_t,
    alloc: std.mem.Allocator,
) Errors!void {
    std.debug.assert(args.len == types.len);
    var memory_i: usize = 0;
    for (0..args.len) |arg_i| {
        const tag: tag_t = load_field(tag_t, memory_i);
        memory_i += 1;
        switch (tag) {
            1 => {
                if (types[arg_i] != .Int32) return Errors.TypeMismatch;
                const data_t = i32;
                args[arg_i] = WASMArg{ .Int32 = load_field(data_t, memory_i) };
                memory_i += @sizeOf(data_t);
            },
            2 => {
                if (types[arg_i] != .Uint32) return Errors.TypeMismatch;
                const data_t = u32;
                args[arg_i] = WASMArg{ .Uint32 = load_field(data_t, memory_i) };
                memory_i += @sizeOf(data_t);
            },
            3 => {
                if (types[arg_i] != .string) return Errors.TypeMismatch;

                const length_t = u32;
                const length: usize = @bitCast(load_field(length_t, memory_i));
                memory_i += @sizeOf(length_t);

                const str = try alloc.dupe(u8, wasm_buf[memory_i .. memory_i + length]);
                args[arg_i] = WASMArg{ .string = str };
                memory_i += length;
            },
            4 => {
                if (types[arg_i] != .Int32Array) return Errors.TypeMismatch;

                const length_t = u32;
                var length: usize = @bitCast(load_field(length_t, memory_i));
                memory_i += @sizeOf(length_t);

                const data_t = i32;
                var arr = std.ArrayList(data_t).init(alloc);
                errdefer arr.deinit();
                while (length > 0) : (length -= 1) {
                    try arr.append(load_field(data_t, memory_i));
                    memory_i += @sizeOf(data_t);
                }
                args[arg_i] = WASMArg{ .Int32Array = try arr.toOwnedSlice() };
            },
            5 => {
                if (types[arg_i] != .Uint32Array) return Errors.TypeMismatch;

                const length_t = u32;
                var length: usize = @bitCast(load_field(length_t, memory_i));
                memory_i += @sizeOf(length_t);

                const data_t = i32;
                var arr = std.ArrayList(data_t).init(alloc);
                errdefer arr.deinit();
                while (length > 0) : (length -= 1) {
                    try arr.append(load_field(data_t, memory_i));
                    memory_i += 4;
                }
                args[arg_i] = WASMArg{ .Int32Array = try arr.toOwnedSlice() };
            },
            else => return Errors.TypeWithUnkownTag,
        }
    }
    // Wipe the buffer for storing after export call
    @memset(wasm_buf_i8[0..memory_i], -1);
}

fn load_field(comptime T: type, memory_i: usize) T {
    return std.mem.readPackedInt(
        T,
        wasm_buf[memory_i .. memory_i + @sizeOf(T)],
        0,
        .little,
    );
}

pub fn store(
    args: []const WASMArg,
) void {
    const length_t = u32;
    var memory_i: usize = 0;
    for (args) |arg| {
        const tag: tag_t = @bitCast(@intFromEnum(arg));
        switch (arg) {
            .Int32 => |*int| {
                store_field(tag_t, tag, memory_i);
                memory_i += 1;

                const data_t = @TypeOf(int.*);
                store_field(data_t, int.*, memory_i);
                memory_i += @sizeOf(data_t);
            },
            .Uint32 => |*int| {
                store_field(tag_t, tag, memory_i);
                memory_i += 1;

                const data_t = @TypeOf(int.*);
                store_field(data_t, int.*, memory_i);
                memory_i += @sizeOf(data_t);
            },
            .string => |*str| {
                store_field(tag_t, tag, memory_i);
                memory_i += 1;

                const length: usize = str.*.len;
                store_field(length_t, @bitCast(length), memory_i);
                memory_i += @sizeOf(length_t);

                @memcpy(wasm_buf[memory_i .. memory_i + length], str.*);
                memory_i += length;
            },
            .Int32Array => |*arr| {
                store_field(tag_t, tag, memory_i);
                memory_i += 1;

                const length: usize = arr.*.len;
                store_field(length_t, @bitCast(length), memory_i);
                memory_i += @sizeOf(length_t);

                const data_t = @TypeOf(arr.*[0]);
                for (arr.*) |ele| {
                    store_field(data_t, ele, memory_i);
                    memory_i += @sizeOf(data_t);
                }
            },
            .Uint32Array => |*arr| {
                store_field(tag_t, tag, memory_i);
                memory_i += 1;

                const length: usize = arr.*.len;
                store_field(length_t, @bitCast(length), memory_i);
                memory_i += @sizeOf(length_t);

                const data_t = @TypeOf(arr.*[0]);
                for (arr.*) |ele| {
                    store_field(data_t, ele, memory_i);
                    memory_i += @sizeOf(data_t);
                }
            },
        }
    }
    store_field(tag_t, -1, memory_i);
    memory_i += 1;
}

fn store_field(comptime T: type, data: T, memory_i: usize) void {
    return std.mem.writePackedInt(
        T,
        wasm_buf[memory_i .. memory_i + @sizeOf(T)],
        0,
        data,
        .little,
    );
}
