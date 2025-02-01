#include "wgAllocator.h"

#include <cstdio>
#include <cstdlib>

static void allocate3D(double** ppArray, int sizeX, int sizeY, int sizeZ)
{
	*ppArray = (double*)calloc((size_t)sizeX * sizeY * sizeZ, sizeof(double));
	if (!*ppArray)
	{
		fprintf(stderr, "Failed to allocate 3D array of size %dx%dx%d\n", sizeX, sizeY, sizeZ);
		exit(1);
	}
}

void wgAllocateGrid(wgGrid* pGrid, int sizeX, int sizeY, int sizeZ)
{
	if (!pGrid)
	{
		fprintf(stderr, "Invalid grid pointer\n");
		exit(1);
	}

	pGrid->sizeX = sizeX;
	pGrid->sizeY = sizeY;
	pGrid->sizeZ = sizeZ;

	allocate3D(&pGrid->pHx, sizeX, sizeY - 1, sizeZ - 1);
	allocate3D(&pGrid->pChxh, sizeX, sizeY - 1, sizeZ - 1);
	allocate3D(&pGrid->pChxe, sizeX, sizeY - 1, sizeZ - 1);

	allocate3D(&pGrid->pHy, sizeX - 1, sizeY, sizeZ - 1);
	allocate3D(&pGrid->pChyh, sizeX - 1, sizeY, sizeZ - 1);
	allocate3D(&pGrid->pChye, sizeX - 1, sizeY, sizeZ - 1);

	allocate3D(&pGrid->pHz, sizeX - 1, sizeY - 1, sizeZ);
	allocate3D(&pGrid->pChzh, sizeX - 1, sizeY - 1, sizeZ);
	allocate3D(&pGrid->pChze, sizeX - 1, sizeY - 1, sizeZ);

	allocate3D(&pGrid->pEx, sizeX - 1, sizeY, sizeZ);
	allocate3D(&pGrid->pCexe, sizeX - 1, sizeY, sizeZ);
	allocate3D(&pGrid->pCexh, sizeX - 1, sizeY, sizeZ);

	allocate3D(&pGrid->pEy, sizeX, sizeY - 1, sizeZ);
	allocate3D(&pGrid->pCeye, sizeX, sizeY - 1, sizeZ);
	allocate3D(&pGrid->pCeyh, sizeX, sizeY - 1, sizeZ);

	allocate3D(&pGrid->pEz, sizeX, sizeY, sizeZ - 1);
	allocate3D(&pGrid->pCeze, sizeX, sizeY, sizeZ - 1);
	allocate3D(&pGrid->pCezh, sizeX, sizeY, sizeZ - 1);
}

void wgFreeGrid(wgGrid* pGrid)
{
	if (!pGrid)
		return;

	free(pGrid->pHx);
	free(pGrid->pChxh);
	free(pGrid->pChxe);
	free(pGrid->pHy);
	free(pGrid->pChyh);
	free(pGrid->pChye);
	free(pGrid->pHz);
	free(pGrid->pChzh);
	free(pGrid->pChze);
	free(pGrid->pEx);
	free(pGrid->pCexe);
	free(pGrid->pCexh);
	free(pGrid->pEy);
	free(pGrid->pCeye);
	free(pGrid->pCeyh);
	free(pGrid->pEz);
	free(pGrid->pCeze);
	free(pGrid->pCezh);
}