/** Representation of one of a battle's participants. */
export type Player = 'p1' | 'p2';

/** A choice made by a player during battle. */
export interface Choice {
  /** The choice type. */
  type: 'pass' | 'move' | 'switch';
  /**
   * The choice data:
   *
   *    - 0 for 'pass'
   *    - 0-4 for 'move'
   *    - 2-6 for 'switch'
   */
  data: number;
}

/**
 * The result of the battle - all defined results should be considered terminal.
 */
export interface Result {
  /**
   * The type of result from the perspective of Player 1:
   *
   *   - undefined: no result, battle is non-terminal
   *   - win: Player 1 wins
   *   - lose: Player 2 wins
   *   - tie: Player 1 & 2 tie
   *   - error: the battle has terminated in error (e.g. due to a desync)
   *
   * 'error' is not possible when in Pokémon Showdown compatibility mode.
   */
  type: undefined | 'win' | 'lose' | 'tie' | 'error';
  /** The choice type of the result for Player 1. */
  p1: Choice['type'];
  /** The choice type of the result for Player 2. */
  p2: Choice['type'];
}

/** Utilities for working with `Choice` objects. */
export class Choice {
  /** Encoded values of the various choice types. */
  static Encoding = {pass: 0, move: 1, switch: 2} as const;
  /** All valid choices types. */
  static Types = Object.keys(Choice.Encoding) as readonly Choice['type'][];

  protected static MATCH = /^(?:(pass)|((move) ([0-4]))|((switch) ([2-6])))$/;

  private constructor() {}

  /** Decode a choice from its binary representation. */
  static decode(byte: number): Choice {
    return {type: Choice.Types[byte & 0b11], data: byte >> 2};
  }

  /** Encode a choice to its binary representation. */
  static encode(choice?: Choice): number {
    return (choice ? (choice.data << 2 | Choice.Encoding[choice.type]) : 0);
  }

  /**
   * Parse a Pokémon Showdown choice string into a `Choice`.
   * Only numeric choice data is supported.
   */
  static parse(choice: string): Choice {
    const m = Choice.MATCH.exec(choice);
    if (!m) throw new Error(`Invalid choice: '${choice}'`);
    const type = (m[1] ?? m[3] ?? m[6]) as Choice['type'];
    const data = +(m[4] ?? m[7] ?? 0);
    return {type, data};
  }

  /** Formats a `Choice` into a Pokémon Showdown compatible choice string. */
  static format(choice: Choice): string {
    return choice.type === 'pass' ? choice.type : `${choice.type} ${choice.data}`;
  }

  /** The canonical "pass" `Choice`. */
  static pass: Choice = {type: 'pass', data: 0} as const;

  /** Returns a "move" `Choice` with the provided data. */
  static move(data: 0 | 1 | 2 | 3 | 4): Choice {
    return {type: 'move', data};
  }

  /** Returns a "switch" `Choice` with the provided data. */
  static switch(data: 2 | 3 | 4 | 5 | 6): Choice {
    return {type: 'switch', data};
  }
}

/** Utilities for working with `Result` objects. */
export class Result {
  /** Encoded values of non-empty various result types. */
  static Encoding = {win: 1, lose: 2, tie: 3, error: 4} as const;
  /** All valid result types. */
  static Types = [undefined, 'win', 'lose', 'tie', 'error'] as const;

  private constructor() {}

  /** Decode a `Result` from its binary representation. */
  static decode(byte: number): Result {
    return {
      type: Result.Types[byte & 0b1111],
      p1: Choice.Types[(byte >> 4) & 0b11],
      p2: Choice.Types[byte >> 6],
    };
  }

  /** Encode a `Result`` to its binary representation. */
  static encode(result: Result): number {
    return ((result.type ? Result.Encoding[result.type] : 0) |
        Choice.Encoding[result.p1] << 4 |
        Choice.Encoding[result.p2] << 6);
  }
}
