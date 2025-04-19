<script src="main.js">
    import { onMount } from "svelte";

    import { wasmWorker, playerBox, enemyBox } from './stores.js';
    import { WASIReactorWorkerHost, Int32, Uint32} from '@runno/wasi';
    import TreeWorker from './tree-worker?worker'

    import Settings      from './components/Settings.svelte';
    import Import        from './components/Import.svelte';
    import Box           from './components/Box.svelte';
    import Editor        from './components/Editor.svelte';
    import DecisionGraph from './components/DecisionGraph.svelte';

    onMount(async () => {
        const binaryURL = new URL("gen1.wasm", window.location.origin).toString();
        $wasmWorker = new WASIReactorWorkerHost(
            binaryURL,
            8, 
            {
                args: [],
                env: {},
                stdout: (out) => console.log("stdout", out),
                stderr: (err) => console.log("stderr", err),
                fs: {},
            },
            (err) => {
                let err_message;
                switch (err) {
                    case 1:
                        err_message = "Unhandled Error!";
                        break;
                    case 2:
                        err_message = "Type Mismatch!";
                        break;
                    case 3:
                        err_message = "TooManyEnemies";
                        break;
                    case 4:
                        err_message = "OutOfMemory!";
                        break;
                    default:
                        err_message = "";
                        break;
                };
                if (err_message != "") console.log("stderr", err_message);
            },
        );

        await $wasmWorker.initialize();
        console.log($wasmWorker.exports);

        const args = await $wasmWorker.exports.test_memory(new Int32(-1), new Uint32(1), "passing", new Int32Array([-1, -1, -1]), new Uint32Array([1, 1, 1]));
        console.log(args);

        await $wasmWorker.exports.init();
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
        <Box mons={playerBox} type="player"/>
        <Box mons={enemyBox} type="enemy"/>
    </div>
    <div class="editor">
        <Editor/>
    </div>
    <div class="decision-tree">
        <DecisionGraph/>
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
        height: fit-content;
        width: fit-content;
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
        grid-area: 1 / 4 / 3 / 5;
    }
    .decision-tree {
        height: fit-content;
        width: fit-content;
        grid-area: 2 / 1 / 3 / 3;
    }
</style>
