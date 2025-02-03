#pragma once
#include "wgGrid.h"

typedef enum
{
	WG_PLOT_SLICES = 1,
	WG_PLOT_3D	   = 2,
	WG_PLOT_ALL	   = 3,
	WG_PLOT_NONE   = 4,
} wgPlotMode;

void wgPlotInit(const char* pBaseFileName, wgPlotMode mode);
void wgPlotFrame(wgGrid* pGrid, int frame);
void wgPlotCleanup(void);