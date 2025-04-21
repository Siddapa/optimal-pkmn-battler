<div>
    <h3>Import</h3>

    <div class="imports">
        <select class="format-selector" bind:this={playerFormat}>
            <option value="Normal">Normal</option>
            <option value="Packed">Packed</option>
            <option value="JSON">JSON</option>
        </select>
        <select class="format-selector" bind:this={enemyFormat}>
            <option value="Normal">Normal</option>
            <option value="Packed">Packed</option>
            <option value="JSON">JSON</option>
        </select>
        <textarea class="import-input" bind:this={playerImport}>Articuno
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
        <textarea class="import-input" bind:this={enemyImport}>Jynx
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
    </div>
    <input type="submit" value="Import Boxes" onclick={submitImport}>
    <div class = "invalid-import">
        {#each invalidPlayerImports as alert}
            <span class="invalid-import">{alert['species']} is not within this generation!</span>
            <br>
        {/each}
    </div>
    <div clas="invalid-import">
        {#each invalidEnemyImports as alert}
            <span class="invalid-import">{alert['species']} is not within this generation!</span>
            <br>
        {/each}
    </div>
</div>

<script>
    import { Uint32 } from '@runno/wasi';
    import { wasmWorker, playerBox, enemyBox } from '../stores.js';

    let playerImport;
    let playerFormat;
    let enemyImport;
    let enemyFormat;
    let invalidPlayerImports = $state([]);
    let invalidEnemyImports = $state([]);

    const submitImport = async () => {
        await $wasmWorker.exports.clear();
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
            await $wasmWorker.exports.importPokemon(JSON.stringify(pokemon), new Uint32(1));
        }
        for (const pokemon of $enemyBox) {
            await $wasmWorker.exports.importPokemon(JSON.stringify(pokemon), new Uint32(0));
        }
    }

    function normalToJson(importTeam) {
        var lines = importTeam.split("\n");
        const numOfLines = lines.length;
        var box = [];
        const base_dv = 15;
        const base_exp = 0xFFFF;
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
        };
        var moveID = 0;
        for (let i = 0; i < numOfLines; i++) {
            const line = lines[i];

            const species_item = line.match(/^([\'\w\s-]+)/);
            const ivs = line.match(/IVs: (.+)/);
            const exp = line.match(/EXP: (.+)/);
            const move = line.match(/- ([\w\s-]+)/);

            if (ivs) {
                const stats = ivs[1].matchAll(/(\d+) (\w+)/g);
                for (const stat of stats) {
                    const value = stat[1];
                    const name = stat[2];
                    newPokemon["dvs"][name.toLowerCase()] = Number(value);
                }
            } else if (exp) {
                const stats = exp[1].matchAll(/(\d+) (\w+)/g);
                for (const stat of stats) {
                    const value = stat[1];
                    const name = stat[2];
                    newPokemon["exp"][name.toLowerCase()] = Number(value);
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
        // TODO Separate .then's into separate variables
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
    .imports {
        width: fit-content;
        height: fit-content;
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        grid-template-rows: repeat(2, fit-content(100%));
        grid-column-gap: 1em;
        grid-row-gap: 0em;
    }

    .format-selector {
        width: 5em;
        height: 2em;
    }

    .import-input {
        width: 10em;
        height: 20em;
    }

    .invalid-import {
        color: red;
        font-size: 0.75em;
    }
</style>
