//
//  INKBlobstore.m
//  InkCore
//
//  Created by Jonathan Uy on 5/26/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "INKBlobstore.h"

@implementation INKBlobstore

+ (id)getSingleton
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)create
{
    
}

- (void)read
{
    
}

- (void)update
{
    
}

@end
