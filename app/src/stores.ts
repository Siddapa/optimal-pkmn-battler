import { writable } from 'svelte/store';


export const wasmWorker = writable();
export const playerBox = writable([]);
export const enemyBox = writable([]);
