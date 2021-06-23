#include "api.h"
#import <Contacts/Contacts.h>

int wiiauto_lua_add_contact(lua_State *ls)
{
    const char *name = luaL_optstring(ls, 1, NULL);
    const char *phone = luaL_optstring(ls, 2, NULL);

    if (!name || !phone) goto finish;

    @autoreleasepool {

        CNContactStore *store = [[CNContactStore alloc] init];

        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!granted) {
                return;
            }

            // create contact
            @autoreleasepool {
                CNMutableContact *contact = [[CNMutableContact alloc] init];
                contact.givenName = [NSString stringWithUTF8String:name];

                CNLabeledValue *homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:[NSString stringWithUTF8String:phone]]];
                contact.phoneNumbers = @[homePhone];

                CNSaveRequest *request = [[CNSaveRequest alloc] init];
                [request addContact:contact toContainerWithIdentifier:nil];

                // save it

                NSError *saveError;
                if (![store executeSaveRequest:request error:&saveError]) {
                }
            }
        }];

    }

finish:
    return 0;
}

int wiiauto_lua_delete_all_contacts(lua_State *ls)
{
    @autoreleasepool {

         CNContactStore *contactStore = [[CNContactStore alloc] init];

        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted == YES) {
                @autoreleasepool {

                    NSArray *keys = @[CNContactPhoneNumbersKey];
                    NSString *containerId = contactStore.defaultContainerIdentifier;
                    NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
                    NSError *error;
                    NSArray *cnContacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];

                    if (error) {
                        
                    } else {
                        CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];

                        for (CNContact *contact in cnContacts) {
                            [saveRequest deleteContact:[contact mutableCopy]];
                        }

                        [contactStore executeSaveRequest:saveRequest error:nil];
                    }
                }
            }
        }];

    }
    return 0;
}