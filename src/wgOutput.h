#pragma once
#include "wgGrid.h"

void wgOutputInit(const char* pBaseFileName);
void wgOutputFrame(wgGrid* pGrid, int frame);
void wgOutputCleanup(void);