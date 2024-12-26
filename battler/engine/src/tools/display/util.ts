import {GenderName, MoveName, SpeciesName, TypeName} from '@pkmn/data';

import {Battle, Choice, Data, ParsedLine, Result} from '../../pkg';

export interface Frame {
  result: Result;
  c1: Choice;
  c2: Choice;
  battle: Data<Battle>;
  parsed: ParsedLine[];
}

export interface Species {
  name: SpeciesName;
  num: number;
  genderRatio: {M: number; F: number};
  gender?: GenderName;
}

export interface Move {
  name: MoveName;
  num: number;
  maxpp: number;
  basePower: number;
  type: TypeName;
}

const format = (kwVal: any) => typeof kwVal === 'boolean' ? '' : ` ${kwVal as string}`;
const trim = (args: string[]) => {
  while (args.length && !args[args.length - 1]) args.pop();
  return args;
};

const compact = (line: ParsedLine) =>
  [...trim(line.args.slice(0) as string[]), ...Object.keys(line.kwArgs)
    .map(k => `[${k}]${format((line.kwArgs as any)[k])}`)].join('|');

export const toText = (parsed: ParsedLine[]) =>
  parsed.length ? `|${parsed.map(compact).join('\n|')}` : '';

export const pretty = (choice?: Choice) => choice
  ? choice.type === 'pass' ? choice.type : `${choice.type} ${choice.data}`
  : '???';

export const imports = (memory: [WebAssembly.Memory], decoder: TextDecoder) => ({
  js: {
    log(ptr: number, len: number) {
      if (len === 0) return console.log('');
      const msg = decoder.decode(new Uint8Array(memory[0].buffer, ptr, len));
      console.log(msg);
    },
    panic(ptr: number, len: number) {
      const msg = decoder.decode(new Uint8Array(memory[0].buffer, ptr, len));
      throw new Error('panic: ' + msg);
    },
  },
});
