const std = @import("std");
const VirtualMachine = @import("vm.zig").VirtualMachine;
const Value = @import("vm.zig").Value;
const Object = @import("vm.zig").Object;
const CallFrame = @import("vm.zig").CallFrame;
const GlobalsHashMap = @import("vm.zig").GlobalsHashMap;

pub const GarbageCollectorOptions = struct {
    store_transitions: bool = false,
};

pub fn TreeAllocator(comptime options: GarbageCollectorOptions, comptime T: type, comptime L: type) type {
    return struct {
        const Self = @This();
        pub const Error = error{OutOfMemory};

        // Stored GPA, used for runtime allocations, TODO: make in configurable
        runtime_gpa: std.heap.GeneralPurposeAllocator(.{}),
        // Stored allocator, used for internal allocations
        inner_allocator: std.mem.Allocator,

        objs: ?*std.ArrayList(*T) = null,
        parents: ?*std.ArrayList(struct {
            transition: L,
            p: usize,
        }) = null,

        pub fn init(allocator_: std.mem.Allocator) Self {
            const gpa = std.heap.GeneralPurposeAllocator(.{}).init();
            return Self{
                .runtime_gpa = gpa,
                .inner_allocator = allocator_,
            };
        }

        pub fn deinit(self: *Self) std.heap.Check {
            var gray = self.grays.first;
            while (gray) |node| {
                gray = node.next;
                self.inner_allocator.destroy(node);
            }
            return self.runtime_gpa.deinit();
        }

        pub fn allocator(self: *Self) std.mem.Allocator {
            return .{
                .ptr = self,
                .vtable = &.{
                    .alloc = alloc,
                    .free = free,
                    .resize = resize,
                },
            };
        }

        fn alloc(ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) ?[*]u8 {
            const self: *Self = @ptrCast(@alignCast(ctx));

            self.bytes_allocated += len;
            if (self.bytes_allocated > self.next_gc or options.stress) {
                self.collectGarbage() catch return null;
            }

            return self.runtime_gpa.allocator().rawAlloc(len, ptr_align, ret_addr);
        }

        fn resize(ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) bool {
            const self: *Self = @ptrCast(@alignCast(ctx));

            self.bytes_allocated += new_len - buf.len;
            if (self.bytes_allocated > self.next_gc or options.stress) {
                self.collectGarbage() catch return false;
            }

            return self.runtime_gpa.allocator().rawResize(buf, buf_align, new_len, ret_addr);
        }

        fn free(ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) void {
            const self: *Self = @ptrCast(@alignCast(ctx));
            self.bytes_allocated -= buf.len;
            self.runtime_gpa.allocator().rawFree(buf, buf_align, ret_addr);
        }
    };
}
