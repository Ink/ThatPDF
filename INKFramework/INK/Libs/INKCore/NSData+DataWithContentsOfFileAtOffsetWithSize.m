//
//  NSData+DataWithContentsOfFileAtOffsetWithSize.m
//  Ink
//
//  Created by Liyan David Chang on 5/3/13.
//  Copyright (c) 2013 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "NSData+DataWithContentsOfFileAtOffsetWithSize.h"

@implementation NSData(DataWithContentsOfFileAtOffsetWithSize)

+ (NSData *) dataWithContentsOfFile:(NSString *)path atOffset:(off_t)offset withSize:(size_t)bytes
{
    NSLog(@"dataWithContentsOfFile: %zd, %zd",offset, bytes);
    FILE *file = fopen([path UTF8String], "rb");
    if(file == NULL) {
        NSLog(@"FILE(%@) IS NULL", path);
        return nil;
    }
    
    void *data = malloc(bytes);  // check for NULL!
    fseeko(file, offset, SEEK_SET);
    fread(data, 1, bytes, file);  // check return value, in case read was short!
    fclose(file);
    
    // NSData takes ownership and will call free(data) when it's released
    return [NSData dataWithBytesNoCopy:data length:bytes];
}

@end