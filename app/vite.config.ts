import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import crossOriginIsolation from 'vite-plugin-cross-origin-isolation'

// https://vite.dev/config/
export default defineConfig({
    plugins: [svelte(), crossOriginIsolation()],
    base: "/",
    optimizeDeps: {
        esbuildOptions: {
            target: 'esnext'
        },
    },
    build: {
        target: 'esnext'
    },
})
