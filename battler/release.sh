zig build
wasmedge compile zig-out/bin/gen1.wasm zig-out/bin/gen1_aot.wasm
cp zig-out/bin/gen1_aot.wasm ../app/public/gen1.wasm
