#include "X11/X.h"
#include "kdrive.h"
#include <SDL/SDL.h>

typedef struct {
  SDL_Window* window;
  SDL_Surface* surface;
} WasmDriver;

static Bool wasmScreenInit(KdScreenInfo *screen) {
  SDL_Init(SDL_INIT_EVERYTHING);

  int width = 640;
  int height = 480;

  SDL_Window* window = SDL_CreateWindow("X.Org Server", 0, 0, width, height, SDL_WINDOW_SHOWN);
  SDL_Surface* surface = SDL_GetWindowSurface(window);
  WasmDriver* driver = malloc(sizeof (WasmDriver));

  driver->window = window;
  driver->surface = surface;
  surface->locked = TRUE;

  screen->driver = driver;
  screen->rate = 60;
  screen->width = width;
  screen->height = height;
  screen->fb.visuals = (1 << TrueColor);
  screen->fb.frameBuffer = surface->pixels;
  screen->fb.byteStride = surface->pitch;
  screen->fb.pixelStride = surface->w;
	screen->fb.redMask = surface->format->Rmask;
	screen->fb.greenMask = surface->format->Gmask;
	screen->fb.blueMask = surface->format->Bmask;
  screen->fb.bitsPerPixel = surface->format->BitsPerPixel;
  screen->fb.depth = surface->format->BitsPerPixel;
  KdShadowFbAlloc(screen, FALSE);

  return TRUE;
}

static Bool wasmFinishInitScreen(ScreenPtr screenPtr) {
  return TRUE;
}

static Bool wasmCreateRes(ScreenPtr screenPtr) {
  return TRUE;
}

KdCardFuncs wasmCardFuncs = {
  .scrinit = wasmScreenInit,
  .finishInitScreen = wasmFinishInitScreen,
  .createRes = wasmCreateRes
};


void InitInput(int argc, char **argv) {
  KdInitInput();
}

void InitOutput(ScreenInfo *screenInfo, int argc, char **argv) {
  KdInitOutput(screenInfo, argc, argv);
}

void InitCard(char *name) {
  KdCardInfoAdd(&wasmCardFuncs,  0);
}

void OsVendorInit() {

}

void CloseInput() {
  KdCloseInput();
}


int ddxProcessArgument(int argc, char **argv, int i) {
  return KdProcessArgument(argc, argv, i);
}

void ddxUseMsg() {
  KdUseMsg();
}

void ddxInputThreadInit() {}
