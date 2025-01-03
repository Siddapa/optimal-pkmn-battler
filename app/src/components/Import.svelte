<div>
    <h3>Import</h3>

    <div class="imports-container">
        <div class="import">
            <select bind:this={playerFormat}>
                <option value="Normal">Normal</option>
                <option value="Packed">Packed</option>
                <option value="JSON">JSON</option>
            </select>
            <textarea class="import-input" rows="15" cols="12" bind:this={playerImport}></textarea>
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
            <textarea class="import-input" rows="15" cols="10" bind:this={enemyImport}></textarea>
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
            // const memoryView = new Uint8Array($wasmExports.memory.buffer);
            // const { size } = new TextEncoder().encodeInto(playerImport.value, memoryView);
            // $wasmExports.importPlayerPokemon(0, size);
        }
        
        if (enemyImport.value != "") {
            if (enemyFormat.value == "Normal") {
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
    }

    function normalToJson(importTeam) {
        var lines = importTeam.split("\n");
        const numOfLines = lines.length;
        var box = [];
        var newPokemon = {"name": ""};
        for (let i = 0; i < numOfLines; i++) {
            const line = lines[i]

            const species_item = line.match(/([\'\w\s-]+) @ ([\w\s-]+)/);
            const species_gender_item = line.match(/([\'\(\)\w\s-]+) \(([M|F])\) @ ([\w\s-]+)/);
            const ability = line.match(/Ability: ([\w\s-]+)/);
            const ivs = line.match(/IVs: (.+)/);
            const evs = line.match(/EVs: (.+)/);
            const nature = line.match(/([\w\s-]+) Nature/);
            const move = line.match(/- ([\w\s-]+)/);

            if (species_item) {
                newPokemon["species"] = species_item[1];
                newPokemon["item"] = species_item[2].trim();
            } else if (species_gender_item) {
                newPokemon["species"] = species_gender_item[1];
                newPokemon["gender"] = species_gender_item[2];
                newPokemon["item"] = species_gender_item[3].trim();
            } else if (ability) {
                newPokemon["ability"] = ability[1].trim();
            } else if (ivs) {
                const perStat = ivs[1].matchAll(/(\d+) (\w+)/g);
                const numOfStats = perStat.length;
                var ivsJson = {};
                for (let j = 0; j < numOfStats; j++) {
                    const value = perStat[j][1];
                    const stat = perStat[j][2];
                    newPokemon["ivs"][value.toLower()] = stat;
                }
            } else if (evs) {
                const perStat = evs[1].matchAll(/(\d+) (\w+)/g);
                const numOfStats = perStat.length;
                var evsJson = {};
                for (let j = 0; j < numOfStats; j++) {
                    const value = perStat[j][1];
                    const stat = perStat[j][2];
                    newPokemon["evs"][value.toLower()] = stat;
                }
            } else if (nature) {
                newPokemon["nature"] = nature[1];
            } else if (move) {
                if (!newPokemon["moves"]) {
                    newPokemon["moves"] = [];
                }
                newPokemon["moves"].push(move[1].trim());
            } else {
                if (newPokemon["species"]) {
                    box.push(newPokemon);
                }
                newPokemon = {"name": ""};
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
        const contentType = await fetch("sprites/gen1/" + pokemon['species'].toLowerCase() + ".PNG")
                                  .then((response) => Object.fromEntries(response.headers))
                                  .then((headers) => headers["content-type"]);

        if (contentType == "image/png") {
            return true
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
