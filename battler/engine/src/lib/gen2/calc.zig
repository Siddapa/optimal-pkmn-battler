const chance = @import("chance.zig");
const common = @import("../common/data.zig");
const Optional = @import("../common/optional.zig").Optional;
const pkmn = @import("../pkmn.zig");
const std = @import("std");
const util = @import("../common/util.zig");

const Action = chance.Action;
const Actions = chance.Actions;
const assert = std.debug.assert;
const Criticals = chance.Criticals;
const Damages = chance.Damages;
const enabled = pkmn.options.calc;
const isPointerTo = util.isPointerTo;
const Player = common.Player;
const PointerType = util.PointerType;

const Int = if (@hasField(std.builtin.Type, "int")) .int else .Int;
const Enum = if (@hasField(std.builtin.Type, "enum")) .@"enum" else .Enum;

/// Information relevant to damage calculation that occured during a Generation II battle `update`.
pub const Summaries = extern struct {
    /// Relevant information for Player 1.
    p1: Summary = .{},
    /// Relevant information for Player 2.
    p2: Summary = .{},

    comptime {
        assert(@sizeOf(Summaries) == 12);
    }

    /// Returns the `Summary` for the given `player`.
    pub fn get(self: anytype, player: Player) PointerType(@TypeOf(self), Summary) {
        assert(isPointerTo(self, Summaries));
        return if (player == .P1) &self.p1 else &self.p2;
    }
};

/// Information relevant to damage calculation that occured during a Generation II battle `update`
/// for a single player.
pub const Summary = extern struct {
    /// The computed raw damage values.
    damage: Damage = .{},

    /// Intermediate raw damage values computed during a calculation.
    pub const Damage = extern struct {
        /// The base computed damage before the damage roll is applied.
        base: u16 = 0,
        /// The final computed damage that gets applied to the Pokémon. May exceed the target's HP
        // (to determine the *actual* damage done compare the target's stored HP before and after).
        final: u16 = 0,
        /// Whether higher damage will saturate / result in the same outcome (e.g. additional damage
        /// gets ignored due to it already breaking a Substitute or causing the target to faint).
        capped: bool = false,

        // NOTE: 15 bits padding

        comptime {
            assert(@sizeOf(Damage) == 6);
        }
    };

    comptime {
        assert(@sizeOf(Summary) == 6);
    }
};

/// Allows for forcing the value of specific RNG events during a Generation II battle `update` via
/// `overrides` and tracks `summaries` of information relevant to damage calculation.
pub const Calc = struct {
    /// Overrides the normal behavior of the RNG during an `update` to force specific outcomes.
    overrides: Actions = .{},
    /// Information relevant to damage calculation.
    summaries: Summaries = .{},

    pub fn overridden(
        self: Calc,
        player: Player,
        hit: u3,
        comptime field: Action.Field,
    ) ReturnType(field) {
        if (!enabled) return null;

        const val = switch (field) {
            .damages => Damages.get(self.overrides.get(player).damages, hit),
            .critical_hits => Criticals.get(self.overrides.get(player).critical_hits, hit),
            else => val: {
                assert(hit == 0);
                break :val @field(self.overrides.get(player), @tagName(field));
            },
        };

        return if (switch (@typeInfo(@TypeOf(val))) {
            Enum => val != .None,
            Int => val != 0,
            else => unreachable,
        }) val else null;
    }

    pub fn base(self: *Calc, player: Player, val: u16) void {
        if (!enabled) return;

        self.summaries.get(player).damage.base = val;
    }

    pub fn final(self: *Calc, player: Player, val: u16) void {
        if (!enabled) return;

        self.summaries.get(player).damage.final = val;
    }

    pub fn capped(self: *Calc, player: Player) void {
        if (!enabled) return;

        self.summaries.get(player).damage.capped = true;
    }
};

/// Null object pattern implementation of Generation II `Calc` which does nothing, though damage
/// calculator support should additionally be turned off entirely via `options.calc`.
pub const NULL: Null = .{};

const Null = struct {
    pub fn overridden(
        self: Null,
        player: Player,
        hit: u3,
        comptime field: Action.Field,
    ) ReturnType(field) {
        _ = .{ self, player, hit };
        return null;
    }

    pub fn base(self: Null, player: Player, val: u16) void {
        _ = .{ self, player, val };
    }

    pub fn final(self: Null, player: Player, val: u16) void {
        _ = .{ self, player, val };
    }

    pub fn capped(self: Null, player: Player) void {
        _ = .{ self, player };
    }
};

fn ReturnType(comptime field: Action.Field) type {
    return ?(switch (field) {
        .damages => u8,
        .critical_hits => Optional(bool),
        else => std.meta.FieldType(Action, field),
    });
}
