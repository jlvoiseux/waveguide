#include "wgABC.h"
#include "wgCommon.h"

#include <stdio.h>
#include <stdlib.h>

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

	double coef;
} wgABCData;

static wgABCData gABC = {nullptr};

void wgABCCleanup()
{
	free(gABC.pEyx0);
	free(gABC.pEzx0);
	free(gABC.pEyx1);
	free(gABC.pEzx1);
	free(gABC.pExy0);
	free(gABC.pEzy0);
	free(gABC.pExy1);
	free(gABC.pEzy1);
	free(gABC.pExz0);
	free(gABC.pEyz0);
	free(gABC.pExz1);
	free(gABC.pEyz1);
}

void wgABCInit(wgGrid* pGrid)
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

void wgABCApply(wgGrid* pGrid)
{
	if (!pGrid)
		return;

	const int sizeX = pGrid->sizeX;
	const int sizeY = pGrid->sizeY;
	const int sizeZ = pGrid->sizeZ;

	for (int j = 0; j < sizeY - 1; j++)
	{
		for (int k = 0; k < sizeZ; k++)
		{
			const int idx	= WG_IDX2(j, k, sizeZ);
			double*	  pEy	= &pGrid->pEy[WG_IDX3(0, j, k, sizeY - 1, sizeZ)];
			*pEy			= gABC.pEyx0[idx] + gABC.coef * (pGrid->pEy[WG_IDX3(1, j, k, sizeY - 1, sizeZ)] - *pEy);
			gABC.pEyx0[idx] = pGrid->pEy[WG_IDX3(1, j, k, sizeY - 1, sizeZ)];
		}
	}

	for (int j = 0; j < sizeY; j++)
	{
		for (int k = 0; k < sizeZ - 1; k++)
		{
			const int idx	= WG_IDX2(j, k, sizeZ - 1);
			double*	  pEz	= &pGrid->pEz[WG_IDX3(0, j, k, sizeY, sizeZ - 1)];
			*pEz			= gABC.pEzx0[idx] + gABC.coef * (pGrid->pEz[WG_IDX3(1, j, k, sizeY, sizeZ - 1)] - *pEz);
			gABC.pEzx0[idx] = pGrid->pEz[WG_IDX3(1, j, k, sizeY, sizeZ - 1)];
		}
	}

	for (int j = 0; j < sizeY - 1; j++)
	{
		for (int k = 0; k < sizeZ; k++)
		{
			const int idx	= WG_IDX2(j, k, sizeZ);
			double*	  pEy	= &pGrid->pEy[WG_IDX3(sizeX - 1, j, k, sizeY - 1, sizeZ)];
			*pEy			= gABC.pEyx1[idx] + gABC.coef * (pGrid->pEy[WG_IDX3(sizeX - 2, j, k, sizeY - 1, sizeZ)] - *pEy);
			gABC.pEyx1[idx] = pGrid->pEy[WG_IDX3(sizeX - 2, j, k, sizeY - 1, sizeZ)];
		}
	}

	for (int j = 0; j < sizeY; j++)
	{
		for (int k = 0; k < sizeZ - 1; k++)
		{
			const int idx	= WG_IDX2(j, k, sizeZ - 1);
			double*	  pEz	= &pGrid->pEz[WG_IDX3(sizeX - 1, j, k, sizeY, sizeZ - 1)];
			*pEz			= gABC.pEzx1[idx] + gABC.coef * (pGrid->pEz[WG_IDX3(sizeX - 2, j, k, sizeY, sizeZ - 1)] - *pEz);
			gABC.pEzx1[idx] = pGrid->pEz[WG_IDX3(sizeX - 2, j, k, sizeY, sizeZ - 1)];
		}
	}

	for (int i = 0; i < sizeX - 1; i++)
	{
		for (int k = 0; k < sizeZ; k++)
		{
			const int idx	= WG_IDX2(i, k, sizeZ);
			double*	  pEx	= &pGrid->pEx[WG_IDX3(i, 0, k, sizeY, sizeZ)];
			*pEx			= gABC.pExy0[idx] + gABC.coef * (pGrid->pEx[WG_IDX3(i, 1, k, sizeY, sizeZ)] - *pEx);
			gABC.pExy0[idx] = pGrid->pEx[WG_IDX3(i, 1, k, sizeY, sizeZ)];
		}
	}

	for (int i = 0; i < sizeX; i++)
	{
		for (int k = 0; k < sizeZ - 1; k++)
		{
			const int idx	= WG_IDX2(i, k, sizeZ - 1);
			double*	  pEz	= &pGrid->pEz[WG_IDX3(i, 0, k, sizeY, sizeZ - 1)];
			*pEz			= gABC.pEzy0[idx] + gABC.coef * (pGrid->pEz[WG_IDX3(i, 1, k, sizeY, sizeZ - 1)] - *pEz);
			gABC.pEzy0[idx] = pGrid->pEz[WG_IDX3(i, 1, k, sizeY, sizeZ - 1)];
		}
	}

	for (int i = 0; i < sizeX - 1; i++)
	{
		for (int k = 0; k < sizeZ; k++)
		{
			const int idx	= WG_IDX2(i, k, sizeZ);
			double*	  pEx	= &pGrid->pEx[WG_IDX3(i, sizeY - 1, k, sizeY, sizeZ)];
			*pEx			= gABC.pExy1[idx] + gABC.coef * (pGrid->pEx[WG_IDX3(i, sizeY - 2, k, sizeY, sizeZ)] - *pEx);
			gABC.pExy1[idx] = pGrid->pEx[WG_IDX3(i, sizeY - 2, k, sizeY, sizeZ)];
		}
	}

	for (int i = 0; i < sizeX; i++)
	{
		for (int k = 0; k < sizeZ - 1; k++)
		{
			const int idx	= WG_IDX2(i, k, sizeZ - 1);
			double*	  pEz	= &pGrid->pEz[WG_IDX3(i, sizeY - 1, k, sizeY, sizeZ - 1)];
			*pEz			= gABC.pEzy1[idx] + gABC.coef * (pGrid->pEz[WG_IDX3(i, sizeY - 2, k, sizeY, sizeZ - 1)] - *pEz);
			gABC.pEzy1[idx] = pGrid->pEz[WG_IDX3(i, sizeY - 2, k, sizeY, sizeZ - 1)];
		}
	}

	for (int i = 0; i < sizeX - 1; i++)
	{
		for (int j = 0; j < sizeY; j++)
		{
			const int idx	= WG_IDX2(i, j, sizeY);
			double*	  pEx	= &pGrid->pEx[WG_IDX3(i, j, 0, sizeY, sizeZ)];
			*pEx			= gABC.pExz0[idx] + gABC.coef * (pGrid->pEx[WG_IDX3(i, j, 1, sizeY, sizeZ)] - *pEx);
			gABC.pExz0[idx] = pGrid->pEx[WG_IDX3(i, j, 1, sizeY, sizeZ)];
		}
	}

	for (int i = 0; i < sizeX; i++)
	{
		for (int j = 0; j < sizeY - 1; j++)
		{
			const int idx	= WG_IDX2(i, j, sizeY - 1);
			double*	  pEy	= &pGrid->pEy[WG_IDX3(i, j, 0, sizeY - 1, sizeZ)];
			*pEy			= gABC.pEyz0[idx] + gABC.coef * (pGrid->pEy[WG_IDX3(i, j, 1, sizeY - 1, sizeZ)] - *pEy);
			gABC.pEyz0[idx] = pGrid->pEy[WG_IDX3(i, j, 1, sizeY - 1, sizeZ)];
		}
	}

	for (int i = 0; i < sizeX - 1; i++)
	{
		for (int j = 0; j < sizeY; j++)
		{
			const int idx	= WG_IDX2(i, j, sizeY);
			double*	  pEx	= &pGrid->pEx[WG_IDX3(i, j, sizeZ - 1, sizeY, sizeZ)];
			*pEx			= gABC.pExz1[idx] + gABC.coef * (pGrid->pEx[WG_IDX3(i, j, sizeZ - 2, sizeY, sizeZ)] - *pEx);
			gABC.pExz1[idx] = pGrid->pEx[WG_IDX3(i, j, sizeZ - 2, sizeY, sizeZ)];
		}
	}

	for (int i = 0; i < sizeX; i++)
	{
		for (int j = 0; j < sizeY - 1; j++)
		{
			const int idx	= WG_IDX2(i, j, sizeY - 1);
			double*	  pEy	= &pGrid->pEy[WG_IDX3(i, j, sizeZ - 1, sizeY - 1, sizeZ)];
			*pEy			= gABC.pEyz1[idx] + gABC.coef * (pGrid->pEy[WG_IDX3(i, j, sizeZ - 2, sizeY - 1, sizeZ)] - *pEy);
			gABC.pEyz1[idx] = pGrid->pEy[WG_IDX3(i, j, sizeZ - 2, sizeY - 1, sizeZ)];
		}
	}
}