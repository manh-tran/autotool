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
//         sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/keychain_share.db", &__db__);

//         if (__db__) {
//             sql = "CREATE TABLE IF NOT EXISTS INFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, STATE TEXT NOT NULL, ACCOUNT BLOB NOT NULL, KEY BLOB NOT NULL, VALUE BLOB NOT NULL, CONSTRAINT STATE_ACCOUNT_KEY_UNIQUE UNIQUE (STATE, ACCOUNT, KEY));";
//             rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
//             if (rc != SQLITE_OK) {
//                 sqlite3_free(err_msg);
//             }

//             sql = "CREATE TABLE IF NOT EXISTS BUNDLE_STATE (ID INTEGER PRIMARY KEY AUTOINCREMENT, BUNDLE TEXT UNIQUE NOT NULL, STATE TEXT NOT NULL);";
//             rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
//             if (rc != SQLITE_OK) {
//                 sqlite3_free(err_msg);
//             }
//         }
//     }
//     unlock(&__barrier__);    
// }

// void wiiauto_device_db_keychain_share_setup()
// {
//     system("chown mobile:mobile /private/var/mobile/Library/WiiAuto/Databases/keychain_share.db");
//     system("chmod 666 /private/var/mobile/Library/WiiAuto/Databases/keychain_share.db");
// }

// void wiiauto_device_db_keychain_set_bundle_state(const char *bundle, const char *state)
// {
//     __init();
//     if (!__db__) return;

//     lock(&__barrier__);

//     int rc;
//     const char *sql;
//     sqlite3_stmt *stmt;

//     sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

//     if (state) {
//         sql = "INSERT OR REPLACE INTO BUNDLE_STATE(BUNDLE, STATE) VALUES (?, ?);";
//         rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//         if (rc == SQLITE_OK) {
//             sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
//             sqlite3_bind_text(stmt, 2, state, strlen(state), SQLITE_TRANSIENT);

//             rc = sqlite3_step(stmt);
//             rc = sqlite3_clear_bindings(stmt);
//             rc = sqlite3_reset(stmt);
//             rc = sqlite3_finalize(stmt);    
//         }      
//     } else {
//         sql = "DELETE FROM BUNDLE_STATE WHERE BUNDLE = ?;";
//         rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//         if (rc == SQLITE_OK) {
//             sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);

//             rc = sqlite3_step(stmt);
//             rc = sqlite3_clear_bindings(stmt);
//             rc = sqlite3_reset(stmt);
//             rc = sqlite3_finalize(stmt);    
//         }      
//     }          
    
//     sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

//     unlock(&__barrier__);   
// }

// void wiiauto_device_db_keychain_get_bundle_state(const char *bundle, char **state)
// {
//     *state = NULL;

//     __init();
//     if (!__db__) return;

//     lock(&__barrier__);

//     int rc;
//     const char *sql;
//     sqlite3_stmt *stmt;
//     size_t len = 0;

//     sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

//     sql = "SELECT STATE FROM BUNDLE_STATE WHERE BUNDLE = ?;";
//     rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//     if (rc == SQLITE_OK) {
//         sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);

//         rc = sqlite3_step(stmt);
//         if (rc == SQLITE_ROW) {
            
//             len = sqlite3_column_bytes(stmt, 0);

//             if (len > 0) {
//                 *state = malloc(len + 1);
//                 memset(*state, 0, len + 1);
//                 strncpy(*state, sqlite3_column_text(stmt, 0), len);
//             }  
//         }
//         rc = sqlite3_clear_bindings(stmt);
//         rc = sqlite3_reset(stmt);
//         rc = sqlite3_finalize(stmt);    
//     }                
    
//     sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

//     unlock(&__barrier__);  
// }

// void wiiauto_device_db_keychain_set_value(const char *state, const char *acct_in, const size_t acct_len_in, const char *key, const size_t key_len, const char *value, size_t value_len)
// {
//     __init();
//     if (!__db__) return;

//     lock(&__barrier__);

//     const char *acct;
//     size_t acct_len;

//     if (acct_in) {
//         acct = acct_in;
//         acct_len = acct_len_in;
//     } else {
//         acct = "";
//         acct_len = 0;
//     }

//     int rc;
//     const char *sql;
//     sqlite3_stmt *stmt;

//     sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

//     if (value) {
//         sql = "INSERT OR REPLACE INTO INFO(STATE, ACCOUNT, KEY, VALUE) VALUES (?, ?, ?, ?);";
//         rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//         if (rc == SQLITE_OK) {
//             sqlite3_bind_text(stmt, 1, state, strlen(state), SQLITE_TRANSIENT);
//             sqlite3_bind_blob(stmt, 2, acct, acct_len, SQLITE_TRANSIENT);
//             sqlite3_bind_blob(stmt, 3, key, key_len, SQLITE_TRANSIENT);
//             sqlite3_bind_blob(stmt, 4, value, value_len, SQLITE_TRANSIENT);

//             rc = sqlite3_step(stmt);
//             rc = sqlite3_clear_bindings(stmt);
//             rc = sqlite3_reset(stmt);
//             rc = sqlite3_finalize(stmt);    
//         }
        
//         if (acct_len == 0) {
//             sql = "UPDATE INFO SET VALUE = ? WHERE STATE = ? AND KEY = ?;";
//             rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//             if (rc == SQLITE_OK) {
//                 sqlite3_bind_blob(stmt, 1, value, value_len, SQLITE_TRANSIENT);
//                 sqlite3_bind_text(stmt, 2, state, strlen(state), SQLITE_TRANSIENT);
//                 sqlite3_bind_blob(stmt, 3, key, key_len, SQLITE_TRANSIENT);
                
//                 rc = sqlite3_step(stmt);
//                 rc = sqlite3_clear_bindings(stmt);
//                 rc = sqlite3_reset(stmt);
//                 rc = sqlite3_finalize(stmt);    
//             }
//         }
//     } else {
//         if (acct_len > 0) {
//             sql = "DELETE FROM INFO WHERE STATE = ? AND ACCOUNT = ? AND KEY = ?;";
//             rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//             if (rc == SQLITE_OK) {
//                 sqlite3_bind_text(stmt, 1, state, strlen(state), SQLITE_TRANSIENT);
//                 sqlite3_bind_blob(stmt, 2, acct, acct_len, SQLITE_TRANSIENT);
//                 sqlite3_bind_blob(stmt, 3, key, key_len, SQLITE_TRANSIENT);

//                 rc = sqlite3_step(stmt);
//                 rc = sqlite3_clear_bindings(stmt);
//                 rc = sqlite3_reset(stmt);
//                 rc = sqlite3_finalize(stmt);    
//             }
//         } else {
//             sql = "DELETE FROM INFO WHERE STATE = ? AND KEY = ?;";
//             rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//             if (rc == SQLITE_OK) {
//                 sqlite3_bind_text(stmt, 1, state, strlen(state), SQLITE_TRANSIENT);
//                 sqlite3_bind_blob(stmt, 2, key, key_len, SQLITE_TRANSIENT);

//                 rc = sqlite3_step(stmt);
//                 rc = sqlite3_clear_bindings(stmt);
//                 rc = sqlite3_reset(stmt);
//                 rc = sqlite3_finalize(stmt);    
//             }
//         }
//     }                    
    
//     sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

//     unlock(&__barrier__);   
// }

// void wiiauto_device_db_keychain_get_value(const char *state, const char *acct_in, const size_t acct_len_in, const char *key, const size_t key_len, char **value, size_t *value_len, const unsigned int index)
// {
//     *value = NULL;
//     *value_len = 0;

//     const char *acct;
//     size_t acct_len;
//     int search_all = 0;

//     if (acct_in) {
//         acct = acct_in;
//         acct_len = acct_len_in;
//         search_all = 0;
//     } else {
//         acct = "";
//         acct_len = 0;
//         search_all = 1;
//     }

//     __init();
//     if (!__db__) return;

//     lock(&__barrier__);

//     int rc;
//     const char *sql;
//     sqlite3_stmt *stmt;

//     sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);  

//     if (search_all == 0) {
//         sql = "SELECT VALUE FROM INFO WHERE STATE = ? AND ACCOUNT = ? AND KEY = ? LIMIT 1 OFFSET ?;";
//         rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//         if (rc == SQLITE_OK) {
//             sqlite3_bind_text(stmt, 1, state, strlen(state), SQLITE_TRANSIENT);
//             sqlite3_bind_blob(stmt, 2, acct, acct_len, SQLITE_TRANSIENT);
//             sqlite3_bind_blob(stmt, 3, key, key_len, SQLITE_TRANSIENT);
//             sqlite3_bind_int(stmt, 4, index);

//             rc = sqlite3_step(stmt);
//             if (rc == SQLITE_ROW) {
//                 *value_len = sqlite3_column_bytes(stmt, 0);
//                 if (*value_len > 0) {
//                     *value = malloc(*value_len);
//                     memcpy(*value, sqlite3_column_blob(stmt, 0), *value_len);
//                 }   
//             }
//             rc = sqlite3_clear_bindings(stmt);
//             rc = sqlite3_reset(stmt);
//             rc = sqlite3_finalize(stmt);    
//         }
//     } else {
//         sql = "SELECT VALUE FROM INFO WHERE STATE = ? AND KEY = ? ORDER BY LENGTH(ACCOUNT) DESC LIMIT 1 OFFSET ?;";
//         rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//         if (rc == SQLITE_OK) {
//             sqlite3_bind_text(stmt, 1, state, strlen(state), SQLITE_TRANSIENT);
//             sqlite3_bind_blob(stmt, 2, key, key_len, SQLITE_TRANSIENT);
//             sqlite3_bind_int(stmt, 3, index);

//             rc = sqlite3_step(stmt);
//             if (rc == SQLITE_ROW) {
//                 *value_len = sqlite3_column_bytes(stmt, 0);
//                 if (*value_len > 0) {
//                     *value = malloc(*value_len);
//                     memcpy(*value, sqlite3_column_blob(stmt, 0), *value_len);
//                 }   
//             }
//             rc = sqlite3_clear_bindings(stmt);
//             rc = sqlite3_reset(stmt);
//             rc = sqlite3_finalize(stmt);    
//         }
//     }

//     sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     
//     unlock(&__barrier__);     
// }

// void wiiauto_device_db_keychain_get_value_no_account(const char *state, char **value, size_t *value_len, const unsigned int index)
// {
//     *value = NULL;
//     *value_len = 0;

//     __init();
//     if (!__db__) return;

//     lock(&__barrier__);

//     int rc;
//     const char *sql;
//     sqlite3_stmt *stmt;

//     sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);  

//     sql = "SELECT VALUE FROM INFO WHERE STATE = ? AND LENGTH(ACCOUNT) = 0 LIMIT 1 OFFSET ?;";
//     rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//     if (rc == SQLITE_OK) {
//         sqlite3_bind_text(stmt, 1, state, strlen(state), SQLITE_TRANSIENT);
//         sqlite3_bind_int(stmt, 2, index);

//         rc = sqlite3_step(stmt);
//         if (rc == SQLITE_ROW) {
//             *value_len = sqlite3_column_bytes(stmt, 0);
//             if (*value_len > 0) {
//                 *value = malloc(*value_len);
//                 memcpy(*value, sqlite3_column_blob(stmt, 0), *value_len);
//             }   
//         }
//         rc = sqlite3_clear_bindings(stmt);
//         rc = sqlite3_reset(stmt);
//         rc = sqlite3_finalize(stmt);    
//     }

//     sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     
//     unlock(&__barrier__);  
// }

// void wiiauto_device_db_keychain_remove_value_no_account(const char *state)
// {
//     __init();
//     if (!__db__) return;

//     lock(&__barrier__);

//     int rc;
//     const char *sql;
//     sqlite3_stmt *stmt;

//     sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);  

//     sql = "DELETE FROM INFO WHERE STATE = ? AND LENGTH(ACCOUNT) = 0;";
//     rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
//     if (rc == SQLITE_OK) {
//         sqlite3_bind_text(stmt, 1, state, strlen(state), SQLITE_TRANSIENT);

//         rc = sqlite3_step(stmt);
//         rc = sqlite3_clear_bindings(stmt);
//         rc = sqlite3_reset(stmt);
//         rc = sqlite3_finalize(stmt);    
//     }

//     sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     
//     unlock(&__barrier__);  
// }