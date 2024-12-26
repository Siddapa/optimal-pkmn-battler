import * as engine from '../../pkg';
import {LAYOUT, LE} from '../../pkg/data';
import * as gen1 from '../../pkg/gen1';

import {Fragment} from './dom';
import {Battle, Gen, Generation, adapt} from './ui';
import * as util from './util';

class SpeciesNames implements engine.Info {
  gen: Generation;
  battle: engine.Battle;

  constructor(gen: Generation, battle: engine.Battle) {
    this.gen = gen;
    this.battle = battle;
  }

  get p1() {
    const [p1] = Array.from(this.battle.sides);
    const team = Array.from(p1.pokemon)
      .sort((a, b) => a.position - b.position)
      .map(p => ({species: p.stored.species}));
    return new engine.SideInfo(this.gen, {name: 'Player 1', team});
  }

  get p2() {
    const [, p2] = Array.from(this.battle.sides);
    const team = Array.from(p2.pokemon)
      .sort((a, b) => a.position - b.position)
      .map(p => ({species: p.stored.species}));
    return new engine.SideInfo(this.gen, {name: 'Player 2', team});
  }
}

const App = ({gen, data, error, seed}: {
  gen: Generation;
  data: DataView;
  error?: string;
  seed?: bigint;
}) => {
  let offset = 0;
  const showdown = !!data.getUint8(offset);
  offset += 2;
  const N = data.getInt16(offset, LE);
  offset += 2;
  const X = data.getInt32(offset, LE);
  offset += 4;

  const lookup = engine.Lookup.get(gen);
  const size = LAYOUT[gen.num - 1].sizes.Battle;
  const deserialize = (d: DataView): engine.Battle => {
    switch (gen.num) {
      case 1: return new gen1.Battle(lookup, d, {inert: true, showdown});
      default: throw new Error(`Unsupported gen: ${gen.num}`);
    }
  };

  const battle = deserialize(windowed(data, offset, offset += size));
  const names = new SpeciesNames(gen, battle);
  const log = new engine.Log(gen, lookup, names);

  let partial: Partial<util.Frame> | undefined = undefined;
  let last: engine.Data<engine.Battle> = battle;
  const frames: JSX.Element[] = [];
  while (offset < data.byteLength) {
    partial = {parsed: []};

    if (N !== 0) {
      const it = log.parse(windowed(data, offset))[Symbol.iterator]();
      let r = it.next();
      while (!r.done) {
        partial.parsed!.push(r.value);
        r = it.next();
      }
      offset += N > 0 ? N : r.value;
      if (offset >= data.byteLength) break;
    }

    if (X < 0) {
      while (offset < data.byteLength && data.getUint8(offset++));
    } else {
      offset += X;
    }
    if (offset >= data.byteLength) break;

    partial.battle = deserialize(windowed(data, offset, offset += size));
    if (offset >= data.byteLength) break;

    partial.result = engine.Result.decode(data.getUint8(offset++));
    if (offset >= data.byteLength) break;

    partial.c1 = engine.Choice.decode(data.getUint8(offset++));
    if (offset >= data.byteLength) break;

    partial.c2 = engine.Choice.decode(data.getUint8(offset++));

    frames.push(<Frame frame={partial} gen={gen} showdown={showdown} last={last} />);
    last = partial.battle;
    partial = undefined;
  }
  frames.push(<Frame frame={partial || {}} gen={gen} showdown={showdown} last={last} />);

  return <>
    {!!seed && <h1>0x{seed.toString(16).toUpperCase()}</h1>}
    {frames}
    {error && <pre className='error'><code>{error}</code></pre>}
  </>;
};

const Frame = ({frame, gen, showdown, last}: {
  frame: Partial<util.Frame>;
  gen: Generation;
  showdown: boolean;
  last?: engine.Data<engine.Battle>;
}) => <div className='frame'>
  {frame.parsed && <div className='log'>
    <pre><code>{util.toText(frame.parsed)}</code></pre>
  </div>}
  {frame.battle && <Battle battle={frame.battle} gen={gen} showdown={showdown} last={last} />}
  {frame.result && <div className='sides' style={{textAlign: 'center'}}>
    <pre className='side'><code>{frame.result.p1} -&gt; {util.pretty(frame.c1)}</code></pre>
    <pre className='side'><code>{frame.result.p2} -&gt; {util.pretty(frame.c2)}</code></pre>
  </div>}
</div>;

function windowed(data: DataView, byteOffset: number, byteLength?: number) {
  const length = byteLength ? byteLength - byteOffset : undefined;
  return new DataView(data.buffer, data.byteOffset + byteOffset, length);
}

// Data is inlined in the same script tag to save bytes - it would be more proper embed the data in
// a <script type="application/json" id="data">...</script>, however this would force us all of the
// keys to be quoted which wastes space (not to mention parsing the object would then add latency)
const json = (window as any).DATA;
const GEN = adapt(new Gen(json.gen));
// NB: "The Unicode Problem" is not relevant here - we know this isn't Unicode text
// https://developer.mozilla.org/en-US/docs/Glossary/Base64#the_unicode_problem
const buf = Uint8Array.from(atob(json.buf), c => c.charCodeAt(0));
document.getElementById('content')!.appendChild(<App
  gen={GEN}
  data={new DataView(buf.buffer, buf.byteOffset, buf.byteLength)}
  error={json.error}
  seed={json.seed && BigInt(json.seed)}
/>);
