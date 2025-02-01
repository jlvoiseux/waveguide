#include "wgCommon.h"
#include "wgUpdateH.h"

void wgInitializeHCoefficients(wgGrid* pGrid)
{
	const int sizeX = pGrid->sizeX;
	const int sizeY = pGrid->sizeY;
	const int sizeZ = pGrid->sizeZ;

	for (int x = 0; x < sizeX; x++)
	{
		for (int y = 0; y < sizeY - 1; y++)
		{
			for (int z = 0; z < sizeZ - 1; z++)
			{
				pGrid->pChxh[WG_IDX3(x, y, z, sizeY - 1, sizeZ - 1)] = 1.0;
				pGrid->pChxe[WG_IDX3(x, y, z, sizeY - 1, sizeZ - 1)] = pGrid->cdtds / WG_IMP0;
			}
		}
	}

	for (int x = 0; x < sizeX - 1; x++)
	{
		for (int y = 0; y < sizeY; y++)
		{
			for (int z = 0; z < sizeZ - 1; z++)
			{
				pGrid->pChyh[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] = 1.0;
				pGrid->pChye[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] = pGrid->cdtds / WG_IMP0;
			}
		}
	}

	for (int x = 0; x < sizeX - 1; x++)
	{
		for (int y = 0; y < sizeY - 1; y++)
		{
			for (int z = 0; z < sizeZ; z++)
			{
				pGrid->pChzh[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] = 1.0;
				pGrid->pChze[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] = pGrid->cdtds / WG_IMP0;
			}
		}
	}
}

void wgUpdateH(wgGrid* pGrid)
{
	const int sizeX = pGrid->sizeX;
	const int sizeY = pGrid->sizeY;
	const int sizeZ = pGrid->sizeZ;

	for (int x = 0; x < sizeX; x++)
	{
		for (int y = 0; y < sizeY - 1; y++)
		{
			for (int z = 0; z < sizeZ - 1; z++)
			{
				pGrid->pHx[WG_IDX3(x, y, z, sizeY - 1, sizeZ - 1)] =
					pGrid->pChxh[WG_IDX3(x, y, z, sizeY - 1, sizeZ - 1)] * pGrid->pHx[WG_IDX3(x, y, z, sizeY - 1, sizeZ - 1)] +
					pGrid->pChxe[WG_IDX3(x, y, z, sizeY - 1, sizeZ - 1)] * ((pGrid->pEy[WG_IDX3(x, y, z + 1, sizeY - 1, sizeZ)] - pGrid->pEy[WG_IDX3(x, y, z, sizeY - 1, sizeZ)]) - (pGrid->pEz[WG_IDX3(x, y + 1, z, sizeY, sizeZ - 1)] - pGrid->pEz[WG_IDX3(x, y, z, sizeY, sizeZ - 1)]));
			}
		}
	}

	for (int x = 0; x < sizeX - 1; x++)
	{
		for (int y = 0; y < sizeY; y++)
		{
			for (int z = 0; z < sizeZ - 1; z++)
			{
				pGrid->pHy[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] =
					pGrid->pChyh[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] * pGrid->pHy[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] +
					pGrid->pChye[WG_IDX3(x, y, z, sizeY, sizeZ - 1)] * ((pGrid->pEz[WG_IDX3(x + 1, y, z, sizeY, sizeZ - 1)] - pGrid->pEz[WG_IDX3(x, y, z, sizeY, sizeZ - 1)]) - (pGrid->pEx[WG_IDX3(x, y, z + 1, sizeY, sizeZ)] - pGrid->pEx[WG_IDX3(x, y, z, sizeY, sizeZ)]));
			}
		}
	}

	for (int x = 0; x < sizeX - 1; x++)
	{
		for (int y = 0; y < sizeY - 1; y++)
		{
			for (int z = 0; z < sizeZ; z++)
			{
				pGrid->pHz[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] =
					pGrid->pChzh[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] * pGrid->pHz[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] +
					pGrid->pChze[WG_IDX3(x, y, z, sizeY - 1, sizeZ)] * ((pGrid->pEx[WG_IDX3(x, y + 1, z, sizeY, sizeZ)] - pGrid->pEx[WG_IDX3(x, y, z, sizeY, sizeZ)]) - (pGrid->pEy[WG_IDX3(x + 1, y, z, sizeY - 1, sizeZ)] - pGrid->pEy[WG_IDX3(x, y, z, sizeY - 1, sizeZ)]));
			}
		}
	}
}