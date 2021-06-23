#include "preference.h"

#include "preference.h"
#include "cherry/json/json.h"
#include "cherry/core/buffer.h"
#include "wiiauto/common/common.h"
#import <sqlite3.h>
#include "wiiauto/file/file.h"

typedef struct
{
    sqlite3 *db;
    spin_lock barrier;
}
__wiiauto_preference;

make_type(wiiauto_preference, __wiiauto_preference);

static void __wiiauto_preference_init(__wiiauto_preference *__p)
{
    __p->db = NULL;
    __p->barrier = SPIN_LOCK_INIT;
}

static void __wiiauto_preference_clear(__wiiauto_preference *__p)
{
    if (__p->db) {
        sqlite3_close(__p->db);
    }
}

void wiiauto_preference_save(const wiiauto_preference p)
{
    __wiiauto_preference *__p;
    wiiauto_preference_fetch(p, &__p);
    assert(__p != NULL);

    lock(&__p->barrier);




    unlock(&__p->barrier);
}

void wiiauto_preference_create(const char *name, wiiauto_preference *p)
{
    wiiauto_preference_new(p);
    __wiiauto_preference *__p;
    char *err_msg = NULL;
    int rc;
    const char *sql;
    const char *ptr;
    buffer url;
    buffer url2;

    wiiauto_preference_fetch(*p, &__p);   

    buffer_new(&url);
    buffer_new(&url2);

    common_get_internal_url(name, url);
    buffer_get_ptr(url, &ptr); 
    wiiauto_convert_url(ptr, url2);
    buffer_get_ptr(url2, &ptr); 

    sqlite3_open(ptr, &__p->db);

    if (__p->db) {
        sql = "CREATE TABLE IF NOT EXISTS TIMER (ID INTEGER PRIMARY KEY AUTOINCREMENT, URL TEXT NOT NULL UNIQUE, FIRETIME INTEGER NOT NULL, REPEAT INTEGER NOT NULL, INTERVAL INTEGER NOT NULL, ENABLE INTEGER NOT NULL);";
        rc = sqlite3_exec(__p->db, sql, 0, 0, &err_msg);
        if (rc != SQLITE_OK) {
            sqlite3_free(err_msg);
        }
    }

    release(url.iobj);
    release(url2.iobj);
}

void wiiauto_preference_set_firetime(const wiiauto_preference p, const char *url, const time_t fire_time)
{
    __wiiauto_preference *__p;
    wiiauto_preference_fetch(p, &__p);
    assert(__p != NULL);
    char *sql;
    char *err_msg = NULL;
    int rc;
    
    lock(&__p->barrier);

    sql = sqlite3_mprintf("UPDATE TIMER SET FIRETIME=%d WHERE URL='%q';", fire_time, url);
    if (sql) {
        rc = sqlite3_exec(__p->db, sql, 0, 0, &err_msg);
        if (rc != SQLITE_OK) {
            sqlite3_free(err_msg);
        }
        sqlite3_free(sql);
    }

    unlock(&__p->barrier);
}

void wiiauto_preference_set_timer(const wiiauto_preference p, const char *url, const time_t fire_time, const u8 repeat, const i32 interval)
{
    __wiiauto_preference *__p;
    wiiauto_preference_fetch(p, &__p);
    assert(__p != NULL);
    char *sql;
    char *err_msg = NULL;
    int rc;

    lock(&__p->barrier);

    sql = sqlite3_mprintf("INSERT OR REPLACE INTO TIMER(URL, FIRETIME, REPEAT, INTERVAL, ENABLE) VALUES ('%q', %d, %d, %d, %d);", url, fire_time, repeat, interval, 1);
    if (sql) {
        rc = sqlite3_exec(__p->db, sql, 0, 0, &err_msg);
        if (rc != SQLITE_OK) {
            sqlite3_free(err_msg);
        }
        sqlite3_free(sql);
    }

    unlock(&__p->barrier);
}

void wiiauto_preference_clear_timer(const wiiauto_preference p, const char *url)
{
    __wiiauto_preference *__p;
    wiiauto_preference_fetch(p, &__p);
    assert(__p != NULL);
    char *sql;
    char *err_msg = NULL;
    int rc;

    lock(&__p->barrier);


    sql = sqlite3_mprintf("DELETE FROM TIMER WHERE URL='%q';", url);
    if (sql) {
        rc = sqlite3_exec(__p->db, sql, 0, 0, &err_msg);
        if (rc != SQLITE_OK) {
            sqlite3_free(err_msg);
        }
        sqlite3_free(sql);
    }


    unlock(&__p->barrier);
}

void wiiauto_preference_enable_timer(const wiiauto_preference p, const char *url, const u8 enable)
{
    __wiiauto_preference *__p;
    wiiauto_preference_fetch(p, &__p);
    assert(__p != NULL);
    char *sql;
    char *err_msg = NULL;
    int rc;

    lock(&__p->barrier);

    sql = sqlite3_mprintf("UPDATE TIMER SET ENABLE=%d WHERE URL='%q';", enable, url);
    if (sql) {
        rc = sqlite3_exec(__p->db, sql, 0, 0, &err_msg);
        if (rc != SQLITE_OK) {
            sqlite3_free(err_msg);
        }
        sqlite3_free(sql);
    }


    unlock(&__p->barrier);
}

typedef struct
{
    char *url;
    time_t fire_time;
    u8 repeat;
    i32 interval;
    u8 enable;
}
__result;

static int __callback(void *callBackArg, int argc, char **argv, char **azColName)
{
    if (argc > 0) {
        __result *ret = (__result *)callBackArg;

        for (int i = 0; i < argc; i++) {

            if (strcmp(azColName[i], "URL") == 0 || strcmp(azColName[i], "url") == 0) {
                ret->url = malloc(strlen(argv[i]) + 1);
                strcpy(ret->url, argv[i]);
            } else if (strcmp(azColName[i], "FIRETIME") == 0 || strcmp(azColName[i], "firetime") == 0) {
                ret->fire_time = strtol(argv[i], NULL, 10);
            } else if (strcmp(azColName[i], "REPEAT") == 0 || strcmp(azColName[i], "repeat") == 0) {
                ret->repeat = strtol(argv[i], NULL, 10);
            } else if (strcmp(azColName[i], "INTERVAL") == 0 || strcmp(azColName[i], "interval") == 0) {
                ret->interval = strtol(argv[i], NULL, 10);
            } else if (strcmp(azColName[i], "ENABLE") == 0 || strcmp(azColName[i], "enable") == 0) {
                ret->enable = strtol(argv[i], NULL, 10);
            }

        }
    }

    return 0;
}

void wiiauto_preference_iterate_timer(const wiiauto_preference p, const u32 index, const char **url, time_t *fire_time, u8 *repeat, i32 *interval, u8 *enable)
{
    __wiiauto_preference *__p;
    wiiauto_preference_fetch(p, &__p);
    assert(__p != NULL);
    char *sql;
    char *err_msg = NULL;
    int rc;
    __result ret;
    ret.url = NULL;

    lock(&__p->barrier);

    sql = sqlite3_mprintf("SELECT * FROM TIMER LIMIT 1 OFFSET %d;", index);
    if (sql) {
        rc = sqlite3_exec(__p->db, sql, __callback, &ret, &err_msg);
        if (rc != SQLITE_OK) {
            sqlite3_free(err_msg);
        }
        sqlite3_free(sql);
    }

    if (ret.url) {

        *url = ret.url;
        *fire_time = ret.fire_time;
        *repeat = ret.repeat;
        *interval = ret.interval;
        *enable = ret.enable;

    } else {
        *url = NULL;
        *fire_time = 0;
        *repeat = 0;
        *interval = 0;
        *enable = 0;
    }

    unlock(&__p->barrier);
}