<script src="main.js">
    import { onMount } from "svelte";

    import { wasmExports, playerBox, enemyBox } from './stores.js';
    import {WASIWorkerHost} from "@runno/wasi";
    import TreeWorker from './tree-worker?worker'

    import Settings      from './components/Settings.svelte';
    import Import        from './components/Import.svelte';
    import Box           from './components/Box.svelte';
    import Editor        from './components/Editor.svelte';
    import DecisionGraph from './components/DecisionGraph.svelte';

    onMount(async () => {
        function wasmWorker(modulePath) {
            const proxy = {};
         
            let id = 0;
            let idPromises = {};

            return new Promise((resolve, reject) => {
                const worker = new TreeWorker();
                worker.postMessage({eventType: "INITIALIZE", eventData: modulePath});

                worker.addEventListener('message', function(event) {
                    const { eventType, eventData, eventId } = event.data;
                    
                    if (eventType === "INITIALIZED") {
                        proxy['clear'] = function() {
                            return new Promise((resolve, reject) => {
                                worker.postMessage({
                                    eventType: "CLEAR",
                                    eventId: id
                                });

                                idPromises[id] = { resolve, reject };
                                id++;
                            });
                        }

                        proxy['importPokemon'] = function(importJSON, player) {
                            return new Promise((resolve, reject) => {
                                worker.postMessage({
                                    eventType: "IMPORT_POKEMON",
                                    eventData: {
                                        import: JSON.parse(JSON.stringify(importJSON)),
                                        player: player
                                    },
                                    eventId: id
                                });

                                idPromises[id] = { resolve, reject };
                                id++;
                            });
                        }

                        proxy['generateTree'] = function() {
                            return new Promise((resolve, reject) => {
                                worker.postMessage({
                                    eventType: "GENERATE_TREE",
                                    eventId: id
                                });

                                idPromises[id] = { resolve, reject };
                                id++;
                            });
                        }

                        proxy['populateGraph'] = function() {
                            return new Promise((resolve, reject) => {
                                worker.postMessage({
                                    eventType: "POPULATE_GRAPH",
                                    eventId: id
                                });

                                idPromises[id] = { resolve, reject };
                                id++;
                            });
                        }
                        
                        resolve(proxy);
                        return;
                    } else if (eventType === "RESULT") {
                        if (eventId !== undefined && idPromises[eventId]) {
                            idPromises[eventId].resolve(eventData);
                            delete idPromises[eventId];
                        }
                    }
                     
                });

                // Handles any errors within the worker thread itself,
                // not individual functions
                worker.addEventListener("error", function(error) {
                    reject(error);
                });
            })
        }

        // $wasmExports = await wasmWorker("gen1.wasm");
        // await $wasmExports.init();

        const binaryURL = new URL("gen1.wasm", window.location.origin).toString();
        const workerHost = new WASIWorkerHost(binaryURL, {
            args: [],
            env: {},
            stdout: (out) => console.log("stdout", out),
            stderr: (err) => console.log("stderr", err),
            fs: {},
        });

        const result = await workerHost.start();

        workerHost.pushStdin("bye world");
        console.log("Finished");
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
