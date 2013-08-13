//
//  InkLibrary.m
//  Ink
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import "InkLibrary.h"
#import <UIKit/UIKit.h>
#import "NSData+DataWithContentsOfFileAtOffsetWithSize.h"


@implementation InkLibrary


+ (NSString *) genRandStringLength: (int) len {

    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

/* In Memory Operations */
+ (NSString *) set: (NSData*) data {
    NSString* key = [self genRandStringLength:10];
    return [self set:data at:key];
}

+ (NSString *) set: (NSData*) data at:(NSString*)key {
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:key create:YES];
    [pasteboard setData:data forPasteboardType:@"data"];
    return key;
}

+ (NSData *) get:(NSString *)key {
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:key create:YES];
    NSData *data = [pasteboard dataForPasteboardType:@"data"];
    return data;
}


/* Background low memory operations */
+ (void) runBackgroundProcess {
    if ([[UIDevice currentDevice] isMultitaskingSupported]) { //Check if device supports mulitasking
        UIApplication *application = [UIApplication sharedApplication]; //Get the shared application instance
        __block UIBackgroundTaskIdentifier backgroundTask; //Create a task object
        backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^ {
            [application endBackgroundTask: backgroundTask]; //Tell the system that we are done with the tasks
            backgroundTask = UIBackgroundTaskInvalid; //Set the task to be invalid
            //System will be shutting down the app at any point in time now
        }];
        //Background tasks require you to use asyncrous tasks
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //Perform your tasks that your application requires
            NSLog(@"\n\nRunning in the background!\n\n");
            
            [self bgSetProcess];
            
            [application endBackgroundTask: backgroundTask]; //End the task so the system knows that you are done with what you need to perform
            backgroundTask = UIBackgroundTaskInvalid; //Invalidate the backgroundTask
        });
    }
}

+ (NSString *) bgSetFromFilePath: (NSString *)filepath :(NSString *)filedata {
    NSString* key = [self genRandStringLength:10];

    //Init the pasteboards
    //TODO: should be key specific
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"bgset" create:YES];
    pasteboard.string = filepath;

    UIPasteboard *pasteboardkey = [UIPasteboard pasteboardWithName:@"bgkey" create:YES];
    pasteboardkey.string = key;
    
    UIPasteboard *pasteboardfiledata = [UIPasteboard pasteboardWithName:@"bgdata" create:YES];
    pasteboardfiledata.string = filedata;

    UIPasteboard *pasteboardflag = [UIPasteboard pasteboardWithName:@"bgflag" create:YES];
    pasteboardflag.string = @"get";

    return key;
}


+ (NSString *) bgSet: (NSData*) data {
    NSString* key = [self genRandStringLength:10];
    
    //write to temp storage
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
    NSURL *tempURL = [NSURL fileURLWithPath:tempPath isDirectory:NO];
    [data writeToURL:tempURL atomically:YES];
    
    return [self bgSetFromFilePath:tempPath];
}

+ (void) bgSetProcess {

    //TODO: should think more about how to get the right key, path and move that around.
    //local dictionary with keys?
    
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"bgset" create:YES];
    NSString * filepath = pasteboard.string;
    
    UIPasteboard *pasteboardkey = [UIPasteboard pasteboardWithName:@"bgkey" create:YES];
    NSString *key = pasteboardkey.string;
    
    UIPasteboard *pasteboardfiledata = [UIPasteboard pasteboardWithName:@"bgdata" create:YES];
    NSString *filedata = pasteboardfiledata.string;

    UIPasteboard *pasteboardRWFlag = [UIPasteboard pasteboardWithName:@"bgflag" create:YES];
    pasteboardRWFlag.string = @"";
    
    UIPasteboard *pasteboardDoneFlag = [UIPasteboard pasteboardWithName:@"bgdone" create:YES];
    pasteboardDoneFlag.string = @"started";
    
    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filepath error:nil][NSFileSize] longLongValue];
    long long offset = 0;
    
    while (offset < fileSize){
        while ([pasteboardRWFlag.string isEqualToString:@"writedone"]){
            NSLog(@"sleeping while waiting for read to start.");
            usleep(10);
        }
        while ([pasteboardRWFlag.string isEqualToString:@"reading"]) {
            NSLog(@"sleeping while read is in progress. %@", pasteboardRWFlag.string);
            usleep(5);
        }
        
        NSLog(@"writing");
        pasteboardRWFlag.string = @"writing";
        size_t sz = 1000000;
        if (fileSize - offset < sz){
            sz = fileSize - offset;
        }
        NSData *data = [NSData dataWithContentsOfFile:filepath atOffset:offset withSize:sz];
        NSLog(@"got file data, now writing");
        
        [self set:data at:key];
        pasteboardRWFlag.string = @"writedone";
        NSLog(@"writing done");
        
        NSLog(@"offset: %llu size: %llu", offset, fileSize);
        offset += sz;
    }
    
    pasteboardDoneFlag.string = @"done";
    NSLog(@"DONE: %@", pasteboardRWFlag.string);
}

+ (NSString *) bgGet: (NSString*) key {

    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
    
    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:tempPath];
    if(file == nil) {
        [[NSFileManager defaultManager] createFileAtPath:tempPath contents:nil attributes:nil];
        file = [NSFileHandle fileHandleForWritingAtPath:tempPath];
    }

    UIPasteboard *pasteboardRWFlag = [UIPasteboard pasteboardWithName:@"bgflag" create:YES];
    UIPasteboard *pasteboardDoneFlag = [UIPasteboard pasteboardWithName:@"bgdone" create:YES];
    if ([pasteboardDoneFlag.string isEqualToString:@"done"] && [[self get:key] length] == 0) {
        NSLog(@"Empty but done, resetting");
        pasteboardDoneFlag.string = @"started";
    }
    
    //until we're finished
    while (!([pasteboardDoneFlag.string isEqualToString:@"done"] && [pasteboardRWFlag.string isEqualToString:@"readdone"])){
        //see if we're still writing
        while ([pasteboardRWFlag.string isEqualToString:@"readdone"]){
            NSLog(@"sleeping while waiting for write to occur %@", pasteboardRWFlag.string);
            usleep(20);
        }
        while ([pasteboardRWFlag.string isEqualToString:@"writing"]){
            NSLog(@"sleeping while write is in progress");
            usleep(5);
        }

        NSLog(@"reading data");
        pasteboardRWFlag.string = @"reading";
        NSData *data = [self get:key];
        NSLog(@"got data %d", [data length]);
        pasteboardRWFlag.string = @"readdone";

        [file seekToEndOfFile];
        [file writeData:data];
        NSLog(@"finished writing to file");
    }
    [file closeFile];
    
    return tempPath;    
}


@end

