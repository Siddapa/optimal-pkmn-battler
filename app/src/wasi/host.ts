import {
    WASMArgMessage,
    HostMessage,
    WorkerMessage,
} from "./worker";
import { WASMArg, Int32, Uint32 } from "./types.ts";
import WASIReactorWorker from "./worker?worker&inline";

function sendMessage(worker: Worker, message: WorkerMessage) {
    worker.postMessage(message);
}

// (export function names) => (worker promises)
type Exports = Record<string, Function>;
type Callbacks = Record<number, { resolve: Function; reject: Function }>;

export class WASIReactorWorkerHost {
    binaryURL: string;

    worker!: Worker;
    exports: Exports = {};
    memory_start_index: number = 4;
    little_endian: boolean = true;

    callbacks: Callbacks = {};

    constructor(
        binaryURL: string,
        errorHandler: (err: any) => void
    ) {
        this.binaryURL = binaryURL;
        window.addEventListener("unhandledrejection", (event) => 
            errorHandler(event.reason)
        );
    }

    initialize() {
        return new Promise<void>((resolve, _) => {
            this.worker = new WASIReactorWorker();
            this.worker.addEventListener("message", (messageEvent) => {
        const message: HostMessage = messageEvent.data;
                switch (message.type) {
                    case "stdout":
                        console.log("stdout", message.text);
                        break;
                    case "stderr":
                        console.log("stderr", message.text);
                        break;
                    case "initialized":
                        message.exports.forEach((func_name: any, id: number) => {
                            if (func_name === "memory") {
                                return;
                            }
                            this.exports[func_name] = (...args: WASMArg[]) => {
                                let typed_args: WASMArgMessage[] = [];
                                args.forEach((arg: WASMArg) => {
                                    let arg_type: any;
                                    switch (true) {
                                        case arg instanceof Int32:
                                            arg_type = "Int32";
                                            break;
                                        case arg instanceof Uint32:
                                            arg_type = "Uint32";
                                            break;
                                        case typeof arg === "string":
                                            arg_type = "string";
                                            break;
                                        case arg instanceof Int32Array:
                                            arg_type = "Int32Array";
                                            break;
                                        case arg instanceof Uint32Array:
                                            arg_type = "Uint32Array";
                                            break;
                                    }
                                    typed_args.push({ type: arg_type, data: arg });
                                });
                                return new Promise((resolve, reject) => {
                                    sendMessage(this.worker, {
                                    target: "client",
                                        type: "call",
                                        call_id: id,
                                        method: func_name,
                                        args: typed_args,
                                    });
                                    this.callbacks[id] = {
                                        resolve: resolve,
                                        reject: reject,
                                    };
                                });
                            };
                        });
                        resolve();
                        break;
                    case "result":
                        if (message.err_code != 0) {
                            this.callbacks[message.call_id].reject(message.err_code);
                            break;
                        }

                        let ret_vals: any[] = [];
                        let mem_i: object = {data: this.memory_start_index};
                        // this.displayBuffer(message.memory, 40);
                        while (true) {
                            // arg_length includes any bits used for tagging and length storing
                            const arg = this.loadArg(mem_i, message.memory);
                            if (arg === null) {
                                break;
                            }
                            ret_vals.push(arg);
                        }

                        this.callbacks[message.call_id].resolve(ret_vals);

                        // Wipe memory buffer for next export call
                        const buffer = new Int32Array(
                            message.memory,
                            this.memory_start_index,
                            length / 4
                        );
                        buffer.fill(-1);
                        break;
                }
            });

            sendMessage(this.worker, {
                target: "client",
                type: "initialize",
                binaryURL: this.binaryURL,
                memory_start_index: this.memory_start_index,
            });
        });
    }

    displayBuffer(memory: SharedArrayBuffer, count: number): void {
        const view = new DataView(memory);

        for (let i = this.memory_start_index; i < count; i += 4) {
            console.log("db", view.getInt32(i, true));
        }
    }

    loadArg(mem_i: object, memory: SharedArrayBuffer): [any, number] {
        const view = new DataView(memory);

        const tag = view.getInt32(mem_i.data, this.little_endian);
        mem_i.data += 4;

        let arg;
        switch (tag) {
            case -1:
                arg = null;
                break;
            case 1:
                arg = view.getInt32(mem_i.data, this.little_endian);
                mem_i.data += 4;
                break;
            case 2:
                arg = view.getUint32(mem_i.data, this.little_endian);
                mem_i.data += 4;
                break;
            case 3:
                const str_length = view.getUint32(mem_i.data, this.little_endian);
                mem_i.data += 4;

                const str_buffer = new Uint8Array(memory, mem_i.data, str_length);
                mem_i.data += str_length;

                let padding;
                switch (str_length % 4) {
                    case 0: 
                        padding = 0;
                        break;
                    case 1:
                        padding = 3;
                        break;
                    case 2:
                        padding = 2;
                        break;
                    case 3:
                        padding = 1;
                        break;
                }
                mem_i.data += padding;

                arg = new TextDecoder().decode(str_buffer);
                break;
            case 4:
                const i32_length = view.getUint32(mem_i.data, this.little_endian);
                mem_i.data += 4;

                let i32_buffer = [];
                let i32_i = 0;
                while (i32_i < i32_length) {
                    i32_buffer.push(view.getInt32(mem_i.data, this.little_endian));
                    i32_i += 1;
                    mem_i.data += 4;
                }

                arg = new Int32Array(i32_buffer);
                break;
            case 5:
                const u32_length = view.getUint32(mem_i.data, this.little_endian);
                mem_i.data += 4;

                let u32_buffer = [];
                let u32_i = 0;
                while (u32_i < u32_length) {
                    u32_buffer.push(view.getUint32(mem_i.data, this.little_endian));
                    u32_i += 1;
                    mem_i.data += 4;
                }

                arg = new Uint32Array(u32_buffer);
                break;
            case 6:
                mem_i.data -= 4;

                arg = this.loadTree(mem_i, memory);
                break;
            default:
                throw new TypeError(
                    `Unsupported Type Read From Buffer - tag: ${tag}, mem_i: ${mem_i.data}!`
                );
        }

        return arg;
    }

    loadTree(mem_i: object, memory: SharedArrayBuffer) {
        const node_data = this.loadNode(mem_i, memory);
        
        let tree = {data: node_data, children: []};

        switch (node_data) {
            case null:
                return null;
            default:
                let i = 0;
                while (true) {
                    const sub_tree = this.loadTree(mem_i, memory);
                    if (sub_tree == null) break;
                    tree.children.push(sub_tree);
                }
                return tree;
        }
    }

    loadNode(mem_i: object, memory: SharedArrayBuffer): [number, number, number, number] {
        const view = new DataView(memory);

        const tag = view.getInt32(mem_i.data, this.little_endian);
        mem_i.data += 4;

        switch (tag) {
            case 6:
                const data_length = view.getUint32(mem_i.data, this.little_endian);
                mem_i.data += 4;

                let node_data = [];
                for (let i = 0; i < data_length; i++) {
                    const node_arg = this.loadArg(mem_i, memory);
                    node_data.push(node_arg);
                }

                return node_data;
            case -2:
                return null;
                break;
        }
    }
}
