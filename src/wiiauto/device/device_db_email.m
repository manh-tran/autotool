#include "device_db.h"
#import <sqlite3.h>
#include "cherry/def.h"

static sqlite3 *__db__ = NULL;
static spin_lock __barrier__ = SPIN_LOCK_INIT;

static void __init()
{
    char *err_msg = NULL;
    int rc;
    const char *sql;

    lock(&__barrier__);
    if (!__db__) {
        sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/email.db", &__db__);

        if (__db__) {
            sql = "CREATE TABLE IF NOT EXISTS EMAIL (ID INTEGER PRIMARY KEY AUTOINCREMENT, EMAIL TEXT UNIQUE NOT NULL, PASSWORD TEXT NOT NULL);";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }

            sql = "CREATE TABLE IF NOT EXISTS APPLEID (ID INTEGER PRIMARY KEY AUTOINCREMENT, EMAIL_ID INTEGER UNIQUE NOT NULL, STATE INTEGER NOT NULL DEFAULT 0);";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }

            sql = "CREATE TABLE IF NOT EXISTS APPLEID_MACHINE (ID INTEGER PRIMARY KEY AUTOINCREMENT, APPLEID_ID INTEGER NOT NULL, SERIAL TEXT NOT NULL, CONSTRAINT APPLEID_ID_SERIAL_UNIQUE UNIQUE (APPLEID_ID, SERIAL));";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
        }
    }
    unlock(&__barrier__);    
}

void wiiauto_device_db_email_setup()
{
    __init();

    system("chown mobile:mobile /private/var/mobile/Library/WiiAuto/Databases/email.db");
    system("chmod 666 /private/var/mobile/Library/WiiAuto/Databases/email.db");
}


void wiiauto_device_db_email_add(const char *email, const char *password)
{
    __init();
    if (!__db__) return;

    lock(&__barrier__);

    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql = "INSERT OR IGNORE INTO EMAIL(EMAIL, PASSWORD) VALUES (?, ?);";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, email, strlen(email), SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, password, strlen(password), SQLITE_TRANSIENT);

        rc = sqlite3_step(stmt);
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    sql = "UPDATE EMAIL SET PASSWORD = ? WHERE EMAIL = ?;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, password, strlen(password), SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, email, strlen(email), SQLITE_TRANSIENT);

        rc = sqlite3_step(stmt);
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}

void wiiauto_device_db_email_set_appleid_register_state(const char *email, const char *password, const int state)
{
    __init();
    if (!__db__) return;
    
    int email_id = -1;
    int rc;
    const char *sql;
    sqlite3_stmt *stmt;

    // add email
    wiiauto_device_db_email_add(email, password);

    // get email id
    {
        lock(&__barrier__);
        sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

        sql = "SELECT EMAIL.ID FROM EMAIL WHERE EMAIL.EMAIL = ? AND EMAIL.PASSWORD = ?;";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, email, strlen(email), SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 2, password, strlen(password), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            if (rc == SQLITE_ROW) {
                email_id = sqlite3_column_int(stmt, 0);
            }
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }

        sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

        unlock(&__barrier__);
    }

    // set state
    if (email_id >= 0) {

        lock(&__barrier__);

        sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

        sql = "INSERT OR IGNORE INTO APPLEID(EMAIL_ID, STATE) VALUES (?, ?);";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, email_id);
            sqlite3_bind_int(stmt, 2, state);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }

        sql = "UPDATE APPLEID SET STATE = ? WHERE EMAIL_ID = ?;";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, state);
            sqlite3_bind_int(stmt, 2, email_id);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }

        sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

        unlock(&__barrier__);

    }

}

void wiiauto_device_db_email_get_appleid_unregistered(const char *serial, char **email, char **password, const int auto_register)
{
    *email = NULL;
    *password = NULL;

    __init();
    if (!__db__) return;
    
    int rc;
    int len;
    const char *sql;
    sqlite3_stmt *stmt;
    int appleid_id = -1;

    lock(&__barrier__);

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql =  "SELECT A.EMAIL, A.PASSWORD, B.ID FROM EMAIL A, APPLEID B WHERE "
            "A.ID = B.EMAIL_ID AND "
            "B.STATE = 0 AND "
            "NOT EXISTS( "
                "SELECT 1 FROM APPLEID_MACHINE C WHERE C.APPLEID_ID = B.ID AND C.SERIAL = ?  "
            ") AND NOT EXISTS( "
                "SELECT 1 FROM APPLEID_MACHINE D WHERE D.APPLEID_ID = B.ID GROUP BY D.APPLEID_ID HAVING COUNT(D.SERIAL) > 5"
            ")"
            "LIMIT 1;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, serial, strlen(serial), SQLITE_TRANSIENT);

        rc = sqlite3_step(stmt);
        if (rc == SQLITE_ROW) {

            len = sqlite3_column_bytes(stmt, 0);
            *email = malloc(len + 1);
            memset(*email, 0, len + 1);
            strncpy(*email, sqlite3_column_text(stmt, 0), len);

            len = sqlite3_column_bytes(stmt, 1);
            *password = malloc(len + 1);
            memset(*password, 0, len + 1);
            strncpy(*password, sqlite3_column_text(stmt, 1), len);

            appleid_id = sqlite3_column_int(stmt, 2);

        }
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    if (appleid_id >= 0 && auto_register) {

        sql = "INSERT OR IGNORE INTO APPLEID_MACHINE(APPLEID_ID, SERIAL) VALUES (?, ?);";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, appleid_id);
            sqlite3_bind_text(stmt, 2, serial, strlen(serial), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }

    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}

void wiiauto_device_db_email_get_appleid_unregistered_alike(const char *serial, char **email, char **password, const char *alike, const int auto_register)
{
    *email = NULL;
    *password = NULL;

    __init();
    if (!__db__) return;
    
    int rc;
    int len;
    const char *sql;
    sqlite3_stmt *stmt;
    int appleid_id = -1;

    lock(&__barrier__);

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql =  "SELECT A.EMAIL, A.PASSWORD, B.ID FROM EMAIL A, APPLEID B WHERE "
            "A.EMAIL like ? AND "
            "A.ID = B.EMAIL_ID AND "
            "B.STATE = 0 AND "
            "NOT EXISTS( "
                "SELECT 1 FROM APPLEID_MACHINE C WHERE C.APPLEID_ID = B.ID AND C.SERIAL = ?  "
            ") AND NOT EXISTS( "
                "SELECT 1 FROM APPLEID_MACHINE D WHERE D.APPLEID_ID = B.ID GROUP BY D.APPLEID_ID HAVING COUNT(D.SERIAL) > 5"
            ") LIMIT 1;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, alike, strlen(alike), SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, serial, strlen(serial), SQLITE_TRANSIENT);

        rc = sqlite3_step(stmt);
        if (rc == SQLITE_ROW) {

            len = sqlite3_column_bytes(stmt, 0);
            *email = malloc(len + 1);
            memset(*email, 0, len + 1);
            strncpy(*email, sqlite3_column_text(stmt, 0), len);

            len = sqlite3_column_bytes(stmt, 1);
            *password = malloc(len + 1);
            memset(*password, 0, len + 1);
            strncpy(*password, sqlite3_column_text(stmt, 1), len);

            appleid_id = sqlite3_column_int(stmt, 2);

        }
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    if (appleid_id >= 0 && auto_register) {

        sql = "INSERT OR IGNORE INTO APPLEID_MACHINE(APPLEID_ID, SERIAL) VALUES (?, ?);";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, appleid_id);
            sqlite3_bind_text(stmt, 2, serial, strlen(serial), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }

    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}   

void wiiauto_device_db_email_add_appleid_machine(const char *serial, const char *email, const char *password)
{
    __init();
    if (!__db__) return;
    
    int rc;
    int len;
    const char *sql;
    sqlite3_stmt *stmt;
    int appleid_id = -1;

    lock(&__barrier__);

    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

    sql =  "SELECT B.ID FROM EMAIL A, APPLEID B WHERE A.EMAIL = ? AND A.PASSWORD = ? AND A.ID = B.EMAIL_ID;";
    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, email, strlen(email), SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, password, strlen(password), SQLITE_TRANSIENT);

        rc = sqlite3_step(stmt);
        if (rc == SQLITE_ROW) {
            appleid_id = sqlite3_column_int(stmt, 0);

        }
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);    
    }

    if (appleid_id >= 0) {

        sql = "INSERT OR IGNORE INTO APPLEID_MACHINE(APPLEID_ID, SERIAL) VALUES (?, ?);";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, appleid_id);
            sqlite3_bind_text(stmt, 2, serial, strlen(serial), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }

    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

    unlock(&__barrier__);
}   