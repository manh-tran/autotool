#include "device_db.h"
#import <sqlite3.h>
#include "cherry/def.h"
#include "cherry/core/buffer.h"

#define LTR(p) p, sizeof(p) - 1

static sqlite3 *__db__ = NULL;
static spin_lock __barrier__ = SPIN_LOCK_INIT;

static void __init()
{
    char *err_msg = NULL;
    int rc;
    const char *sql;

    lock(&__barrier__);
    if (!__db__) {
        sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/keychain_share_2.db", &__db__);

        if (__db__) {
            sql = "CREATE TABLE IF NOT EXISTS INFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, STATE TEXT NOT NULL, ACCOUNT BLOB NOT NULL, AGRP TEXT NOT NULL, CLASS TEXT NOT NULL, TYPE INTEGER, SVCE TEXT NOT NULL, VALUE BLOB NOT NULL, CONSTRAINT STATE_ACCOUNT_KEY_UNIQUE UNIQUE (STATE, ACCOUNT, AGRP, CLASS, TYPE, SVCE));";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }

            sql = "CREATE TABLE IF NOT EXISTS BUNDLE_STATE (ID INTEGER PRIMARY KEY AUTOINCREMENT, BUNDLE TEXT UNIQUE NOT NULL, STATE TEXT NOT NULL);";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
        }
    }
    unlock(&__barrier__);    
}

void wiiauto_device_db_keychain_share_setup()
{
    system("chown mobile:mobile /private/var/mobile/Library/WiiAuto/Databases/keychain_share_2.db");
    system("chmod 666 /private/var/mobile/Library/WiiAuto/Databases/keychain_share_2.db");
}

void wiiauto_device_db_keychain_set_bundle_state(const char *bundle, const char *state)
{
    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    if (state) {
        sql = "INSERT OR REPLACE INTO BUNDLE_STATE(BUNDLE, STATE) VALUES (?, ?);";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 2, state, strlen(state), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }      
    } else {
        sql = "DELETE FROM BUNDLE_STATE WHERE BUNDLE = ?;";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }      
    }          
    
    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);   
}

void wiiauto_device_db_keychain_get_bundle_state(const char *bundle, char **state)
{
    *state = NULL;

    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;
    size_t len = 0;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql = "SELECT STATE FROM BUNDLE_STATE WHERE BUNDLE = ?;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);

        rc = sqlite3_step(stmt);
        if (rc == SQLITE_ROW) {
            
            len = sqlite3_column_bytes(stmt, 0);

            if (len > 0) {
                *state = malloc(len + 1);
                memset(*state, 0, len + 1);
                strncpy(*state, sqlite3_column_text(stmt, 0), len);
            }  
        }
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }                
    
    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);  
}

void wiiauto_device_db_keychain_set_value(const char *state, 
    const char *acct, const size_t acct_len,
    const char *agrp, const size_t agrp_len, 
    const char *clss, const size_t clss_len,
    const int type,
    const char *svce, const size_t svce_len,
    const char *value, size_t value_len
)
{
    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    if (value) {
        sql = "INSERT OR REPLACE INTO INFO(STATE, ACCOUNT, AGRP, CLASS, TYPE, SVCE, VALUE) VALUES (?, ?, ?, ?, ?, ?, ?);";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, state, strlen(state), SQLITE_TRANSIENT);
            if (acct) {
                sqlite3_bind_blob(stmt, 2, acct, acct_len, SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_blob(stmt, 2, "", 0, SQLITE_TRANSIENT);
            }
            if (agrp) {
                sqlite3_bind_text(stmt, 3, agrp, agrp_len, SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(stmt, 3, "", 0, SQLITE_TRANSIENT);
            }
            if (clss) {
                sqlite3_bind_text(stmt, 4, clss, clss_len, SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(stmt, 4, "", 0, SQLITE_TRANSIENT);
            }
            sqlite3_bind_int(stmt, 5, type);
            if (svce) {
                sqlite3_bind_text(stmt, 6, svce, svce_len, SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(stmt, 6, "", 0, SQLITE_TRANSIENT);
            }
            sqlite3_bind_blob(stmt, 7, value, value_len, SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }
    
    } else {
        buffer buf;
        buffer_new(&buf);

        buffer_append(buf, LTR("DELETE FROM INFO WHERE STATE = ?"));
        buffer_append(buf, LTR(" AND TYPE = ?"));
        if (acct) {
            buffer_append(buf, LTR(" AND ACCOUNT = ?"));
        }
        if (agrp) {
            buffer_append(buf, LTR(" AND AGRP = ?"));
        }
        if (clss) {
            buffer_append(buf, LTR(" AND CLASS = ?"));
        }            
        if (svce) {
            buffer_append(buf, LTR(" AND SVCE = ?"));
        }
        buffer_append(buf, LTR(";"));

        buffer_get_ptr(buf, &sql);
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, state, strlen(state), SQLITE_TRANSIENT);
            sqlite3_bind_int(stmt, 2, type);
            int idx = 3;
            if (acct) {
                sqlite3_bind_blob(stmt, idx, acct, acct_len, SQLITE_TRANSIENT);
                idx++;
            }
            if (agrp) {
                sqlite3_bind_text(stmt, idx, agrp, agrp_len, SQLITE_TRANSIENT);
                idx++;
            }
            if (clss) {
                sqlite3_bind_text(stmt, idx, clss, clss_len, SQLITE_TRANSIENT);
                idx++;
            }
            if (svce) {
                sqlite3_bind_text(stmt, idx, svce, svce_len, SQLITE_TRANSIENT);
                idx++;
            }

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }

        release(buf.iobj);
    }                    
    
    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     
    unlock(&__barrier__);   
}

void wiiauto_device_db_keychain_get_value(const char *state, 
    const char *acct, const size_t acct_len,
    const char *agrp, const size_t agrp_len,
    const char *clss, const size_t clss_len,
    const int type,
    const char *svce, const size_t svce_len,
    char **value, size_t *value_len,
    const int index    
)
{
    *value = NULL;
    *value_len = 0;

    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);  

    buffer buf;
    buffer_new(&buf);

    buffer_append(buf, LTR("SELECT VALUE FROM INFO WHERE STATE = ? AND TYPE = ?"));
    if (acct) {
        buffer_append(buf, LTR(" AND ACCOUNT = ?"));
    }
    if (agrp) {
        buffer_append(buf, LTR(" AND AGRP = ?"));
    }
    if (clss) {
        buffer_append(buf, LTR(" AND CLASS = ?"));
    }
    if (svce) {
        buffer_append(buf, LTR(" AND SVCE = ?"));
    }
    buffer_append(buf, LTR(" LIMIT 1 OFFSET ?;"));
    
    buffer_get_ptr(buf, &sql);
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, state, strlen(state), SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 2, type);
        int idx = 3;
        if (acct) {
            sqlite3_bind_blob(stmt, idx, acct, acct_len, SQLITE_TRANSIENT);
            idx++;
        }
        if (agrp) {
            sqlite3_bind_text(stmt, idx, agrp, agrp_len, SQLITE_TRANSIENT);
            idx++;
        }
        if (clss) {
            sqlite3_bind_text(stmt, idx, clss, clss_len, SQLITE_TRANSIENT);
            idx++;
        }
        if (svce) {
            sqlite3_bind_text(stmt, idx, svce, svce_len, SQLITE_TRANSIENT);
            idx++;
        }
        sqlite3_bind_int(stmt, idx, index);

        rc = sqlite3_step(stmt);
        if (rc == SQLITE_ROW) {
            *value_len = sqlite3_column_bytes(stmt, 0);
            if (*value_len > 0) {
                *value = malloc(*value_len);
                memcpy(*value, sqlite3_column_blob(stmt, 0), *value_len);
            }   
        }
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    release(buf.iobj);

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     
    unlock(&__barrier__);     
}