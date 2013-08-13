//
//  INKBlob.m
//  InkCore
//
//  Created by Jonathan Uy on 5/25/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "INKBlob.h"
#import "InkLibrary.h"

@implementation INKBlob


@synthesize filename, location, uti, url, size, createdAt, lastUpdated, data;

+ (id)blobFromData:(NSData *)source
{
    INKBlob *blob = [[self alloc] init];
    [blob setData:source];
    return blob;
}



+ (id)blobFromQuery:(NSDictionary *)params
{
    // Pull key from the dictionary to get the file path
    NSString *key = [params objectForKey:@"key"];
    NSString *filePath = [InkLibrary bgGet:key];
    NSLog(@"read from %@", filePath);
    
    // Get data for the file
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    INKBlob *blob = [[self alloc] init];
    [blob setData:data];
    return blob;
}

+ (id)blobFromPasteboard
{
    NSString *pasteboardDataName = @"com.inkSDK.pasteboardData";
    UIPasteboard *pasteboardData = [UIPasteboard pasteboardWithName:pasteboardDataName create:YES];
    
    NSData *encodedData = [pasteboardData dataForPasteboardType:pasteboardDataName];
    
    INKBlob *blob = [NSKeyedUnarchiver unarchiveObjectWithData:encodedData];
    return blob;
}

+ (id)blobFromUrl:(NSURL *)source
{
    return nil;
}

+ (id)blobFromLocalFile:(NSURL *)source
{
    INKBlob *blob = [[self alloc] init];
    [blob setData:[NSData dataWithContentsOfURL:source]];
    return blob;
}

+ (id)blobFromCloudService:(NSString *)service withPath:(NSString *)path
{
    return nil;
}

- (void)update
{
    
}

- (void)which
{
    
}

- (void)getActions
{
    
}



- (void) encodeWithCoder:(NSCoder*)encoder {
    // If parent class also adopts NSCoding, include a call to
    // [super encodeWithCoder:encoder] as the first statement.
    
    [encoder encodeObject:data forKey:@"data"];
    [encoder encodeObject:filename forKey:@"filename"];
    [encoder encodeObject:uti forKey:@"uti"];
    [encoder encodeObject:size forKey:@"size"];
    [encoder encodeObject:createdAt forKey:@"cretedAt"];
    [encoder encodeObject:lastUpdated forKey:@"lastUpdated"];

}

- (id) initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) {
        // If parent class also adopts NSCoding, replace [super init]
        // with [super initWithCoder:decoder] to properly initialize.
        
        // NOTE: Decoded objects are auto-released and must be retained
   
        
        data = [decoder decodeObjectForKey:@"data"] ;
        filename = [decoder decodeObjectForKey:@"filename"];
        uti = [decoder decodeObjectForKey:@"uti"] ;
        size = [decoder decodeObjectForKey:@"size"] ;
        createdAt = [decoder decodeObjectForKey:@"cretedAt"] ;
        lastUpdated = [decoder decodeObjectForKey:@"lastUpdated"] ;
        
    }
    return self;
}


@end
