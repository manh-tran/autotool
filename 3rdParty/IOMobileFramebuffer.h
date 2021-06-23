#ifndef __IOMOBILEFRAMEBUFFER_H
#define __IOMOBILEFRAMEBUFFER_H

#include <stdio.h>
#include <sys/mman.h>

#ifdef __cplusplus
extern "C" {
#endif

#define kIOMobileFramebufferError 0xE0000000

typedef kern_return_t IOMobileFramebufferReturn;
typedef struct __IOMobileFramebuffer *IOMobileFramebufferConnection;

IOMobileFramebufferReturn IOMobileFramebufferOpen(mach_port_t service, mach_port_t owningTask, unsigned int type, IOMobileFramebufferConnection *connection);
IOMobileFramebufferReturn IOMobileFramebufferGetLayerDefaultSurface(IOMobileFramebufferConnection connection, int surface, IOSurfaceRef *buffer);
IOMobileFramebufferReturn IOMobileFramebufferGetMainDisplay(IOMobileFramebufferConnection *pointer);

#ifdef __cplusplus
}
#endif

#endif