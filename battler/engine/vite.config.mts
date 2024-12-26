import {defineConfig} from 'vitest/config';

export default defineConfig({
  test: {
    watch: false,
    globals: true,
    testTimeout: 60_000,
    exclude: ['node_modules', 'build', 'examples'],
    coverage: {reportsDirectory: 'coverage/js', exclude: ['src/test', '**/*.test.ts']},
  }
});
