import {
  BoostID, BoostsTable, Generation, ID, PokemonSet, StatID, StatsTable, StatusName, TypeName,
} from '@pkmn/data';

import * as addon from './addon';
import {Choice, Player, Result} from './common';
import {Lookup} from './data';
import * as gen1 from './gen1';

/** The one-indexed location of a player's Pokémon in battle. */
export type Slot = 1 | 2 | 3 | 4 | 5 | 6;

/** Representation of the entire state of a Pokémon battle. */
export type Battle = Gen1.Battle;
/** Representation of one side of a Pokémon battle's state. */
export type Side = Gen1.Side;
/** Representation of the state for single Pokémon in a battle. */
export type Pokemon = Gen1.Pokemon;
/** Representation of a Pokémon's move slot in a battle. */
export type MoveSlot = Gen1.MoveSlot;

/** Generic API supported by all Generations of Battle. */
export interface API {
  /**
   * The most recent buffer of binary protocol message log data filled by
   * `update` if logging is enabled, otherwise undefined. Meant to be parsed by
   * `Log`.
   */
  log?: DataView;
  /** FIXME */
  bytes(): DataView;
  /**
  * Returns the result of applying Player 1's choice `c1` and Player 2's choice
  * `c2` to the battle.
  */
  update(c1: Choice, c2: Choice): Result;
  /**
   * Returns all possible choices for the `player` given the previous `result`
   * of an {@link update}.
   *
   * This function may return zero results in Generation I if Pokémon Showdown
   * compatibility move is not enabled due to how the Transform + Mirror
   * Move/Metronome PP error interacts with Disable (i.e. on the cartridge a
   * soft-lock occurs).
   */
  choices(player: Player, result: Result): Choice[];
  /** Returns a copy of the Battle data. */
  toJSON(): Data<Battle>;
}

/** Helper type removing function types from a data type `T`. */
export type Data<T> =
  T extends readonly any[] ? {[K in keyof T]: Data<T[K]>} :
  T extends Iterable<infer U> ? (U extends object ? Iterable<Data<U>> : T) :
  // eslint-disable-next-line @typescript-eslint/no-unsafe-function-type
  T extends object ? {[K in keyof T as T[K] extends Function ? never : K]: Data<T[K]>} : T;

/** Type definitions for Generation I Pokémon data relevant in a battle. */
export namespace Gen1 {
  /** Representation of the entire state of a Generation I Pokémon battle. */
  export interface Battle extends API {
    /** The sides involved in the battle. */
    sides: Iterable<Side>;
    /** Returns the side of the `player`. */
    side(player: Player): Side;
    /** Returns the opposing side to `player`. */
    foe(player: Player): Side;
    /** The battle's current turn number. */
    turn: number;
    /** The last damage dealt by either side. */
    lastDamage: number;
    /**
     * The RNG state - a 4-tuple representing 16-bit big-endian chunks of a
     * 64-bit state if Pokémon Showdown compatibility mode is enabled, otherwise
     * a 10-tuple with each value representing one byte of the RNG's current
     * state.
     */
    prng: readonly number[];
  }

  /** Representation of one side of a Generation I Pokémon battle's state. */
  export interface Side {
    /**
     * The active Pokémon for the side, or undefined if the battle has yet to
     * start. Note that fainted Pokémon are still consider "active" until their
     * replacement switches in.
     */
    active: Pokemon | undefined;
    /**
     * The player's party in its current order (e.g. after taking into account
     * the effect switching would have on its original order).
     */
    pokemon: Iterable<Pokemon>;
    /**
     * Returns the current slot of the Pokémon that started the battle at index
     * `id`, or undefined if the index is invalid.
     */
    slot(id: number): Slot | undefined;
    /**
     * Returns the Pokémon currently at the provided `slot`, or undefined if
     * nothing occupies the slot.
     */
    get(slot: Slot): Pokemon | undefined;
    /** The last move the player used. */
    lastUsedMove: ID | undefined;
    /** The last move the player selected. */
    lastSelectedMove: ID | undefined;
    /** The move slot index of the last move selected in the battle menu. */
    lastMoveIndex: 1 | 2 | 3 | 4 | undefined;
    /** Whether the last move executed by the player was counterable. */
    lastMoveCounterable: boolean;
  }

  /**
   * Representation of the state for single Generation I Pokémon in a battle.
   */
  export interface Pokemon {
    /**
     * The Pokémon's current species (which may differ from its original stored
     * species).
     */
    species: ID;
    /**
     * The Pokémon's current typing (which may differ from its original stored
     * types).
     */
    types: readonly [TypeName, TypeName];
    /** The Pokémon's level. */
    level: number;
    /** The Pokémon's current level. */
    hp: number;
    /** The Pokémon's current status. */
    status: StatusName | undefined;
    /** Additional data related to the Pokémon's status. */
    statusData: {
      /** If status is slp, the number of sleep turns remaining. */
      sleep: number;
      /** If status is slp, whether or not it was self-inflicted. */
      self: boolean;
      /** The state of the Toxic counter. */
      toxic: number;
    };
    /**
     * The Pokémon's current stats, after accounting for modification from
     * boosts/status/etc (and which may differ from its original stored stats).
     */
    stats: StatsTable;
    /** Returns the value Pokémon's current `stat`. */
    stat(stat: StatID | 'spc'): number;
    /** The Pokémon's current boosts. */
    boosts: BoostsTable;
    /** Returns the value Pokémon's current `boost`. */
    boost(boost: BoostID): number;
    /**
     * The Pokémon's move slots (which may differ from its original stored
     * moves).
     */
    moves: Iterable<MoveSlot>;
    /** The Pokémon's current move at `slot`, or undefined if absent. */
    move(slot: 1 | 2 | 3 | 4): MoveSlot | undefined;
    /** The Pokémon's volatiles statuses. */
    volatiles: Volatiles;
    stored: {
      /** The Pokémon's original species. */
      species: ID;
      /** The Pokémon's original typing. */
      types: readonly [TypeName, TypeName];
      /** The Pokémon original unmodified stats.  */
      stats: StatsTable;
      /** Returns the value Pokémon's original `stat`. */
      stat(stat: StatID | 'spc'): number;
      /** The Pokémon's original move slots.  */
      moves: Iterable<Omit<MoveSlot, 'disabled'>>;
      /** The Pokémon's original move at `slot`, or undefined if absent. */
      move(slot: 1 | 2 | 3 | 4): Omit<MoveSlot, 'disabled'> | undefined;
    };
    /** The current one-indexed position of this Pokémon in the party. */
    position: Slot;
  }

  /** Representation of a Generation I Pokémon's move slot in a battle. */
  export interface MoveSlot {
    /** The identifier for the move. */
    id: ID;
    /** The remaining PP of the move. */
    pp: number;
    /** If present, the remaining number of turns this move slot is disabled. */
    disabled?: number;
  }

  /**
   * Representation of an active Generation I Pokémon's volatile status state in
   * a battle.
   */
  export interface Volatiles {
    /** Whether the "Bide" volatile status is present. */
    bide?: {
      /** The number of turns before energy is unleashed. */
      duration: number;
      /** The total damage accumulated by Bide. */
      damage: number;
    };
    /** Whether the "Thrashing" volatile status is present. */
    thrashing?: {
      /** The number of attacks remaining. */
      duration: number;
      /**
       * The thrashing move's current overwritten accuracy as a number from 1-255.
       * 0 if not overwritten. Also note that it may be "overwritten" to its original 255 accuracy.
       */
      accuracy: number;
    };
    /** Whether the "Flinch" volatile status is present. */
    flinch?: unknown;
    /** Whether the "Charging" volatile status is present. */
    charging?: unknown;
    /** Whether the "Binding" volatile status is present. */
    binding?: {
      /** The number of attacks remaining. */
      duration: number;
    };
    /** Whether the "Invulnerable" volatile status is present. */
    invulnerable?: unknown;
    /** Whether the "Confusion" volatile status is present. */
    confusion?: {
      /** The number of confusion turns remaining. */
      duration: number;
    };
    /** Whether the "Mist" volatile status is present. */
    mist?: unknown;
    /** Whether the "FocusEnergy" volatile status is present. */
    focusenergy?: unknown;
    /** Whether the "Substitute" volatile status is present. */
    substitute?: {
      /** The Substitute's current HP. */
      hp: number;
    };
    /** Whether the "Recharging" volatile status is present. */
    recharging?: unknown;
    /** Whether the "Rage" volatile status is present. */
    rage?: {
      /**
       * Rage's current overwritten accuracy as a number from 1-255. 0 if not overwritten.
       * Also note that it may be "overwritten" to its original 255 accuracy.
       */
      accuracy: number;
    };
    /** Whether the "LeechSeed" volatile status is present. */
    leechseed?: unknown;
    /** Whether the "LightScreen" volatile status is present. */
    lightscreen?: unknown;
    /** Whether the "Reflect" volatile status is present. */
    reflect?: unknown;
    /** Whether the "Transform" volatile status is present. */
    transform?: {
      /** Which player's Pokémon this Pokémon is transformed into. */
      player: 'p1' | 'p2';
      /** The slot number of the player's Pokémon. */
      slot: number;
    };
  }
}

/** Options for creating a battle via Battle.create. */
export type CreateOptions = {
  /**
   * The seed for the Battle's RNG - the expected format of this value depends
   * on the generation of the Battle being created.
   */
  seed: number[];
  /**
   * Whether or not create a Pokémon Showdown compatible battle or not (requires
   * that the engine be built in a specific compatibility mode).
   */
  showdown?: boolean;
  /** Whether the battle should be initialized without functionality afforded by native code. */
  inert?: true;
} & ({
  /** Player 1's options. */
  p1: PlayerOptions;
  /** Player 2's options. */
  p2: PlayerOptions;
  /**
   * Whether to capture protocol message logs. Note that if the engine itself
   * was not build with protocol logging enabled then enabling this will have no
   * effect.
   */
  log: true;
} | {
  /** Player 1's options. */
  p1: Omit<PlayerOptions, 'name'>;
  /** Player 2's options. */
  p2: Omit<PlayerOptions, 'name'>;
  /**
   * Whether to capture protocol message logs. Note that if the engine itself
   * was not build with protocol logging enabled then enabling this will have no
   * effect.
   */
  log?: false;
});

/** Options for restoring a battle via Battle.restore. */
export type RestoreOptions = {
  /** Player 1's options. */
  p1: PlayerOptions;
  /** Player 2's options. */
  p2: PlayerOptions;
  /**
   * Whether or not create a Pokémon Showdown compatible battle or not (requires
   * that the engine be built in a specific compatibility mode).
   */
  showdown?: boolean;
  /**
   * Whether to capture protocol message logs. Note that if the engine itself
   * was not build with protocol logging enabled then enabling this will have no
   * effect.
   */
  log: true;
} | {
  /**
   * Whether or not create a Pokémon Showdown compatible battle or not (requires
   * that the engine be built in a specific compatibility mode).
   */
  showdown?: boolean;
  /**
   * Whether to capture protocol message logs. Note that if the engine itself
   * was not build with protocol logging enabled then enabling this will have no
   * effect.
   */
  log?: false;
};

/** Options about a particular player. */
export interface PlayerOptions {
  /** The player's name. */
  name: string;
  /** The player's team. */
  team: Partial<PokemonSet>[];
}

/** Factory for creating Battle objects. */
export const Battle = new class {
  /** Create a `Battle` in the given generation with the provided options. */
  create(gen: Generation, options: CreateOptions): Battle {
    addon.check(!!options.showdown);
    const lookup = Lookup.get(gen);
    switch (gen.num) {
      case 1: return gen1.Battle.create(gen, lookup, options);
      default: throw new Error(`Unsupported gen ${gen.num}`);
    }
  }

  /**
   * Restore a (possibly in-progress) `Battle` in the given generation with the
   * provided options.
   */
  restore(gen: Generation, battle: Data<Battle>, options: RestoreOptions): Battle {
    addon.check(!!options.showdown);
    const lookup = Lookup.get(gen);
    switch (gen.num) {
      case 1: return gen1.Battle.restore(gen, lookup, battle, options);
      default: throw new Error(`Unsupported gen ${gen.num}`);
    }
  }
};

export {initialize} from './addon';
export {Choice, Result} from './common';
export type {Player} from './common';
export type {ParsedLine, PokemonInfo} from './protocol';
export {Info, SideInfo, Log} from './protocol';
export {Lookup} from './data';
