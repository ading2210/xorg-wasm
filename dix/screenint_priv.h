/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 * Copyright © 1987, 1998 The Open Group
 */
#ifndef _XSERVER_DIX_SCREENINT_PRIV_H
#define _XSERVER_DIX_SCREENINT_PRIV_H

#include <X11/Xdefs.h>

typedef struct _Screen *ScreenPtr;

typedef Bool (*ScreenInitProcPtr)(ScreenPtr pScreen, int argc, char **argv);

int AddScreen(ScreenInitProcPtr pfnInit, int argc, char **argv);
int AddGPUScreen(ScreenInitProcPtr pfnInit, int argc, char **argv);

void RemoveGPUScreen(ScreenPtr pScreen);

#endif /* _XSERVER_DIX_SCREENINT_PRIV_H */