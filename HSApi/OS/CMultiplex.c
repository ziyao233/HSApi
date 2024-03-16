/*
 *	HSApi
 *	/HSApi/OS/CMultiplex.c
 *	This file is distributed under Mozilla Public License Version 2.0
 *	Copyright (c) 2024 Yao Zi. All rights reserved.
 */

#include<stdio.h>
#include<stdlib.h>
#include<stdint.h>
#include<string.h>
#include<errno.h>

#include<unistd.h>
#include<sys/select.h>

typedef struct {
	unsigned int maxNum;
	int maxFd;
	fd_set rSet, wSet;
} HSApi_Watcher;

#define HSAPI_WATCHER_NULL	0x00
#define HSAPI_WATCHER_READ	0x01
#define HSAPI_WATCHER_WRITE	0x02

HSApi_Watcher *
hsapi_watcher_new(unsigned int maxNum)
{
	if(maxNum > FD_SETSIZE)
		return NULL;

	HSApi_Watcher *watcher = (HSApi_Watcher *)malloc(sizeof(HSApi_Watcher));
	if(!watcher)
		return NULL;

	FD_ZERO(&(watcher->rSet));
	FD_ZERO(&(watcher->wSet));
	watcher->maxFd = 0;

	return watcher;
}

int
hsapi_watcher_watch(HSApi_Watcher *watcher, int fd, int flag)
{
	if(fd > (FD_SETSIZE - 1)) {
		errno = EINVAL;
		return -1;
	}
	if(!flag) {
		errno = EINVAL;
		return -1;
	}

	if(FD_ISSET(fd, &(watcher->rSet)) ||
	   FD_ISSET(fd, &(watcher->rSet))) {
		errno = EEXIST;
		return -1;
	}

	if(flag & HSAPI_WATCHER_READ)
		FD_SET(fd, &(watcher->rSet));
	if(flag & HSAPI_WATCHER_WRITE)
		FD_SET(fd, &(watcher->wSet));
	watcher->maxFd = watcher->maxFd > fd ? watcher->maxFd : fd;

	return 0;
}

int
hsapi_watcher_wait(HSApi_Watcher *watcher, int *list,
		   size_t maxNum, int timeout)
{
	if(!list)
		return -1;

	list[0] = -1;

	fd_set wSet, rSet;

	memcpy(&wSet, &(watcher->wSet), sizeof(fd_set));
	memcpy(&rSet, &(watcher->rSet), sizeof(fd_set));

	struct timeval timeVal, *timeoutPointer = NULL;
	if (timeout) {
		timeoutPointer = &timeVal;
		timeVal = (struct timeval) {
						.tv_sec  = timeout / 1000,
						.tv_usec = timeout % 1000 *
							   1000,
					   };
	}

	int readyNum = select(watcher->maxFd + 1, &rSet, &wSet, NULL,
			      timeoutPointer);
	if(readyNum < 0)
		return -1;

	unsigned int listIndex = 0;
	for(int testFd = 0;
		testFd < FD_SETSIZE &&
		listIndex < (unsigned int)readyNum &&
		listIndex < maxNum;
		testFd++) {
		if(FD_ISSET(testFd, &rSet) || FD_ISSET(testFd, &wSet)) {
			list[listIndex] = testFd;
			listIndex++;
		}
	}

	list[listIndex] = -1;

	return timeVal.tv_sec * 1000 + timeVal.tv_usec / 1000;
}

int
hsapi_watcher_unwatch(HSApi_Watcher *watcher, int fd)
{
	if(FD_ISSET(fd, &(watcher->wSet)) ||
	   FD_ISSET(fd, &(watcher->rSet))) {
		FD_CLR(fd, &(watcher->wSet));
		FD_CLR(fd, &(watcher->rSet));
		if (fd == watcher->maxFd) {
			int nextMax = watcher->maxFd - 1;
			while (!FD_ISSET(nextMax,&(watcher->wSet)) &&
			       !FD_ISSET(nextMax,&(watcher->rSet)) &&
			       nextMax > 0)
				nextMax--;
			watcher->maxFd = nextMax;
		}

		return 0;
	}

	errno = EINVAL;
	return -1;
}

void
hsapi_watcher_destroy(HSApi_Watcher *watcher)
{
	free(watcher);
	return;
}
