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
Cd into this directory and run `./build.sh setup` to build the dependencies. You need `xorg-macros` and a recent version of Meson. This script will download the Emscripten SDK for you.

Then run `./build.sh` to compile the X server itself.

Run `(cd web; python3 ../run_server.py)` to start a web server.

## Credit
Inspired by [xserver-xsdl](https://github.com/pelya/xserver-xsdl).

This port was written by [Allen Ding](https://github.com/ading2210/).