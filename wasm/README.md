# X.Org Server WASM Port

This is an attempt to get the X.Org server running on the browser via Emscripten and WebAssembly. 

## Status:
Currently, the X server libraries compile fine, however Xephyr is not enabled. Thus the build doesn't actually produce a usable binary.

## Build Prerequisites:
- A Linux PC
- Meson
- GNU Autotools
- CMake
- Bash
- Wget
- GCC

## Building:
Cd into this directory and run `./build.sh`, then wait a bit. This script will download the Emscripten SDK for you.

## Credit
Inspired by [xserver-xsdl](https://github.com/pelya/xserver-xsdl).

This port was written by [Allen Ding](https://github.com/ading2210/).