#!/bin/bash

set -e
set -x

#define basic paths and variables
CORE_COUNT="$(nproc --all)"
BASE_PATH="$(realpath .)"
SRC_PATH="$(realpath ..)"
DEPS_PATH="$BASE_PATH/deps"
PREFIX_PATH="$BASE_PATH/prefix"
BUILD_PATH="$BASE_PATH/build"

#dependency paths
XORGPROTO_PATH="$DEPS_PATH/xorgproto"
XKBPROTO_PATH="$DEPS_PATH/xkbproto"
LIBXAU_PATH="$DEPS_PATH/libxau"
LIBXKB_PATH="$DEPS_PATH/libxkb"
LIBXTRANS_PATH="$DEPS_PATH/libxtrans"
LIBX11_PATH="$DEPS_PATH/libx11"

#export global build options
export EM_PKG_CONFIG_PATH="$PREFIX_PATH/share/pkgconfig:$PREFIX_PATH/lib/pkgconfig"

#helper functions
clone_repo() {
  rm -rf "$1"
  git clone --depth=1 -b master "$2" "$1"
  cd "$1"
}

#dependency build functions
download_x11proto() {
  clone_repo "$XORGPROTO_PATH" "https://gitlab.freedesktop.org/xorg/proto/xorgproto"
  autoreconf -fi
  ./configure --prefix="$PREFIX_PATH"
  make install
}

download_xkbproto() {
  clone_repo "$XKBPROTO_PATH" "https://gitlab.freedesktop.org/xorg/proto/xcbproto"
  autoreconf -fi
  ./configure --prefix="$PREFIX_PATH"
  make install
}

build_libxkb() {
  clone_repo "$LIBXKB_PATH" "https://gitlab.freedesktop.org/xorg/lib/libxcb"
  autoreconf -fi
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH"
  emmake make -j$CORE_COUNT
  emmake make install
}

build_libxau() {
  clone_repo "$LIBXAU_PATH" "https://gitlab.freedesktop.org/xorg/lib/libxau"
  autoreconf -fi
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH"
  emmake make -j$CORE_COUNT
  emmake make install
}

build_libxtrans() {
  clone_repo "$LIBXTRANS_PATH" "https://gitlab.freedesktop.org/xorg/lib/libxtrans"
  autoreconf -fi
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH"
  emmake make -j$CORE_COUNT
  emmake make install
}

build_libx11() {
  clone_repo "$LIBX11_PATH" "https://gitlab.freedesktop.org/xorg/lib/libx11"
  autoreconf -fi
  LDFLAGS="-sSINGLE_FILE=1" emconfigure ./configure --prefix="$PREFIX_PATH" --with-keysymdefdir="$PREFIX_PATH/include/X11"

  cd src/util
  gcc makekeys.c -o makekeys #this needs to be executed on the host
  echo -e "all:\ninstall:" > Makefile #change the makefile to a no-op to prevent recompiling
  cd -

  emmake make -j$CORE_COUNT
  emmake make install
  bash
}

#create build dirs
mkdir -p "$BUILD_PATH"
mkdir -p "$DEPS_PATH"
mkdir -p "$PREFIX_PATH"

#build all deps
if [ ! -f "$PREFIX_PATH/include/X11/XF86keysym.h" ]; then
  download_x11proto
fi
if [ ! -d "$PREFIX_PATH/share/xcb/" ]; then
  download_xkbproto
fi
if [ ! -f "$PREFIX_PATH/lib/libXau.a" ]; then
  build_libxau
fi
if [ ! -f "$PREFIX_PATH/lib/libxcb-xkb.a" ]; then
  build_libxkb
fi
if [ ! -f "$PREFIX_PATH/include/X11/Xtrans/Xtrans.c" ]; then
  build_libxtrans
fi
if [ ! -f "$PREFIX_PATH/lib/libX11.a" ]; then
  build_libx11
fi

#setup meson
cd "$BUILD_PATH"
cp "$BASE_PATH/wasm.cross" ./wasm.cross
cross_file="$(cat wasm.cross)"
cross_file="${cross_file//__PREFIX_DIR_HERE__/$PREFIX_PATH}"
echo "$cross_file" > wasm.cross

#run the compile!
meson setup "$SRC_PATH" --cross-file ./wasm.cross