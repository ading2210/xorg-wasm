project_dir = meson.project_source_root()
wasm_lib_dir = join_paths(project_dir, 'wasm', 'prefix', 'lib')
c_compiler = meson.get_compiler('c')

srcs = [
  'xwasm.c',
]

xwasm_dep = [
  common_dep,
  c_compiler.find_library('z', dirs : wasm_lib_dir, static : true),
  c_compiler.find_library('freetype', dirs : wasm_lib_dir, static : true),
  c_compiler.find_library('fontenc', dirs : wasm_lib_dir, static : true)
]

xwasm_server = executable(
  'xwasm',
  srcs,
  include_directories: [
    inc,
    include_directories('../src')
  ],
  dependencies: xwasm_dep,
  link_with: [
    libxserver_main,
    kdrive,
    libxserver_fb,
    libxserver,
    libxserver_config,
    libxserver_xkb_stubs,
    libxserver_xi_stubs,
    libxserver_glx,
    libglxvnd
  ],
  c_args: ['-sUSE_SDL=2'],
  link_args: ['-sUSE_SDL=2', '-sSYSCALL_DEBUG', '-sSOCKET_DEBUG', '-lwebsocket.js', '-g'],
  install: true,
)
