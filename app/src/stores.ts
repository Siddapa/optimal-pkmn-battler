import { writable } from 'svelte/store';

export const status = writable("");
export const wasmWorker = writable();
export const playerBox = writable([]);
export const enemyBox = writable([]);
