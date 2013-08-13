//
//  INKBlobstore.h
//  InkCore
//
//  Created by Jonathan Uy on 5/26/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INKBlobstore : NSObject

+ (id)getSingleton;

// Creates a new version of blob in the blobstore
- (void)create;

// Reads information about current blob in the blobstore
- (void)read;

// Updates information about the blob in the blobstore.
- (void)update;

@end