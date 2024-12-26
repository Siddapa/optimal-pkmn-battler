import {Generations} from '@pkmn/data';
import {Dex, PRNG} from '@pkmn/sim';

import {Options} from '../test/benchmark';

import {Battle} from './index';

for (const gen of new Generations(Dex as any)) {
  if (gen.num > 1) {
    describe(`Gen ${gen.num}`, () => {
      test('Battle.create/restore', () => {
        const options = {showdown: true} as any;
        expect(() => Battle.create(gen, options)).toThrow('Unsupported gen');
        expect(() => Battle.restore(gen, {} as any, options)).toThrow('Unsupported gen');
      });
    });
    continue;
  }

  describe(`Gen ${gen.num}`, () => {
    test('Battle.create/restore', () => {
      const options = Options.get(gen, new PRNG([1, 2, 3, 4]));
      const battle = Battle.create(gen, options);
      const restored = Battle.restore(gen, battle, options);
      expect(restored.toJSON()).toEqual(battle.toJSON());
    });
  });
}
