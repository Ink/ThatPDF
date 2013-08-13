//
//  ViewController.m
//  UItest
//
//  Created by Albert Swantner on 6/14/13.
//  Copyright (c) 2013 Albert Swantner. All rights reserved.
//

#import "InkHeader.h"

@interface InkHeader ()


@end

@implementation InkHeader

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
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color0 = [UIColor colorWithRed: 0.064 green: 0.511 blue: 0.7 alpha: 1];
    UIColor* color1 = [UIColor colorWithRed: 0.072 green: 0.575 blue: 0.773 alpha: 1];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.width;


    if (width == 768) {
        
        {
            //// SVGID_2_
            {
                CGContextSaveGState(context);
                
                //// Clip Bezier
                UIBezierPath* bezierPath = [UIBezierPath bezierPath];
                [bezierPath moveToPoint: CGPointMake(0, 0)];
                [bezierPath addLineToPoint: CGPointMake(width, 0)];
                [bezierPath addLineToPoint: CGPointMake(width, height)];
                [bezierPath addLineToPoint: CGPointMake(0, height)];
                [bezierPath addLineToPoint: CGPointMake(0, 0)];
                [bezierPath closePath];
                [bezierPath addClip];
                
                
                //// Group 3
                {
                    //// SVGID_4_
                    {
                        CGContextSaveGState(context);
                        
                        //// Clip Bezier 2
                        UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
                        [bezier2Path moveToPoint: CGPointMake(0, 0)];
                        [bezier2Path addLineToPoint: CGPointMake(width, 0)];
                        [bezier2Path addLineToPoint: CGPointMake(width, height)];
                        [bezier2Path addLineToPoint: CGPointMake(0, height)];
                        [bezier2Path addLineToPoint: CGPointMake(0, 0)];
                        [bezier2Path closePath];
                        [bezier2Path addClip];
                        
                        
                        //// Rectangle Drawing
                        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 590, width, 65)];
                        [color1 setFill];
                        [rectanglePath fill];
                        
                        CGContextRestoreGState(context);
                    }
                }
                
                
                CGContextRestoreGState(context);
            }
        }
        
        UILabel *label =  [[UILabel alloc] initWithFrame: CGRectMake(0, 0,100,25)];
        label.text = @"test";
        label.font = [UIFont fontWithName:@"Roboto-Condensed" size:24.0];
        label.backgroundColor = [UIColor clearColor];
        [label setUserInteractionEnabled:NO];
        [self addSubview:label];
        
    }
    else {
        {
            //// SVGID_2_
            {
                CGContextSaveGState(context);
                
                //// Clip Bezier
                UIBezierPath* bezierPath = [UIBezierPath bezierPath];
                [bezierPath moveToPoint: CGPointMake(0, 0)];
                [bezierPath addLineToPoint: CGPointMake(width, 0)];
                [bezierPath addLineToPoint: CGPointMake(width, height)];
                [bezierPath addLineToPoint: CGPointMake(0, height)];
                [bezierPath addLineToPoint: CGPointMake(0, 0)];
                [bezierPath closePath];
                [bezierPath addClip];
                
                
                //// Group 3
                {
                    //// SVGID_4_
                    {
                        CGContextSaveGState(context);
                        
                        //// Clip Bezier 2
                        UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
                        [bezier2Path moveToPoint: CGPointMake(0, 0)];
                        [bezier2Path addLineToPoint: CGPointMake(width, 0)];
                        [bezier2Path addLineToPoint: CGPointMake(width, height)];
                        [bezier2Path addLineToPoint: CGPointMake(0, height)];
                        [bezier2Path addLineToPoint: CGPointMake(0, 0)];
                        [bezier2Path closePath];
                        [bezier2Path addClip];
                        
                        
                        //// Bezier 3 Drawing
                        UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
                        [bezier3Path moveToPoint: CGPointMake(width - 102, 140)];
                        [bezier3Path addLineToPoint: CGPointMake(216.52, 140)];
                        [bezier3Path addLineToPoint: CGPointMake(189.57, 101)];
                        [bezier3Path addLineToPoint: CGPointMake(210.9, 75)];
                        [bezier3Path addLineToPoint: CGPointMake(width - 102, 75)];
                        [bezier3Path addLineToPoint: CGPointMake(width - 102, 147)];
                        [bezier3Path closePath];
                        bezier3Path.miterLimit = 4;
                        
                        [color0 setFill];
                        [bezier3Path fill];
                        
                        
                        //// Rectangle Drawing
                        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 75, 75, 65)];
                        [color1 setFill];
                        [rectanglePath fill];
                        
                        //// Rectangle Drawing
                        UIBezierPath* rightrectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(width - 22, 75, 15, 65)];
                        [color0 setFill];
                        [rightrectanglePath fill];
                        
                        
                        CGContextRestoreGState(context);
                    }
                }
                
                
                CGContextRestoreGState(context);
            }
        }
        
        UILabel *label =  [[UILabel alloc] initWithFrame: CGRectMake(0, 0,100,25)];
        label.text = @"test";
        label.font = [UIFont fontWithName:@"Roboto-Condensed" size:24.0];
        label.backgroundColor = [UIColor clearColor];
        [label setUserInteractionEnabled:NO];
        [self addSubview:label];
        
        
    }
    //// Group
}


@end