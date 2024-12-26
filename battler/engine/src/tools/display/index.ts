import * as fs from 'fs';
import * as path from 'path';

import * as pkmn from '@pkmn/data';
import * as esbuild from 'esbuild';
import {minify} from 'html-minifier';

import type {Battle, Data} from '../../pkg';

import {Move, Species} from './util';

export * from './util';

const ROOT = path.resolve(__dirname, '..', '..', '..');

export function render(entryPoint: string, json: any, options: {
  styles?: string[];
  wasm?: string;
} = {}) {
  const result = esbuild.buildSync({
    jsx: 'transform',
    jsxFactory: 'h',
    jsxFragment: 'Fragment',
    // NB: trying to include the .js built version of this doesn't work, it must be the .ts version
    inject: [path.join(ROOT, 'src', 'tools', 'display', 'dom.ts')],
    entryPoints: [entryPoint],
    // esbuild is insanely annoying and refuses to look in NODE_MODULES to find globally installed
    // packages unless we explicitly tell it to do so. require.resolve.paths will return the full
    // lookup path Node uses... which is what a sane person would expect esbuild to do to begin with
    nodePaths: require.resolve.paths('') ?? [],
    bundle: true,
    write: false,
  });

  const styles = options.styles?.map(style => fs.readFileSync(style, 'utf8')) ?? [];

  return minify(`<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="https://pkmn.cc/favicon.ico">
    <title>@pkmn/engine</title>
    <style>
    ${fs.readFileSync(path.join(ROOT, 'src', 'tools', 'display', 'ui.css'), 'utf8')}
    ${styles.join('')}
    </style>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="content"></div>
    <script>
     window.DATA = ${JSON.stringify(json)};
     ${options.wasm ? `window.WASM = '${options.wasm}';` : ''}

  ${result.outputFiles[0].text}

      for (const details of document.getElementsByTagName('details')) {
        details.addEventListener('toggle', e => {
          for (const d of details.parentElement.parentElement.getElementsByTagName('details')) {
            if (d.open !== details.open) d.open = details.open;
          }
        });
      }
    </script>
  </body>
</html>`, {minifyCSS: true, minifyJS: true});
}

export function prune(gen: pkmn.Generation, battle: Data<Battle>) {
  // In order to avoid requiring the full @pkmn/data Generation (more importantly, the @pkmn/dex Dex
  // data backing it), we need to figure out the minimum amount of data actually required to render
  // the battle. We only need data for the game objects that occur in the battle, though without
  // reading through all of the frames here we can't know for sure what is required. We error on the
  // side of overincluding information to save having to parse the entire buffer twice
  const pruned: {
    num: pkmn.GenerationNum;
    species: {[id: string]: Species};
    moves: {[id: string]: Move};
  } = {num: gen.num, species: {}, moves: {}};

  let metronome = false;
  for (const side of battle.sides) {
    for (const pokemon of side.pokemon) {
      const s = gen.species.get(pokemon.species)!;
      // Certain Pokémon can change formes in battle (eg. Shaymin-Sky -> Shaymin) so
      // we just greedily include all formes of a species just to be safe
      for (const forme of [s.id, ...(s.formes ?? [])]) {
        const species = gen.species.get(forme)!;
        pruned.species[species.id] = pruneSpecies(gen, species);
      }
      // Similarly - Metronome can proc pretty much any other move. If any Pokémon
      // has Metronome we just give up and include the whole set of moves
      if (!metronome) {
        for (const ms of pokemon.moves) {
          if (ms.id === 'metronome') {
            metronome = true;
            break;
          }
          const move = gen.moves.get(ms.id)!;
          pruned.moves[move.id] = pruneMove(gen, move);
        }
      }
    }
  }
  if (metronome) {
    for (const move of gen.moves) {
      pruned.moves[move.id] = pruneMove(gen, move);
    }
  }

  return pruned;
}

export function pruneSpecies(gen: pkmn.Generation, species: pkmn.Specie) {
  return {
    name: species.name,
    num: species.num,
    genderRatio: species.genderRatio,
    gender: species.gender,
  };
}

export function pruneMove(gen: pkmn.Generation, move: pkmn.Move) {
  return {
    name: move.name,
    num: move.num,
    maxpp: Math.min(move.pp / 5 * 8, gen.num === 1 ? 61 : 64),
    basePower: move.basePower,
    type: move.type,
  };
}
