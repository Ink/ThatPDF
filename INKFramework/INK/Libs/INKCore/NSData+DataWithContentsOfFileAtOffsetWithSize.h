//
//  NSData+DataWithContentsOfFileAtOffsetWithSize.h
//  Ink
//
//  Created by Liyan David Chang on 5/3/13.
//  Copyright (c) 2013 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(DataWithContentsOfFileAtOffsetWithSize)
+ (NSData *) dataWithContentsOfFile:(NSString *)path atOffset:(off_t)offset withSize:(size_t)bytes;
@end