#include "api.h"
#import <sqlite3.h>
#include "cherry/util/util.h"

static void __kill_itunesstored()
{
    i32 num[2];
    char buf[1024];
    i32 exec_pid = -1;

    FILE *fp = popen("ps -u mobile | grep itunesstored", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (!strstr(buf, "grep")) {
                util_strtovl(2, buf, num);
                exec_pid = num[1];  
                break;           
            }
        }
        pclose(fp);
    }

    if (exec_pid >= 0) {
        sprintf(buf, "kill -9 %d ", exec_pid);
        system(buf);    
    }
}

static void __kill_appstored()
{
    i32 num[2];
    char buf[1024];
    i32 exec_pid = -1;

    FILE *fp = popen("ps -u mobile | grep appstored", "r");
    if (fp) {
        while (fgets(buf, 1024, fp) != NULL) {
            if (!strstr(buf, "grep")) {
                util_strtovl(2, buf, num);
                exec_pid = num[1];  
                break;           
            }
        }
        pclose(fp);
    }

    if (exec_pid >= 0) {
        sprintf(buf, "kill -9 %d ", exec_pid);
        system(buf);    
    }
}

static void __delete_condition(const sqlite3 *db, const char *table, const char *condition)
{
    char buf[1024];
    char *errMsg;

    sprintf(buf, "delete from %s where %s;", table, condition);

    if (sqlite3_exec(db, buf, NULL, NULL, &errMsg) != SQLITE_OK) {
        // printf("delete %s failed\n", table);
        sqlite3_free(errMsg);
    }
}

static void __delete_all(const sqlite3 *db, const char *table)
{
    char buf[1024];
    char *errMsg;

    sprintf(buf, "delete from %s;", table);

    if (sqlite3_exec(db, buf, NULL, NULL, &errMsg) != SQLITE_OK) {
        // printf("delete %s failed\n", table);
        sqlite3_free(errMsg);
    }
}

static void __vacuum(const sqlite3 *db)
{
    char *errMsg;
    const char *sql_stmt = "VACUUM;";
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
        // printf("VACUUM failed\n");
        sqlite3_free(errMsg);
    }
}

void wiiauto_clear_keychain()
{
    sqlite3 *db = nil;

    if (sqlite3_open_v2("/private/var/Keychains/keychain-2.db", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        printf("open keychain\n");
        __delete_condition(db, "genp", "agrp not like 'com%' and agrp not like 'ichat' and agrp not like 'wifianalyticsd'");
        __vacuum(db);   
        sqlite3_close(db);
    }
}

void wiiauto_clear_account()
{
    sqlite3 *db = nil;

    system("launchctl unload /System/Library/LaunchDaemons/com.apple.accountsd.plist  ");

    // if (sqlite3_open_v2("/private/var/Keychains/keychain-2.db", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    // {
    //     printf("open keychain\n");
    //     __delete_condition(db, "genp", "agrp not like 'com%' and agrp not like 'ichat' and agrp not like 'wifianalyticsd'");
    //     __vacuum(db);   
    //     sqlite3_close(db);
    // }

    if (sqlite3_open("/private/var/mobile/Library/Accounts/Accounts3.sqlite", &db) == SQLITE_OK)
    {
        // printf("open Accounts3\n");
        __delete_all(db, "ZACCOUNTPROPERTY");
        __delete_condition(db, "ZACCOUNT", "Z_PK > 2"); 
        __vacuum(db);        
        sqlite3_close(db);
    }

    if (sqlite3_open_v2("/private/var/mobile/Library/Accounts/VerifiedBackup/Accounts3.sqlite", &db,  SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        // printf("open backup Accounts3\n");
        __delete_all(db, "ZACCOUNTPROPERTY");  
        __delete_condition(db, "ZACCOUNT", "Z_PK > 2"); 
        __vacuum(db);        
        sqlite3_close(db);
    }

    if (sqlite3_open_v2("/private/var/mobile/Library/Caches/com.apple.appstored/storeUser.db", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        // printf("open storeUser\n");
        __delete_all(db, "account_events"); 
        __delete_all(db, "current_apps_crossfire"); 
        __delete_all(db, "iap_info_db_properties"); 
        __delete_all(db, "iap_info_iaps"); 
        __delete_all(db, "purchase_history_apps"); 
        __delete_all(db, "purchase_history_db_properties"); 
        __vacuum(db);
        sqlite3_close(db);
    }
    

    if (sqlite3_open_v2("/private/var/mobile/Library/Caches/com.apple.appstored/DAAP.sqlitedb", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        // printf("open DAAP\n");
        __delete_all(db, "iap_info_db_properties_table");
        __delete_all(db, "iap_info_iaps_table");
        __delete_all(db, "purchase_history_apps_table");
        __delete_all(db, "purchase_history_db_properties_table");
        __vacuum(db);
        sqlite3_close(db);
    }    

    if (sqlite3_open_v2("/private/var/mobile/Library/Caches/com.apple.routined/Cloud-V2.sqlite", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        // printf("open Cloud-v2\n");
        __delete_all(db, "ACHANGE");
        __delete_all(db, "ATRANSACTION");
        __delete_all(db, "ZRTADDRESSMO");
        __delete_all(db, "ZRTLEARNEDPLACEMO");
        __delete_all(db, "ZRTLEARNEDTRANSITIONMO");
        __delete_all(db, "ZRTLEARNEDVISITMO");
        __delete_all(db, "ZRTMAPITEMMO");
        __vacuum(db);
        sqlite3_close(db);
    }  

    if (sqlite3_open_v2("/private/var/mobile/Library/Caches/com.apple.routined/Cloud.sqlite", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        // printf("open Cloud\n");
        __delete_all(db, "ACHANGE");
        __delete_all(db, "ATRANSACTION");
        __delete_all(db, "ZRTADDRESSMO");
        __delete_all(db, "ZRTLEARNEDPLACEMO");
        __delete_all(db, "ZRTLEARNEDTRANSITIONMO");
        __delete_all(db, "ZRTLEARNEDVISITMO");
        __delete_all(db, "ZRTMAPITEMMO");
        __vacuum(db);
        sqlite3_close(db);
    }  

    if (sqlite3_open_v2("/private/var/mobile/Library/Caches/com.apple.routined/Cache.sqlite", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        // printf("open Cache\n");
        __delete_all(db, "ZRTCLLOCATIONMO");
        __delete_all(db, "ZRTHINTMO");
        __delete_all(db, "ZRTVISITMO");
        __vacuum(db);
        sqlite3_close(db);
    }    

    if (sqlite3_open_v2("/private/var/mobile/Library/Caches/com.apple.itunescloudd/Cache.db", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        // printf("open Cache\n");
        __delete_all(db, "cfurl_cache_blob_data");
        __delete_all(db, "cfurl_cache_receiver_data");
        __delete_all(db, "cfurl_cache_response");
        __vacuum(db);
        sqlite3_close(db);
    }    

    if (sqlite3_open_v2("/private/var/mobile/Library/AggregateDictionary/ADDataStore.sqlitedb", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        // printf("open ADDataStore\n");
        __delete_all(db, "DistributionKeys");
        __delete_all(db, "DistributionValues");
        __delete_all(db, "Scalars");
        __vacuum(db);
        sqlite3_close(db);
    }    

    if (sqlite3_open_v2("/private/var/mobile/Library/Caches/com.apple.AppleMediaServices/Cache.db", &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        // printf("open AppMediaServices-Cache\n");
        __delete_all(db, "cfurl_cache_blob_data");
        __delete_all(db, "cfurl_cache_receiver_data");
        __delete_all(db, "cfurl_cache_response");
        __vacuum(db);
        sqlite3_close(db);
    }    

    __kill_itunesstored();
    __kill_appstored();

    system("launchctl load /System/Library/LaunchDaemons/com.apple.accountsd.plist  ");
}

int wiiauto_lua_clear_account(lua_State *ls)
{
    wiiauto_clear_account();
    return 0;
}