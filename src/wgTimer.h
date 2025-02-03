#pragma once
#include <stddef.h>

typedef struct {
	double startTime;
	double* pFrameTimes;
	size_t frameCount;
	size_t maxFrames;
} wgTimer;

void wgTimerStart(wgTimer* pTimer, size_t maxFrames);
void wgTimerFrameStart(wgTimer* pTimer);
void wgTimerFrameEnd(wgTimer* pTimer);
double wgTimerGetTotalTime(wgTimer* pTimer);
double wgTimerGetMedianFrameTime(wgTimer* pTimer);
void wgTimerCleanup(wgTimer* pTimer);