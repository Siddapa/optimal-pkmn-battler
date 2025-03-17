import { vitePreprocess } from '@sveltejs/vite-plugin-svelte'


export default {
    // Consult https://svelte.dev/docs#compile-time-svelte-preprocess
    // for more information about preprocessors
    preprocess: vitePreprocess(),
    // server: {
    //     headers: {
    //         'Cross-Origin-Opener-Policy': 'same-origin',
    //         'Cross-Origin-Embedder-Policy': 'require-corp',
    //     }
    // }
}
