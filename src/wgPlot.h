#pragma once
#include "wgGrid.h"

void wgPlotInit(const char* baseFileName);
void wgPlotFrame(wgGrid* pGrid, int frame);
void wgPlotCleanup();