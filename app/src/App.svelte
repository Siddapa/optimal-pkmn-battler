<script src="main.js">
    import { onMount } from "svelte";

    import { wasmExports, playerBox, enemyBox } from './stores.js';
    import TreeWorker from './tree-worker?worker'
    import * as binaryen from "binaryen";
    import * as Asyncify from 'https://unpkg.com/asyncify-wasm?module';

    import Settings      from './components/Settings.svelte';
    import Import        from './components/Import.svelte';
    import Box           from './components/Box.svelte';
    import Editor        from './components/Editor.svelte';
    import DecisionGraph from './components/DecisionGraph.svelte';

    onMount(async () => {
        function wasmWorker(modulePath) {
         
            // Create an object to later interact with 
            const proxy = {};
         
            // Keep track of the messages being sent
            // so we can resolve them correctly
            let id = 0;
            let idPromises = {};

            return new Promise((resolve, reject) => {
                const worker = new TreeWorker();

                worker.addEventListener('message', function(event) {
                    const { eventType, eventData, eventId } = event.data;
                    
                    if (eventType === "INITIALIZED") {
                        const methods = event.data.eventData;
                        methods.forEach((method) => {
                            proxy[method] = function() {
                                return new Promise((resolve, reject) => {
                                    worker.postMessage({
                                        eventType: "CALL",
                                        eventData: {
                                            method: method,
                                            arguments: Array.from(arguments) // arguments is not an array
                                        },
                                        eventId: id
                                    });
                                    
                                    idPromises[id] = { resolve, reject };
                                    id++
                                });
                            }
                        });
                        resolve(proxy);
                        return;
                    } else if (eventType === "RESULT") {
                        if (eventId !== undefined && idPromises[eventId]) {
                            idPromises[eventId].resolve(eventData);
                            delete idPromises[eventId];
                        }
                    } else if (eventType === "ERROR") {
                        if (eventId !== undefined && idPromises[eventId]) {
                            idPromises[eventId].reject(event.data.eventData);
                            delete idPromises[eventId];
                        }
                    }
                     
                });

                worker.addEventListener("error", function(error) {
                    reject(error);
                });

                worker.postMessage({eventType: "INITIALIZE", eventData: modulePath});
            })
         
        }

        console.log("Hello");
        wasmWorker("gen1.wasm").then((proxyInstance) => {
            proxyInstance.check()
                .then((result) => {
                    console.log(result);
                })
                .catch((error) => {
                    console.log(error);
                });
        });
        console.log("Goodbye");


        // console.log(typeof binaryen.readBinary)
        // const ir = binaryen.readBinary(`
        //   (module
        //     (memory 1 1)
        //     (import "env" "before" (func $before))
        //     (import "env" "sleep" (func $sleep (param i32)))
        //     (import "env" "after" (func $after))
        //     (export "memory" (memory 0))
        //     (export "main" (func $main))
        //     (func $main
        //       (call $before)
        //       (call $sleep (i32.const 2000))
        //       (call $after)
        //     )
        //   )
        // `);
        // // const ir = new binaryen.parseText(fetch('gen1.wasm'));

        // binaryen.setOptimizeLevel(1);
        // ir.runPasses(['asyncify']);

        // const binary = ir.emitBinary();
        // const compiled = new WebAssembly.Module(binary);
        // const instance = new WebAssembly.Instance(compiled, {});





        // const worker = new Worker("./src/tree-worker.js");
        // const obj = Comlink.wrap(worker);

        // console.log(obj);
        // console.log(await obj.counter);
        // await obj.init();

        // console.log(await obj.counter);




        // const wasi = new WASI({
        //     args: [],
        //     env: {},
        //     stdout: (out) => console.log("stdout", out),
        //     stderr: (out) => console.log("stdout", out),
        //     stdin: () => prompt("stdin:"),
        //     fs: {},
        // });
        // const wasm = await WebAssembly.instantiateStreaming(
        //     fetch("gen1.wasm"), {
        //         ...wasi.getImportObject(),
        //         env: {},
        //     });
        // // const result = wasi.start(wasm, {});

        // $wasmExports = wasm.instance.exports;
        // $wasmExports.memory.grow(100);
        // $wasmExports.init();
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
