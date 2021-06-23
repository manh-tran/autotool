#include "device_db.h"
#import <sqlite3.h>
#include "cherry/def.h"
#include "cherry/core/buffer.h"
#include "log/remote_log.h"

static sqlite3 *__db__ = NULL;
static spin_lock __barrier__ = SPIN_LOCK_INIT;

#define LTR(p) p, sizeof(p) - 1

static void __init()
{
    char *err_msg = NULL;
    int rc;
    const char *sql;

    lock(&__barrier__);
    if (!__db__) {
        sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/keychain.db", &__db__);

        if (__db__) {
            sql = "CREATE TABLE IF NOT EXISTS KEYCHAIN (ID INTEGER PRIMARY KEY AUTOINCREMENT, BUNDLE TEXT NOT NULL, VENDOR_ID TEXT NOT NULL, IDFA TEXT NOT NULL, NAME TEXT NOT NULL, KEYCHAIN TEXT NOT NULL);";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
        }
    }
    unlock(&__barrier__);    
}

typedef struct
{
    const char *bundle;
    const char *vendor_id;
    const char *idfa;
}
__param_save;

static int __callback_save(void *callBackArg, int argc, char **argv, char **azColName)
{
    char *err_msg = NULL;
    int rc;
    const char *sql;
    NSString *name = nil;

    if (argc > 0) {
        __param_save *pr = (__param_save *)callBackArg;

        @autoreleasepool {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];

            for (int i = 0; i < argc; i++) {

                NSString *key = [NSString stringWithUTF8String:azColName[i]];
                NSString *value = [NSString stringWithUTF8String:argv[i]];

                if ([key isEqualToString:@"agrp"]) {
                    name = value;
                }

                dict[key] = value;
            }

            NSError *error; 
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                options:NSJSONWritingPrettyPrinted
                error:&error];

            if (jsonData) {                
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);
                sql = sqlite3_mprintf("INSERT INTO KEYCHAIN(BUNDLE, VENDOR_ID, IDFA, NAME, KEYCHAIN) VALUES ('%q', '%q', '%q', '%q', '%q');", pr->bundle, pr->vendor_id, pr->idfa, [name UTF8String], [jsonString UTF8String]);
                if (sql) {
                    rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
                    if (rc != SQLITE_OK) {
                        sqlite3_free(err_msg);
                    }
                    sqlite3_free(sql);
                }

                sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);
            }
        }
        
    }

    return 0;
}

int wiiauto_device_keychain_save(const char *bundle, const int length, const char **name)
{
    __init();
    if (!__db__) return 0;

    char *err_msg = NULL;
    int rc;
    const char *sql;

    int ret = 0;
    int i;
    const char *vendor_id = NULL;
    const char *idfa = NULL;
    sqlite3 *keychain_db = nil;
    __param_save pr;
    sqlite3_stmt *stmt;
    buffer buf;

    buffer_new(&buf);
    
    vendor_id = wiiauto_device_db_get(bundle, "WiiAuto_VendorID");
    if (!vendor_id) goto finish;

    idfa = wiiauto_device_db_get(bundle, "WiiAuto_IDFA");
    if (!idfa) goto finish;    

    pr.bundle = bundle;
    pr.vendor_id = vendor_id;
    pr.idfa = idfa;

    lock(&__barrier__);

    // delete old keychain
    sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);

    buffer_append(buf, LTR("DELETE FROM KEYCHAIN WHERE BUNDLE = ? AND VENDOR_ID = ? AND IDFA = ? AND ("));
    for (i = 0; i < length; ++i) {
        if (i == 0) {
            buffer_append(buf, LTR("NAME = ?"));
        } else {
            buffer_append(buf, LTR(" OR NAME = ?"));
        }        
    }
    buffer_append(buf, LTR(");"));
    buffer_get_ptr(buf, &sql);

    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {

        sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, vendor_id, strlen(vendor_id), SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 3, idfa, strlen(idfa), SQLITE_TRANSIENT);
        for (i = 0; i < length; ++i) {
            sqlite3_bind_text(stmt, i + 4, name[i], strlen(name[i]), SQLITE_TRANSIENT);
        }

        rc = sqlite3_step(stmt);
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);
    }

    sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);

    // save new keychain
    if (sqlite3_open_v2("/private/var/Keychains/keychain-2.db", &keychain_db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        buffer_erase(buf);

        buffer_append(buf, LTR("SELECT hex(cdat) as _cdat, hex(mdat) as _mdat, hex(desc) as _desc, hex(icmt) as _icmt, hex(crtr) as _crtr, hex(type) as _type, hex(scrp) as _scrp, hex(labl) as _labl, hex(alis) as _alis, hex(invi) as _invi, hex(nega) as _nega, hex(cusi) as _cusi, hex(prot) as _prot, hex(acct) as _acct, hex(svce) as _svce, hex(gena) as _gena, hex(data) as _data, agrp, hex(agrp) as _agrp, hex(pdmn) as _pdmn, hex(sync) as _sync, hex(tomb) as _tomb, hex(sha1) as _sha1, hex(vwht) as _vwht, hex(tkid) as _tkid, hex(musr) as _musr, hex(UUID) as _UUID, hex(sysb) as _sysb, hex(pcss) as _pcss, hex(pcsk) as _pcsk, hex(pcsi) as _pcsi, hex(persistref) as _persistref FROM genp WHERE ("));
        for (i = 0; i < length; ++i) {
            if (i == 0) {
                buffer_append(buf, LTR("agrp = ?"));
            } else {
                buffer_append(buf, LTR(" OR agrp = ?"));
            }
        }
        buffer_append(buf, LTR(") order by rowid;"));
        buffer_get_ptr(buf, &sql);

        rc = sqlite3_prepare_v2(keychain_db, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {

            for (i = 0; i < length; ++i) {
                sqlite3_bind_text(stmt, i + 1, name[i], strlen(name[i]), SQLITE_TRANSIENT);
            }

            sql = sqlite3_expanded_sql(stmt);

            if (sql) {
                rc = sqlite3_exec(keychain_db, sql, __callback_save, &pr, &err_msg);
                if (rc != SQLITE_OK) {
                    sqlite3_free(err_msg);
                }
                sqlite3_free(sql);
            }

            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);
        }

        sqlite3_close(keychain_db);
    }    
    
    unlock(&__barrier__);
    ret = 1;

finish:
    release(buf.iobj);

    if (vendor_id) {
        free(vendor_id);
    }
    if (idfa) {
        free(idfa);
    }
    return ret;
}


typedef struct
{
    const char *bundle;
    const char *vendor_id;
    const char *idfa;
    sqlite3 *keychain_db;
    int ret;
}
__param_load;

static unsigned char *__hex_to_blob(const char *str, size_t *slen)
{
    const char *ctr;
    char c;
    int val;
    int i;
    size_t len;
    unsigned char *ret;

    len = strlen(str) / 2;
    ret = malloc(len + 1);
    *slen = len;

    if (len == 0) goto finish;

    memset(ret, 0, len);

    i = 0;
    ctr = str;
    while (ctr && *ctr) {
        c = tolower(*ctr);

        if (c >= 97) {
            val = c - 87;
        } else {
            val = c - 48;
        }

        if (i % 2 == 0) {
            ret[i/2] = val << 4;
        } else {
            ret[i/2] |= val;
        }

        i++;
        ctr++;
    }

finish:
    return ret;
}

static unsigned char *__hex_to_string(const char *str, size_t *slen)
{
    const char *ctr;
    char c;
    int val;
    int i;
    size_t len;
    unsigned char *ret;

    len = strlen(str) / 2 + 1;
    ret = malloc(len);
    *slen = len - 1;

    memset(ret, 0, len);

    i = 0;
    ctr = str;
    while (ctr && *ctr) {
        c = tolower(*ctr);

        if (c >= 97) {
            val = c - 87;
        } else {
            val = c - 48;
        }

        if (i % 2 == 0) {
            ret[i/2] = val << 4;
        } else {
            ret[i/2] |= val;
        }

        i++;
        ctr++;
    }

    return ret;
}

static double __hex_to_double(const char *str)
{
    size_t len;

    char *data = __hex_to_string(str, &len);
    double value = strtod(data, NULL);
    free(data);
    return value;
}

static int __hex_to_int(const char *str)
{
    size_t len;

    char *data = __hex_to_string(str, &len);
    int value = atoi(data);
    free(data);
    return value;
}

static int __callback_load(void *callBackArg, int argc, char **argv, char **azColName)
{
    static int __sync__ = 0;

    char *err_msg = NULL;
    int rc;
    const char *sql;
    int i;
    sqlite3_stmt *stmt;
    unsigned char *data;
    size_t len;
    size_t vlen;

    if (argc > 0) {
        __param_load *pr = (__param_load *)callBackArg;

        for (i = 0; i < argc; ++i) {
            if (strcmp(azColName[i], "KEYCHAIN") == 0 || strcmp(azColName[i], "keychain") == 0) {

                @autoreleasepool {
                    
                    @try {

                        NSError *jsonError;
                        NSString *jsonString = [NSString stringWithUTF8String:argv[i]];
                        NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                            options:NSJSONReadingMutableContainers 
                            error:&jsonError];

                        if (json) {

                            sqlite3_exec(pr->keychain_db, "PRAGMA ignore_check_constraints = ON;", NULL, NULL, NULL);
                            sqlite3_exec(pr->keychain_db, "BEGIN TRANSACTION;", NULL, NULL, NULL);                            

                            sql = "INSERT INTO genp(cdat,mdat,desc,icmt,crtr,type,scrp,labl,alis,invi,nega,cusi,prot,acct,svce,gena,data,agrp,pdmn,sync,tomb,sha1,vwht,tkid,musr,UUID,sysb,pcss,pcsk,pcsi,persistref) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
                            rc = sqlite3_prepare_v2(pr->keychain_db, sql, strlen(sql), &stmt, NULL);
                            
                            if (rc == SQLITE_OK) {
                                remote_log("------------------insert:\n");
                                for (NSString *key in json) {
                                    NSString *value = json[key];         
                                    vlen = [value length];                       

                                    if ([key isEqualToString:@"_cdat"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 1);
                                        } else {
                                            sqlite3_bind_double(stmt, 1, __hex_to_double([value UTF8String]));
                                        }                                        

                                    } else if ([key isEqualToString:@"_mdat"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 2);
                                        } else {
                                            sqlite3_bind_double(stmt, 2, __hex_to_double([value UTF8String]));
                                        }

                                    } else if ([key isEqualToString:@"_desc"]) {       
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 3);
                                        } else {                                 
                                            data = __hex_to_blob([value UTF8String], &len);
                                            sqlite3_bind_blob(stmt, 3, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }

                                    } else if ([key isEqualToString:@"_icmt"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 4);
                                        } else {
                                            data = __hex_to_blob([value UTF8String], &len);
                                            sqlite3_bind_blob(stmt, 4, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }

                                    } else if ([key isEqualToString:@"_crtr"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 5);
                                        } else {
                                            sqlite3_bind_int(stmt, 5, __hex_to_int([value UTF8String]));
                                        }

                                    } else if ([key isEqualToString:@"_type"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 6);
                                        } else {
                                            sqlite3_bind_int(stmt, 6, __hex_to_int([value UTF8String]));
                                        }
                                        
                                    } else if ([key isEqualToString:@"_scrp"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 7);
                                        } else {
                                            sqlite3_bind_int(stmt, 7, __hex_to_int([value UTF8String]));
                                        }
                                        
                                    } else if ([key isEqualToString:@"_labl"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 8);
                                        } else {
                                            data = __hex_to_blob([value UTF8String], &len);
                                            sqlite3_bind_blob(stmt, 8, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }
                                        
                                    } else if ([key isEqualToString:@"_alis"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 9);
                                        } else {
                                            data = __hex_to_blob([value UTF8String], &len);
                                            sqlite3_bind_blob(stmt, 9, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }
                                        
                                    } else if ([key isEqualToString:@"_invi"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 10);
                                        } else {
                                            sqlite3_bind_int(stmt, 10, __hex_to_int([value UTF8String]));
                                        }
                                        
                                    } else if ([key isEqualToString:@"_nega"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 11);
                                        } else {
                                            sqlite3_bind_int(stmt, 11, __hex_to_int([value UTF8String]));
                                        }
                                        
                                    } else if ([key isEqualToString:@"_cusi"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 12);
                                        } else {
                                            sqlite3_bind_int(stmt, 12, __hex_to_int([value UTF8String]));
                                        }
                                        
                                    } else if ([key isEqualToString:@"_prot"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 13);
                                        } else {
                                            data = __hex_to_blob([value UTF8String], &len);
                                            sqlite3_bind_blob(stmt, 13, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }

                                    }  else if ([key isEqualToString:@"_acct"]) {   
                                        remote_log("acct: %s\n", [value UTF8String]);
                                        data = __hex_to_blob([value UTF8String], &len);
                                        sqlite3_bind_blob(stmt, 14, data, len, SQLITE_TRANSIENT);
                                        free(data);

                                    } else if ([key isEqualToString:@"_svce"]) {
                                        remote_log("svce: %s\n", [value UTF8String]);
                                        data = __hex_to_blob([value UTF8String], &len);
                                        sqlite3_bind_blob(stmt, 15, data, len, SQLITE_TRANSIENT);
                                        free(data);

                                    } else if ([key isEqualToString:@"_gena"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 16);
                                        } else {
                                            data = __hex_to_blob([value UTF8String], &len);
                                            sqlite3_bind_blob(stmt, 16, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }

                                    } else if ([key isEqualToString:@"_data"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 17);
                                        } else {
                                            data = __hex_to_blob([value UTF8String], &len);
                                            sqlite3_bind_blob(stmt, 17, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }

                                    } else if ([key isEqualToString:@"_agrp"]) {
                                        remote_log("agrp: %s\n", [value UTF8String]);
                                        data = __hex_to_string([value UTF8String], &len);
                                        sqlite3_bind_text(stmt, 18, data, len, SQLITE_TRANSIENT);
                                        free(data);

                                    } else if ([key isEqualToString:@"_pdmn"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 19);
                                        } else {
                                            data = __hex_to_string([value UTF8String], &len);
                                            sqlite3_bind_text(stmt, 19, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }

                                    } else if ([key isEqualToString:@"_sync"]) {
                                        remote_log("sync: %s\n", [value UTF8String]);
                                        sqlite3_bind_int(stmt, 20, __hex_to_int([value UTF8String]));

                                    } else if ([key isEqualToString:@"_tomb"]) {
                                        sqlite3_bind_int(stmt, 21, __hex_to_int([value UTF8String]));
                                        
                                    } else if ([key isEqualToString:@"_sha1"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 22);
                                        } else {
                                            data = __hex_to_blob([value UTF8String], &len);
                                            sqlite3_bind_blob(stmt, 22, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }

                                    } else if ([key isEqualToString:@"_vwht"]) {
                                        remote_log("vwht: %s\n", [value UTF8String]);                                       
                                        data = __hex_to_string([value UTF8String], &len);                                    
                                        sqlite3_bind_text(stmt, 23, data, len, SQLITE_TRANSIENT);
                                        free(data);

                                    } else if ([key isEqualToString:@"_tkid"]) {
                                        remote_log("tkid: %s\n", [value UTF8String]);
                                        data = __hex_to_string([value UTF8String], &len);
                                        sqlite3_bind_text(stmt, 24, data, len, SQLITE_TRANSIENT);
                                        free(data);

                                    } else if ([key isEqualToString:@"_musr"]) {
                                        remote_log("musr: %s\n", [value UTF8String]);
                                        data = __hex_to_blob([value UTF8String], &len);
                                        sqlite3_bind_blob(stmt, 25, data, len, SQLITE_TRANSIENT);
                                        free(data);

                                    } else if ([key isEqualToString:@"_UUID"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 26);
                                        } else {
                                            data = __hex_to_string([value UTF8String], &len);
                                            sqlite3_bind_text(stmt, 26, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }

                                    } else if ([key isEqualToString:@"_sysb"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 27);
                                        } else {
                                            sqlite3_bind_int(stmt, 27, __hex_to_int([value UTF8String]));
                                        }
                                        
                                    } else if ([key isEqualToString:@"_pcss"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 28);
                                        } else {
                                            sqlite3_bind_int(stmt, 28, __hex_to_int([value UTF8String]));
                                        }
                                        
                                    } else if ([key isEqualToString:@"_pcsk"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 29);
                                        } else {
                                            data = __hex_to_blob([value UTF8String], &len);
                                            sqlite3_bind_blob(stmt, 29, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }

                                    } else if ([key isEqualToString:@"_pcsi"]) {
                                        if (vlen == 0) {
                                            sqlite3_bind_null(stmt, 30);
                                        } else {
                                            data = __hex_to_blob([value UTF8String], &len);
                                            sqlite3_bind_blob(stmt, 30, len > 0 ? data : NULL, len, SQLITE_TRANSIENT);
                                            free(data);
                                        }

                                    } else if ([key isEqualToString:@"_persistref"]) {
                                        data = __hex_to_blob([value UTF8String], &len);
                                        sqlite3_bind_blob(stmt, 31, data, len, SQLITE_TRANSIENT);
                                        free(data);
                                    } 
                                }

                                pr->ret = 1;

                                rc = sqlite3_step(stmt);
                                if (rc != SQLITE_DONE && rc != SQLITE_ROW) {
                                    pr->ret = 0;    

                                    const char *err = sqlite3_errmsg(pr->keychain_db);
                                    if (err) {
                                        remote_log("err: %s\n", err);
                                    }
                                }
                                

                                rc = sqlite3_clear_bindings(stmt);
                                rc = sqlite3_reset(stmt);
                                rc = sqlite3_finalize(stmt);    
                                
                                sqlite3_exec(pr->keychain_db, "END TRANSACTION;", NULL, NULL, NULL);                      
                                sqlite3_exec(pr->keychain_db, "PRAGMA ignore_check_constraints = OFF;", NULL, NULL, NULL);
                            }
                        }
                    } @catch (NSException *e) {

                    }                    
                }

            }
        }
    }

    return 0;
}

int wiiauto_device_keychain_load(const char *bundle, const int length, const char **name)
{
    __init();
    if (!__db__) return 0;

    char *err_msg = NULL;
    int rc;
    const char *sql;

    int ret = 0;
    const char *vendor_id = NULL;
    const char *idfa = NULL;
    sqlite3 *keychain_db = nil;
    __param_load pr;
    buffer buf;
    int i;
    sqlite3_stmt *stmt;

    buffer_new(&buf);

    vendor_id = wiiauto_device_db_get(bundle, "WiiAuto_VendorID");
    if (!vendor_id) goto finish;

    idfa = wiiauto_device_db_get(bundle, "WiiAuto_IDFA");
    if (!idfa) goto finish;        

    lock(&__barrier__);
 
    rc = sqlite3_open_v2("/private/var/Keychains/keychain-2.db", &keychain_db, SQLITE_OPEN_READWRITE, NULL);
    if (rc != SQLITE_OK) {
        unlock(&__barrier__);
        goto finish;
    }

    pr.bundle = bundle;
    pr.vendor_id = vendor_id;
    pr.idfa = idfa;
    pr.keychain_db = keychain_db;
    pr.ret = 0;

    sqlite3_exec(keychain_db, "BEGIN TRANSACTION;", NULL, NULL, NULL);

    buffer_append(buf, LTR("DELETE FROM genp WHERE ("));
    for (i = 0; i < length; ++i) {
        if (i == 0) {
            buffer_append(buf, LTR("agrp = ?"));
        } else {
            buffer_append(buf, LTR(" OR agrp = ?"));
        }
    }
    buffer_append(buf, LTR(");"));
    buffer_get_ptr(buf, &sql);

    rc = sqlite3_prepare_v2(keychain_db, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {

        for (i = 0; i < length; ++i) {
            sqlite3_bind_text(stmt, i + 1, name[i], strlen(name[i]), SQLITE_TRANSIENT);
        }

        rc = sqlite3_step(stmt);
        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);
    }

    sqlite3_exec(keychain_db, "END TRANSACTION;", NULL, NULL, NULL);
    // // delete current keychain
    // sql = sqlite3_mprintf("DELETE FROM genp WHERE agrp = '%q';", name);
    // if (sql) {
    //     sqlite3_exec(keychain_db, "BEGIN TRANSACTION;", NULL, NULL, NULL);
    //     rc = sqlite3_exec(keychain_db, sql, NULL, NULL, &err_msg);
    //     if (rc != SQLITE_OK) {
    //         sqlite3_free(err_msg);
    //     }
    //     sqlite3_free(sql);
    //     sqlite3_exec(keychain_db, "END TRANSACTION;", NULL, NULL, NULL);
    // }

    // backup old keychain
    buffer_erase(buf);

    buffer_append(buf, LTR("SELECT * FROM KEYCHAIN WHERE BUNDLE = ? AND VENDOR_ID = ? AND IDFA = ? AND ("));
    for (i = 0; i < length; ++i) {
        if (i == 0) {
            buffer_append(buf, LTR("NAME = ?"));
        } else {
            buffer_append(buf, LTR(" OR NAME = ?"));
        }
    }
    buffer_append(buf, LTR(");"));
    buffer_get_ptr(buf, &sql);

    rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
    if (rc == SQLITE_OK) {

        sqlite3_bind_text(stmt, 1, bundle, strlen(bundle), SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, vendor_id, strlen(vendor_id), SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 3, idfa, strlen(idfa), SQLITE_TRANSIENT);
        for (i = 0; i < length; ++i) {
            sqlite3_bind_text(stmt, i + 4, name[i], strlen(name[i]), SQLITE_TRANSIENT);
        }

        sql = sqlite3_expanded_sql(stmt);
        if (sql) {
            rc = sqlite3_exec(__db__, sql, __callback_load, &pr, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
            sqlite3_free(sql);
        }

        // rc = sqlite3_step(stmt);

        rc = sqlite3_clear_bindings(stmt);
        rc = sqlite3_reset(stmt);
        rc = sqlite3_finalize(stmt);
    }

    // sql = sqlite3_mprintf("SELECT * FROM KEYCHAIN WHERE BUNDLE = '%q' AND VENDOR_ID = '%q' AND IDFA = '%q' AND NAME = '%q';", bundle, vendor_id, idfa, name);
    // if (sql) {
    //     rc = sqlite3_exec(__db__, sql, __callback_load, &pr, &err_msg);
    //     if (rc != SQLITE_OK) {
    //         sqlite3_free(err_msg);
    //     }
    //     sqlite3_free(sql);
    // }

    ret = pr.ret;

    sqlite3_close(keychain_db);
    unlock(&__barrier__);    

finish:
    release(buf.iobj);

    if (vendor_id) {
        free(vendor_id);
    }
    if (idfa) {
        free(idfa);
    }
    return ret;
}