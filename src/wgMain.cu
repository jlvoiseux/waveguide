#include "wgABC.h"
#include "wgAllocator.h"
#include "wgCommon.h"
#include "wgGrid.h"
#include "wgOutput.h"
#include "wgPlot.h"
#include "wgSource.h"
#include "wgTimer.h"
#include "wgUpdateE.h"
#include "wgUpdateH.h"

#include <cstdio>

int main()
{
	wgTimer timer;
	wgTimerStart(&timer, WG_SIM_STEPS);

	wgGrid grid = {nullptr};

	wgAllocateGrid(&grid, WG_GRID_SIZE_X, WG_GRID_SIZE_Y, WG_GRID_SIZE_Z);
	grid.cdtds = 1.0 / sqrt(3.0);

	wgInitializeECoefficients(&grid);
	wgInitializeHCoefficients(&grid);

	wgInitSource(grid.cdtds, 15.0);
	wgABCInit(&grid);
	wgPlotInit("dipole_sim", WG_PLOT_ALL);
	wgOutputInit("dipole_sim");

	for (int t = 0; t < WG_SIM_STEPS; t++)
	{
		wgTimerFrameStart(&timer);

		wgUpdateH(&grid);
		wgUpdateE(&grid);

		int centerX = (WG_GRID_SIZE_X - 1) / 2;
		int centerY = WG_GRID_SIZE_Y / 2;
		int centerZ = WG_GRID_SIZE_Z / 2;

		double sourceValue = wgGetSourceValue((double)t, 0.0);
		grid.pEx[WG_IDX3(centerX, centerY, centerZ, WG_GRID_SIZE_Y, WG_GRID_SIZE_Z)] += sourceValue;

		if (t == WG_SIM_STEPS - 1)
		{
			if (abs(grid.pEx[WG_IDX3(centerX, centerY, centerZ, WG_GRID_SIZE_Y, WG_GRID_SIZE_Z)] - 0.00030464571644239882) > 0.00000001)
			{
				printf("ERROR\n");
			}
		}

		wgABCApply(&grid);

		wgPlotFrame(&grid, t);

		wgTimerFrameEnd(&timer);
	}

	wgOutputCleanup();
	wgPlotCleanup();
	wgABCCleanup();
	wgFreeGrid(&grid);

	printf("Total simulation time: %.3f seconds\n", wgTimerGetTotalTime(&timer));
	printf("Median frame time: %.3f ms\n", wgTimerGetMedianFrameTime(&timer) * 1000.0);

	wgTimerCleanup(&timer);

	return 0;
}