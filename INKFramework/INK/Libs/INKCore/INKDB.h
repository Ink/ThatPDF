//
//  INKDB.h
//  INK
//
//  Created by Dave Rauchwerk on 7/7/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface INKDB : NSObject


@property (nonatomic, retain) NSString *someProperty;
@property(nonatomic, retain) NSArray *INKDB_paths;
@property(nonatomic, retain) NSString *INKDB_docsPath;

@property(nonatomic,retain) NSString *INKDB_path;



+ (id)sharedDB;

@end
