<script src="main.js">
    import PanningDecisionTree from './PanningDecisionTree.svelte';
    import { WASI } from "@runno/wasi";


    async function tester() {
        const result = WASI.start(fetch("/gen1.wasm"), {
            args: [],
            env: {},
            stdout: (out) => console.log("stdout", out),
            stderr: (err) => console.log("stderr", err),
            stdin: () => prompt("stdin:"),
            fs: {},
        });
    }
    

    async function generate_decision_tree() {
        const wasi = new WASI({
            args: [],
            env: {},
            stdout: (out) => console.log("stdout", out),
            stdin: () => prompt("stdin:"),
            fs: {},
        });
        const myMemory = new WebAssembly.Memory({ initial: 32, maximum: 1000 });
        const wasm = await WebAssembly.instantiateStreaming(fetch("gen1.wasm"), {
            ...wasi.getImportObject(),
            env: {},
        });
        const result = wasi.start(wasm, {});

        console.log(wasm.instance.exports.blah());

        const { generateOptimizedDecisionTree, getNodeSpecies, memory } = wasm.instance.exports;
        const root = generateOptimizedDecisionTree();
        console.log(root);

        const speciesStr = fetchString(memory, root, 0, getNodeSpecies);
        console.log(speciesStr);
    }

    function fetchString(memory, root, start_index, func) {
        const strLength = func(root, true, start_index); // 0 is pointer for top of memory.buffer
        const outputView = new Uint8Array(memory.buffer, 0, strLength);
        return new TextDecoder().decode(outputView);
    }


    generate_decision_tree();
    // const { memory, getOptimizedDecisionTree, getNodeSpecies, allocBytes, freeBytes, processValues } = generate_decision_tree();

    // const values_len = 10;
    // const values_ptr = allocBytes(values_len * Int32Array.BYTES_PER_ELEMENT);
    // // Address 0 isn't protected in wasm so don't forget to check for null!
    // if (values_ptr === 0) {
    //     throw new Error("OOM")
    // }
    // try {
    //     const values = new Int32Array(memory.buffer, values_ptr, values_len);
    //     for (let i = 0; i < values_len; i++) values[i] = 2 * i - 6;
    //     processValues(values_ptr, values_len);
    // } finally {
    //     freeBytes(values_ptr, values_len * Int32Array.BYTES_PER_ELEMENT)
    // }
</script>


<main class="container">
    <div class="settings">
        <h3>Settings</h3>
    </div>
    <div class="import">
        <h3>Hello</h3>
        <form method="POST">
            <input class="import-input" type="text" align="left">
            <br>
            <input value="Import Box" class="import-submit" type="submit">
        </form>
    </div>
    <div class="box" overflow-y=auto>
        <h3>Box</h3>
        <div class="box-container">
            <img class="box-mon" src="sprites/gen1/mew.PNG" alt="Empty Image">
        </div>
    </div>
    <div class="editor">
        <h3>Editor</h3>
        <div class="editor-inline">
            <h5>Type: </h5>
            <select max-height=10px>
                <option value="None">-</option>
                <option value="Normal">Normal</option>
                <option value="Fire">Fire</option>
                <option value="Water">Water</option>
                <option value="Electric">Electric</option>
                <option value="Grass">Grass</option>
                <option value="Ice">Ice</option>
                <option value="Fighting">Fighting</option>
                <option value="Poison">Poison</option>
                <option value="Ground">Ground</option>
                <option value="Flying">Fighting</option>
                <option value="Psychic">Psychic</option>
                <option value="Bug">Bug</option>
                <option value="Rock">Rock</option>
                <option value="Ghost">Ghost</option>
                <option value="Dragon">Dragon</option>
            </select>
            <select max-height=10px>
                <option value="None">-</option>
                <option value="Normal">Normal</option>
                <option value="Fire">Fire</option>
                <option value="Water">Water</option>
                <option value="Electric">Electric</option>
                <option value="Grass">Grass</option>
                <option value="Ice">Ice</option>
                <option value="Fighting">Fighting</option>
                <option value="Poison">Poison</option>
                <option value="Ground">Ground</option>
                <option value="Flying">Fighting</option>
                <option value="Psychic">Psychic</option>
                <option value="Bug">Bug</option>
                <option value="Rock">Rock</option>
                <option value="Ghost">Ghost</option>
                <option value="Dragon">Dragon</option>
            </select>
        </div>
    </div>
    <div class = "decision-tree">
        <h3>Decision Tree</h3>
        <PanningDecisionTree/>
    </div>
</main>


<style>
    .container {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        grid-template-rows: repeat(2, 1fr);
        grid-column-gap: 100px;
        grid-row-gap: 0px;
    }
    .container > div {
        min-width: 300px;
        min-height: 300px;
    }

    .settings {
        grid-area: 1 / 1 / 2 / 2;
    }
    .import {
        grid-area: 1 / 2 / 2 / 3;
    }
    .box {
        width: fit-content;
        grid-area: 2 / 1 / 3 / 2;
    }
    .editor {
        grid-area: 2 / 2 / 3 / 3;
    }
    .decision-tree {
        grid-area: 1 / 3 / 3 / 4;
    }

    .box-container {
        display: grid;
        grid-template-columns: auto auto auto auto auto auto;
        overflow-y: auto;
        overflow-x: hidden;
        height: 300px;
        width: 500px;
        background-image: url("backgrounds/beach.png");
        background-size: cover;
        border: 3px solid blue;
        grid-row-gap: 10px;
        grid-column-gap: 10px;
        padding: 5px;
    }

    canvas {
        box-sizing: border-box;
        width: 100%;
        height: 100%;
        user-select: none;
        touch-action: none;
        background-color: #ccc;
        overscroll-behavior: none;
        -webkit-user-select: none; /* disable selection/Copy of UIWebView */
        -webkit-touch-callout: none; /* disable the IOS popup when long-press on a link */
    }

    .editor-inline {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        width: fit-content;
        column-gap: 10px;
    }

    .box-mon {
        mix-blend-mode: multiply;
    }

    .import-input {
        width: 200px;
        height: 200px;
    }
</style>
