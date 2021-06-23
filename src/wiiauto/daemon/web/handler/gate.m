#include "handler.h"
#import <sqlite3.h>
#include "wiiauto/common/common.h"
#include "wiiauto/lua/lua.h"

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
        sqlite3_open("/private/var/mobile/Library/WiiAuto/Databases/webservice_gate.db", &__db__);

        if (__db__) {
            sql = "CREATE TABLE IF NOT EXISTS GATES (ID INTEGER PRIMARY KEY AUTOINCREMENT, GATE TEXT UNIQUE NOT NULL, PATH TEXT NOT NULL);";
            rc = sqlite3_exec(__db__, sql, 0, 0, &err_msg);
            if (rc != SQLITE_OK) {
                sqlite3_free(err_msg);
            }
        }
    }
    unlock(&__barrier__);    
}


static const char *ok_200 = "HTTP/1.1 200 OK\r\n\r\n";

void wiiauto_daemon_web_service_handle_register_gate(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    __init();

    buffer str, b;
    const char *ptr;
    i32 ret;
    const char *gate;
    const char *path;

    buffer_new(&b);
    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));

    wiiauto_daemon_web_url_get_param(url, "gate", &gate);
    wiiauto_daemon_web_url_get_param(url, "path", &path);
    
    if (gate && path && __db__) {

        lock(&__barrier__);

        int rc;
        const char *sql;
        sqlite3_stmt *stmt;

        sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

        sql = "INSERT OR REPLACE INTO GATES(GATE, PATH) VALUES (?, ?);";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, gate, strlen(gate), SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt, 2, path, strlen(path), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }   

        sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

        unlock(&__barrier__);  

    }

    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
    release(b.iobj);
}

void wiiauto_daemon_web_service_handle_remove_gate(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    __init();

    buffer str, b;
    const char *ptr;
    i32 ret;
    const char *gate;

    buffer_new(&b);
    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));

    wiiauto_daemon_web_url_get_param(url, "gate", &gate);
    
    if (gate && __db__) {

        lock(&__barrier__);

        int rc;
        const char *sql;
        sqlite3_stmt *stmt;

        sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);     

        sql = "DELETE FROM GATES WHERE GATE = ?;";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, gate, strlen(gate), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }   

        sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

        unlock(&__barrier__);  
    }

    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
    release(b.iobj);
}

void wiiauto_daemon_web_service_handle_process_gate(const wiiauto_daemon_web_service service, const net_socket server, const net_socket sock, const wiiauto_daemon_web_url url, const buffer current_read)
{
    __init();

    buffer str, b;
    const char *ptr, *ctr;
    i32 ret;
    int len;
    const char *gate = NULL;
    const char *arguments = NULL;
    int content_length = 0;

    buffer_get_ptr(current_read, &ptr);
    buffer_length(current_read, 1, &len);

    printf("%s\n", ptr);

    content_length = 0;
    ctr = strstr(ptr,"Content-Length");
    if(ctr){
        sscanf(ctr,"%*s %d", &content_length);
    }

    if (content_length > 0) {
        ctr = ptr + len - 1 - content_length + 1;
        arguments = ctr;
    }

    buffer_new(&b);
    buffer_new(&str);
    buffer_append(str, ok_200, strlen(ok_200));

    wiiauto_daemon_web_url_get_param(url, "gate", &gate);
    
    if (gate && __db__) {

        char *path = NULL;

        lock(&__barrier__);

        int rc;
        const char *sql;
        sqlite3_stmt *stmt;

        sqlite3_exec(__db__, "BEGIN TRANSACTION;", NULL, NULL, NULL);                            

        sql = "SELECT PATH FROM GATES WHERE GATE = ?;";
        rc = sqlite3_prepare_v2(__db__, sql, strlen(sql), &stmt, NULL);
        if (rc == SQLITE_OK) {
            sqlite3_bind_text(stmt, 1, gate, strlen(gate), SQLITE_TRANSIENT);

            rc = sqlite3_step(stmt);
            if (rc == SQLITE_ROW) {

                int path_len = sqlite3_column_bytes(stmt, 0);

                if (path_len > 0) {
                    path = malloc(path_len + 1);
                    memset(path, 0, path_len + 1);
                    strncpy(path, sqlite3_column_text(stmt, 0), path_len);
                }           
            }
            rc = sqlite3_clear_bindings(stmt);
            rc = sqlite3_reset(stmt);
            rc = sqlite3_finalize(stmt);    
        }
        
        sqlite3_exec(__db__, "END TRANSACTION;", NULL, NULL, NULL);     

        unlock(&__barrier__);   

        if (path) {
            
            int executed = 0;
            buffer scr;
            buffer_new(&scr);

            common_get_script_url(path, scr);
            buffer_get_ptr(scr, &ptr);

            char *result = NULL;
            while (!executed) {
                result = NULL;
                executed = wiiauto_lua_execute_file(ptr, 0, "main", arguments, &result);

                if (executed) {
                    if (result) {
                        buffer_append(str, result, strlen(result));
                        free(result);
                    } else {
                        const char *msg = "{\"status\" : 0}";
                        buffer_append(str, msg, strlen(msg));
                    }
                }
            }

            free(path);
            release(scr.iobj);
        } else {
            const char *msg = "{\"status\" : 0}";
            buffer_append(str, msg, strlen(msg));
        }
    } else {
        const char *msg = "{\"status\" : 0}";
        buffer_append(str, msg, strlen(msg));
    }

    buffer_append(str, "\r\n\r\n", sizeof("\r\n\r\n") - 1);    

    buffer_get_ptr(str, &ptr);
    net_socket_send(server, sock, ptr, strlen(ptr), &ret);
    release(str.iobj);
    net_socket_close(server, sock);
    release(b.iobj);
}