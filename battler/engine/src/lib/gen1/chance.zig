const DEBUG = @import("../common/debug.zig").print;

const array = @import("../common/array.zig");
const common = @import("../common/data.zig");
const data = @import("data.zig");
const optional = @import("../common/optional.zig");
const options = @import("../common/options.zig");
const rational = @import("../common/rational.zig");
const std = @import("std");
const util = @import("../common/util.zig");

const Array = array.Array;
const assert = std.debug.assert;
const enabled = options.chance;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const isPointerTo = util.isPointerTo;
const Move = data.Move;
const MoveSlot = data.MoveSlot;
const Optional = optional.Optional;
const Player = common.Player;
const PointerType = util.PointerType;
const print = std.debug.print;
const showdown = options.showdown;

const Int = if (@hasField(std.builtin.Type, "int")) .int else .Int;
const Enum = if (@hasField(std.builtin.Type, "enum")) .@"enum" else .Enum;
const Struct = if (@hasField(std.builtin.Type, "struct")) .@"struct" else .Struct;

/// Actions taken by a hypothetical "chance player" that convey information about which RNG events
/// were observed during a Generation I battle `update`. This can additionally be provided as input
/// to the `update` call to override the normal behavior of the RNG in order to force specific
/// outcomes.
pub const Actions = extern struct {
    /// Information about the RNG activity for Player 1.
    p1: Action = .{},
    /// Information about the RNG activity for Player 2.
    p2: Action = .{},

    comptime {
        assert(@sizeOf(Actions) == 16);
    }

    /// Returns the `Action` for the given `player`.
    pub fn get(self: anytype, player: Player) PointerType(@TypeOf(self), Action) {
        assert(isPointerTo(self, Actions));
        return if (player == .P1) &self.p1 else &self.p2;
    }

    /// Returns true if `a` is equal to `b`.
    pub fn eql(a: Actions, b: Actions) bool {
        return @as(u128, @bitCast(a)) == @as(u128, @bitCast(b));
    }

    /// Returns true if `a` has the same "shape" as `b`, where `Actions` are defined to have the
    /// same shape if they have the same fields set (though those fields need not necessarily be
    /// set to the same value).
    pub fn matches(a: Actions, b: Actions) bool {
        inline for (@field(@typeInfo(Actions), @tagName(Struct)).fields) |player| {
            inline for (@field(@typeInfo(Action), @tagName(Struct)).fields) |field| {
                const a_val = @field(@field(a, player.name), field.name);
                const b_val = @field(@field(b, player.name), field.name);

                switch (@typeInfo(@TypeOf(a_val))) {
                    Enum => if ((@intFromEnum(a_val) > 0) != (@intFromEnum(b_val) > 0))
                        return false,
                    Int => if ((a_val > 0) != (b_val > 0)) return false,
                    else => unreachable,
                }
            }
        }
        return true;
    }

    /// TODO
    pub fn matchesAny(a: Actions, bs: []Actions, i: usize) bool {
        for (bs, 0..) |b, j| {
            // TODO: is skipping this redundant check worth it?
            if (i == j) continue;
            if (b.matches(a)) return true;
        }
        return false;
    }

    /// TODO
    pub fn relax(actions: Actions) Actions {
        if (!options.overwrite) return actions;
        var a = actions;
        if (a.p1.confusion == .overwritten) a.p1.confusion = .continuing;
        if (a.p2.confusion == .overwritten) a.p2.confusion = .continuing;
        return a;
    }

    pub fn fmt(self: Actions, writer: anytype, shape: bool) !void {
        try writer.writeAll("<P1 = ");
        try self.p1.fmt(writer, shape);
        try writer.writeAll(", P2 = ");
        try self.p2.fmt(writer, shape);
        try writer.writeAll(">");
    }

    pub fn format(a: Actions, comptime f: []const u8, o: std.fmt.FormatOptions, w: anytype) !void {
        _ = .{ f, o };
        try fmt(a, w, false);
    }
};

test Actions {
    const a: Actions = .{ .p1 = .{ .hit = .true, .critical_hit = .false, .damage = 245 } };
    const b: Actions = .{ .p1 = .{ .hit = .false, .critical_hit = .true, .damage = 246 } };
    const c: Actions = .{ .p1 = .{ .hit = .true } };

    try expect(a.eql(a));
    try expect(!a.eql(b));
    try expect(!b.eql(a));
    try expect(!a.eql(c));
    try expect(!c.eql(a));

    try expect(a.matches(a));
    try expect(a.matches(b));
    try expect(b.matches(a));
    try expect(!a.matches(c));
    try expect(!c.matches(a));
}

/// Observation made about a duration - whether the duration has started, been continued, or ended.
pub const Observation = enum { started, continuing, ended };
/// An extension of Observation to account for "hidden" confusion.
pub const Confusion = enum {
    started,
    continuing,
    ended,
    /// An indicator that an existing confusion duration has been overwritten by a new confusion
    /// duration due to a Thrashing move ending. This is not immediately observable to an opponent,
    /// to compute probabilities from an opponent's point of view based solely on public information
    /// extra work must be done to correct for the information leak
    overwritten,
};

/// Information about the RNG that was observed during a Generation I battle `update` for a
/// single player.
pub const Action = packed struct(u64) {
    /// If not 0, the roll to be returned Rolls.damage.
    damage: u8 = 0,

    /// If not None, the value to return for Rolls.hit.
    hit: Optional(bool) = .None,
    /// If not None, the value to be returned by Rolls.criticalHit.
    critical_hit: Optional(bool) = .None,
    /// If not None, the value to be returned for
    /// Rolls.{confusionChance,secondaryChance,poisonChance}.
    secondary_chance: Optional(bool) = .None,
    /// If not None, the Player to be returned by Rolls.speedTie.
    speed_tie: Optional(Player) = .None,

    /// If not None, the value to return for Rolls.confused.
    confused: Optional(bool) = .None,
    /// If not None, the value to return for Rolls.paralyzed.
    paralyzed: Optional(bool) = .None,
    /// If not 0, the value to be returned by Rolls.distribution in the case of binding moves
    /// or Rolls.{sleepDuration,disableDuration,confusionDuration,attackingDuration} otherwise.
    duration: u4 = 0,

    /// TODO
    sleep: Optional(Observation) = .None,
    /// TODO
    confusion: Optional(Confusion) = .None,
    /// TODO
    disable: Optional(Observation) = .None,
    /// TODO
    attacking: Optional(Observation) = .None,
    /// TODO
    binding: Optional(Observation) = .None,

    _: u1 = 0,

    /// If not 0, the move slot (1-4) to return in Rolls.moveSlot. If present as an override,
    /// invalid values (eg. due to empty move slots or 0 PP) will be ignored.
    move_slot: u4 = 0,

    /// TODO
    pp: u4 = 0,
    /// If not 0, the value (2-5) to return for Rolls.distribution for multi hit.
    multi_hit: u4 = 0,

    /// If not 0, psywave - 1 should be returned as the damage roll for Rolls.psywave.
    psywave: u8 = 0,

    /// If not None, the Move to return for Rolls.metronome.
    metronome: Move = .None,

    pub const Field = std.meta.FieldEnum(Action);

    pub fn format(a: Action, comptime f: []const u8, o: std.fmt.FormatOptions, w: anytype) !void {
        _ = .{ f, o };
        try fmt(a, w, false);
    }

    pub fn fmt(self: Action, writer: anytype, shape: bool) !void {
        try writer.writeByte('(');
        var printed = false;
        inline for (@field(@typeInfo(Action), @tagName(Struct)).fields) |field| {
            const val = @field(self, field.name);
            switch (@typeInfo(@TypeOf(val))) {
                Enum => if (val != .None) {
                    if (printed) try writer.writeAll(", ");
                    if (shape) {
                        try writer.print("{s}:?", .{field.name});
                    } else if (@TypeOf(val) == Optional(bool)) {
                        try writer.print("{s}{s}", .{
                            if (val == .false) "!" else "",
                            field.name,
                        });
                    } else if (@TypeOf(val) == Optional(Observation) or
                        @TypeOf(val) == Optional(Confusion))
                    {
                        try writer.print("{s}{s}", .{
                            ([_][]const u8{ "+", "", "-", "#" })[@intFromEnum(val) - 1],
                            field.name,
                        });
                    } else {
                        try writer.print("{s}:{s}", .{ field.name, @tagName(val) });
                    }
                    printed = true;
                },
                Int => if (val != 0) {
                    if (printed) try writer.writeAll(", ");
                    if (shape) {
                        try writer.print("{s}:?", .{field.name});
                    } else {
                        try writer.print("{s}:{d}", .{ field.name, val });
                    }
                    printed = true;
                },
                else => unreachable,
            }
        }
        try writer.writeByte(')');
    }
};

/// TODO
pub const Durations = extern struct {
    /// TODO
    p1: Duration = .{},
    /// TODO
    p2: Duration = .{},

    comptime {
        assert(@sizeOf(Durations) == 8);
    }

    /// TODO
    pub fn get(self: anytype, player: Player) PointerType(@TypeOf(self), Duration) {
        assert(isPointerTo(self, Durations));
        return if (player == .P1) &self.p1 else &self.p2;
    }

    pub fn format(
        self: Durations,
        comptime fmt: []const u8,
        opts: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = .{ fmt, opts };
        try writer.print("[P1 = {}, P2 = {}]", .{ self.p1, self.p2 });
    }
};

pub const Sleeps = Array(6, u3);

/// TODO
pub const Duration = packed struct(u32) {
    sleeps: Sleeps.T = 0,
    confusion: u3 = 0,
    disable: u4 = 0,
    attacking: u3 = 0,
    binding: u3 = 0,

    _: u1 = 0,

    pub fn format(
        self: Duration,
        comptime fmt: []const u8,
        opts: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = .{ fmt, opts };
        try writer.writeByte('(');
        var printed = false;
        inline for (@field(@typeInfo(Duration), @tagName(Struct)).fields) |field| {
            const val = @field(self, field.name);
            switch (@typeInfo(@TypeOf(val))) {
                Int => if (val != 0) {
                    if (printed) try writer.writeAll(", ");
                    if (comptime std.mem.eql(u8, field.name, "sleeps")) {
                        try writer.print("{s}:[", .{field.name});
                        for (0..6) |i| {
                            if (i != 0) try writer.writeByte(',');
                            try writer.print("{d}", .{Sleeps.get(val, i)});
                        }
                        try writer.writeAll("]");
                    } else {
                        try writer.print("{s}:{d}", .{ field.name, val });
                    }
                    printed = true;
                },
                else => unreachable,
            }
        }
        try writer.writeByte(')');
    }
};

pub const Commit = enum { hit, miss, binding, err, glitch };

const uN = if (options.miss) u8 else u9;

/// Tracks chance actions and their associated probability during a Generation I battle update when
/// `options.chance` is enabled.
pub fn Chance(comptime Rational: type) type {
    return struct {
        const Self = @This();

        /// The probability of the actions taken by a hypothetical "chance player" occurring.
        probability: Rational,
        /// The actions taken by a hypothetical "chance player" that convey information about which
        /// RNG events were observed during a battle `update`.
        actions: Actions = .{},
        /// TODO
        durations: Durations = .{},

        // In many cases on both the cartridge and on Pokémon Showdown rolls are made even though
        // later checks render their result irrelevant (missing when the target is actually immune,
        // rolling for damage when the move is later revealed to have missed, etc). We can't reorder
        // the logic to ensure we only ever make rolls when required due to our desire to maintain
        // RNG frame accuracy, so instead we save these "pending" updates to the probability and
        // only commit them once we know they are relevant (a naive solution would be to instead
        // update the probability eagerly and later "undo" the update by multiplying by the inverse
        // but this would be more costly and also error prone in the presence of
        // overflow/normalization).
        //
        // This design deliberately make use of the fact that recursive moves on the cartridge may
        // overwrite critical hit information multiple times as only the last update actually
        // matters for the purposes of the logical results.
        //
        // Finally, because each player's actions are processed sequentially we only need a single
        // shared structure to track this information (though it needs to be cleared appropriately)
        pending: if (showdown) struct {} else struct {
            crit: bool = false,
            crit_probablity: u8 = 0,
            damage_roll: u8 = 0,
            hit: bool = false,
            hit_probablity: uN = 0,
            glitch: bool = false,
        } = .{},

        /// Possible error returned by operations tracking chance probability.
        pub const Error = Rational.Error;

        /// Convenience helper to clear fields which typically should be cleared between updates.
        pub fn reset(self: *Self) void {
            if (!enabled) return;

            self.probability.reset();
            self.actions = .{};
            self.pending = .{};
        }

        pub fn commit(self: *Self, player: Player, kind: Commit) Error!void {
            if (!enabled) return;

            assert(!showdown);

            if (kind == .glitch and !self.pending.glitch) return;

            var action = self.actions.get(player);

            if (kind == .err and self.pending.crit_probablity != 0) {
                try self.probability.update(self.pending.crit_probablity, 256);
                action.critical_hit = if (self.pending.crit) .true else .false;
                return;
            }

            // Always commit the hit result if we make it here (commit won't be called at all if the
            // target is immune*/behind a sub/etc)
            if (self.pending.hit_probablity != 0) {
                try self.probability.update(self.pending.hit_probablity, 256);
                action.hit = if (self.pending.hit) .true else .false;
            }

            // If the move actually lands we can commit any past critical hit / damage rolls. Note
            // we can't rely on the presence or absence of a damage roll to determine whether a
            // "critical hit" was spurious or not as moves that do 1 or less damage don't roll for
            // damage but can still crit (instead, whether or not a roll is deemed to be a no-op is
            // passed to the critical hit helper).
            //
            // There is a special edge case with the division-by-zero freeze where we need to commit
            // the status of critical hit roll the occured before the move missed to avoid missing
            // out on the possibility that the alternative branch encountered an error
            if (kind != .hit and !self.pending.glitch) {
                return assert(!self.pending.crit or self.pending.crit_probablity > 0);
            }

            if (self.pending.crit_probablity != 0) {
                try self.probability.update(self.pending.crit_probablity, 256);
                action.critical_hit = if (self.pending.crit) .true else .false;
            } else assert(!self.pending.glitch);

            if (self.pending.damage_roll > 0 and (!self.pending.glitch or self.pending.hit)) {
                try self.probability.update(1, 39);
                action.damage = self.pending.damage_roll;
            }
        }

        pub fn glitch(self: *Self) void {
            if (!enabled) return;

            assert(!showdown);
            self.pending.glitch = true;
        }

        pub fn clearPending(self: *Self) void {
            if (!enabled) return;

            assert(!showdown);
            self.pending = .{};
        }

        pub fn switched(self: *Self, player: Player, slot: u8) void {
            if (!enabled) return;

            assert(slot >= 1 and slot <= 6);

            var d = self.durations.get(player);

            const out = Sleeps.get(d.sleeps, 0);
            d.sleeps = Sleeps.set(d.sleeps, 0, Sleeps.get(d.sleeps, slot - 1));
            d.sleeps = Sleeps.set(d.sleeps, slot - 1, out);

            d.confusion = 0;
            d.disable = 0;
            d.attacking = 0;
            d.binding = 0;

            self.durations.get(player.foe()).binding = 0;
        }

        pub fn speedTie(self: *Self, p1: bool) Error!void {
            if (!enabled) return;

            try self.probability.update(1, 2);
            self.actions.p1.speed_tie = if (p1) .P1 else .P2;
            self.actions.p2.speed_tie = self.actions.p1.speed_tie;
        }

        pub fn hit(self: *Self, player: Player, ok: bool, accuracy: uN) Error!void {
            if (!enabled) return;

            const p = if (ok) accuracy else @as(u8, @intCast(256 - @as(u9, accuracy)));
            if (showdown) {
                try self.probability.update(p, 256);
                self.actions.get(player).hit = if (ok) .true else .false;
            } else {
                self.pending.hit = ok;
                self.pending.hit_probablity = p;
            }
        }

        pub fn criticalHit(self: *Self, player: Player, crit: bool, rate: u8) Error!void {
            if (!enabled) return;

            const n = if (crit) rate else @as(u8, @intCast(256 - @as(u9, rate)));
            if (showdown) {
                try self.probability.update(n, 256);
                self.actions.get(player).critical_hit = if (crit) .true else .false;
            } else {
                self.pending.crit = crit;
                self.pending.crit_probablity = n;
            }
        }

        pub fn damage(self: *Self, player: Player, roll: u8) Error!void {
            if (!enabled) return;

            if (showdown) {
                try self.probability.update(1, 39);
                self.actions.get(player).damage = roll;
            } else {
                self.pending.damage_roll = roll;
            }
        }

        pub fn secondaryChance(self: *Self, player: Player, proc: bool, rate: u8) Error!void {
            if (!enabled) return;

            const n = if (proc) rate else @as(u8, @intCast(256 - @as(u9, rate)));
            try self.probability.update(n, 256);
            self.actions.get(player).secondary_chance = if (proc) .true else .false;
        }

        pub fn confused(self: *Self, player: Player, cfz: bool) Error!void {
            if (!enabled) return;

            try self.probability.update(1, 2);
            self.actions.get(player).confused = if (cfz) .true else .false;
        }

        pub fn paralyzed(self: *Self, player: Player, par: bool) Error!void {
            if (!enabled) return;

            try self.probability.update(@as(u8, if (par) 1 else 3), 4);
            self.actions.get(player).paralyzed = if (par) .true else .false;
        }

        pub fn moveSlot(
            self: *Self,
            player: Player,
            slot: u4,
            ms: []const MoveSlot,
            n: u4,
        ) Error!void {
            if (!enabled) return;

            const denominator = if (n != 0) n else denominator: {
                var i: usize = ms.len;
                while (i > 0) {
                    i -= 1;
                    if (ms[i].id != .None) break :denominator i + 1;
                }
                unreachable;
            };

            if (denominator != 1) try self.probability.update(1, denominator);
            self.actions.get(player).move_slot = @intCast(slot);
        }

        pub fn multiHit(self: *Self, player: Player, n: u3) Error!void {
            if (!enabled) return;

            try self.probability.update(@as(u8, if (n > 3) 1 else 3), 8);
            self.actions.get(player).multi_hit = n;
        }

        pub fn duration(self: *Self, player: Player, turns: u4) void {
            if (!enabled) return;

            self.actions.get(player).duration = if (options.key) 2 else turns;
        }

        pub fn observe(
            self: *Self,
            comptime field: Action.Field,
            player: Player,
            obs: Optional(Confusion),
        ) void {
            if (!enabled) return;

            var a = self.actions.get(player);
            const val = @field(a, @tagName(field));
            switch (obs) {
                .overwritten => {
                    assert(field == .confusion);
                    assert(val == .started or val == .continuing);
                    assert(a.duration > 0);
                    a.confusion = obs;
                    self.durations.get(player).confusion = 1;
                },
                .None => {
                    @field(a, @tagName(field)) = .None;
                    if (field == .sleep) {
                        var d = self.durations.get(player);
                        d.sleeps = Sleeps.set(d.sleeps, 0, 0);
                    } else {
                        @field(self.durations.get(player), @tagName(field)) = 0;
                    }
                },
                .started => {
                    assert(val == .None or val == .ended);
                    assert(switch (field) {
                        .confusion => a.duration > 0 or self.actions.get(player.foe()).duration > 0,
                        .sleep, .disable => self.actions.get(player.foe()).duration > 0,
                        else => a.duration > 0,
                    });
                    @field(a, @tagName(field)) = .started;
                    if (field == .sleep) {
                        var d = self.durations.get(player);
                        d.sleeps = Sleeps.set(d.sleeps, 0, 1);
                    } else {
                        @field(self.durations.get(player), @tagName(field)) = 1;
                    }
                },
                else => unreachable,
            }
        }

        pub fn sleep(self: *Self, player: Player, obs: Optional(Observation)) Error!void {
            if (!enabled) return;

            var a = self.actions.get(player);
            assert(a.sleep == .None or a.sleep == .started);
            a.sleep = obs;

            var d = self.durations.get(player);
            const n = Sleeps.get(d.sleeps, 0);

            if (obs == .None) {
                d.sleeps = Sleeps.set(d.sleeps, 0, 0);
            } else if (obs == .ended) {
                assert(n >= 1 and n <= 7);
                if (n != 7) try self.probability.update(1, 8 - @as(u4, n));
                d.sleeps = Sleeps.set(d.sleeps, 0, 0);
            } else {
                assert(obs == .continuing);
                assert(n >= 1 and n < 7);
                try self.probability.update(8 - @as(u4, n) - 1, 8 - @as(u4, n));
                d.sleeps = Sleeps.set(d.sleeps, 0, n + 1);
            }
        }

        pub fn confusion(self: *Self, player: Player, obs: Optional(Confusion)) Error!void {
            if (!enabled) return;

            var a = self.actions.get(player);
            assert(a.confusion == .None or a.confusion == .started);
            a.confusion = obs;

            var d = self.durations.get(player);
            const n = d.confusion;

            if (obs == .ended) {
                assert(n >= 2 and n <= 5);
                if (n != 5) try self.probability.update(1, 6 - @as(u4, n));
                d.confusion = 0;
            } else {
                assert(obs == .continuing);
                assert(n >= 1 and n < 5);
                if (n > 1) try self.probability.update(6 - @as(u4, n) - 1, 6 - @as(u4, n));
                d.confusion += 1;
            }
        }

        pub fn disable(self: *Self, player: Player, obs: Optional(Observation)) Error!void {
            if (!enabled) return;

            var a = self.actions.get(player);
            assert(a.disable == .None or a.disable == .started);
            a.disable = obs;

            var d = self.durations.get(player);
            const n = d.disable;

            if (obs == .ended) {
                assert(n >= 1 and n <= 8);
                if (n != 8) try self.probability.update(1, 9 - @as(u4, n));
                d.disable = 0;
            } else {
                assert(obs == .continuing);
                assert(n >= 1 and n < 8);
                try self.probability.update(9 - @as(u4, n) - 1, 9 - @as(u4, n));
                d.disable += 1;
            }
        }

        pub fn attacking(self: *Self, player: Player, obs: Optional(Observation)) Error!void {
            if (!enabled) return;

            var a = self.actions.get(player);
            assert(a.attacking == .None or a.attacking == .started);
            a.attacking = obs;

            var d = self.durations.get(player);
            const n = d.attacking;
            if (obs == .ended) {
                // "3-4 turns" includes the turn for the initial attack *plus* the forced attacks
                assert(n >= 2 and n <= 3);
                if (n != 3) try self.probability.update(1, 4 - @as(u4, n));
                d.attacking = 0;
            } else {
                assert(obs == .continuing);
                assert(n >= 1 and n < 3);
                if (n > 1) try self.probability.update(4 - @as(u4, n) - 1, 4 - @as(u4, n));
                d.attacking += 1;
            }
        }

        pub fn binding(self: *Self, player: Player, obs: Optional(Observation)) Error!void {
            if (!enabled) return;

            var a = self.actions.get(player);
            assert(a.binding == .None or a.binding == .started);
            a.binding = obs;

            var d = self.durations.get(player);
            const n = d.binding;

            assert(n > 0);
            const p: u4 = if (n < 3) 3 else 1;
            const q: u4 = if (n < 3) 8 - ((n - 1) * p) else 2;

            if (obs == .ended) {
                // "2-5 turns" includes the turn for the initial attack *plus* the forced attacks
                assert(n >= 1 and n <= 4);
                if (n != 4) try self.probability.update(p, q);
                d.binding = 0;
            } else {
                assert(obs == .continuing);
                assert(n >= 1 and n < 4);
                try self.probability.update(q - p, q);
                d.binding += 1;
            }
        }

        pub fn psywave(self: *Self, player: Player, power: u8, max: u8) Error!void {
            if (!enabled) return;

            try self.probability.update(1, max);
            self.actions.get(player).psywave = power + 1;
        }

        pub fn metronome(self: *Self, player: Player, move: Move) Error!void {
            if (!enabled) return;

            try self.probability.update(1, Move.METRONOME.len);
            self.actions.get(player).metronome = move;
        }

        pub fn pp(self: *Self, player: Player, n: u4) bool {
            if (!enabled) return true;

            var a = self.actions.get(player);
            if (n > 1 and a.pp == n) return false;
            if (a.metronome != .None) a.pp += n;
            return true;
        }
    };
}

test "Chance.speedTie" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    try chance.speedTie(true);
    try expectProbability(&chance.probability, 1, 2);
    try expectValue(Optional(Player).P1, chance.actions.p1.speed_tie);
    try expectValue(chance.actions.p1.speed_tie, chance.actions.p2.speed_tie);

    chance.reset();

    try chance.speedTie(false);
    try expectProbability(&chance.probability, 1, 2);
    try expectValue(Optional(Player).P2, chance.actions.p1.speed_tie);
    try expectValue(chance.actions.p1.speed_tie, chance.actions.p2.speed_tie);
}

test "Chance.hit" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    try chance.hit(.P1, true, 229);
    if (!showdown) {
        try expectProbability(&chance.probability, 1, 1);
        try expectValue(Optional(bool).None, chance.actions.p1.hit);

        try chance.commit(.P1, .hit);
    }
    try expectValue(Optional(bool).true, chance.actions.p1.hit);
    try expectProbability(&chance.probability, 229, 256);

    chance.reset();

    try chance.hit(.P2, false, 255);
    if (!showdown) {
        try expectProbability(&chance.probability, 1, 1);
        try expectValue(Optional(bool).None, chance.actions.p2.hit);

        try chance.commit(.P2, .miss);
    }
    try expectValue(Optional(bool).false, chance.actions.p2.hit);
    try expectProbability(&chance.probability, 1, 256);
}

test "Chance.criticalHit" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    try chance.criticalHit(.P1, true, 17);
    if (showdown) {
        try expectValue(Optional(bool).true, chance.actions.p1.critical_hit);
        try expectProbability(&chance.probability, 17, 256);
    } else {
        try expectProbability(&chance.probability, 1, 1);
        try expectValue(Optional(bool).None, chance.actions.p1.critical_hit);

        try chance.hit(.P1, true, 128);

        try expectProbability(&chance.probability, 1, 1);
        try expectValue(Optional(bool).None, chance.actions.p1.critical_hit);

        try chance.damage(.P1, 217);

        try expectProbability(&chance.probability, 1, 1);
        try expectValue(Optional(bool).None, chance.actions.p1.critical_hit);

        try chance.commit(.P1, .hit);

        try expectProbability(&chance.probability, 17, 19968); // (1/2) * (17/256) * (1/39)
        try expectValue(Optional(bool).true, chance.actions.p1.critical_hit);
    }

    chance.reset();

    try chance.criticalHit(.P2, false, 5);
    if (showdown) {
        try expectProbability(&chance.probability, 251, 256);
        try expectValue(Optional(bool).false, chance.actions.p2.critical_hit);
    } else {
        try expectProbability(&chance.probability, 1, 1);
        try expectValue(Optional(bool).None, chance.actions.p1.critical_hit);

        try chance.hit(.P1, true, 128);

        try expectProbability(&chance.probability, 1, 1);
        try expectValue(Optional(bool).None, chance.actions.p1.critical_hit);

        try chance.damage(.P1, 217);
        try chance.commit(.P1, .hit);

        try expectProbability(&chance.probability, 251, 19968); // (1/2) * (251/256) * (1/39)
        try expectValue(Optional(bool).false, chance.actions.p1.critical_hit);
    }
}

test "Chance.damage" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    try chance.damage(.P1, 217);
    if (showdown) {
        try expectValue(@as(u8, 217), chance.actions.p1.damage);
        try expectProbability(&chance.probability, 1, 39);
    } else {
        try expectProbability(&chance.probability, 1, 1);
        try expectValue(@as(u8, 0), chance.actions.p1.damage);

        try chance.commit(.P1, .hit);

        try expectProbability(&chance.probability, 1, 39);
        try expectValue(@as(u8, 217), chance.actions.p1.damage);
    }
}

test "Chance.secondaryChance" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    try chance.secondaryChance(.P1, true, 25);
    try expectProbability(&chance.probability, 25, 256);
    try expectValue(Optional(bool).true, chance.actions.p1.secondary_chance);

    chance.reset();

    try chance.secondaryChance(.P2, false, 77);
    try expectProbability(&chance.probability, 179, 256);
    try expectValue(Optional(bool).false, chance.actions.p2.secondary_chance);
}

test "Chance.confused" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    try chance.confused(.P1, false);
    try expectProbability(&chance.probability, 1, 2);
    try expectValue(Optional(bool).false, chance.actions.p1.confused);

    chance.reset();

    try chance.confused(.P2, true);
    try expectProbability(&chance.probability, 1, 2);
    try expectValue(Optional(bool).true, chance.actions.p2.confused);
}

test "Chance.paralyzed" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    try chance.paralyzed(.P1, false);
    try expectProbability(&chance.probability, 3, 4);
    try expectValue(Optional(bool).false, chance.actions.p1.paralyzed);

    chance.reset();

    try chance.paralyzed(.P2, true);
    try expectProbability(&chance.probability, 1, 4);
    try expectValue(Optional(bool).true, chance.actions.p2.paralyzed);
}

test "Chance.moveSlot" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };
    var ms = [_]MoveSlot{ .{ .id = Move.Surf }, .{ .id = Move.Psychic }, .{ .id = Move.Recover } };

    try chance.moveSlot(.P2, 2, &ms, 2);
    try expectProbability(&chance.probability, 1, 2);
    try expectValue(@as(u4, 2), chance.actions.p2.move_slot);

    chance.reset();

    try chance.moveSlot(.P1, 1, &ms, 0);
    try expectProbability(&chance.probability, 1, 3);
    try expectValue(@as(u4, 1), chance.actions.p1.move_slot);
}

test "Chance.multiHit" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    try chance.multiHit(.P1, 3);
    try expectProbability(&chance.probability, 3, 8);
    try expectValue(@as(u4, 3), chance.actions.p1.multi_hit);

    chance.reset();

    try chance.multiHit(.P2, 5);
    try expectProbability(&chance.probability, 1, 8);
    try expectValue(@as(u4, 5), chance.actions.p2.multi_hit);
}

test "Chance.duration" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    chance.duration(.P1, 2);
    try expectValue(@as(u4, 2), chance.actions.p1.duration);

    chance.reset();

    chance.duration(.P2, 4);
    try expectValue(@as(u4, 4), chance.actions.p2.duration);
}

test "Chance.sleep" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    for ([_]u8{ 7, 6, 5, 4, 3, 2, 1 }, 1..8) |d, i| {
        chance.durations.p1.sleeps = Sleeps.set(chance.durations.p1.sleeps, 0, @intCast(i));
        try chance.sleep(.P1, .ended);
        try expectProbability(&chance.probability, 1, d);
        try expectValue(@as(u3, 0), Sleeps.get(chance.durations.p1.sleeps, 0));

        chance.reset();

        if (i < 7) {
            chance.durations.p1.sleeps = Sleeps.set(chance.durations.p1.sleeps, 0, @intCast(i));
            try chance.sleep(.P1, .continuing);
            try expectProbability(&chance.probability, d - 1, d);
            try expectValue(@as(u3, @intCast(i)) + 1, Sleeps.get(chance.durations.p1.sleeps, 0));

            chance.reset();
        }
    }
}

test "Chance.confusion" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    for ([_]u8{ 1, 4, 3, 2, 1 }, 1..6) |d, i| {
        if (i > 1) {
            chance.durations.p2.confusion = @intCast(i);
            try chance.confusion(.P2, .ended);
            try expectProbability(&chance.probability, 1, d);
            try expectValue(@as(u3, 0), chance.durations.p2.confusion);

            chance.reset();
        }

        if (i < 5) {
            chance.durations.p2.confusion = @intCast(i);
            try chance.confusion(.P2, .continuing);
            try expectProbability(&chance.probability, if (d > 1) d - 1 else d, d);
            try expectValue(@as(u3, @intCast(i)) + 1, chance.durations.p2.confusion);

            chance.reset();
        }
    }
}

test "Chance.disable" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    for ([_]u8{ 8, 7, 6, 5, 4, 3, 2, 1 }, 1..9) |d, i| {
        chance.durations.p1.disable = @intCast(i);
        try chance.disable(.P1, .ended);
        try expectProbability(&chance.probability, 1, d);
        try expectValue(@as(u4, 0), chance.durations.p1.disable);

        chance.reset();

        if (i < 8) {
            chance.durations.p1.disable = @intCast(i);
            try chance.disable(.P1, .continuing);
            try expectProbability(&chance.probability, d - 1, d);
            try expectValue(@as(u4, @intCast(i)) + 1, chance.durations.p1.disable);

            chance.reset();
        }
    }
}

test "Chance.attacking" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    for ([_]u8{ 1, 2, 1 }, 1..4) |d, i| {
        if (i > 1) {
            chance.durations.p2.attacking = @intCast(i);
            try chance.attacking(.P2, .ended);
            try expectProbability(&chance.probability, 1, d);
            try expectValue(@as(u3, 0), chance.durations.p2.attacking);

            chance.reset();
        }

        if (i < 3) {
            chance.durations.p2.attacking = @intCast(i);
            try chance.attacking(.P2, .continuing);
            try expectProbability(&chance.probability, if (d > 1) d - 1 else d, d);
            try expectValue(@as(u3, @intCast(i)) + 1, chance.durations.p2.attacking);

            chance.reset();
        }
    }
}

test "Chance.binding" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    const ps = [_]u8{ 3, 3, 1, 1 };
    const qs = [_]u8{ 8, 5, 2, 1 };

    for (ps, qs, 1..5) |p, q, i| {
        chance.durations.p1.binding = @intCast(i);
        try chance.binding(.P1, .ended);
        try expectProbability(&chance.probability, p, q);
        try expectValue(@as(u3, 0), chance.durations.p1.binding);

        chance.reset();

        if (i < 4) {
            chance.durations.p1.binding = @intCast(i);
            try chance.binding(.P1, .continuing);
            try expectProbability(&chance.probability, q - p, q);
            try expectValue(@as(u3, @intCast(i)) + 1, chance.durations.p1.binding);

            chance.reset();
        }
    }
}

test "Chance.psywave" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    try chance.psywave(.P2, 100, 150);
    try expectProbability(&chance.probability, 1, 150);
    try expectValue(@as(u8, 101), chance.actions.p2.psywave);
}

test "Chance.metronome" {
    var chance: Chance(rational.Rational(u64)) = .{ .probability = .{} };

    try chance.metronome(.P1, Move.HornAttack);
    try expectProbability(&chance.probability, 1, 163);
    try expectValue(Move.HornAttack, chance.actions.p1.metronome);
}

pub fn expectProbability(r: anytype, p: u64, q: u64) !void {
    if (!enabled) return;

    r.reduce();
    if (r.p != p or r.q != q) {
        print("expected {d}/{d}, found {}\n", .{ p, q, r });
        return error.TestExpectedEqual;
    }
}

pub fn expectValue(a: anytype, b: anytype) !void {
    if (!enabled) return;

    try expectEqual(a, b);
}

/// Null object pattern implementation of Generation I `Chance` which does nothing, though chance
/// tracking should additionally be turned off entirely via `options.chance`.
pub const NULL: Null = .{};

const Null = struct {
    pub const Error = error{};

    pub fn commit(self: Null, player: Player, kind: Commit) Error!void {
        _ = .{ self, player, kind };
    }

    pub fn glitch(self: Null) void {
        _ = .{self};
    }

    pub fn clearPending(self: Null) void {
        _ = .{self};
    }

    pub fn switched(self: Null, player: Player, slot: u8) void {
        _ = .{ self, player, slot };
    }

    pub fn speedTie(self: Null, p1: bool) Error!void {
        _ = .{ self, p1 };
    }

    pub fn hit(self: Null, player: Player, ok: bool, accuracy: uN) Error!void {
        _ = .{ self, player, ok, accuracy };
    }

    pub fn criticalHit(self: Null, player: Player, crit: bool, rate: u8) Error!void {
        _ = .{ self, player, crit, rate };
    }

    pub fn damage(self: Null, player: Player, roll: u8) Error!void {
        _ = .{ self, player, roll };
    }

    pub fn confused(self: Null, player: Player, ok: bool) Error!void {
        _ = .{ self, player, ok };
    }

    pub fn paralyzed(self: Null, player: Player, ok: bool) Error!void {
        _ = .{ self, player, ok };
    }

    pub fn secondaryChance(self: Null, player: Player, proc: bool, rate: u8) Error!void {
        _ = .{ self, player, proc, rate };
    }

    pub fn moveSlot(self: Null, player: Player, slot: u4, ms: []const MoveSlot, n: u4) Error!void {
        _ = .{ self, player, slot, ms, n };
    }

    pub fn multiHit(self: Null, player: Player, n: u3) Error!void {
        _ = .{ self, player, n };
    }

    pub fn duration(self: Null, player: Player, turns: u4) void {
        _ = .{ self, player, turns };
    }

    pub fn observe(
        self: Null,
        comptime field: Action.Field,
        player: Player,
        obs: Optional(Confusion),
    ) void {
        _ = .{ self, field, player, obs };
    }

    pub fn sleep(self: Null, player: Player, obs: Optional(Observation)) Error!void {
        _ = .{ self, player, obs };
    }

    pub fn confusion(self: Null, player: Player, obs: Optional(Confusion)) Error!void {
        _ = .{ self, player, obs };
    }

    pub fn disable(self: Null, player: Player, obs: Optional(Observation)) Error!void {
        _ = .{ self, player, obs };
    }

    pub fn attacking(self: Null, player: Player, obs: Optional(Observation)) Error!void {
        _ = .{ self, player, obs };
    }

    pub fn binding(self: Null, player: Player, obs: Optional(Observation)) Error!void {
        _ = .{ self, player, obs };
    }

    pub fn psywave(self: Null, player: Player, power: u8, max: u8) Error!void {
        _ = .{ self, player, power, max };
    }

    pub fn metronome(self: Null, player: Player, move: Move) Error!void {
        _ = .{ self, player, move };
    }

    pub fn pp(self: Null, player: Player, n: u4) bool {
        _ = .{ self, player, n };
        return true;
    }
};
