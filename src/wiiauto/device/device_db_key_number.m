// #include "device_db.h"
// #import <sqlite3.h>
// #include "cherry/def.h"

// static sqlite3 *__db__ = NULL;
// static spin_lock __barrier__ = SPIN_LOCK_INIT;

// static void __init()
// {
//     char *err_msg = NULL;
//     int rc;
//     const char *sql;

//     lock(&__barrier__);
//     if (!__db__) {
//         sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/key_number_2.db", &__db__);

//         if (__db__) {
//             sql = "CREATE TABLE IF NOT EXISTS INFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, BUNDLE TEXT NOT NULL, KEY TEXT NOT NULL, VALUE TEXT NOT NULL, CONSTRAINT BUNDLE_KEY_VALUE_UNIQUE UNIQUE (BUNDLE, KEY, VALUE));";
//             rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
//             if (rc != SQLITE_OK) {
//                 sqlite3_free(err_msg);
//             }
//         }
//     }
//     unlock(&__barrier__);    
// }

// void wiiauto_device_db_key_number_setup()
// {
//     system("chown mobile:mobile /private/var/mobile/Library/WiiAuto/Databases/key_number_2.db");
//     system("chmod 666 /private/var/mobile/Library/WiiAuto/Databases/key_number_2.db");
// }


// void wiiauto_device_db_key_number_set(const char *bundle, const char *key, const int num)
// {
//     __init();
//     if (!__db__) return;

//     lock(&__barrier__);

//     int rc;
//     const char *sql;
//     sqlite3_stmt *stmt;

//     sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

//     sql = "INSERT OR REPLACE INTO INFO(BUNDLE, KEY, VALUE) VALUES (?, ?, ?);";
//     rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//     if (rc == SQLITE_OK) {
//         sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
//         sqlite3_bind_text(stmt, 2, key, strlen(key), SQLITE_TRANSIENT);
//         sqlite3_bind_int(stmt, 3, num);

//         rc = sqlite3_step(stmt);
//         rc = sqlite3_clear_bindings(stmt);
//         rc = sqlite3_reset(stmt);
//         rc = sqlite3_finalize(stmt);    
//     }

//     sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

//     unlock(&__barrier__);   
// }

// void wiiauto_device_db_key_number_get_lowest(const char *bundle, const int limit, const int offset, int *result_len, __db_key_number_result **result)
// {
//     __init();
//     if (!__db__) return;

//     *result_len = 0;
//     *result = NULL;

//     lock(&__barrier__);

//     int rc;
//     const char *sql;
//     sqlite3_stmt *stmt;

//     sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

//     sql = "SELECT KEY, VALUE FROM INFO WHERE BUNDLE = ? ORDER BY VALUE ASC LIMIT ? OFFSET ?;";
//     rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//     if (rc == SQLITE_OK) {
//         sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
//         sqlite3_bind_int(stmt, 2, limit);
//         sqlite3_bind_int(stmt, 3, offset);

//         while (sqlite3_step(stmt) == SQLITE_ROW) {

//             *result_len = (*result_len) + 1;
//             *result = realloc(*result, sizeof(__db_key_number_result) * (*result_len));            

//             int len = sqlite3_column_bytes(stmt, 0);

//             if (len > 0) {
//                 (*result)[(*result_len) - 1].key = malloc(len + 1);
//                 memset((*result)[(*result_len) - 1].key, 0, len + 1);
//                 strncpy((*result)[(*result_len) - 1].key, sqlite3_column_text(stmt, 0), len);
//             } else {
//                 (*result)[(*result_len) - 1].key = NULL;
//             }

//             (*result)[(*result_len) - 1].num = sqlite3_column_int(stmt, 1);
//         }

//         rc = sqlite3_clear_bindings(stmt);
//         rc = sqlite3_reset(stmt);
//         rc = sqlite3_finalize(stmt);    
//     }

//     sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

//     unlock(&__barrier__);   
// }

// void wiiauto_device_db_key_number_remove(const char *bundle, const char *key)
// {
//     __init();
//     if (!__db__) return;

//     lock(&__barrier__);

//     int rc;
//     const char *sql;
//     sqlite3_stmt *stmt;

//     sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

//     sql = "DELETE FROM INFO WHERE BUNDLE = ? AND KEY = ?;";
//     rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//     if (rc == SQLITE_OK) {
//         sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
//         sqlite3_bind_text(stmt, 2, key, strlen(key), SQLITE_TRANSIENT);

//         rc = sqlite3_step(stmt);
//         rc = sqlite3_clear_bindings(stmt);
//         rc = sqlite3_reset(stmt);
//         rc = sqlite3_finalize(stmt);    
//     }

//     sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

//     unlock(&__barrier__); 
// }