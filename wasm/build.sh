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
LIBXSHMFENCE_PATH="$DEPS_PATH/libxshmfence"
PIXMAN_PATH="$DEPS_PATH/pixman"
LIBXKBFILE_PATH="$DEPS_PATH/libxkbfile"
FREETYPE_PATH="$DEPS_PATH/freetype"
ZLIB_PATH="$DEPS_PATH/zlib"
LIBFONTENC_PATH="$DEPS_PATH/libfontenc"
LIBXFONT_PATH="$DEPS_PATH/libxfont"
LIBXCVT_PATH="$DEPS_PATH/libxcvt"
LIBSHA1_PATH="$DEPS_PATH/libsha1"
LIBXCB_RENDERUTIL_PATH="$DEPS_PATH/libxcb-render-util"

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
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH" --disable-shared
  emmake make -j$CORE_COUNT
  emmake make install
}

build_libxau() {
  clone_repo "$LIBXAU_PATH" "https://gitlab.freedesktop.org/xorg/lib/libxau"
  autoreconf -fi
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH" --disable-shared
  emmake make -j$CORE_COUNT
  emmake make install
}

build_libxtrans() {
  clone_repo "$LIBXTRANS_PATH" "https://gitlab.freedesktop.org/xorg/lib/libxtrans"
  autoreconf -fi
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH" --disable-shared
  emmake make -j$CORE_COUNT
  emmake make install
}

build_libx11() {
  clone_repo "$LIBX11_PATH" "https://gitlab.freedesktop.org/xorg/lib/libx11"
  autoreconf -fi
  LDFLAGS="-sSINGLE_FILE=1" emconfigure ./configure --prefix="$PREFIX_PATH" --disable-shared --with-keysymdefdir="$PREFIX_PATH/include/X11"

  cd src/util
  gcc makekeys.c -o makekeys #this needs to be executed on the host
  echo -e "all:\ninstall:" > Makefile #change the makefile to a no-op to prevent recompiling
  cd -

  emmake make -j$CORE_COUNT
  emmake make install
  bash
}

build_pixman() {
  clone_repo "$PIXMAN_PATH" "https://gitlab.freedesktop.org/pixman/pixman"
  meson setup build --cross-file "$BUILD_PATH/wasm.cross" --default-library static --prefix "$PREFIX_PATH"
  cd build
  meson compile
  meson install
}

build_libxkbfile() {
  clone_repo "$LIBXKBFILE_PATH" "https://gitlab.freedesktop.org/xorg/lib/libxkbfile"
  autoreconf -fi
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH" --disable-shared
  emmake make -j$CORE_COUNT
  emmake make install
}

build_zlib() {
  clone_repo "$ZLIB_PATH" "https://github.com/madler/zlib"
  emconfigure ./configure --prefix="$PREFIX_PATH" --static
  emmake make -j$CORE_COUNT
  emmake make install
}

build_freetype() {
  clone_repo "$FREETYPE_PATH" "https://github.com/freetype/freetype"
  ./autogen.sh
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH" --disable-shared
  emmake make -j$CORE_COUNT
  emmake make install
}

build_libfontenc() {
  clone_repo "$LIBFONTENC_PATH" "https://gitlab.freedesktop.org/xorg/lib/libfontenc"
  autoreconf -fi
  CFLAGS="-I$PREFIX_PATH/include" LDFLAGS="-L$PREFIX_PATH/lib" emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH" --disable-shared
  emmake make -j$CORE_COUNT
  emmake make install
}

build_libxfont() {
  clone_repo "$LIBXFONT_PATH" "https://gitlab.freedesktop.org/xorg/lib/libxfont"
  autoreconf -fi
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH" --disable-shared
  emmake make -j$CORE_COUNT
  emmake make install
}

build_libxcvt() {
  clone_repo "$LIBXCVT_PATH" "https://gitlab.freedesktop.org/xorg/lib/libxcvt"
  sed -i 's/shared_library/library/' lib/meson.build
  meson setup build --cross-file "$BUILD_PATH/wasm.cross" --default-library static --prefix "$PREFIX_PATH"
  cd build
  meson compile
  meson install
}

build_libsha1() {
  clone_repo "$LIBSHA1_PATH" "https://github.com/dottedmag/libsha1"
  autoreconf -fi
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH" --disable-shared
  emmake make -j$CORE_COUNT
  emmake make install
}

build_libxcb-render-util() {
  clone_repo "$LIBXCB_RENDERUTIL_PATH" "https://gitlab.freedesktop.org/xorg/lib/libxcb-render-util"

  sed -i 's/git:\/\/anongit.freedesktop.org\/xcb\/util-common-m4.git/https:\/\/gitlab.freedesktop.org\/xorg\/util\/xcb-util-m4/' .gitmodules
  git submodule update --init
  
  autoreconf -fi
  emconfigure ./configure --host=i686-linux --prefix="$PREFIX_PATH" --disable-shared
  emmake make -j$CORE_COUNT
  emmake make install
}

#create build dirs
mkdir -p "$BUILD_PATH"
mkdir -p "$DEPS_PATH"
mkdir -p "$PREFIX_PATH"

#setup meson
cp "$BASE_PATH/wasm.cross" "$BUILD_PATH/wasm.cross"
cross_file="$(cat "$BUILD_PATH/wasm.cross")"
cross_file="${cross_file//__PREFIX_DIR_HERE__/$PREFIX_PATH}"
echo "$cross_file" > "$BUILD_PATH/wasm.cross"

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
if [ ! -f "$PREFIX_PATH/lib/libpixman-1.a" ]; then
  build_pixman
fi
if [ ! -f "$PREFIX_PATH/lib/libxkbfile.a" ]; then
  build_libxkbfile
fi
if [ ! -f "$PREFIX_PATH/lib/libz.a" ]; then
  build_zlib
fi
if [ ! -f "$PREFIX_PATH/lib/libfreetype.a" ]; then
  build_freetype
fi
if [ ! -f "$PREFIX_PATH/lib/libfontenc.a" ]; then
  build_libfontenc
fi
if [ ! -f "$PREFIX_PATH/lib/libXfont2.a" ]; then
  build_libxfont
fi
if [ ! -f "$PREFIX_PATH/lib/libxcvt.a" ]; then
  build_libxcvt
fi
if [ ! -f "$PREFIX_PATH/lib/libsha1.a" ]; then
  build_libsha1
fi
if [ ! -f "$PREFIX_PATH/lib/libxcb-render-util.a" ]; then
  build_libxcb-render-util
fi


#setup xserver build
cd "$SRC_PATH"
meson setup "$BUILD_PATH" --cross-file "$BUILD_PATH/wasm.cross" \
  --default-library static \
  -Dudev=false \
  -Dudev_kms=false \
  -Dsha1=libsha1 \
  -Dxdmcp=false \
  -Dglx=false \
  -Dglamor=false \
  -Dpciaccess=false \
  -Dmitshm=false \
  -Dxvfb=false \
  -Dxorg=false \
  -Dxwasm=true 
  
#run the compile!
cd "$BUILD_PATH"
meson compile