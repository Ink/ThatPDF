//
//  INKRightAction.m
//  INK
//
//  Created by Albert Swantner on 6/27/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "INKRightAction.h"

@implementation INKRightAction


@synthesize iconUrl, actionName, options;

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
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Group
    {
        //// SVGID_2_
        {
            
            CGContextSaveGState(context);
            CGFloat actionWidth = self.bounds.size.width - 100;
            CGFloat itemHeight = 60;
            CGFloat iconWidth = 60;
            CGFloat barWidth = 15;
            CGFloat spaceBetween = 10;
            
            //Main button
            _button1 = [[UIView alloc] initWithFrame: CGRectMake(0, 0, actionWidth, itemHeight)];
            [_button1 setUserInteractionEnabled:NO];
            [self addSubview:_button1];
            
            //Label for Main Button
            UILabel *label =  [[UILabel alloc] initWithFrame: CGRectMake(15, 17,actionWidth,25)];
            label.text = actionName;
            label.font = [UIFont fontWithName:@"Roboto-Condensed" size:20.0];
            label.backgroundColor = [UIColor clearColor];
            [label setUserInteractionEnabled:NO];
            [self addSubview:label];
            
            //Right Three button bar
            
            if (options) {
                
                _button1right1=  [[UIView alloc] initWithFrame: CGRectMake(actionWidth+2*spaceBetween+iconWidth, 0, barWidth, itemHeight/3)];
                [self addSubview:_button1right1];
                _button1right2=  [[UIView alloc] initWithFrame: CGRectMake(actionWidth+2*spaceBetween+iconWidth, itemHeight/3, barWidth, itemHeight/3)];
                [self addSubview:_button1right2];
                _button1right3=  [[UIView alloc] initWithFrame: CGRectMake(actionWidth+2*spaceBetween+iconWidth, 2*itemHeight/3, barWidth, itemHeight/3)];
                [self addSubview:_button1right3];
                
            }
            else {
                _button1right1=  [[UIView alloc] initWithFrame: CGRectMake(actionWidth+2*spaceBetween+iconWidth, 0, barWidth, itemHeight)];
                [self addSubview:_button1right1];
                
            }
            
            //Icon for Action
            /*
            NSString *imageURL= iconUrl;
            NSURL *url = [NSURL URLWithString:imageURL];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *appIcon = [[UIImage alloc] initWithData:data];
            */
            UIImage *appIcon = [UIImage imageNamed:[@"INK.bundle/" stringByAppendingString:iconUrl]];
            UIImageView *appIconbutton = [[UIImageView alloc] initWithFrame:CGRectMake(actionWidth+10, 0, 60, 60)];
            [appIconbutton setUserInteractionEnabled:NO];
            appIconbutton.image = appIcon;
            
            [self setBackgroundImage:[UIImage imageNamed:@"INK.bundle/selected.png"] forState:UIControlStateHighlighted];

            
            [self addSubview:appIconbutton];
            
            
            CGContextRestoreGState(context);
        }
    }

    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIColor* color1 = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:(100.0/100.0)];
    UIColor* color2 = [UIColor colorWithRed:203.0/255.0 green:203.0/255.0 blue:203.0/255.0 alpha:(100.0/100.0)];
    UIColor* color3 = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:(100.0/100.0)];
    UIColor* selected = [UIColor colorWithRed:107.0/255.0 green:107.0/255.0 blue:107.0/255.0 alpha:(100.0/100.0)];
    
    if (self.state == UIControlStateHighlighted) {
        //Main Button
        _button1.backgroundColor = selected;
        
        //Side bar
        _button1right1.backgroundColor = selected;
        _button1right2.backgroundColor = selected;
        _button1right3.backgroundColor = selected;
        
    } else {
        _button1.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:(100.0/100.0)];
        _button1right1.backgroundColor = color1;
        _button1right2.backgroundColor = color2;
        _button1right3.backgroundColor = color3;
    }
}


@end
