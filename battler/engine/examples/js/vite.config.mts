import commonjs from 'vite-plugin-commonjs';

export default {
  publicDir: 'node_modules/@pkmn/engine/build/lib',
  plugins: [commonjs()]
}