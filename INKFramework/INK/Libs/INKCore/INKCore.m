//
//  INKCore.m
//  InkCore
//
//  Created by Jonathan Uy on 6/3/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "INKCore.h"
#import "InkLibrary.h"

@implementation INKCore

+ (void)registerAction:(INKAction *)action withTarget:(NSObject *)target selector:(SEL)selector
{
    if (action) {
        [INKCore handleAction:action.type withBlock:^(NSDictionary *inputParams, IACSuccessBlock success, IACFailureBlock failure) {
            // Get the data from the Pasteboard
            INKBlob *blob = [INKBlob blobFromPasteboard];
            
            if (target) {
                [target performSelector:selector withObject:blob];
            }
        }];
    }
}

+ (void)registerAction:(INKAction *)action withBlock:(void (^)(INKBlob *blob, NSError *error))actionCallback
{
    if (action) {

        NSLog(@"LDCDL actionType: %@", action.type);
        [INKCore handleAction:action.type withBlock:^(NSDictionary *inputParams, IACSuccessBlock success, IACFailureBlock failure) {
            // Get the data from the Pasteboard
            INKBlob *blob = [INKBlob blobFromPasteboard];
            
            actionCallback(blob, failure);
        }];
    }
}

+ (void)return:(INKBlob *)blob
{
    // Get originating URL from the UIPasteboard
    UIPasteboard *pasteboardOriginURL = [UIPasteboard pasteboardWithName:@"com.inkSDK.pasteboardOriginURL" create:YES];
    INKAction *action = [INKAction action:@"Return" type:INKActionType_Return appURL:[pasteboardOriginURL string]];
    [INKTriple executeTriple:blob withAction:action useChunking:NO];
}

+ (void)returnWithError:(NSError *)error
{
    UIPasteboard *pasteboardOriginURL = [UIPasteboard pasteboardWithName:@"com.inkSDK.pasteboardOriginURL" create:YES];
    INKAction *action = [INKAction action:@"Return" type:INKActionType_Return appURL:[pasteboardOriginURL string]];
    [INKTriple executeTriple:nil withAction:action useChunking:NO];
    
    // TODO: Serialize the NSError and pass it back to the originating URL through UIPasteboard
    //  -- not exactly sure if this is the best thing to do
}

+ (BOOL)appShouldReturn
{
    UIPasteboard *pasteboardOriginURL = [UIPasteboard pasteboardWithName:@"com.inkSDK.pasteboardOriginURL" create:YES];
    if ([pasteboardOriginURL string] != nil && ![[pasteboardOriginURL string] isEqualToString:[IACManager sharedManager].callbackURLScheme]) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (NSString *)callingAppUrl {
    UIPasteboard *pasteboardOriginURL = [UIPasteboard pasteboardWithName:@"com.inkSDK.pasteboardOriginURL" create:YES];
    NSString *url = [pasteboardOriginURL string];
    if (url != nil && ![url isEqualToString:[IACManager sharedManager].callbackURLScheme]) {
        return url;
    } else {
        return nil;
    }
}

+ (void)setCallbackURLScheme:(NSString *)url
{
    [IACManager sharedManager].callbackURLScheme = url;
}

+ (void)handleAction:(NSString *)action withBlock:(IACActionHandlerBlock)handler
{
    [[IACManager sharedManager] handleAction:action
                                   withBlock:handler];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [[IACManager sharedManager] handleOpenURL:url];
}

+ (void)runBackgroundProcess
{
    [InkLibrary runBackgroundProcess];
}

@end
