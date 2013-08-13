//
//  UIImageView+Ink.h
//  INK Workflow Framework
//
//  Created by Jonathan Uy on 5/17/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InkCore.h"

@interface UIView (Ink)

//typedef  int (^BlobBlock)(void);

@property (nonatomic, retain) id objectTag;

@property (nonatomic, retain) id UTITag;
@property (nonatomic, retain) id returnBlockTag;



- (UIView *)viewWithObjectTag:(id)object;


- (void) INKEnable:(INKBlob *(^)(void))Block withUTI:(NSString *)UTI;
//- (void) INKEnable:(INKBlob *(^)(void))Block withUTI:(NSString *)UTI onReturn:(void (^)(INKAction *returnAction))ReturnBlock;


@end





