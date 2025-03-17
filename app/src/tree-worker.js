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
                    env: {},
                });
            
            wasmResolve(wasm.instance.exports);

            self.postMessage({
                eventType: 'INITIALIZED',
                eventData: Object.keys(wasm.instance.exports),
            });
            break;

        case "CALL":
            wasmReady
                .then((wasmInstance) => {
                    const method = wasmInstance[eventData.method];
                    const result = method.apply(null, eventData.arguments);
                    self.postMessage({
                        eventType: "RESULT",
                        eventData: result,
                        eventId: eventId,
                    });
                })
                .catch((error) => {
                    self.postMessage({
                        eventType: "ERROR",
                        eventData: error.toString(),
                        eventId: eventId,
                    })
                })
            break;
        
    }
}, false);
