//
//  ViewController.m
//  UItest
//
//  Created by Albert Swantner on 6/14/13.
//  Copyright (c) 2013 Albert Swantner. All rights reserved.
//

#import "leftActionListItemView.h"

@interface leftActionListItemView ()


@end

@implementation leftActionListItemView
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
    CGRect screenRect = [[UIScreen mainScreen] bounds];


    CGFloat width = CGRectGetWidth(self.bounds);
    
    CGFloat actionWidth = 240;
    CGFloat itemHeight = 60;
    CGFloat iconWidth = 60;
    CGFloat barWidth = 15;
    CGFloat spaceBetween = 10;    
    
    UIColor *color = [UIColor blackColor];
    self.backgroundColor = color;
    
    NSURL *url = [NSURL URLWithString:@"http://albertut.com/acrobat.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *appIcon = [[UIImage alloc] initWithData:data];
    UIButton *appIconbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    appIconbutton.frame = CGRectMake(0, 0, iconWidth, itemHeight);
    [appIconbutton setBackgroundImage:appIcon forState:UIControlStateNormal];
    [appIconbutton setBackgroundColor:[UIColor clearColor]];
    [appIconbutton addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:appIconbutton];
    
    
    UIButton *button1right1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1right1.frame = CGRectMake(iconWidth+spaceBetween, 0, barWidth, itemHeight/3);
    [button1right1 setTag:1];
    button1right1.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [button1right1 setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:(100.0/100.0)]];
    [self addSubview:button1right1];
    UIButton *button1right2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1right2.frame = CGRectMake(iconWidth+spaceBetween, itemHeight/3, barWidth, itemHeight/3);
    [button1right2 setTag:1];
    button1right2.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [button1right2 setBackgroundColor:[UIColor colorWithRed:203.0/255.0 green:203.0/255.0 blue:203.0/255.0 alpha:(100.0/100.0)]];
    [self addSubview:button1right2];
    UIButton *button1right3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1right3.frame = CGRectMake(iconWidth+spaceBetween, 2*itemHeight/3, barWidth, itemHeight/3);
    [button1right3 setTag:1];
    button1right3.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [button1right3 setBackgroundColor:[UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:(100.0/100.0)]];
    [self addSubview:button1right3];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(iconWidth+2*spaceBetween+barWidth, 0, actionWidth, itemHeight);
    [button1 setTag:1];
    [button1 setTitle:@"Open in Acrobat" forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont fontWithName:@"Roboto Condensed" size:30.0];
    [button1 setTitleColor:[UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:(100.0/100.0)] forState:UIControlStateNormal];
    button1.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    button1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button1 setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:(100.0/100.0)]];
    [button1 addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:button1];
    

    
    
}


@end
