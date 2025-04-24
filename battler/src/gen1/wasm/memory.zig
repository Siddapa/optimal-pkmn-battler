const std = @import("std");
const print = std.debug.print;
var da: std.heap.DebugAllocator(.{}) = .init;

const pkmn = @import("pkmn");
const builder = @import("builder");

const exports = @import("exports.zig");

const Errors = @import("errors.zig").Errors;

// Zig treats 0x0 as a special memory location for optional
// pointers so ignore that address just to be safe.
// Start at 0x4 for 4 byte alignment with padded length (32-bit)
const buf_beg: usize = 0x4;
const wasm_buf_u8: [*]u8 = @ptrFromInt(buf_beg);
const wasm_buf_i32: [*]i32 = @ptrFromInt(buf_beg);
const wasm_buf_u32: [*]u32 = @ptrFromInt(buf_beg);

// All sizes are 4s however it's good naming to be reduntant
// and easier to maniuplate for later
const tag_t = i32;
const tag_t_size = @sizeOf(tag_t);
const length_t = u32;
const length_t_size = @sizeOf(length_t);
const ptr_t = usize;
const ptr_t_size = @sizeOf(ptr_t);

const data_gen_t = *const fn (*const builder.DecisionNode, std.mem.Allocator) Errors![]WASMArg;

pub const WASM_t = enum(u8) {
    Int32 = 1,
    Uint32 = 2,
    string = 3,
    Int32Array = 4,
    Uint32Array = 5,
    Tree = 6,

    pub fn to_type(t: WASM_t) type {
        return switch (t) {
            .Int32 => u32,
            .Uint32 => i32,
            .string => u8,
            .Int32Array => i32,
            .Uint32Array => u32,
            .Tree => null,
        };
    }
};

pub const WASMArg = union(WASM_t) {
    Int32: i32,
    Uint32: u32,
    string: []const u8,
    Int32Array: []const i32,
    Uint32Array: []const u32,
    Tree: struct {
        root: *builder.DecisionNode,
        data_gen: data_gen_t,
    },
};

pub fn print_buf(comptime len: usize) void {
    var i: usize = 0;
    while (i < len) : (i += 4) {
        print("{}: {} {}\n\n", .{ i, load_field(i32, i), load_field(u32, i) });
    }
    print("\n\n\n\n\n", .{});
}

pub fn wipe(memory_i: usize) void {
    @memset(wasm_buf_i32[0..memory_i], -1);
}

// Because an allocator isn't used, the wasm_buf MUST ONLY be cleared
// when all arguements are done being in use (often when storing return values)
pub fn load(
    args: []WASMArg,
    comptime types: []const WASM_t,
    alloc: std.mem.Allocator,
) Errors!void {
    std.debug.assert(args.len == types.len);
    var memory_i: usize = 0;

    inline for (0..types.len) |arg_i| {
        const curr_t = types[arg_i];

        const tag: tag_t = load_field(tag_t, memory_i);
        if (curr_t != @as(WASM_t, @enumFromInt(tag))) return Errors.LoadingTypeMismatch;
        memory_i += tag_t_size;

        const data_t = WASM_t.to_type(curr_t);
        const data_t_size = @sizeOf(data_t);

        switch (tag) {
            1 => {
                // TODO Won't compile without hardcoding the field
                args[arg_i] = WASMArg{ .Int32 = load_field(i32, memory_i) };
                memory_i += data_t_size;
            },
            2 => {
                // TODO Won't compile without hardcoding the field
                args[arg_i] = WASMArg{ .Uint32 = load_field(u32, memory_i) };
                memory_i += data_t_size;
            },
            3 => {
                const length: usize = @bitCast(load_field(length_t, memory_i));
                memory_i += length_t_size;

                const string: []u8 = try alloc.dupe(u8, wasm_buf_u8[memory_i .. memory_i + length]);

                args[arg_i] = WASMArg{ .string = string };

                const padding: usize = switch (length % length_t_size) {
                    0 => 0,
                    1 => 3,
                    2 => 2,
                    3 => 1,
                    else => unreachable,
                };
                memory_i += (length * data_t_size) + padding;
            },
            4 => {
                const length: usize = @bitCast(load_field(length_t, memory_i));
                memory_i += length_t_size;

                // memory_i is byte addressable so realign to fit the 32-bit spacing
                const start_i = memory_i / data_t_size;
                const end_i = memory_i / data_t_size + length;
                const array = try alloc.dupe(i32, wasm_buf_i32[start_i..end_i]);
                args[arg_i] = WASMArg{ .Int32Array = array };
                memory_i += length * data_t_size;
            },
            5 => {
                const length: usize = @bitCast(load_field(length_t, memory_i));
                memory_i += length_t_size;

                // memory_i is byte addressable so realign to fit the 32-bit spacing
                const start_i = memory_i / data_t_size;
                const end_i = memory_i / data_t_size + length;
                const array = try alloc.dupe(u32, wasm_buf_u32[start_i..end_i]);
                args[arg_i] = WASMArg{ .Uint32Array = array };
                memory_i += length * data_t_size;
            },
            else => {
                return Errors.LoadingTypeWithUnknownTag;
            },
        }
    }

    wipe(memory_i);
}

fn load_field(comptime T: type, memory_i: usize) T {
    return std.mem.readVarInt(
        T,
        wasm_buf_u8[memory_i .. memory_i + @sizeOf(T)],
        .little,
    );
}

pub fn store(args: []const WASMArg) Errors!void {
    var memory_i: usize = 0;
    try store_args(args, &memory_i);
    store_field(tag_t, -1, memory_i);
    memory_i += 1;
}

pub fn store_args(
    args: []const WASMArg,
    memory_i: *usize,
) Errors!void {
    for (args) |arg| {
        const tag: tag_t = @intCast(@intFromEnum(arg));
        store_field(tag_t, tag, memory_i.*);
        memory_i.* += tag_t_size;

        switch (arg) {
            .Int32 => |*int| {
                const data_t = i32;
                store_field(data_t, int.*, memory_i.*);
                memory_i.* += @sizeOf(data_t);
            },
            .Uint32 => |*int| {
                const data_t = u32;
                store_field(data_t, int.*, memory_i.*);
                memory_i.* += @sizeOf(data_t);
            },
            .string => |*str| {
                const length: usize = str.*.len;
                store_field(length_t, length, memory_i.*);
                memory_i.* += length_t_size;

                @memcpy(wasm_buf_u8[memory_i.* .. memory_i.* + length], str.*);
                memory_i.* += length;

                const padding: usize = switch (length % length_t_size) {
                    0 => 0,
                    1 => 3,
                    2 => 2,
                    3 => 1,
                    else => unreachable,
                };
                memory_i.* += padding;
            },
            .Int32Array => |*arr| {
                const length: usize = arr.*.len;
                store_field(length_t, length, memory_i.*);
                memory_i.* += length_t_size;

                const data_t = i32;
                for (arr.*) |ele| {
                    store_field(data_t, ele, memory_i.*);
                    memory_i.* += @sizeOf(data_t);
                }
            },
            .Uint32Array => |*arr| {
                const length: usize = arr.*.len;
                store_field(length_t, length, memory_i.*);
                memory_i.* += length_t_size;

                const data_t = u32;
                for (arr.*) |ele| {
                    store_field(data_t, ele, memory_i.*);
                    memory_i.* += @sizeOf(data_t);
                }
            },
            .Tree => |*tree| {
                // Use store_node to store tag to make it consistent for when store_tree
                // needs to call store_node too
                memory_i.* -= tag_t_size;

                try store_node(tree.root, tree.data_gen, memory_i);

                // Because we want to store tree in BFS fashion, allocate space for pointer
                // to children by holding start index of that space and filling after
                // storing children of tree
                const ptr_i: usize = memory_i.*;
                memory_i.* += @sizeOf(ptr_t);

                const transitions_ptr = try store_tree(tree.root, tree.data_gen, memory_i);
                store_field(ptr_t, @intCast(transitions_ptr), ptr_i);
            },
        }
    }
}

fn store_tree(curr_node: *const builder.DecisionNode, data_gen: data_gen_t, memory_i: *usize) !usize {
    const alloc = da.allocator();
    var ptr_indexes = std.ArrayList(u32).init(alloc);
    try ptr_indexes.ensureTotalCapacity(curr_node.transitions.items.len);
    defer ptr_indexes.deinit();

    const transitions_memory_i: usize = memory_i.*;

    for (curr_node.transitions.items) |next_node| {
        try store_node(next_node, data_gen, memory_i);

        // Because we want to store tree in BFS fashion, allocate space for pointer
        // to children by holding start index of that space and filling after
        // storing children of tree
        const ptr_i: usize = memory_i.*;
        memory_i.* += @sizeOf(ptr_t);
        try ptr_indexes.append(ptr_i);
    }

    for (curr_node.transitions.items, 0..) |next_node, i| {
        const transitions_ptr = try store_tree(next_node, data_gen, memory_i);
        store_field(ptr_t, @intCast(transitions_ptr), ptr_indexes.items[i]);
    }

    return transitions_memory_i;
}

fn store_node(curr_node: *const builder.DecisionNode, data_gen: data_gen_t, memory_i: *usize) !void {
    const alloc = da.allocator();
    store_field(tag_t, @intCast(@intFromEnum(WASM_t.Tree)), memory_i.*);
    memory_i.* += tag_t_size;

    const node_data = try data_gen(curr_node, alloc);
    defer alloc.free(node_data);

    store_field(length_t, node_data.len, memory_i.*);
    memory_i.* += length_t_size;

    try store_args(node_data, memory_i);

    store_field(length_t, curr_node.transitions.items.len, memory_i.*);
    memory_i.* += length_t_size;
}

fn store_field(comptime T: type, data: T, memory_i: usize) void {
    return std.mem.writePackedInt(
        T,
        wasm_buf_u8[memory_i .. memory_i + @sizeOf(T)],
        0,
        data,
        .little,
    );
}
