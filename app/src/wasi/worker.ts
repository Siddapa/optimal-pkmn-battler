// Imports a pre-compiled single .js file of the @runno/wasi package
import { WASI, WASIContext } from "./runno-wasi.js";
import { WASMArg } from "./types";

export type WASMArgMessage = {
    type: "Int32" | "Uint32" | "string" | "Int32Array" | "Uint32Array";
    data: WASMArg;
};

type InitializeWorkerMessage = {
    target: "client";
    type: "initialize";
    binaryURL: string;
    memory_start_index: number;
};

type CallWorkerMessage = {
    target: "client";
    type: "call";
    call_id: number;
    method: any;
    args: WASMArgMessage[];
};

export type WorkerMessage = InitializeWorkerMessage | CallWorkerMessage;

type InitializedHostMessage = {
    target: "host";
    type: "initialized";
    // TODO Make these types stricter
    exports: any;
};

type StdoutHostMessage = {
    target: "host";
    type: "stdout";
    text: string;
};

type StderrHostMessage = {
    target: "host";
    type: "stderr";
    text: string;
};

type ResultHostMessage = {
    target: "host";
    type: "result";
    call_id: number;
    memory: SharedArrayBuffer;
    err_code: number;
};

export type HostMessage =
    | InitializedHostMessage
    | StdoutHostMessage
    | StderrHostMessage
    | ResultHostMessage

let exports: any;
let memory_start_index: number;

onmessage = async (ev: MessageEvent) => {
    const data = ev.data as WorkerMessage;

    switch (data.type) {
        case "initialize":
            const wasi = new WASI({
                stdout: (out) => console.log("stdout", out),
                stderr: (err) => console.error("stderr", err),
            });
            exports = await WASI.initialize(
                fetch(data.binaryURL),
                new WASIContext({
                    stdout: sendStdout,
                    stderr: sendStderr,
                })
            );
            exports.memory.grow(100);
            memory_start_index = data.memory_start_index;
            sendMessage({
                target: "host",
                type: "initialized",
                exports: Object.keys(exports),
            });
            break;
        case "call":
            let memory_i: number = memory_start_index;
            data.args.forEach((arg: WASMArgMessage) => {
                memory_i = parseArg(arg, memory_i);
            });

            // Mark end of arguments list with -1
            const view = new DataView(exports.memory.buffer);
            view.setInt32(memory_i, -1);
            memory_i += 4;

            const err_code = exports[data.method].apply(null, []);

            sendMessage({
                target: "host",
                type: "result",
                call_id: data.call_id,
                memory: exports.memory.buffer,
                err_code: err_code,
            });
    }
};

function parseArg(arg: any, start_index: number) {
    // "arg" should be typed as WASMArgMessage however casting the inner
    // WASMArg to Int32 or Uint32 is undefined for some reason
    // For functionality, typing will be forgoed so that _value's can be passed
    switch (arg.type) {
        case "Int32":
            return storeInt32(arg.data._value, exports.memory.buffer, start_index);
            break;
        case "Uint32":
            return storeUint32(arg.data._value, exports.memory.buffer, start_index);
            break;
        case "string":
            return storeString(
                arg.data as string,
                exports.memory.buffer,
                start_index
            );
            break;
        case "Int32Array":
            return storeInt32Array(
                arg.data as Int32Array,
                exports.memory.buffer,
                start_index
            );
            break;
        case "Uint32Array":
            return storeUint32Array(
                arg.data as Uint32Array,
                exports.memory.buffer,
                start_index
            );
            break;
        default:
            throw new TypeError(`Unsupported Type Given - arg: ${arg}, arg-type: ${arg.type}, start-index: ${start_index}!`);
    }
}

const tag_t_size: number = 4;

function storeInt32(
    arg: number,
    memory: SharedArrayBuffer,
    memory_i: number
) {
    // 0-4 byte  => tag of 1 for Int32 (i32)
    // 4-8 bytes => data               (i32)
    const view = new DataView(memory);

    view.setInt32(memory_i, 1, true);
    memory_i += 4;

    view.setInt32(memory_i, arg, true);
    const data_t_size = 4;
    memory_i += data_t_size;

    return memory_i;
}

function storeUint32(
    arg: number,
    memory: SharedArrayBuffer,
    memory_i: number
) {
    // 0-4 byte  => tag of 2 for Uint64 (i32)
    // 4-8 bytes => data                (u32)
    const view = new DataView(memory);

    view.setInt32(memory_i, 2, true);
    memory_i += tag_t_size;

    view.setUint32(memory_i, arg, true);
    const data_t_size = 4;
    memory_i += data_t_size;

    return memory_i;
}

function storeString(
    arg: string,
    memory: SharedArrayBuffer,
    memory_i: number
) {
    // 0-4             byte  => tag of 3 for string (i32)
    // 4-8             bytes => length of string    (u32)
    // 8-(5+n+padding) bytes => string data         (u8)
    const view = new DataView(memory);

    view.setInt32(memory_i, 3, true);
    memory_i += tag_t_size;

    const encodedText = new TextEncoder().encode(arg);
    const length = encodedText.byteLength;
    const length_t_size = 4;
    view.setUint32(memory_i, length, true);
    memory_i += length_t_size;

    const buffer = new Uint8Array(
        memory,
        memory_i,
        length
    );
    buffer.set(encodedText);
    memory_i += length;

    let padding;
    switch (length % length_t_size) {
        case 0: padding = 0; break;
        case 1: padding = 3; break;
        case 2: padding = 2; break;
        case 3: padding = 1; break;
    }
    return memory_i + padding;
}

function storeInt32Array(
    arg: Int32Array,
    memory: SharedArrayBuffer,
    memory_i: number
) {
    // 0-1       byte  => tag of 4 for Int32Array (i32)
    // 1-5       bytes => length of array         (u32)
    // 5-(5+n*4) bytes => array data              (i32)
    const view = new DataView(memory);

    view.setInt32(memory_i, 4, true);
    memory_i += tag_t_size;

    view.setUint32(memory_i, arg.byteLength / 4, true);
    const len_t_size = 4;
    memory_i += len_t_size;

    let data_t_size = 4;
    for (const i32 of arg) {
        view.setInt32(
            memory_i,
            i32,
            true
        );
        memory_i += data_t_size;
    }

    return memory_i;
}

function storeUint32Array(
    arg: Uint32Array,
    memory: SharedArrayBuffer,
    memory_i: number
) {
    // 0-1       byte  => tag of 5 for Uint64Array (i32)
    // 1-5       bytes => length of array          (u32)
    // 5-(5+n*8) bytes => array data               (u64)
    const view = new DataView(memory);

    view.setInt32(memory_i, 5, true);
    memory_i += tag_t_size

    view.setUint32(memory_i, arg.byteLength / 4, true);
    const len_t_size = 4;
    memory_i += len_t_size;

    let data_t_size = 4;
    for (const u32 of arg) {
        view.setUint32(
            memory_i,
            u32,
            true
        );
        memory_i += data_t_size;
    }

    return memory_i;
}

function sendMessage(message: HostMessage) {
    postMessage(message);
}

function sendStdout(out: string) {
    sendMessage({
        target: "host",
        type: "stdout",
        text: out,
    });
}

function sendStderr(err: string) {
    sendMessage({
        target: "host",
        type: "stderr",
        text: err,
    });
}
