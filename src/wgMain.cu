#include "wgABC.h"
#include "wgAllocator.h"
#include "wgCommon.h"
#include "wgGrid.h"
#include "wgOutput.h"
#include "wgPlot.h"
#include "wgSource.h"
#include "wgUpdateE.h"
#include "wgUpdateH.h"

int main()
{
	wgGrid grid = {nullptr};

	wgAllocateGrid(&grid, WG_GRID_SIZE, WG_GRID_SIZE, WG_GRID_SIZE);
	grid.cdtds = 1.0 / sqrt(3.0);

	wgInitializeECoefficients(&grid);
	wgInitializeHCoefficients(&grid);

	wgInitSource(grid.cdtds, 15.0);
	wgABCInit(&grid);
	wgPlotInit("dipole_sim");
	wgOutputInit("dipole_sim");

	for (int t = 0; t < WG_SIM_STEPS; t++)
	{
		wgUpdateH(&grid);
		wgUpdateE(&grid);

		int centerX = (WG_GRID_SIZE - 1) / 2;
		int centerY = WG_GRID_SIZE / 2;
		int centerZ = WG_GRID_SIZE / 2;
		grid.pEx[WG_IDX3(centerX, centerY, centerZ, WG_GRID_SIZE, WG_GRID_SIZE)] += wgGetSourceValue((double)t, 0.0);

		wgABCApply(&grid);

		if (t % 5 == 0)
		{
			wgPlotFrame(&grid, t);
			wgOutputFrame(&grid, t);
		}
	}

	wgOutputCleanup();
	wgPlotCleanup();
	wgABCCleanup();
	wgFreeGrid(&grid);

	return 0;
}