// wgPlot.cu
#include "wgCommon.h"
#include "wgPlot.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef _WIN32
#define POPEN _popen
#define PCLOSE _pclose
#else
#define POPEN popen
#define PCLOSE pclose
#endif

static FILE*	  gPlotPipeX  = NULL;
static FILE*	  gPlotPipeY  = NULL;
static FILE*	  gPlotPipe3D = NULL;
static char		  gBaseFileName[256];
static wgPlotMode gPlotMode;

static double scaleValue(double val)
{
	double magnitude = fabs(val / 0.3);
	return magnitude > 0.0 ? log10(magnitude) : -3.0;
}

static void initSlicePlots(void)
{
	const char* commonSettings = "set term gif animate delay 1\n"
								 "set size square\n"
								 "set palette defined (-3 'blue', -2 'cyan', -1 'yellow', 0 'red')\n"
								 "set cbrange [-3:0]\n"
								 "set pm3d map corners2color c4\n"
								 "set pm3d interpolate 0,0\n"
								 "unset key\n"
								 "set xrange [0:31]\n"
								 "set yrange [0:31]\n";

	gPlotPipeX = POPEN("\"" GNUPLOT_EXECUTABLE "\" --persist", "w");
	gPlotPipeY = POPEN("\"" GNUPLOT_EXECUTABLE "\" --persist", "w");

	if (!gPlotPipeX || !gPlotPipeY)
	{
		fprintf(stderr, "Failed to open gnuplot pipe for slices\n");
		exit(1);
	}

	char fileNameX[512], fileNameY[512];
	sprintf(fileNameX, "%s-x.gif", gBaseFileName);
	sprintf(fileNameY, "%s-y.gif", gBaseFileName);

	fprintf(gPlotPipeX, "%s", commonSettings);
	fprintf(gPlotPipeX, "set output '%s'\n", fileNameX);
	fprintf(gPlotPipeX, "set xlabel 'Y'\n");
	fprintf(gPlotPipeX, "set ylabel 'Z'\n");

	fprintf(gPlotPipeY, "%s", commonSettings);
	fprintf(gPlotPipeY, "set output '%s'\n", fileNameY);
	fprintf(gPlotPipeY, "set xlabel 'X'\n");
	fprintf(gPlotPipeY, "set ylabel 'Z'\n");
}

static void init3DPlot(void)
{
	char fileName[512];
	sprintf(fileName, "%s-3d.gif", gBaseFileName);

	gPlotPipe3D = POPEN("\"" GNUPLOT_EXECUTABLE "\" --persist", "w");
	if (!gPlotPipe3D)
	{
		fprintf(stderr, "Failed to open gnuplot pipe for 3D\n");
		exit(1);
	}

	fprintf(gPlotPipe3D, "set term gif animate delay 10\n");
	fprintf(gPlotPipe3D, "set output '%s'\n", fileName);
	fprintf(gPlotPipe3D, "set xlabel 'X'\n");
	fprintf(gPlotPipe3D, "set ylabel 'Y'\n");
	fprintf(gPlotPipe3D, "set zlabel 'Z'\n");
	fprintf(gPlotPipe3D, "set view 60,30\n");
	fprintf(gPlotPipe3D, "set palette defined (-3 'blue', -2 'cyan', -1 'yellow', 0 'red')\n");
	fprintf(gPlotPipe3D, "set cbrange [-3:0]\n");
	fprintf(gPlotPipe3D, "set pm3d\n");
	fprintf(gPlotPipe3D, "set hidden3d\n");
}

void wgPlotInit(const char* pBaseFileName, wgPlotMode mode)
{
	if (!pBaseFileName)
	{
		fprintf(stderr, "Invalid base filename\n");
		exit(1);
	}

#ifdef GNUPLOT_EXECUTABLE
	sprintf(gBaseFileName, "%s", pBaseFileName);
	gPlotMode = mode;

	if (mode & WG_PLOT_SLICES)
		initSlicePlots();
	if (mode & WG_PLOT_3D)
		init3DPlot();
#else
	fprintf(stderr, "Gnuplot not available\n");
	exit(1);
#endif
}

static void plotSlices(wgGrid* pGrid, int frame)
{
	int centerX = (pGrid->sizeX - 1) / 2;
	int centerY = pGrid->sizeY / 2;

	// X slice
	fprintf(gPlotPipeX, "set title 'X Slice (Frame %d)'\n", frame);
	fprintf(gPlotPipeX, "splot '-' using 1:2:3 with pm3d\n");

	for (int y = 0; y < pGrid->sizeY; y++)
	{
		for (int z = 0; z < pGrid->sizeZ; z++)
		{
			double ex = pGrid->pEx[WG_IDX3(centerX, y, z, pGrid->sizeY, pGrid->sizeZ)];
			fprintf(gPlotPipeX, "%d %d %f\n", y, z, scaleValue(ex));
		}
		fprintf(gPlotPipeX, "\n");
	}
	fprintf(gPlotPipeX, "e\n");
	fflush(gPlotPipeX);

	// Y slice
	fprintf(gPlotPipeY, "set title 'Y Slice (Frame %d)'\n", frame);
	fprintf(gPlotPipeY, "splot '-' using 1:2:3 with pm3d\n");

	for (int x = 0; x < pGrid->sizeX - 1; x++)
	{
		for (int z = 0; z < pGrid->sizeZ; z++)
		{
			double ex = pGrid->pEx[WG_IDX3(x, centerY, z, pGrid->sizeY, pGrid->sizeZ)];
			fprintf(gPlotPipeY, "%d %d %f\n", x, z, scaleValue(ex));
		}
		fprintf(gPlotPipeY, "\n");
	}
	fprintf(gPlotPipeY, "e\n");
	fflush(gPlotPipeY);
}

static void plot3D(wgGrid* pGrid, int frame)
{
	fprintf(gPlotPipe3D, "splot '-' using 1:2:3:4 with pm3d title 'Frame %d'\n", frame);

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

				fprintf(gPlotPipe3D, "%d %d %d %f\n", x, y, z, scaleValue(magnitude));
			}
			fprintf(gPlotPipe3D, "\n");
		}
		fprintf(gPlotPipe3D, "\n");
	}

	fprintf(gPlotPipe3D, "e\n");
	fflush(gPlotPipe3D);
}

void wgPlotFrame(wgGrid* pGrid, int frame)
{
#ifdef GNUPLOT_EXECUTABLE
	if (!pGrid || gPlotMode & WG_PLOT_NONE)
		return;

	if (gPlotMode & WG_PLOT_SLICES)
		plotSlices(pGrid, frame);
	if (gPlotMode & WG_PLOT_3D)
		plot3D(pGrid, frame);
#endif
}

void wgPlotCleanup(void)
{
#ifdef GNUPLOT_EXECUTABLE
	if (gPlotPipeX)
	{
		PCLOSE(gPlotPipeX);
		gPlotPipeX = NULL;
	}
	if (gPlotPipeY)
	{
		PCLOSE(gPlotPipeY);
		gPlotPipeY = NULL;
	}
	if (gPlotPipe3D)
	{
		PCLOSE(gPlotPipe3D);
		gPlotPipe3D = NULL;
	}
#endif
}