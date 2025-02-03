#pragma once

#define WG_IDX2(x, y, sizeY) ((x) * (sizeY) + (y))
#define WG_IDX3(x, y, z, sizeY, sizeZ) ((x) * (sizeY) * (sizeZ) + (y) * (sizeZ) + (z))

#define WG_IMP0 377.0

#define WG_GRID_SIZE_X 32
#define WG_GRID_SIZE_Y 31
#define WG_GRID_SIZE_Z 31

#define WG_SIM_STEPS 300

#define WG_PI 3.14159265358979323846