import * as fs from 'fs';
import * as path from 'path';

import {Generations} from '@pkmn/data';
import {Dex} from '@pkmn/sim';

import * as addon from '../pkg/addon';

import * as fuzz from './fuzz';
import * as integration from './integration';

const FIXTURES = path.join(__dirname, 'fixtures');
const SKIP: string[] = [];

const gens = new Generations(Dex as any);
for (const gen of gens) {
  if (gen.num > 1) break;
  (addon.supports(true, true) ? describe : describe.skip)(`Gen ${gen.num}`, () => {
    const dir = path.join(FIXTURES, `gen${gen.num}`);
    for (const file of fs.readdirSync(path.join(dir))) {
      const name = file.slice(0, file.indexOf('.'));
      (SKIP.includes(name) ? test.skip : test)(`${name}`, async () => {
        if (file.endsWith('log')) {
          expect(await integration.run(gens, path.join(dir, file))).toBe(0);
        } else {
          const showdown = file.includes('showdown');
          expect(await fuzz.run(gens, path.join(dir, file), showdown, true)).toBe(true);
        }
      });
    }
  });
}
