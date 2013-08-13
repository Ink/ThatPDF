//
//  INKAction.h
//  InkCore
//
//  Created by Jonathan Uy on 5/25/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//
//  A specific app-action pair to perform
//

#import <Foundation/Foundation.h>
#import "INKBlob.h"

@interface INKAction : NSObject

// Bundle ID of the app that performs the action
@property(nonatomic, strong) NSString *appBundleId;

@property(nonatomic) NSString *name;

// App url used to trigger the specific action
@property(nonatomic, strong) NSString *appUrl;

// url to img for action icon
@property(nonatomic, strong) NSString *iconSmallURL;
// List of supported UTI's for a given action, as UTType objects
@property(nonatomic, strong) NSArray *supportedUTIs;

// Name of Action Type. Action types are categories of actions that can be performed by a number of different applications. They are specific to UTI. Ex: Sign, Annotate, Edit, Convert, Crop
@property(nonatomic, strong) NSString *type;

+ (id)action:(NSString *)name;
+ (id)action:(NSString *)name appURL:(NSString *)appUrl;
+ (id)action:(NSString *)name type:(NSString *)type;
+ (id)action:(NSString *)name type:(NSString *)type appURL:(NSString *)appUrl;
+ (id)action:(NSString *)name type:(NSString *)type appURL:(NSString *)appUrl supports:(NSArray *)utis;
+ (void)fetchActions;
- (BOOL)canActOn:(INKBlob *)blob;

+(NSArray*)actionsForB;
+(NSArray*)leftActionsForB;


@end
