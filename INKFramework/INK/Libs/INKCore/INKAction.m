//
//  INKAction.m
//  InkCore
//
//  Created by Jonathan Uy on 5/25/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//


#import "INKAction.h"
#import "INKDB.h"
#import "FMDatabaseQueue.h"
#import "INKConstants.h"
#import "InkCore.h"

@implementation INKAction

@synthesize appBundleId, appUrl, name,supportedUTIs, type, iconSmallURL;


+ (id)action:(NSString *)name
{
    return [INKAction action:name type:INKActionType_Default appURL:nil supports:nil];
}

+ (id)action:(NSString *)name appURL:(NSString *)appUrl
{
    return [INKAction action:name type:INKActionType_Default appURL:nil supports:nil];
}

+ (id)action:(NSString *)name type:(NSString *)type
{
    return [INKAction action:name type:type appURL:nil supports:nil];
}

+ (id) action:(NSString *)name type:(NSString *)type appURL:(NSString *)appUrl
{
    return [INKAction action:name type:type appURL:appUrl supports:nil];
}

+ (id) action:(NSString *)name type:(NSString *)type appURL:(NSString *)appUrl supports:(NSArray *)utis
{
    INKAction *action = [[self alloc] init];
    action.name = name;
    action.type = type;
    action.appUrl = appUrl;
    action.supportedUTIs = utis;
    return action;
}

+(NSArray*)actionsForB{
    
    INKDB *sharedDB = [INKDB sharedDB];
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSLog(@"Current appID: %@", appID);
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[sharedDB INKDB_path]];
    //FIXED array index - MEGA HACK NO BUENO
    NSMutableArray *actionsArray = [NSMutableArray arrayWithCapacity:200];
    //add actions to db using async GDC FMDB method
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *results = [db executeQuery:@"select * from action where app_id!=?", appID];
        while([results next]) {
            
            //NSLog([results stringForColumn:@"name"]);
            INKAction *action = [INKAction alloc];
            [action setName:[results stringForColumn:@"name"]];
            //TODO: should not be based on call_to_action, should be app_type or similar
            [action setType:[results stringForColumn:@"call_to_action"]];
            [action setIconSmallURL:[results stringForColumn:@"icon_sm"]];
            [action setAppUrl:[results stringForColumn:@"appurl_full"]];
            [actionsArray addObject:action];
            
        }
        
    }];
    
    return actionsArray;
}

+(NSArray*)leftActionsForB{
    
    INKDB *sharedDB = [INKDB sharedDB];
    NSString *callingUrl = [INKCore callingAppUrl];
    if (!callingUrl) {
        return [NSArray array]; //no calling url, return empty array
    }
    
    NSLog(@"Get left actions for app url:%@", callingUrl);
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[sharedDB INKDB_path]];
    //FIXED array index - MEGA HACK NO BUENO
    NSMutableArray *actionsArray = [NSMutableArray arrayWithCapacity:200];
    //add actions to db using async GDC FMDB method
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *results = [db executeQuery:@"select * from leftaction where appurl_full=?", callingUrl];
        while([results next]) {
            
            //NSLog([results stringForColumn:@"name"]);
            INKAction *action = [INKAction alloc];
            [action setName:[results stringForColumn:@"name"]];
            //TODO: should not be based on call_to_action, should be app_type or similar
            [action setType:[results stringForColumn:@"call_to_action"]];
            [action setIconSmallURL:[results stringForColumn:@"icon_sm"]];
            [action setAppUrl:[results stringForColumn:@"appurl_full"]];
            [actionsArray addObject:action];
            
        }
        
    }];
    
    return actionsArray;
}

+ (void) fetchActions
{
    
    NSError *error = nil;
    
    //NSURL *url = [NSURL URLWithString:@"http://albertut.com/sampledata.json"];
    NSURL *url = [NSURL URLWithString:@"https://www.dropbox.com/s/pvkver4hct5p4qw/actions.json?dl=true"];
    
    NSString *json = [NSString stringWithContentsOfURL:url
                                              encoding:NSASCIIStringEncoding
                                                 error:&error];
    NSLog(@"\nJSON: %@ \n Error: %@", json, error);
    NSData *jsonData = [json dataUsingEncoding:NSASCIIStringEncoding];
    NSArray *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    //Right Actions
    NSArray *actionNames = [jsonDict valueForKey: @"actions"];
    INKDB *sharedDB = [INKDB sharedDB];
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[sharedDB INKDB_path]];
    
    
    
    [queue inDatabase:^(FMDatabase *db) {
        //need to add other fields to json and db herez
        [db executeUpdate:@"DELETE FROM action"];
        
    }];
    
    //Right Actions
    for (id object in actionNames) {
        
        
        
        //Right hand side actions
        NSString *integerValue = [object valueForKey:@"id"];
        //rightActionButton.tag = integerValue.intValue;
        NSLog(@"\n%@ ", integerValue);
        
        NSString *appId = [object valueForKey:@"app_id"];
        
        //Label for Action
        NSString *labelServer = [object valueForKey: @"name"];
        //rightActionButton.actionName = labelServer;
        NSLog(@"\n%@ ", labelServer);
        
        
        //Icon for Action
        NSString *iconUrlServer= [object valueForKey: @"icon_sm"];
        //rightActionButton.iconUrl = iconUrlServer;
        NSLog(@"\n%@ ", iconUrlServer);
        
        // Building the string ourself
        //NSString *query = [NSString stringWithFormat:@"insert into action values ('%@', %@)", iconUrlServer, iconUrlServer];
        NSString *appUrlServer= [object valueForKey: @"appurl_full"];
        NSLog(@"\n%@ ", appUrlServer);
        
        NSString *typeServer= [object valueForKey: @"app_type"];
        NSLog(@"\n%@ ", typeServer);
        
        //add actions to db using async GDC FMDB method
        [queue inDatabase:^(FMDatabase *db) {
            //need to add other fields to json and db herez
            [db executeUpdate:@"insert into action(name, icon_sm,appurl_full,call_to_action,app_id) values(?,?,?,?,?)", labelServer,iconUrlServer, appUrlServer, typeServer, appId, nil];
            
        }];
        
        
    }
    NSLog(@"db update complete");
    
    
    [queue inDatabase:^(FMDatabase *db) {
        //need to add other fields to json and db herez
        [db executeUpdate:@"DELETE FROM leftaction"];
        
    }];

    
    //Left Action
    NSArray *leftActionNames = [jsonDict valueForKey: @"leftActions"];

    //Right Actions
    for (id object in leftActionNames) {
        
        //Right hand side actions
        NSString *integerValue = [object valueForKey:@"id"];
        //rightActionButton.tag = integerValue.intValue;
        NSLog(@"\n%@ ", integerValue);
        
        //Label for Action
        NSString *labelServer = [object valueForKey: @"name"];
        //rightActionButton.actionName = labelServer;
        NSLog(@"\n%@ ", labelServer);
        
        
        //Icon for Action
        NSString *iconUrlServer= [object valueForKey: @"icon_sm"];
        //rightActionButton.iconUrl = iconUrlServer;
        NSLog(@"\n%@ ", iconUrlServer);
        
        // Building the string ourself
        //NSString *query = [NSString stringWithFormat:@"insert into action values ('%@', %@)", iconUrlServer, iconUrlServer];
        NSString *appUrlServer= [object valueForKey: @"appurl_full"];
        NSLog(@"\n%@ ", appUrlServer);
        
        NSString *typeServer= [object valueForKey: @"app_type"];
        NSLog(@"\n%@ ", typeServer);
        
        //add actions to db using async GDC FMDB method
        [queue inDatabase:^(FMDatabase *db) {
            //need to add other fields to json and db herez
            [db executeUpdate:@"insert into leftaction(name, icon_sm,appurl_full,call_to_action) values(?,?,?,?)", labelServer,iconUrlServer, appUrlServer, typeServer, nil];
            
        }];
        
        
    }
    
}

- (BOOL)canActOn:(INKBlob *)blob
{
    return NO;
}

@end
