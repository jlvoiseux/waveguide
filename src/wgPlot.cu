#include "wgCommon.h"
#include "wgPlot.h"

#include <cstdio>
#include <cstdlib>

#ifdef _WIN32
#define POPEN _popen
#define PCLOSE _pclose
#else
#define POPEN popen
#define PCLOSE pclose
#endif

static FILE* gPlotPipe = nullptr;

void wgPlotInit(const char* baseFileName)
{
	if (!baseFileName)
	{
		fprintf(stderr, "Invalid base filename\n");
		exit(1);
	}

#ifdef GNUPLOT_EXECUTABLE
	gPlotPipe = POPEN("\"" GNUPLOT_EXECUTABLE "\" --persist", "w");
	if (!gPlotPipe)
	{
		fprintf(stderr, "Failed to open gnuplot pipe\n");
		exit(1);
	}

	fprintf(gPlotPipe, "set term gif animate delay 10\n");
	fprintf(gPlotPipe, "set output '%s.gif'\n", baseFileName);
	fprintf(gPlotPipe, "set xlabel 'X'\n");
	fprintf(gPlotPipe, "set ylabel 'Y'\n");
	fprintf(gPlotPipe, "set zlabel 'Z'\n");
	fprintf(gPlotPipe, "set view 60,30\n");
	fprintf(gPlotPipe, "set palette defined (-0.01 'blue', 0 'white', 0.01 'red')\n");
	fprintf(gPlotPipe, "set cbrange [-0.01:0.01]\n");
	fprintf(gPlotPipe, "set pm3d\n");
	fprintf(gPlotPipe, "set hidden3d\n");
#else
	fprintf(stderr, "Gnuplot not available\n");
	exit(1);
#endif
}

void wgPlotFrame(wgGrid* pGrid, int frame)
{
#ifdef GNUPLOT_EXECUTABLE
	if (!gPlotPipe || !pGrid)
		return;

	fprintf(gPlotPipe, "splot '-' using 1:2:3:4 with pm3d title 'Frame %d'\n", frame);

	for (int x = 0; x < pGrid->sizeX - 1; x++)
	{
		for (int y = 0; y < pGrid->sizeY - 1; y++)
		{
			for (int z = 0; z < pGrid->sizeZ - 1; z++)
			{
				double ex		 = pGrid->pEx[WG_IDX3(x, y, z, pGrid->sizeY, pGrid->sizeZ)];
				double ey		 = pGrid->pEy[WG_IDX3(x, y, z, pGrid->sizeY - 1, pGrid->sizeZ)];
				double ez		 = pGrid->pEz[WG_IDX3(x, y, z, pGrid->sizeY, pGrid->sizeZ - 1)];
				double magnitude = sqrt(ex * ex + ey * ey + ez * ez);

				magnitude = magnitude > 1.0 ? 1.0 : (magnitude < -1.0 ? -1.0 : magnitude);

				fprintf(gPlotPipe, "%d %d %d %f\n", x, y, z, magnitude);
			}
			fprintf(gPlotPipe, "\n");
		}
		fprintf(gPlotPipe, "\n");
	}

	fprintf(gPlotPipe, "e\n");
	fflush(gPlotPipe);
#endif
}

void wgPlotCleanup()
{
#ifdef GNUPLOT_EXECUTABLE
	if (gPlotPipe)
	{
		PCLOSE(gPlotPipe);
		gPlotPipe = nullptr;
	}
#endif
}