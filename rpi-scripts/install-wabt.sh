git clone --recursive https://github.com/WebAssembly/wabt
cd wabt/
cmake -Bbuild -H. -DCMAKE_BUILD_TYPE=DEBUG -DCMAKE_INSTALL_PREFIX=~/.wasm
cmake --build build --target install
