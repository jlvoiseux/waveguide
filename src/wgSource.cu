#include "wgCommon.h"
#include "wgSource.h"

#include <cstdio>

static double gCdtds			   = 0.0;
static double gPointsPerWavelength = 0.0;

void wgInitSource(double cdtds, double pointsPerWavelength)
{
	if (pointsPerWavelength <= 0.0)
	{
		fprintf(stderr, "Points per wavelength must be positive\n");
		exit(1);
	}

	gCdtds				 = cdtds;
	gPointsPerWavelength = pointsPerWavelength;
}

double wgGetSourceValue(double time, double location)
{
	if (gPointsPerWavelength <= 0.0)
	{
		fprintf(stderr, "Source not initialized. Call wgInitSource first\n");
		exit(1);
	}

	double arg = WG_PI * ((gCdtds * time - location) / gPointsPerWavelength - 1.0);
	arg		   = arg * arg;

	return (1.0 - 2.0 * arg) * exp(-arg);
}