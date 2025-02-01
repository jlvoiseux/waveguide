#include "wgOutput.h"
#include "wgCommon.h"
#include <stdio.h>
#include <stdlib.h>

static FILE* gOutputFile = NULL;
static char gOutputFileName[256];

void wgOutputInit(const char* pBaseFileName)
{
	if (!pBaseFileName)
	{
		fprintf(stderr, "Invalid base filename\n");
		exit(1);
	}

	snprintf(gOutputFileName, sizeof(gOutputFileName), "%s.txt", pBaseFileName);

	gOutputFile = fopen(gOutputFileName, "w");
	if (!gOutputFile)
	{
		fprintf(stderr, "Failed to open output file %s\n", gOutputFileName);
		exit(1);
	}
}

void wgOutputFrame(wgGrid* pGrid, int frame)
{
	if (!gOutputFile || !pGrid)
		return;

	fprintf(gOutputFile, "Frame %d\n", frame);

	for (int x = 0; x < pGrid->sizeX - 1; x++)
	{
		for (int y = 0; y < pGrid->sizeY - 1; y++)
		{
			for (int z = 0; z < pGrid->sizeZ - 1; z++)
			{
				double ex = pGrid->pEx[WG_IDX3(x, y, z, pGrid->sizeY, pGrid->sizeZ)];
				double ey = pGrid->pEy[WG_IDX3(x, y, z, pGrid->sizeY - 1, pGrid->sizeZ)];
				double ez = pGrid->pEz[WG_IDX3(x, y, z, pGrid->sizeY, pGrid->sizeZ - 1)];

				fprintf(gOutputFile, "x=%d y=%d z=%d Ex=%f Ey=%f Ez=%f\n",
					x, y, z, ex, ey, ez);
			}
		}
	}
	fprintf(gOutputFile, "\n");
	fflush(gOutputFile);
}

void wgOutputCleanup(void)
{
	if (gOutputFile)
	{
		fclose(gOutputFile);
		gOutputFile = NULL;
	}
}