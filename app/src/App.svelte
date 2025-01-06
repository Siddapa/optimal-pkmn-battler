<script src="main.js">
    import { onMount } from "svelte";
    import { WASI } from "@runno/wasi";

    import { wasmExports } from './stores.js';
    import Settings            from './components/Settings.svelte';
    import Import              from './components/Import.svelte';
    import PlayerBox                 from './components/PlayerBox.svelte';
    import EnemyBox                 from './components/EnemyBox.svelte';
    import Editor              from './components/Editor.svelte';
    import PanningDecisionTree from './components/PanningDecisionTree.svelte';

    onMount(async () => {
        const wasi = new WASI({
            args: [],
            env: {},
            stdout: (out) => console.log("stdout", out),
            stderr: (out) => console.log("stdout", out),
            stdin: () => prompt("stdin:"),
            fs: {},
        });
        const wasm = await WebAssembly.instantiateStreaming(
            fetch("gen1.wasm"), {
                ...wasi.getImportObject(),
                env: {},
            });
        const result = wasi.start(wasm, {});

        $wasmExports = wasm.instance.exports;
        $wasmExports.init();
    })
</script>


<main class="container">
    <div class="settings">
        <Settings/>
    </div>
    <div class="import">
        <Import/>
    </div>
    <div class="boxes">
        <PlayerBox/>
        <EnemyBox/>
    </div>
    <div class="editor">
        <Editor/>
    </div>
    <div class = "decision-tree">
        <PanningDecisionTree/>
    </div>
</main>


<style>
    .container {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        grid-template-rows: repeat(2, 1fr);
        padding-top: 0px;
        padding-side: 0px;
        grid-column-gap: 20px;
        grid-row-gap: 0px;
    }
    

    .import {
        grid-area: 1 / 1 / 2 / 2;
    }
    .boxes {
        display: flex;
        grid-area: repeat(2, 1fr);
        column-gap: 10px;
        height: fit-content;
        width: fit-content;
        overflow-y: auto;
        grid-area: 1 / 2 / 2 / 3;
    }
    .editor {
        height: fit-content;
        width: fit-content;
        grid-area: 1 / 3 / 2 / 4;
    }
    .settings {
        height: fit-content;
        width: fit-content;
        grid-area: 2 / 1 / 3 / 3;
    }
    .decision-tree {
        height: fit-content;
        width: fit-content;
        grid-area: 1 / 4 / 3 / 5;
    }
</style>
