const std = @import("std");

const debug = std.debug;
const io = std.io;

const Array = if (@hasField(std.builtin.Type, "array")) .array else .Array;
const Enum = if (@hasField(std.builtin.Type, "enum")) .@"enum" else .Enum;
const Optional = if (@hasField(std.builtin.Type, "optional")) .optional else .Optional;
const Pointer = if (@hasField(std.builtin.Type, "pointer")) .pointer else .Pointer;
const Struct = if (@hasField(std.builtin.Type, "struct")) .@"struct" else .Struct;
const Union = if (@hasField(std.builtin.Type, "union")) .@"union" else .Union;

pub fn print(value: anytype) void {
    if (@hasDecl(debug, "lockStdErr")) debug.lockStdErr() else debug.getStderrMutex().lock();
    defer if (@hasDecl(debug, "unlockStdErr"))
        debug.unlockStdErr()
    else
        debug.getStderrMutex().unlock();
    const stderr = io.getStdErr().writer();

    nosuspend {
        stderr.writeAll("\x1b[41m") catch return;
        if (@TypeOf(@src()) == @TypeOf(value)) {
            stderr.print("{s} ({s}:{d}:{d})", .{
                value.fn_name,
                value.file,
                value.line,
                value.column,
            }) catch return;
        } else {
            switch (@typeInfo(@TypeOf(value))) {
                Struct => |info| {
                    if (info.is_tuple) {
                        inline for (info.fields, 0..) |f, i| {
                            inspect(@field(value, f.name));
                            if (i < info.fields.len - 1) stderr.writeAll(" ") catch return;
                        }
                    } else {
                        inspect(value);
                    }
                },
                else => inspect(value),
            }
        }
        stderr.writeAll("\x1b[K\x1b[0m\n") catch return;
    }
}

fn inspect(value: anytype) void {
    const stderr = io.getStdErr().writer();

    nosuspend {
        const err = "Unable to format type '" ++ @typeName(@TypeOf(value)) ++ "'";
        switch (@typeInfo(@TypeOf(value))) {
            Array => |info| {
                if (info.child == u8) return stderr.print("{s}", .{value}) catch return;
                @compileError(err);
            },
            Pointer => |ptr_info| switch (ptr_info.size) {
                .One => switch (@typeInfo(ptr_info.child)) {
                    Array => |info| {
                        if (info.child == u8) return stderr.print("{s}", .{value}) catch return;
                        @compileError(err);
                    },
                    Enum, Union, Struct => return inspect(value.*),
                    else => @compileError(err),
                },
                .Many, .C => {
                    if (ptr_info.sentinel) |_| return inspect(std.mem.span(value));
                    if (ptr_info.child == u8) {
                        return stderr.print("{s}", .{std.mem.span(value)}) catch return;
                    }
                    @compileError(err);
                },
                .Slice => {
                    if (ptr_info.child == u8) return stderr.print("{s}", .{value}) catch return;
                    @compileError(err);
                },
            },
            Optional => stderr.print("{?}", .{value}) catch return,
            else => stderr.print("{}", .{value}) catch return,
        }
    }
}

const showdown = @import("./options.zig").showdown;
const Result = @import("./data.zig").Result;
const Choice = @import("./data.zig").Choice;

pub fn dump(gen: u8, battle: anytype, frame: ?struct { Result, Choice, Choice }) void {
    const file = std.fs.cwd().createFile("logs/dump.bin", .{}) catch return;
    defer file.close();
    var w = file.writer();
    w.writeByte(@intFromBool(showdown)) catch return;
    w.writeByte(gen) catch return;
    w.writeInt(i16, 0, .little) catch return;
    w.writeInt(i32, 0, .little) catch return;
    w.writeStruct(battle) catch return;
    w.writeStruct(battle) catch return;
    if (frame) |f| {
        w.writeStruct(f[0]) catch return;
        w.writeStruct(f[1]) catch return;
        w.writeStruct(f[2]) catch return;
    }
}
