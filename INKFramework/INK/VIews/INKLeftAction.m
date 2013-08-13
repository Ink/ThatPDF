//
//  INKRightAction.m
//  INK
//
//  Created by Albert Swantner on 6/27/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "INKLeftAction.h"

@implementation INKLeftAction

@synthesize iconUrl, actionName, actionColor;

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
        
    CGFloat actionWidth = self.bounds.size.width - 85;
    CGFloat itemHeight = 60;
        
    //Main button
    _button1 = [[UIView alloc] initWithFrame: CGRectMake(75, 0, actionWidth, itemHeight)];
    [_button1 setUserInteractionEnabled:NO];
    
    [self addSubview:_button1];
    //Label for Main Button
    UILabel *label =  [[UILabel alloc] initWithFrame: CGRectMake(90, 17,200,25)];
    label.text = actionName;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Roboto-Condensed" size:20.0];
    label.backgroundColor = [UIColor clearColor];
    [label setUserInteractionEnabled:NO];
    [self addSubview:label];
    
    //Icon for Action
    /*
    NSString *imageURL= iconUrl;
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *appIcon = [[UIImage alloc] initWithData:data];
    */
    UIImage *appIcon = [UIImage imageNamed:[@"INK.bundle/" stringByAppendingString:iconUrl]];
    UIImageView *appIconbutton = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 60, 60)];
    [appIconbutton setUserInteractionEnabled:NO];
    appIconbutton.image = appIcon;
    
    [self addSubview:appIconbutton];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIColor* selected = [UIColor colorWithRed:107.0/255.0 green:107.0/255.0 blue:107.0/255.0 alpha:(100.0/100.0)];
    
    if (self.state == UIControlStateHighlighted) {
        //Main Button
        _button1.backgroundColor = selected;
        
    } else {
        if ([actionColor isEqual: @"red"]) {
            _button1.backgroundColor = [UIColor colorWithRed:173.0/255.0 green:74.0/255.0 blue:44.0/255.0 alpha:(100.0/100.0)];
        }
        else if ([actionColor isEqual:@"green"]) {
            _button1.backgroundColor = [UIColor colorWithRed:111.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:(100.0/100.0)];
        }
        else {
            _button1.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:(100.0/100.0)];
        }

    }
}


@end
