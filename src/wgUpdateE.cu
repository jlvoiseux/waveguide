#include "wgCommon.h"
#include "wgUpdateE.h"

void wgInitializeECoefficients(wgGrid* pGrid)
{
	const int sizeX = pGrid->sizeX;
	const int sizeY = pGrid->sizeY;
	const int sizeZ = pGrid->sizeZ;

	for (int x = 0; x < sizeX - 1; x++)
	{
		for (int y = 0; y < sizeY; y++)
		{
			for (int z = 0; z < sizeZ; z++)
			{
				pGrid->pCexe[WG_IDX3(x, y, z, sizeY, sizeZ)] = 1.0;
				pGrid->pCexh[WG_IDX3(x, y, z, sizeY, sizeZ)] = pGrid->cdtds * WG_IMP0;
			}
		}
	}

	for (int x = 0; x < sizeX; x++)
	{
		for (int y = 0; y < sizeY - 1; y++)
		{
			for (int z = 0; z < sizeZ; z++)
			{
				pGrid->pCeye[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] = 1.0;
				pGrid->pCeyh[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] = pGrid->cdtds * WG_IMP0;
			}
		}
	}

	for (int x = 0; x < sizeX; x++)
	{
		for (int y = 0; y < sizeY; y++)
		{
			for (int z = 0; z < sizeZ - 1; z++)
			{
				pGrid->pCeze[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] = 1.0;
				pGrid->pCezh[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] = pGrid->cdtds * WG_IMP0;
			}
		}
	}
}

void wgUpdateE(wgGrid* pGrid)
{
	const int sizeX = pGrid->sizeX;
	const int sizeY = pGrid->sizeY;
	const int sizeZ = pGrid->sizeZ;

	for (int x = 0; x < sizeX - 1; x++)
	{
		for (int y = 1; y < sizeY - 1; y++)
		{
			for (int z = 1; z < sizeZ - 1; z++)
			{
				pGrid->pEx[WG_IDX3(x, y, z, sizeY, sizeZ)] =
					pGrid->pCexe[WG_IDX3(x, y, z, sizeY, sizeZ)] * pGrid->pEx[WG_IDX3(x, y, z, sizeY, sizeZ)] +
					pGrid->pCexh[WG_IDX3(x, y, z, sizeY, sizeZ)] * ((pGrid->pHz[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] - pGrid->pHz[WG_IDX3(x, y - 1, z, sizeY - 1, sizeZ)]) - (pGrid->pHy[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] - pGrid->pHy[WG_IDX3(x, y, z - 1, sizeY, sizeZ - 1)]));
			}
		}
	}

	for (int x = 1; x < sizeX - 1; x++)
	{
		for (int y = 0; y < sizeY - 1; y++)
		{
			for (int z = 1; z < sizeZ - 1; z++)
			{
				pGrid->pEy[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] =
					pGrid->pCeye[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] * pGrid->pEy[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] +
					pGrid->pCeyh[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] * ((pGrid->pHx[WG_IDX3(x, y, z, sizeY - 1, sizeZ - 1)] - pGrid->pHx[WG_IDX3(x, y, z - 1, sizeY - 1, sizeZ - 1)]) - (pGrid->pHz[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] - pGrid->pHz[WG_IDX3(x - 1, y, z, sizeY - 1, sizeZ)]));
			}
		}
	}

	for (int x = 1; x < sizeX - 1; x++)
	{
		for (int y = 1; y < sizeY - 1; y++)
		{
			for (int z = 0; z < sizeZ - 1; z++)
			{
				pGrid->pEz[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] =
					pGrid->pCeze[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] * pGrid->pEz[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] +
					pGrid->pCezh[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] * ((pGrid->pHy[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] - pGrid->pHy[WG_IDX3(x - 1, y, z, sizeY, sizeZ - 1)]) - (pGrid->pHx[WG_IDX3(x, y, z, sizeY - 1, sizeZ - 1)] - pGrid->pHx[WG_IDX3(x, y - 1, z, sizeY - 1, sizeZ - 1)]));
			}
		}
	}
}