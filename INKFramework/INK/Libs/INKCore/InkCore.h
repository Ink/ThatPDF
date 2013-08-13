//
//  InkCore.h
//  InkCore
//
//  Created by Jonathan Uy on 5/25/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "INKConstants.h"
#import "INKAction.h"
#import "INKBlob.h"
#import "INKUser.h"
#import "INKBlobstore.h"
#import "INKTriple.h"
#import "IACManager.h"

// For InkCore class
#import "IACClient.h"
#import "zlib.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <UIKit/UIKit.h>

@interface INKCore : NSObject

// Receive actions by registering the app to listen to specific actions. The selector
// will be called upon receiving the action. The selector should support receiving
// an INKBlob object as a parameter.
+ (void)registerAction:(INKAction *)action withTarget:(NSObject *)target selector:(SEL)selector;
+ (void)registerAction:(INKAction *)action withBlock:(void (^)(INKBlob *blob, NSError *error))actionCallback;

// Use for receiving apps to return data back to the originating app
+ (void)return:(INKBlob *)blob;

+ (void)returnWithError:(NSError *)error;

// Returns whether app was launched via ink and this should return in the corresponding way
+ (BOOL)appShouldReturn;
+ (NSString *)callingAppUrl;

+ (void)setCallbackURLScheme:(NSString *)url;
+ (void)handleAction:(NSString *)action withBlock:(IACActionHandlerBlock)handler;
+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void) runBackgroundProcess;

@end