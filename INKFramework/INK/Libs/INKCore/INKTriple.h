//
//  INKTriple.h
//  InkCore
//
//  Created by Jonathan Uy on 5/25/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//
// A Triple contains all of the information about a blob, its location, creator,
// future and past actions. A triple is a first class object, and can be saved
// or passed around an application before triggered.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "InkCore.h"

@interface INKTriple : NSObject

@property(nonatomic, strong) INKBlob *blob;
@property(nonatomic, strong) INKAction *action;
@property(nonatomic, strong) INKUser *user;

// Instantiates a new triple for the given [Action, Blob, User] set.
+ (id)tripleWithAction:(INKAction *)action blob:(INKBlob *)blob user:(INKUser *)user;
+ (void)executeTriple:(INKBlob *)blob withAction:(INKAction *)action useChunking:(BOOL)bUseChunking;

// Triggers the event, passing the data to the app for the specified INKAction.
- (void)triggerForReturn:(void (^)(INKBlob *result, NSError *error))block;
- (void)trigger:(void (^)(INKBlob *result, NSError *error))block;


@end
