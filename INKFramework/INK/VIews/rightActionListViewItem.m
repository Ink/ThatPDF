//
//  ViewController.m
//  UItest
//
//  Created by Albert Swantner on 6/14/13.
//  Copyright (c) 2013 Albert Swantner. All rights reserved.
//

#import "rightActionListViewItem.h"

@interface rightActionListViewItem ()


@end

@implementation rightActionListViewItem
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        // Initialization code
        
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

    CGFloat width = CGRectGetWidth(self.bounds);

    CGFloat actionWidth = 240;
    CGFloat itemHeight = 60;
    CGFloat iconWidth = 60;
    CGFloat barWidth = 15;
    CGFloat spaceBetween = 10;
    CGFloat barHeight = 20;
    CGFloat topBoundary = 200;


    
    UIColor *color = [UIColor blackColor];
    self.backgroundColor = color;
    
    
    UIView *button1 = [[UIView alloc] initWithFrame: CGRectMake(0, 0, actionWidth, itemHeight)];
    button1.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:(100.0/100.0)];
    [self addSubview:button1];
    
    UIView *button1right1=  [[UIView alloc] initWithFrame: CGRectMake(actionWidth+2*spaceBetween+iconWidth, 0, barWidth, itemHeight/3)];
    button1right1.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:(100.0/100.0)];
    [self addSubview:button1right1];
     UIView *button1right2=  [[UIView alloc] initWithFrame: CGRectMake(actionWidth+2*spaceBetween+iconWidth, itemHeight/3, barWidth, itemHeight/3)];
    button1right2.backgroundColor = [UIColor colorWithRed:203.0/255.0 green:203.0/255.0 blue:203.0/255.0 alpha:(100.0/100.0)];
    [self addSubview:button1right2];
    UIView *button1right3=  [[UIView alloc] initWithFrame: CGRectMake(actionWidth+2*spaceBetween+iconWidth, 2*itemHeight/3, barWidth, itemHeight/3)];
    button1right3.backgroundColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:(100.0/100.0)];
    [self addSubview:button1right3];
       
}



@end
