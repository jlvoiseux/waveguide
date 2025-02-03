#include "wgTimer.h"
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
static double getTime(void)
{
    LARGE_INTEGER freq, counter;
    QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&counter);
    return (double)counter.QuadPart / (double)freq.QuadPart;
}
#else
#include <time.h>
static double getTime(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}
#endif

static int compareDoubles(const void* a, const void* b)
{
    double da = *(const double*)a;
    double db = *(const double*)b;
    return (da > db) - (da < db);
}

void wgTimerStart(wgTimer* pTimer, size_t maxFrames)
{
    if (!pTimer)
        return;

    pTimer->pFrameTimes = (double*)malloc(maxFrames * sizeof(double));
    pTimer->frameCount = 0;
    pTimer->maxFrames = maxFrames;
    pTimer->startTime = getTime();
}

void wgTimerFrameStart(wgTimer* pTimer)
{
    if (!pTimer || pTimer->frameCount >= pTimer->maxFrames)
        return;

    pTimer->startTime = getTime();
}

void wgTimerFrameEnd(wgTimer* pTimer)
{
    if (!pTimer || pTimer->frameCount >= pTimer->maxFrames)
        return;

    pTimer->pFrameTimes[pTimer->frameCount++] = getTime() - pTimer->startTime;
}

double wgTimerGetTotalTime(wgTimer* pTimer)
{
    if (!pTimer)
        return 0.0;

    double total = 0.0;
    for (size_t i = 0; i < pTimer->frameCount; i++)
        total += pTimer->pFrameTimes[i];
    return total;
}

double wgTimerGetMedianFrameTime(wgTimer* pTimer)
{
    if (!pTimer || pTimer->frameCount == 0)
        return 0.0;

    // Create a copy of frame times for sorting
    double* sortedTimes = (double*)malloc(pTimer->frameCount * sizeof(double));
    memcpy(sortedTimes, pTimer->pFrameTimes, pTimer->frameCount * sizeof(double));

    // Sort the copy
    qsort(sortedTimes, pTimer->frameCount, sizeof(double), compareDoubles);

    // Get median
    double median;
    if (pTimer->frameCount % 2 == 0)
        median = (sortedTimes[pTimer->frameCount/2 - 1] + sortedTimes[pTimer->frameCount/2]) / 2.0;
    else
        median = sortedTimes[pTimer->frameCount/2];

    free(sortedTimes);
    return median;
}

void wgTimerCleanup(wgTimer* pTimer)
{
    if (!pTimer)
        return;

    free(pTimer->pFrameTimes);
    pTimer->pFrameTimes = NULL;
    pTimer->frameCount = 0;
    pTimer->maxFrames = 0;
}