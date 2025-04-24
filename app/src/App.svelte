<script src="main.js">
    import { onMount } from "svelte";

    import { wasmWorker, playerBox, enemyBox } from './stores.ts';
    import { WASIReactorWorkerHost } from './wasi/host.ts';
    import { Int32, Uint32 } from './wasi/types.ts';

    import Settings      from './components/Settings.svelte';
    import Import        from './components/Import.svelte';
    import Box           from './components/Box.svelte';
    import Editor        from './components/Editor.svelte';
    import DecisionGraph from './components/DecisionGraph.svelte';

    onMount(async () => {
        const binaryURL = new URL("gen1.wasm", window.location.origin).toString();
        $wasmWorker = new WASIReactorWorkerHost(
            binaryURL,
            4,
            (err) => {
                let err_message;
                switch (err) {
                    case 1:
                        err_message = "UnhandledError!";
                        break;
                    case 2:
                        err_message = "LoadingTypeMismatch!";
                        break;
                    case 3:
                        err_message = "TooManyEnemies";
                        break;
                    case 4:
                        err_message = "OutOfMemory!";
                        break;
                    case 5:
                        err_message = "LoadingTypeWithUnknownTag";
                        break;
                    default:
                        err_message = "";
                        break;
                };
                if (err_message != "") throw new Error(err_message);
            },
        );
        await $wasmWorker.initialize();
        // console.log(await $wasmWorker.exports.test_memory(new Int32(-1), new Uint32(1), "passing", new Int32Array([-1, -2, -3]), new Uint32Array([1, 2, 3])));
        await $wasmWorker.exports.init();
    })
</script>


<main>
    <div class="container">
        <div class="import">
            <Import/>
        </div>
        <div class="boxes">
            <Box mons={playerBox} type="player"/>
            <Box mons={enemyBox} type="enemy"/>
        </div>
        <div class="settings">
            <Settings/>
        </div>
        <div class="editor">
            <Editor/>
        </div>
        <div class="decision-tree">
            <DecisionGraph/>
        </div>
    </div>
</main>


<style>
    .container {
        display: grid;
        grid-template-columns: repeat(3, fit-content(100%));
        grid-template-rows: repeat(2, fit-content(100%));
        padding-top: 3em;
        padding-side: 3em;
        grid-column-gap: 3em;
        grid-row-gap: 3em;
    }

    .decision-tree {
        grid-area: 1 / 3 / 3 / 4;
    }

    .boxes {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        grid-column-gap: 1em;
    }
</style>
