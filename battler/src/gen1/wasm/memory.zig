const std = @import("std");
const print = std.debug.print;
var da: std.heap.DebugAllocator(.{}) = .init;

const builder = @import("builder");

const Errors = @import("errors.zig").Errors;

// 0x0 is valid address as a function arguement in both Zig and JS
// however as a comptime global, Zig treats that memory location as
// special for optional pointers so ignore that address just to be safe.
// Start at 0x8 for 8 byte alignment for largest type (u64)
const buf_beg: usize = 0x8;
const wasm_buf_i32: [*]i32 = @ptrFromInt(buf_beg);
const wasm_buf_u32: [*]u32 = @ptrFromInt(buf_beg);
const wasm_buf_u8: [*]u8 = @ptrFromInt(buf_beg);

const tag_t = i32;
const tag_t_size = @sizeOf(tag_t);
const length_t = u32;
const length_t_size = @sizeOf(length_t);
const ptr_t = usize;
const ptr_t_size = @sizeOf(ptr_t);

pub const WASM_t = enum(u8) {
    Int32 = 1,
    Uint32 = 2,
    string = 3,
    Int32Array = 4,
    Uint32Array = 5,
    Tree = 6,
};

pub const WASMArg = union(WASM_t) {
    Int32: i32,
    Uint32: u32,
    string: []const u8,
    Int32Array: []const i32,
    Uint32Array: []const u32,
    Tree: struct {
        root: *builder.DecisionNode,
        data_gen: *const fn (*const builder.DecisionNode) []WASMArg,
    },
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
        memory_i += tag_t_size;
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

                const length: usize = @bitCast(load_field(length_t, memory_i));
                memory_i += length_t_size;

                const str = try alloc.dupe(u8, wasm_buf_u8[memory_i .. memory_i + length]);
                const padding = length_t_size - (str.len % length_t_size);

                args[arg_i] = WASMArg{ .string = str };
                memory_i += length + padding;
            },
            4 => {
                if (types[arg_i] != .Int32Array) return Errors.TypeMismatch;

                var length: usize = @bitCast(load_field(length_t, memory_i));
                memory_i += length_t_size;

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

                var length: usize = @bitCast(load_field(length_t, memory_i));
                memory_i += length_t_size;

                const data_t = i32;
                var arr = std.ArrayList(data_t).init(alloc);
                errdefer arr.deinit();
                while (length > 0) : (length -= 1) {
                    try arr.append(load_field(data_t, memory_i));
                    memory_i += 4;
                }
                args[arg_i] = WASMArg{ .Int32Array = try arr.toOwnedSlice() };
            },
            else => return Errors.TypeWithUnknownTag,
        }
    }
    // Wipe the buffer for storing after export call
    @memset(wasm_buf_i32[0..memory_i], -1);
}

fn load_field(comptime T: type, memory_i: usize) T {
    return std.mem.readVarInt(
        T,
        wasm_buf_u8[memory_i .. memory_i + @sizeOf(T)],
        .little,
    );
}

pub fn store(
    args: []const WASMArg,
) Errors!usize {
    var memory_i: usize = 0;
    for (args) |arg| {
        const tag: tag_t = @intCast(@intFromEnum(arg));
        switch (arg) {
            .Int32 => |*int| {
                store_field(tag_t, tag, memory_i);
                memory_i += tag_t_size;

                const data_t = @TypeOf(int.*);
                store_field(data_t, int.*, memory_i);
                memory_i += @sizeOf(data_t);
            },
            .Uint32 => |*int| {
                store_field(tag_t, tag, memory_i);
                memory_i += tag_t_size;

                const data_t = u32;
                store_field(data_t, int.*, memory_i);
                memory_i += @sizeOf(data_t);
            },
            .string => |*str| {
                store_field(tag_t, tag, memory_i);
                memory_i += tag_t_size;

                const length: usize = str.*.len;
                store_field(length_t, @bitCast(length), memory_i);
                memory_i += length_t_size;

                @memcpy(wasm_buf_u8[memory_i .. memory_i + length], str.*);

                const padding = length - (length % length_t_size);
                memory_i += length + padding;
            },
            .Int32Array => |*arr| {
                store_field(tag_t, tag, memory_i);
                memory_i += tag_t_size;

                const length: usize = arr.*.len;
                store_field(length_t, @bitCast(length), memory_i);
                memory_i += length_t_size;

                const data_t = i32;
                for (arr.*) |ele| {
                    store_field(data_t, ele, memory_i);
                    memory_i += @sizeOf(data_t);
                }
            },
            .Uint32Array => |*arr| {
                store_field(tag_t, tag, memory_i);
                memory_i += tag_t_size;

                const length: usize = arr.*.len;
                store_field(length_t, @bitCast(length), memory_i);
                memory_i += length_t_size;

                const data_t = u32;
                for (arr.*) |ele| {
                    store_field(data_t, ele, memory_i);
                    memory_i += @sizeOf(data_t);
                }
            },
            .Tree => |*tree| {
                try store_node(tree.root, tree.data_gen, &memory_i);

                // Because we want to store tree in BFS fashion, allocate space for pointer
                // to children by holding start index of that space and filling after
                // storing children of tree
                const ptr_i = memory_i;
                memory_i += @sizeOf(ptr_t);

                const transitions_ptr = try store_tree(tree.root, tree.data_gen, &memory_i);
                store_field(ptr_t, @intCast(transitions_ptr), ptr_i);
            },
        }
    }
    store_field(tag_t, -1, memory_i);
    memory_i += 1;

    return memory_i;
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

fn store_node(curr_node: *const builder.DecisionNode, data_gen: *const fn (*const builder.DecisionNode) []WASMArg, memory_i: *usize) !void {
    store_field(tag_t, @intCast(@intFromEnum(WASM_t.Tree)), memory_i.*);
    memory_i.* += tag_t_size;

    const node_data = data_gen(curr_node);
    store_field(length_t, node_data.len, memory_i.*);
    memory_i.* += length_t_size;

    memory_i.* += try store(node_data);

    store_field(length_t, curr_node.transitions.items.len, memory_i.*);
    memory_i.* += length_t_size;
}

fn store_tree(curr_node: *const builder.DecisionNode, data_gen: *const fn (*const builder.DecisionNode) []WASMArg, memory_i: *usize) !usize {
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
        const ptr_i = memory_i;
        memory_i.* += @sizeOf(ptr_t);
        try ptr_indexes.append(ptr_i.*);
    }

    for (curr_node.transitions.items, 0..) |next_node, i| {
        const transitions_ptr = try store_tree(next_node, data_gen, memory_i);
        store_field(ptr_t, @intCast(transitions_ptr), ptr_indexes.items[i]);
    }

    return transitions_memory_i;
}
