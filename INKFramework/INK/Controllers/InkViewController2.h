//
//  InkViewController2.h
//  INK Workflow Framework
//
//  Created by Jonathan Uy on 5/21/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ItemSelectedBlock)(int);

@interface InkViewController2 : UIViewController
{
    ItemSelectedBlock completionBlock;
}

@property(readwrite, copy) ItemSelectedBlock completionBlock;
@property(nonatomic, retain) UIPopoverController *popoverRef;

@end
