<div>
    <h3>Import</h3>

    <div class="imports-container">
        <div class="import">
            <select bind:this={playerFormat}>
                <option value="Normal">Normal</option>
                <option value="Packed">Packed</option>
                <option value="JSON">JSON</option>
            </select>
            <textarea class="import-input" rows="15" cols="12" bind:this={playerImport}>Articuno
- Ice Beam
- Growl
- Tackle
- Wrap

Kingler
- Sand Attack
- Headbutt
- Horn Attack
- Tail Whip

Rhyhorn
- Flamethrower
- Mist
- Water Gun
- Psybeam</textarea>
            <br>
            {#each invalidPlayerImports as alert}
                <span class="invalid-import">{alert['species']} is not within this generation!</span>
                <br>
            {/each}
        </div>
        <div class="import">
            <select bind:this={enemyFormat}>
                <option value="Normal">Normal</option>
                <option value="Packed">Packed</option>
                <option value="JSON">JSON</option>
            </select>
            <textarea class="import-input" rows="15" cols="10" bind:this={enemyImport}>Jynx
- Aurora Beam
- Hyper Beam
- Blizzard
- Peck

Chansey
- Counter
- Seismic Toss
- Strength
- Absorb

Goldeen
- Razor Leaf
- SolarBeam
- Poison Powder
- Fire Spin</textarea>
            <br>
            {#each invalidEnemyImports as alert}
                <span class="invalid-import">{alert['species']} is not within this generation!</span>
                <br>
            {/each}
        </div>
    </div>
    <input type="submit" value="Import Boxes" onclick={submitImport}>
</div>

<script>
    import { wasmExports, playerBox, enemyBox } from '../stores.js';

    let playerImport;
    let playerFormat;
    let enemyImport;
    let enemyFormat;
    let invalidPlayerImports = $state([]);
    let invalidEnemyImports = $state([]);

    const submitImport = async () => {
        $wasmExports.clear();
        if (playerImport.value != "") {
            if (playerFormat.value == "Normal") {
                $playerBox = [];
                $playerBox = normalToJson(playerImport.value);
                const promises = $playerBox.map(async (pokemon) => ({
                    valid: await validateBox(pokemon),
                    value: pokemon
                }));
                const resolvedBox = await Promise.all(promises);
                const validPlayerBox = resolvedBox.filter(validity => validity.valid).map(pokemon => pokemon.value);
                invalidPlayerImports = $playerBox.filter(x => !validPlayerBox.includes(x));
                $playerBox = validPlayerBox;
            } else if (playerFormat.value == "Packed") {
                // TODO
            }
        }
        
        if (enemyImport.value != "") {
            if (enemyFormat.value == "Normal") {
                $enemyBox = [];
                $enemyBox = normalToJson(enemyImport.value);
                const promises = $enemyBox.map(async (pokemon) => ({
                    valid: await validateBox(pokemon),
                    value: pokemon
                }));
                const resolvedBox = await Promise.all(promises);
                const validEnemyBox = resolvedBox.filter(validity => validity.valid).map(pokemon => pokemon.value);
                invalidEnemyImports = $enemyBox.filter(x => !validEnemyBox.includes(x));
                $enemyBox = validEnemyBox;
            } else if (enemyformat.value == "Packed") {
                // TODO
            }
        }
        
        for (const pokemon of $playerBox) {
            const memoryView = new Uint8Array($wasmExports.memory.buffer);
            const { written } = new TextEncoder().encodeInto(JSON.stringify(pokemon), memoryView);
            await $wasmExports.importPokemon(0, written, 1);
        }
        for (const pokemon of $enemyBox) {
            const memoryView = new Uint8Array($wasmExports.memory.buffer);
            const { written } = new TextEncoder().encodeInto(JSON.stringify(pokemon), memoryView);
            await $wasmExports.importPokemon(0, written, 0);
        }
        
    }

    function normalToJson(importTeam) {
        var lines = importTeam.split("\n");
        const numOfLines = lines.length;
        var box = [];
        const base_dv = 15;
        const base_exp = 65535;
        var newPokemon = {
            "species": "",
            "dvs": {
                "atk": base_dv,
                "def": base_dv,
                "spc": base_dv,
                "spe": base_dv
            },
            "exp": {
                "hp": base_exp,
                "atk": base_exp,
                "def": base_exp,
                "spc": base_exp,
                "spe": base_exp
            },
            "moves": ["", "", "", ""],
            "bkg-color": 'none',
        };
        var moveID = 0;
        for (let i = 0; i < numOfLines; i++) {
            const line = lines[i];

            const species_item = line.match(/^([\'\w\s-]+)/);
            const ivs = line.match(/IVs: (.+)/);
            const evs = line.match(/EVs: (.+)/);
            const move = line.match(/- ([\w\s-]+)/);

            if (ivs) {
                const stats = ivs[1].matchAll(/(\d+) (\w+)/g);
                for (const stat of stats) {
                    const value = stat[1];
                    const name = stat[2];
                    newPokemon["dvs"][name.toLowerCase()] = Number(value);
                }
            } else if (evs) {
                const stats = evs[1].matchAll(/(\d+) (\w+)/g);
                for (const stat of stats) {
                    const value = stat[1];
                    const name = stat[2];
                    newPokemon["evs"][name.toLowerCase()] = Number(value);
                }
            } else if (move) {
                newPokemon["moves"][moveID] = move[1].trim();
                moveID += 1;
            } else if (species_item) {
                newPokemon["species"] = species_item[1];
            } else {
                if (newPokemon["species"]) {
                    box.push(newPokemon);
                }
                newPokemon = {
                    "species": "",
                    "dvs": {
                        "atk": base_dv,
                        "def": base_dv,
                        "spc": base_dv,
                        "spe": base_dv
                    },
                    "exp": {
                        "hp": base_exp,
                        "atk": base_exp,
                        "def": base_exp,
                        "spc": base_exp,
                        "spe": base_exp
                    },
                    "moves": ["", "", "", ""]
                };
                moveID = 0;
            }
        }
        if (newPokemon["species"]) {
            box.push(newPokemon);
        }
        return box;
    }

    function packedToJSON() {

    }

    async function validateBox(pokemon) {
        const contentType = await fetch("sprites/gen1/" + pokemon['species'].toLowerCase().trim() + ".PNG")
                                  .then((response) => Object.fromEntries(response.headers))
                                  .then((headers) => headers["content-type"]);

        if (contentType == "image/png") {
            return true;
        }
        return false;
    }
</script>

<style>
    .imports-container {
        display: flex;
        flex-direction: row;
        column-gap: 5px;
        width: fit-content;
    }
    .import {
        width: fit-content;
        grid-area: 1 / 1 / 2 / 2;
    }

    .import-input {
        resize: none;
    }

    .invalid-import {
        color: red;
        font-size: 0.75em;
    }
</style>
