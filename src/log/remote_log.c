#include "remote_log.h"
#include "cherry/thread/thread.h"
#include "cherry/core/buffer.h"

#include <netdb.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <sys/socket.h> 
#include <arpa/inet.h>
#include <string.h>
#include <signal.h>

#define MAX 1024

static thread_pool __pool__ = {id_null};
static u8 __connect__ = 0;
static int sockfd = -1; 
static u8 enable = 1;

static void __attribute__((destructor)) __out()
{
    // if (sockfd >= 0) {
    //     close(sockfd);
    // }
}

static void __callback(const buffer buf)
{
    if (!__connect__) {
        struct addrinfo hints, *servinfo = NULL, *p;
        int rv;

        memset(&hints, 0, sizeof hints);
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;

        if ((rv = getaddrinfo("192.168.0.180", "5005", &hints, &servinfo)) != 0) {
            return;
        }

        for(p = servinfo; p != NULL; p = p->ai_next) {
            if ((sockfd = socket(p->ai_family, p->ai_socktype,
                    p->ai_protocol)) == -1) {
                continue;
            }
            if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
                close(sockfd);
                sockfd = -1;            
                continue;
            } 
            break;
        }

        if (p == NULL) {
            return;
        }

        __connect__ = 1;
    }

    const char *ptr;
    u32 len;

    buffer_get_ptr(buf, &ptr);
    buffer_length(buf, sizeof(u8), &len);

    // FILE *f = fopen("/private/log.txt", "a");
    // if (f) {
    //     fwrite(ptr, 1, len, f);
    //     fclose(f);
    // }

    send(sockfd, ptr, len, SO_NOSIGPIPE);
}

static char *__tag__ = NULL;

void remote_log_set_process(const char *tag)
{
    __tag__ = realloc(__tag__, strlen(tag) + 1);
    memcpy(__tag__, tag, strlen(tag));
    __tag__[strlen(tag)] = '\0';
}

void remote_log_set_enable(const int v)
{
    enable = v;
}

void remote_log_send(const char *str, const unsigned int len)
{
    if (!enable) return;
    
    if (!id_validate(__pool__.iobj)) {
        thread_pool_new(&__pool__);
        signal(SIGPIPE, SIG_IGN);
    }
 
    thread_job job;
    buffer b; 
    time_t rawtime;
    struct tm * timeinfo;
    char tbuf[128];

    time ( &rawtime );
    timeinfo = localtime ( &rawtime );

    sprintf(tbuf, "[%02d-%02d-%04d %02d:%02d:%02d] ",timeinfo->tm_mday, timeinfo->tm_mon + 1, timeinfo->tm_year + 1900, timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);

    buffer_new(&b);
    buffer_append(b, tbuf, strlen(tbuf));
    if (__tag__) {
        buffer_append(b, __tag__, strlen(__tag__));
        buffer_append(b, ": ", strlen(": "));
    } else {
        buffer_append(b, "Unknown: ", strlen("Unknown: "));
    }
    buffer_append(b, str, len);

    thread_job_new(&job);
    thread_job_set_callback(job, (thread_job_callback)__callback);
    thread_job_add_arguments(job, b.iobj); 
    release(b.iobj);
    
    thread_pool_add_job(__pool__, job);

    release(job.iobj);
} 