#ifndef __wiiauto_device_db_h
#define __wiiauto_device_db_h

#ifdef __cplusplus
extern "C" {
#endif

int wiiauto_device_db_set(const char *bundle, const char *key, const char *value);
char *wiiauto_device_db_get(const char *bundle, const char *key);

int wiiauto_device_db_set_system(const char *bundle, const char *key, const char *value);
char *wiiauto_device_db_get_system(const char *bundle, const char *key);

int wiiauto_device_db_set_other(const char *bundle, const char *key, const char *value);
char *wiiauto_device_db_get_other(const char *bundle, const char *key);

int wiiauto_device_db_set_share(const char *bundle, const char *key, const char *value);
char *wiiauto_device_db_get_share(const char *bundle, const char *key);
void wiiauto_device_db_get_share_all(const char *bundle, void *ctx, void(*callback)(void *ctx, const char *bundle, const char *key, const char *value));

void wiiauto_device_db_keychain_set_bundle_state(const char *bundle, const char *state);
void wiiauto_device_db_keychain_get_bundle_state(const char *bundle, char **state);

void wiiauto_device_db_keychain_set_value(const char *state, 
    const char *acct, const size_t acct_len, 
    const char *agrp, const size_t agrp_len,
    const char *clss, const size_t clss_len,
    const int type,
    const char *svce, const size_t svce_len,
    const char *value, size_t value_len
);

void wiiauto_device_db_keychain_get_value(const char *state,
    const char *acct, const size_t acct_len,
    const char *agrp, const size_t agrp_len,
    const char *clss, const size_t clss_len,
    const int type,
    const char *svce, const size_t svce_len,
    char **value, size_t *value_len,
    const int index    
);

// void wiiauto_device_db_keychain_get_value(const char *state, const char *acct, const size_t acct_len, const char *key, const size_t key_len, char **value, size_t *value_len, const unsigned int index);
// void wiiauto_device_db_keychain_get_value_no_account(const char *state, char **value, size_t *value_len, const unsigned int index);
// void wiiauto_device_db_keychain_remove_value_no_account(const char *state);


void wiiauto_device_db_multi_add(const char *bundle, const char *key, const char *value);
void wiiauto_device_db_multi_delete(const char *bundle, const char *key);
char *wiiauto_device_db_multi_get(const char *bundle, const char *key, const int index);

// --------------------------------------------------------
int wiiauto_device_db_set_blob_share(const char *bundle, const char *key, const size_t key_len, const char *value, size_t len);
void wiiauto_device_db_get_blob_share(const char *bundle, const char *key, const size_t key_len, char **value, size_t *len);

int wiiauto_device_db_set_keychain_share(const char *bundle, const char *account, const char *key, const size_t key_len, const char *value, size_t len);
void wiiauto_device_db_get_keychain_share(const char *bundle, const char *key, const size_t key_len, char **value, size_t *len);

int wiiauto_device_keychain_save(const char *bundle, const int length, const char **name);
int wiiauto_device_keychain_load(const char *bundle, const int length, const char **name);

//-------------------------------------------------------------------------
// void wiiauto_device_db_key_number_set(const char *bundle, const char *key, const int num);
// typedef struct
// {
//     char *key;
//     int num;
// }
// __db_key_number_result;
// void wiiauto_device_db_key_number_get_lowest(const char *bundle, const int limit, const int offset, int *result_len, __db_key_number_result **result);
// void wiiauto_device_db_key_number_remove(const char *bundle, const char *key);

void wiiauto_device_db_email_add(const char *email, const char *password);
void wiiauto_device_db_email_set_appleid_register_state(const char *email, const char *password, const int state);
void wiiauto_device_db_email_get_appleid_unregistered(const char *serial, char **email, char **password, const int auto_register);
void wiiauto_device_db_email_get_appleid_unregistered_alike(const char *serial, char **email, char **password, const char *alike, const int auto_register);
void wiiauto_device_db_email_add_appleid_machine(const char *serial, const char *email, const char *password);

void wiiauto_device_db_imessage_add(const char *infos);
void wiiauto_device_db_imessage_get(long long *id, char **infos, const int status);
void wiiauto_device_db_imessage_set_status(const long long id, const int status);
void wiiauto_device_db_imessage_delete_processeds();
void wiiauto_device_db_imessage_update_info(const long long id, const char *infos);
void wiiauto_device_db_imessage_get_last_guid(char **guid);

#ifdef __cplusplus
}
#endif

#endif