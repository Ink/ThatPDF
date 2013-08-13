//
//  INKDB.m
//  INK
//
//  Created by Dave Rauchwerk on 7/7/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "INKDB.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "INKAction.h"

@implementation INKDB


@synthesize INKDB_docsPath, INKDB_paths,INKDB_path;



+ (id)sharedDB {
    static INKDB *sharedDB = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDB = [[self alloc] init];
    });
    return sharedDB;
}

-(id)init {
    if (self = [super init]) {
        //create db schema when the singleton is initalized
        [self initDBSchema];
        
    }
    return self;
}

- (void)initDBSchema
{
    
    INKDB_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    INKDB_docsPath = [INKDB_paths objectAtIndex:0];
    INKDB_path = [INKDB_docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *INKDBLoc = [FMDatabase alloc];
    INKDBLoc = [FMDatabase databaseWithPath:INKDB_path];
    [INKDBLoc open];
    
    #pragma mark -  Action Schema


    /*
     INKServer
     Action MODEL
     ------------
     
     id : INTEGER
     uuid : STRING
     name : STRING
     call_to_action : STRING
     description : STRING
     icon_sm : STRING
     icon_lg : STRING
     app_id : STRING
     appurl_full : STRING
     
     */
    
    [INKDBLoc executeUpdate:@"create table action(id integer primary key, uuid text, name text, call_to_action text, description text, icon_sm text, icon_lg text, app_id text, appurl_full txt)"];

    [INKDBLoc executeUpdate:@"create table leftaction(id integer primary key, uuid text, name text, call_to_action text, description text, icon_sm text, icon_lg text, app_id text, appurl_full txt)"];

    
    #pragma mark -  Event Schema

    /*
     INKServer
     Event MODEL
     ------------
     
     id : INTEGER
     device_id : INTEGER
     origin_app_id : INTEGER
     action_id : INTEGER
     user_id : INTEGER
     blob_id : INTEGER
     
     */
    
    [INKDBLoc executeUpdate:@"create table event(name text primary key, age int)"];

    #pragma mark -  Blob Schema

    
    /*
     INKServer
     Blob MODEL
     ----------
     
     id : INTEGERuuid : STRING
     filename : STRING
     content_type_id : INTEGER
     size : INTEGER
     url : STRING
     owner : STRING
     permission_id: INTEGER
     
    */
    
    [INKDBLoc executeUpdate:@"create table blob(name text primary key, age int)"];

    [INKDBLoc close];

    // Let fmdb do the work
    //[database executeUpdate:@"insert into user(name, age) values(?,?)",
    // @"cruffenach",[NSNumber numberWithInt:25],nil];
    
    
}
+ (id)actionForRecord
{
    
    
    
    
    
}


@end
