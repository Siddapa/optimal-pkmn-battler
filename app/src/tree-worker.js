import {WASI} from "@runno/wasi";

let wasmResolve;
let wasmReady = new Promise((resolve) => {
    wasmResolve = resolve;
})

// Handle incoming messages
self.addEventListener('message', async function(event) {
 
    const { eventType, eventData, eventId } = event.data;
 
    switch (eventType) {
        case "INITIALIZE":
            const wasi = new WASI({
                args: [],
                env: {},
                stdout: (out) => console.log("stdout", out),
                stderr: (out) => console.log("stdout", out),
                stdin: () => prompt("stdin:"),
                fs: {},
            });

            const wasm = await WebAssembly.instantiateStreaming(
                fetch("../gen1.wasm"), {
                    ...wasi.getImportObject(),
                    env: {
                        memory: new WebAssembly.Memory({initial: 5000, maximum: 5000})
                    },
                });

            wasmResolve(wasm.instance.exports);

            self.postMessage({ eventType: 'INITIALIZED' });
            break;

        case "CLEAR":
            wasmReady.then((wasmInstance) => {
                wasmInstance.clear();
                self.postMessage({
                    eventType: "RESULT",
                    eventId: eventId,
                });
            });
            break;

        case "IMPORT_POKEMON":
            wasmReady.then((wasmInstance) => {
                console.log(wasmInstance.memory.buffer);
                const memoryView = new Uint8Array(wasmInstance.memory.buffer);
                const { written } = new TextEncoder().encodeInto(JSON.stringify(eventData.import), memoryView);
                wasmInstance.importPokemon(0, written, eventData.player ? 1 : 0);

                self.postMessage({
                    eventType: "RESULT",
                    eventId: eventId,
                });
            });
            break;

        case "GENERATE_TREE":
            wasmReady.then((wasmInstance) => {
                const method = wasmInstance[eventData.method];
                const result = method.apply(null, eventData.arguments);
                self.postMessage({
                    eventType: "RESULT",
                    eventData: result,
                    eventId: eventId,
                });
            });
            break;

        case "CALL":
            wasmReady.then((wasmInstance) => {
                const method = wasmInstance[eventData.method];
                const result = method.apply(null, eventData.arguments);
                self.postMessage({
                    eventType: "RESULT",
                    eventData: result,
                    eventId: eventId,
                });
            }).catch((error) => {
                self.postMessage({
                    eventType: "ERROR",
                    eventData: error.toString(),
                    eventId: eventId,
                })
            })
            break;
        
    }
}, false);
