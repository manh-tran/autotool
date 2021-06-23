// #include "intercom.h"
// #include <sys/mman.h>
// #include <sys/time.h>
// #include <semaphore.h>
// #include <sys/wait.h>
// #include <sys/ipc.h>    
// #include <sys/sem.h>
// #include <pthread.h>
// #include "cherry/core/buffer.h"
// #include "cherry/core/map.h"
// #include <stdatomic.h>
// #include "log/remote_log.h"
// #include "wiiauto/event/event.h"
// #include "wiiauto/thread/thread.h"

// #include "cherry/thread/thread.h"

// static _Bool __compare_exchange(volatile atomic_int *p, const atomic_int expect, const atomic_int desire)
// {
//     return atomic_compare_exchange_weak(p, &expect, desire);
// }

// enum {
//     INTERCOM_SERVER_IDLE = 1,
//     INTERCOM_CLIENT_SETUP,
//     INTERCOM_SERVER_PROCESSING,
//     INTERCOM_SERVER_RETURNING,
//     INTERCOM_CLIENT_FETCHING
// };

// static u64 current_timestamp() 
// {
//     struct timeval te; 
//     gettimeofday(&te, NULL);
//     u64 milliseconds = te.tv_sec*1000LL + te.tv_usec/1000;
//     return milliseconds;
// }

// typedef struct
// {
//     atomic_int state;
//     u64 current_time;
//     u32 data_size;
//     char data[8192];
// }
// __mem;

// local_type(intercom);

// typedef struct
// {
//     __mem *mem;
//     int fd;
//     u32 size;
//     buffer path;
//     wiiauto_intercom_callback callback;
//     volatile int lock;
// }
// __intercom;

// make_local_type(intercom, __intercom);

// static void __intercom_init(__intercom *__p)
// {
//     __p->mem = NULL;
//     __p->fd = -1;
//     __p->size = 0;
//     __p->callback = NULL;
//     __p->lock = 1;
//     buffer_new(&__p->path);
// }

// static void __intercom_clear(__intercom *__p)
// {
//     const char *ptr;

//     if (__p->mem) {
//         munmap(__p->mem, __p->size);
//         __p->mem = NULL;
//     }

//     if (__p->fd >= 0) {
//         close(__p->fd);
//     }

//     if (id_validate(__p->path.iobj)) {
//         buffer_get_ptr(__p->path, &ptr);
//         if (ptr && ptr[0] != '\0') {
//             shm_unlink(ptr);   
//         }        
//     }

//     release(__p->path.iobj);
// }

// static map __intercoms__ = {id_null};

// static void __attribute__((destructor)) __out()
// {
//     release(__intercoms__.iobj);
// }

// static void __execute(const intercom p, const thread_pool pool)
// {
//     __intercom *__p;
//     __block CFDataRef ret;
//     u64 last_time;
//     u64 cm;

//     intercom_fetch(p, &__p);

//     while (__p->lock) {

//         /*
//          * wait client request 
//          */
//         while (__p->lock && atomic_load(&__p->mem->state) != INTERCOM_SERVER_PROCESSING) {
//             usleep(32000);
//         }

//         ret = NULL;

//         if (__p->callback) {

//             dispatch_sync(dispatch_get_main_queue() , ^{
		
//                 CFDataRef data = CFDataCreate(kCFAllocatorDefault, __p->mem->data, __p->mem->data_size);
//                 ret = __p->callback(NULL, 1, data, NULL);
//                 CFRelease(data);

//             });

//         }

//         if (ret) {
//             const void *tmp = CFDataGetBytePtr(ret);
//             int len = CFDataGetLength(ret);

//             __p->mem->data_size = len;
//             memcpy(__p->mem->data, tmp, len);
//             msync(__p->mem->data, len, MS_SYNC);
//             msync(&__p->mem->data_size, sizeof(__p->mem->data_size), MS_SYNC);

//             CFRelease(ret);
//         } else {
//             __wiiauto_event_null evt;
//             __wiiauto_event_null_init(&evt);

//             __p->mem->data_size = sizeof(evt);
//             memcpy(__p->mem->data, &evt, sizeof(evt));
//             msync(__p->mem->data, sizeof(evt), MS_SYNC);
//             msync(&__p->mem->data_size, sizeof(__p->mem->data_size), MS_SYNC);
//         }

//         /*
//          * lock state
//          */
//         atomic_store(&__p->mem->state, INTERCOM_SERVER_RETURNING);

//         last_time = current_timestamp();

//         while (__p->lock && atomic_load(&__p->mem->state) != INTERCOM_SERVER_IDLE) {
//             cm = current_timestamp();
//             if (cm - last_time >= 1000) {
//                 atomic_store(&__p->mem->state, INTERCOM_SERVER_IDLE);
//                 break;
//             }
//             usleep(32000);
//         }
//     }
//     wiiauto_recycle_thread_pool(pool);
// }

// static void __live(const intercom p, const thread_pool pool)
// {
//     __intercom *__p;

//     intercom_fetch(p, &__p);

//     while (true) {
//         __p->mem->current_time = current_timestamp();   
//         msync(&__p->mem->current_time, sizeof(__p->mem->current_time), MS_SYNC);
//         usleep(0.5 * 1000000);            
//     }            

//     wiiauto_recycle_thread_pool(pool);
// }

// void wiiauto_intercom_register_shm(const char *name, const wiiauto_intercom_callback callback)
// {
//     static spin_lock __barrier__ = SPIN_LOCK_INIT;

//     lock(&__barrier__);

//     if (!id_validate(__intercoms__.iobj)) {
//         map_new(&__intercoms__);        
//     }

//     intercom p;
//     __intercom *__p;
//     thread_pool pool;
//     thread_job job;

//     intercom_new(&p);
//     map_set(__intercoms__, key_str(name), p.iobj);
//     release(p.iobj);

//     intercom_fetch(p, &__p);

//     __p->callback = callback;

//     __p->size = sizeof(__mem);
//     buffer_append(__p->path, name, strlen(name));   

//     shm_unlink(name);
//     __p->fd = shm_open(name, (O_CREAT | O_EXCL | O_RDWR), S_IRWXO|S_IRWXG|S_IRWXU);
    
//     if ( __p->fd >= 0) {
//         if (ftruncate( __p->fd, __p->size) == 0) {
//             __p->mem = mmap(NULL, __p->size, (PROT_READ | PROT_WRITE), MAP_SHARED, __p->fd, 0);
//             if (__p->mem != MAP_FAILED) {
//             } else {
//                 __p->mem = NULL;
//             }
//         }
//     }

//     unlock(&__barrier__);

//     if (__p->mem) {

//         atomic_store(&__p->mem->state, INTERCOM_SERVER_IDLE);
//         __p->mem->data_size = 0;
//         __p->mem->current_time = current_timestamp();

//         wiiauto_get_thread_pool(&pool);
//         thread_job_new(&job);
//         thread_job_set_callback(job, (thread_job_callback)__execute);
//         thread_job_add_arguments(job, p.iobj);
//         thread_job_add_arguments(job, pool.iobj);
//         thread_pool_add_job(pool, job);
//         release(job.iobj);  

//         wiiauto_get_thread_pool(&pool);
//         thread_job_new(&job);
//         thread_job_set_callback(job, (thread_job_callback)__live);
//         thread_job_add_arguments(job, p.iobj);
//         thread_job_add_arguments(job, pool.iobj);
//         thread_pool_add_job(pool, job);
//         release(job.iobj);    
//     }
// }


// /*
//  * client
//  */

// local_type(client);

// typedef struct
// {
//     __mem *mem;
//     int fd;
//     u32 size;
//     spin_lock barrier;
//     volatile int lock;
// }
// __client;

// make_local_type(client, __client);

// static void __client_init(__client *__p)
// {
//     __p->mem = NULL;
//     __p->fd = -1;
//     __p->size = 0;
//     __p->barrier = 0;
//     __p->lock = 1;
// }

// static void __client_clear(__client *__p)
// {
//     if (__p->fd >= 0) {
//         close(__p->fd);
//     }
//     if (__p->mem) {
//         munmap(__p->mem, __p->size);
//         __p->mem = NULL;
//     }
// }

// static map __clients__ = {id_null};

// CFDataRef wiiauto_intercom_send_shm(const char *name, const void *data, const u32 len)
// {
//     CFDataRef ret = NULL;

//     static spin_lock __barrier__ = SPIN_LOCK_INIT;

//     client cl;
//     __client *__cl;
//     u64 cm;
//     int checked_count = 0;
//     u64 last_time;

//     /* 
//      * get client 
//      */
//     lock(&__barrier__);
//     if (!id_validate(__clients__.iobj)) {
//         map_new(&__clients__);
//     }
//     map_get(__clients__, key_str(name), &cl.iobj);
//     if (!id_validate(cl.iobj)) {
//         client_new(&cl);
//         map_set(__clients__, key_str(name), cl.iobj);
//         release(cl.iobj);
//     }
//     client_fetch(cl, &__cl);
//     __cl->size = sizeof(__mem);
//     unlock(&__barrier__);


//     /* 
//      * check client 
//      */
//     lock(&__cl->barrier);

// check:
//     if (!__cl->mem) {
//         __cl->fd = shm_open(name, O_RDWR, S_IRUSR | S_IWUSR);
//         if (__cl->fd != -1) {
//             __cl->mem = mmap(NULL, __cl->size, (PROT_READ | PROT_WRITE), MAP_SHARED, __cl->fd, 0);
//             if (!__cl->mem) {
//                 close(__cl->fd);
//                 __cl->fd = -1;
//             }
//         }   
//     }

//     if (__cl->mem) {
//         cm = current_timestamp();   
//         if (cm - __cl->mem->current_time >= 10000) {
//             if (__cl->fd >= 0) {
//                 close(__cl->fd);
//             }
//             if (__cl->mem) {
//                 munmap(__cl->mem, __cl->size);
//                 __cl->mem = NULL;
//             }
//             if (checked_count < 10) {
//                 checked_count++;
//                 goto check;
//             }            
//         } else {

//             last_time = current_timestamp();

//             while (__cl->lock && !__compare_exchange(&__cl->mem->state, INTERCOM_SERVER_IDLE, INTERCOM_CLIENT_SETUP)) {
//                 cm = current_timestamp();
//                 if (cm - last_time >= 6000) {
//                     goto finish_check;
//                 }
//                 usleep(32000);
//             }

//             __cl->mem->data_size = len;
//             memcpy(__cl->mem->data, data, len);
//             msync(__cl->mem->data, len, MS_SYNC);
//             msync(&__cl->mem->data_size, sizeof(__cl->mem->data_size), MS_SYNC);

//             last_time = current_timestamp();
            
//             while (__cl->lock && !__compare_exchange(&__cl->mem->state, INTERCOM_CLIENT_SETUP, INTERCOM_SERVER_PROCESSING)) {
//                 cm = current_timestamp();
//                 if (cm - last_time >= 6000) {
//                     goto finish_check;
//                 }
//                 usleep(32000);
//             }

//             last_time = current_timestamp();

//             while (__cl->lock && !__compare_exchange(&__cl->mem->state, INTERCOM_SERVER_RETURNING, INTERCOM_CLIENT_FETCHING)) {
//                 cm = current_timestamp();
//                 if (cm - last_time >= 6000) {
//                     goto finish_check;
//                 }
//                 usleep(32000);
//             }

//             ret = CFDataCreate(kCFAllocatorDefault, __cl->mem->data, __cl->mem->data_size);

//             atomic_store(&__cl->mem->state, INTERCOM_SERVER_IDLE);
//         }
//     }

// finish_check:
//     unlock(&__cl->barrier);

//     return ret;
// }