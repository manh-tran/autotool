#include "handler.h"
#include <objc/runtime.h>
#import <BackBoardServices/BackBoardServices.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
static void __fetch_arr_ids(NSMutableArray *arr, NSMutableArray *out, int *count);
static void __fetch_ids(NSMutableDictionary *dict, NSMutableArray *out, int *count);

static void __fetch_arr_ids(NSMutableArray *arr, NSMutableArray *out, int *count)
{
    NSData *d;
    NSString *bundle;
    NSMutableDictionary *dict;
    NSString *listType;
    int i;
    int sc;

    for (i = 0; i < [arr count]; ++i) {
        d = arr[i];

        if ([d isKindOfClass:[NSString class]]) {
            bundle = (NSString *)d;
            if ([bundle isEqualToString:@"com.bgate.samurai"]) {
                *count += 1;
            } else {
                if ([bundle containsString:@"com.bgate.samurai"]) {
                    [out addObject:[NSString stringWithString:bundle]];
                    [arr removeObjectAtIndex:i];
                    i--;
                } else {
                    *count += 1;
                }
            }
        } else if ([d isKindOfClass:[NSDictionary class]]) {
            dict = ((NSDictionary *)d).mutableCopy;

            @try {
                listType = dict[@"listType"];
            } @catch (NSException *e) {
                listType = nil;
            }

            if (listType && [listType isEqualToString:@"folder"]) {
                
                sc = 0;
                __fetch_ids(dict, out, &sc);
                if (sc == 0) {
                    [arr removeObjectAtIndex:i];
                    i--;
                }
                *count += sc;
            }
        }
    }
}

static void __fetch_ids(NSMutableDictionary *dict, NSMutableArray *out, int *count)
{
    int i;
    int sc;

    NSMutableArray *iconLists = ((NSArray *)dict[@"iconLists"]).mutableCopy;
    for (int i = 0; i < [iconLists count]; ++i) {
        NSMutableArray *item = ((NSArray *)iconLists[i]).mutableCopy;
        sc = 0;
        __fetch_arr_ids(item, out, &sc);
        if (sc == 0) {
            [iconLists removeObjectAtIndex:i];
            i--;
        } else {
            iconLists[i] = item;
        }
        *count += sc;
    }

    dict[@"iconLists"] = iconLists;
}

static NSMutableDictionary *__create_folder(const int index)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *iconLists;

    dict[@"listType"] = @"folder";
    dict[@"displayName"] = [NSString stringWithFormat:@"TLSGroup_%d", index];

    iconLists = [NSMutableArray array];
    iconLists[0] = [NSMutableArray array];
    dict[@"iconLists"] = iconLists;

    return dict;
}

static void __add_fb_ids(NSMutableDictionary *dict, NSMutableArray *out)
{
    int i, j, sc;
    NSMutableDictionary *folder;
    NSMutableArray *folder_iconLists, *folder_item;

    @try {
        NSMutableArray *iconLists = ((NSArray *)dict[@"iconLists"]).mutableCopy;
        NSMutableArray *item = ((NSArray *)iconLists[0]).mutableCopy;
        
        j = 1;

        folder = __create_folder(j);
        folder_iconLists = (NSMutableArray *)folder[@"iconLists"];
        folder_item = (NSMutableArray *)folder_iconLists[0];
        sc = 0;

        for (i = 0; i < [out count]; ++i) {
            if (sc == 0) {
                [item insertObject:folder atIndex:0];
            }

            [folder_item insertObject:out[i] atIndex:0];
            sc++;
            if (sc == 9) {
                j++;
                folder = __create_folder(j);
                folder_iconLists = (NSMutableArray *)folder[@"iconLists"];
                folder_item = (NSMutableArray *)folder_iconLists[0];
                sc = 0;
            }
        }
        iconLists[0] = item;
        dict[@"iconLists"] = iconLists;

    } @catch (NSException *e) {

    }
}

void wiiauto_tool_run_clone_samurai(const int argc, const char **argv)
{
    int i;
    char buf[2048];

    int from = atoi(argv[2]);
    int to = atoi(argv[3]);

    for (i = from; i <= to; ++i) {

        /* change app info */
        @try {
            NSString* path = @"/private/var/mobile/Downloads/TheLastSamurai_template.app/Info.plist";
            NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 
            
            dict[@"CFBundleName"] = [NSString stringWithFormat:@"TheLastSamurai%d", i];
            dict[@"CFBundleDisplayName"] = [NSString stringWithFormat:@"TheLastSamurai %d", i];
            dict[@"CFBundleIdentifier"] = [NSString stringWithFormat:@"com.bgate.samurai%d", i];

            [dict writeToFile:@"/private/var/mobile/Downloads/TheLastSamurai_template.app/Info.plist" atomically:YES];
            dict = nil;
        } @catch (NSException *e) {
            NSLog(@"info-error: %@", e);
        }

        /* copy app */
        sprintf(buf, "cp -r /private/var/mobile/Downloads/TheLastSamurai_template.app /Applications/TheLastSamurai%d.app", i);
        system(buf);

        printf("create %d\n", i);
    }

    // /* group app folder */
    // @try {
    //     if (argc == 4) {
    //         system("uicache");

    //         system("killall -9 SpringBoard");
    //         usleep(5 * 1000000);
    //     }

    //     NSString* path = @"/private/var/mobile/Library/SpringBoard/IconState.plist";
    //     NSMutableDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy; 

    //     NSMutableArray *ids = [NSMutableArray array];
    //     /* get all facebook ids */
    //     int count = 0;
    //     __fetch_ids(dict, ids, &count);
    //     /* insert facebook ids */
    //     __add_fb_ids(dict, ids);

    //     NSError *err;
    //     NSDictionary* dict2 = [NSPropertyListSerialization dataFromPropertyList:dict
    //         format:NSPropertyListBinaryFormat_v1_0
    //         errorDescription:&err];
    //     [dict2 writeToFile:@"/private/var/mobile/Library/SpringBoard/DesiredIconState.plist" atomically:YES];
    //     [dict2 writeToFile:@"/private/var/mobile/Library/SpringBoard/IconState.plist" atomically:YES];
    //     dict = nil;
    //     dict2 = nil;
    //     system("killall -9 SpringBoard");
    // } @catch (NSException *e) {
    //     NSLog(@"error: %@", e);
    // }
}