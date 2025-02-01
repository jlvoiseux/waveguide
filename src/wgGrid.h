#pragma once

typedef struct {
	double *pHx, *pChxh, *pChxe;
	double *pHy, *pChyh, *pChye;
	double *pHz, *pChzh, *pChze;
	double *pEx, *pCexe, *pCexh;
	double *pEy, *pCeye, *pCeyh;
	double *pEz, *pCeze, *pCezh;
	int sizeX, sizeY, sizeZ;
	int time, maxTime;
	double cdtds;
} wgGrid;