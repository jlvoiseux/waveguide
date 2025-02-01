// src/wgABC.c
#include "wgABC.h"
#include "wgCommon.h"

#include <cstdio>
#include <cstdlib>

typedef struct
{
	double* pEyx0;
	double* pEzx0;
	double* pEyx1;
	double* pEzx1;
	double* pExy0;
	double* pEzy0;
	double* pExy1;
	double* pEzy1;
	double* pExz0;
	double* pEyz0;
	double* pExz1;
	double* pEyz1;
	double	coef;
} wgABCData;

static wgABCData gABC = {nullptr};

void wgInitABC(wgGrid* pGrid)
{
	if (!pGrid)
	{
		fprintf(stderr, "Invalid grid pointer\n");
		exit(1);
	}

	gABC.coef = (pGrid->cdtds - 1.0) / (pGrid->cdtds + 1.0);

	gABC.pEyx0 = (double*)calloc((size_t)(pGrid->sizeY - 1) * pGrid->sizeZ, sizeof(double));
	gABC.pEzx0 = (double*)calloc((size_t)pGrid->sizeY * (pGrid->sizeZ - 1), sizeof(double));
	gABC.pEyx1 = (double*)calloc((size_t)(pGrid->sizeY - 1) * pGrid->sizeZ, sizeof(double));
	gABC.pEzx1 = (double*)calloc((size_t)pGrid->sizeY * (pGrid->sizeZ - 1), sizeof(double));

	gABC.pExy0 = (double*)calloc((size_t)(pGrid->sizeX - 1) * pGrid->sizeZ, sizeof(double));
	gABC.pEzy0 = (double*)calloc((size_t)pGrid->sizeX * (pGrid->sizeZ - 1), sizeof(double));
	gABC.pExy1 = (double*)calloc((size_t)(pGrid->sizeX - 1) * pGrid->sizeZ, sizeof(double));
	gABC.pEzy1 = (double*)calloc((size_t)pGrid->sizeX * (pGrid->sizeZ - 1), sizeof(double));

	gABC.pExz0 = (double*)calloc((size_t)(pGrid->sizeX - 1) * pGrid->sizeY, sizeof(double));
	gABC.pEyz0 = (double*)calloc((size_t)pGrid->sizeX * (pGrid->sizeY - 1), sizeof(double));
	gABC.pExz1 = (double*)calloc((size_t)(pGrid->sizeX - 1) * pGrid->sizeY, sizeof(double));
	gABC.pEyz1 = (double*)calloc((size_t)pGrid->sizeX * (pGrid->sizeY - 1), sizeof(double));
}

void wgApplyABC(wgGrid* pGrid)
{
	int		  i, j;
	const int sizeX = pGrid->sizeX;
	const int sizeY = pGrid->sizeY;
	const int sizeZ = pGrid->sizeZ;

	for (i = 0; i < sizeY - 1; i++)
	{
		for (j = 0; j < sizeZ; j++)
		{
			int		idx		= WG_IDX2(i, j, sizeZ);
			double* pEy		= &pGrid->pEy[WG_IDX3(0, i, j, sizeY - 1, sizeZ)];
			*pEy			= gABC.pEyx0[idx] + gABC.coef * (pGrid->pEy[WG_IDX3(1, i, j, sizeY - 1, sizeZ)] - *pEy);
			gABC.pEyx0[idx] = pGrid->pEy[WG_IDX3(1, i, j, sizeY - 1, sizeZ)];
		}
	}

	for (i = 0; i < sizeY - 1; i++)
	{
		for (j = 0; j < sizeZ; j++)
		{
			int		idx		= WG_IDX2(i, j, sizeZ);
			double* pEy		= &pGrid->pEy[WG_IDX3(sizeX - 1, i, j, sizeY - 1, sizeZ)];
			*pEy			= gABC.pEyx1[idx] + gABC.coef * (pGrid->pEy[WG_IDX3(sizeX - 2, i, j, sizeY - 1, sizeZ)] - *pEy);
			gABC.pEyx1[idx] = pGrid->pEy[WG_IDX3(sizeX - 2, i, j, sizeY - 1, sizeZ)];
		}
	}

	for (i = 0; i < sizeX - 1; i++)
	{
		for (j = 0; j < sizeZ; j++)
		{
			int		idx		= WG_IDX2(i, j, sizeZ);
			double* pEx		= &pGrid->pEx[WG_IDX3(i, 0, j, sizeY, sizeZ)];
			*pEx			= gABC.pExy0[idx] + gABC.coef * (pGrid->pEx[WG_IDX3(i, 1, j, sizeY, sizeZ)] - *pEx);
			gABC.pExy0[idx] = pGrid->pEx[WG_IDX3(i, 1, j, sizeY, sizeZ)];
		}
	}

	for (i = 0; i < sizeX - 1; i++)
	{
		for (j = 0; j < sizeY; j++)
		{
			int		idx		= WG_IDX2(i, j, sizeY);
			double* pEx		= &pGrid->pEx[WG_IDX3(i, j, 0, sizeY, sizeZ)];
			*pEx			= gABC.pExz0[idx] + gABC.coef * (pGrid->pEx[WG_IDX3(i, j, 1, sizeY, sizeZ)] - *pEx);
			gABC.pExz0[idx] = pGrid->pEx[WG_IDX3(i, j, 1, sizeY, sizeZ)];
		}
	}
}