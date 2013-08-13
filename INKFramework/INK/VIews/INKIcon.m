//
//  INKRightAction.m
//  INK
//
//  Created by Albert Swantner on 6/27/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "INKIcon.h"

@implementation INKIcon

@synthesize iconType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    
    CGRect imageFrame = CGRectMake(20,20,25,25);
    UIImageView *myImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    NSString *buttonType = iconType;
    
    if ([buttonType isEqual: @"close"]) {
        myImageView.image=[UIImage imageNamed:@"INK.bundle/close.png"];
        
    }
    
    if ([buttonType isEqual: @"help"]) {
        myImageView.image=[UIImage imageNamed:@"INK.bundle/help.png"];

    }
    
    if ([buttonType isEqual: @"info"]) {
        myImageView.image=[UIImage imageNamed:@"INK.bundle/help.png"];
        
    }
    
    if ([buttonType isEqual: @"preview"]) {
        myImageView.image=[UIImage imageNamed:@"INK.bundle/zoom.png"];

    }
    
    [myImageView setUserInteractionEnabled:NO];
    
    [self addSubview:myImageView];
    
    [self setImage:[UIImage imageNamed:@"INK.bundle/selected.png"] forState:UIControlStateHighlighted];
    
    
}


@end
