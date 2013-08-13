//
//  INKBlob.h
//  InkCore
//
//  Created by Jonathan Uy on 5/25/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//
//  Blobs can be created from local binary data, publically available urls,
//  device file:// urls, and credential­location pairs for cloud storage services.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface INKBlob : NSObject <NSCoding>

//The name of the file
@property(nonatomic, strong) NSString *filename;

// The location of a specific file, can be on device, cloud, etc
@property(nonatomic, strong) NSString *location;

// Mimetype of a file
@property(nonatomic, strong) NSString *uti;

// Globally unique url that responds with the contents of the blob
@property(nonatomic, strong) NSString *url;

// Size of the blob in bytes
@property(nonatomic, strong) NSString *size;

// When file blob created, ISO 8601 format
@property(nonatomic, strong) NSString *createdAt;

// When file was last updated, ISO 8601 format
@property(nonatomic, strong) NSString *lastUpdated;

// ...
@property(nonatomic, strong) NSData *data;

// Creates a blob from binary data
+ (id)blobFromData:(NSData *)source;

// Creates a blob from data in query params from URL call
+ (id)blobFromQuery:(NSDictionary *)params;

// Creates a blob from data found in the Ink-created UIPasteboards
+ (id)blobFromPasteboard;

// Creates a blob from a publically available URL (will use the User­Agent “Ink iOS v1”)
+ (id)blobFromUrl:(NSURL *)source;

// Creates a blob from a file:// url pointing to a file on the device.
+ (id)blobFromLocalFile:(NSURL *)source;

// Creates a blob from a remote hard drive (i.e. Box, Google Drive)
+ (id)blobFromCloudService:(NSString *)service withPath:(NSString *)path;

// Increment the version number and upload the file to the server
- (void)update;

// Returns information about the current blob
- (void)which;

// Get a complete listing of available actions for a given blob. the list of actions
- (void)getActions;

@end
