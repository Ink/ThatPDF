//
//  INKTriple.m
//  InkCore
//
//  Created by Jonathan Uy on 5/25/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "INKTriple.h"
#import "InkLibrary.h"

@implementation INKTriple

@synthesize blob, action, user;

+ (id)tripleWithAction:(INKAction *)action blob:(INKBlob *)blob user:(INKUser *)user
{
    INKTriple *triple = [[self alloc] init];
    [triple setBlob:blob];
    [triple setAction:action];
    [triple setUser:user];
    return triple;
}

+ (void)executeTriple:(INKBlob *)blob withAction:(INKAction *)action useChunking:(BOOL)bUseChunking
{
    //NSData *data = [blob data];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:blob];

    NSString *type = [action type];
    NSString *target = [action appUrl];
    IACClient *client = [[IACClient alloc] initWithURLScheme:target];
    
    if (bUseChunking) {
        // Get data into UIPasteboard
        NSString *key = [InkLibrary bgSet:data];
        
        // Execute Action
        [client performAction:type parameters:@{@"key":key} onSuccess:nil onFailure:nil];
    }
    else {
        // Create pasteboards for passing the data
        NSString *pasteboardDataName = @"com.inkSDK.pasteboardData";
        UIPasteboard *pasteboardData = [UIPasteboard pasteboardWithName:pasteboardDataName create:YES];
        UIPasteboard *pasteboardOriginURL = [UIPasteboard pasteboardWithName:@"com.inkSDK.pasteboardOriginURL" create:YES];
        
        // Place data in pasteboards
        [pasteboardData setData:data forPasteboardType:pasteboardDataName];
        [pasteboardOriginURL setString:[IACManager sharedManager].callbackURLScheme];
        
        // Execute Action
        [client performAction:type parameters:nil onSuccess:nil onFailure:nil];
    }
}

// Triggers the event, passing the data to the app for the specified INKAction.
- (void)triggerForReturn:(void (^)(INKBlob *result, NSError *error))block
{

    [self trigger:block];
    
}

- (void)trigger:(void (^)(INKBlob *result, NSError *error))block
{
    // Register action to handle the return
    //TODO: register actions automatically?
    //INKAction *returnAction = [INKAction action:@"Return" type:INKActionType_Return];
    //[INKCore registerAction:returnAction withBlock:block];
    
    // Create pasteboards for passing the data
    NSString *pasteboardDataName = @"com.inkSDK.pasteboardData";
    UIPasteboard *pasteboardData = [UIPasteboard pasteboardWithName:pasteboardDataName create:YES];
    UIPasteboard *pasteboardOriginURL = [UIPasteboard pasteboardWithName:@"com.inkSDK.pasteboardOriginURL" create:YES];
    
    // Get data into UIPasteboard
    //NSData *data = [inkBlob data];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:blob];
    
    // Execute Action
    NSString *type = [action type];
    NSString *target = [action appUrl];
    IACClient *client = [[IACClient alloc] initWithURLScheme:target];
    
    // Place data in pasteboards
    [pasteboardData setData:data forPasteboardType:pasteboardDataName];
    [pasteboardOriginURL setString:[IACManager sharedManager].callbackURLScheme];
    
    [client performAction:type parameters:nil onSuccess:nil onFailure:nil];
    
}

@end
