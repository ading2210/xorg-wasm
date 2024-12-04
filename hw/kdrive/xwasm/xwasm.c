#include "kdrive.h"
#include <SDL/SDL.h>

typedef struct {
  SDL_Window* window;
  SDL_Surface* surface;
} WasmDriver;

static Bool wasmScreenInit(KdScreenInfo *screen) {
  SDL_Init(SDL_INIT_EVERYTHING);
  SDL_Window* window = SDL_CreateWindow("X.Org Server", 0, 0, screen->width, screen->height, SDL_WINDOW_SHOWN);
  SDL_Surface* surface = SDL_GetWindowSurface(window);
  WasmDriver* driver = malloc(sizeof (WasmDriver));

  driver->window = window;
  driver->surface = surface;
  surface->locked = TRUE;

  KdShadowFbAlloc(screen, FALSE);
  screen->fb.depth = 24;
  screen->fb.frameBuffer = surface->pixels;
  screen->fb.byteStride = surface->pitch;
  screen->fb.pixelStride = surface->w;

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
