//
//  ViewController.m
//  UItest
//
//  Created by Albert Swantner on 6/14/13.
//  Copyright (c) 2013 Albert Swantner. All rights reserved.
//

#import "previewView.h"

@interface previewView ()


@end

@implementation previewView
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
    UIColor* color2 = [UIColor colorWithRed: 0.427 green: 0.427 blue: 0.427 alpha: 1];
    UIColor* color0 = [UIColor colorWithRed: 0.064 green: 0.511 blue: 0.7 alpha: 1];
    UIColor* color1 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Group
    {
        //// SVGID_2_
        {
            CGContextSaveGState(context);
            
            //// Clip Bezier
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint: CGPointMake(0, 0)];
            [bezierPath addLineToPoint: CGPointMake(1024, 0)];
            [bezierPath addLineToPoint: CGPointMake(1024, 768)];
            [bezierPath addLineToPoint: CGPointMake(0, 768)];
            [bezierPath addLineToPoint: CGPointMake(0, 0)];
            [bezierPath closePath];
            [bezierPath addClip];

            
            //// Group 12
            {
                //// SVGID_8_
                {
                    CGContextSaveGState(context);
                    
                    //// Clip Bezier 2
                    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
                    [bezier2Path moveToPoint: CGPointMake(0, 0)];
                    [bezier2Path addLineToPoint: CGPointMake(1024, 0)];
                    [bezier2Path addLineToPoint: CGPointMake(1024, 768)];
                    [bezier2Path addLineToPoint: CGPointMake(0, 768)];
                    [bezier2Path addLineToPoint: CGPointMake(0, 0)];
                    [bezier2Path closePath];
                    [bezier2Path addClip];
                    
                    
                    //// Bezier 3 Drawing
                    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
                    [bezier3Path moveToPoint: CGPointMake(341, 224.87)];
                    [bezier3Path addLineToPoint: CGPointMake(598, 224.87)];
                    [bezier3Path addLineToPoint: CGPointMake(598, 563.18)];
                    [bezier3Path addLineToPoint: CGPointMake(341, 563.18)];
                    [bezier3Path addLineToPoint: CGPointMake(341, 224.87)];
                    [bezier3Path closePath];
                    bezier3Path.miterLimit = 4;
                    
                    [color0 setFill];
                    [bezier3Path fill];
                    
                    
                    CGContextRestoreGState(context);
                }
            }
            
            
            //// Group 16
            {
                //// SVGID_14_
                {
                    CGContextSaveGState(context);
                    
                    //// Clip Bezier 4
                    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
                    [bezier4Path moveToPoint: CGPointMake(0, 0)];
                    [bezier4Path addLineToPoint: CGPointMake(1024, 0)];
                    [bezier4Path addLineToPoint: CGPointMake(1024, 768)];
                    [bezier4Path addLineToPoint: CGPointMake(0, 768)];
                    [bezier4Path addLineToPoint: CGPointMake(0, 0)];
                    [bezier4Path closePath];
                    [bezier4Path addClip];
                    
                    
                    //// Bezier 5 Drawing
                    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
                    [bezier5Path moveToPoint: CGPointMake(591.28, 579.85)];
                    [bezier5Path addCurveToPoint: CGPointMake(593.93, 582.43) controlPoint1: CGPointMake(593.04, 579.85) controlPoint2: CGPointMake(593.93, 581.06)];
                    [bezier5Path addCurveToPoint: CGPointMake(590.4, 585.74) controlPoint1: CGPointMake(593.93, 584.15) controlPoint2: CGPointMake(592.39, 585.74)];
                    [bezier5Path addCurveToPoint: CGPointMake(587.79, 583.12) controlPoint1: CGPointMake(588.72, 585.74) controlPoint2: CGPointMake(587.75, 584.75)];
                    [bezier5Path addCurveToPoint: CGPointMake(591.28, 579.85) controlPoint1: CGPointMake(587.79, 581.74) controlPoint2: CGPointMake(588.95, 579.85)];
                    [bezier5Path closePath];
                    [bezier5Path moveToPoint: CGPointMake(585.84, 606.23)];
                    [bezier5Path addCurveToPoint: CGPointMake(584.4, 601.58) controlPoint1: CGPointMake(584.44, 606.23) controlPoint2: CGPointMake(583.42, 605.37)];
                    [bezier5Path addLineToPoint: CGPointMake(586, 594.87)];
                    [bezier5Path addCurveToPoint: CGPointMake(586, 593.36) controlPoint1: CGPointMake(586.28, 593.79) controlPoint2: CGPointMake(586.32, 593.36)];
                    [bezier5Path addCurveToPoint: CGPointMake(582.7, 594.84) controlPoint1: CGPointMake(585.58, 593.36) controlPoint2: CGPointMake(583.77, 594.11)];
                    [bezier5Path addLineToPoint: CGPointMake(582, 593.68)];
                    [bezier5Path addCurveToPoint: CGPointMake(590.97, 589.1) controlPoint1: CGPointMake(585.4, 590.79) controlPoint2: CGPointMake(589.3, 589.1)];
                    [bezier5Path addCurveToPoint: CGPointMake(591.9, 593.36) controlPoint1: CGPointMake(592.37, 589.1) controlPoint2: CGPointMake(592.6, 590.78)];
                    [bezier5Path addLineToPoint: CGPointMake(590.07, 600.42)];
                    [bezier5Path addCurveToPoint: CGPointMake(590.21, 602.1) controlPoint1: CGPointMake(589.74, 601.67) controlPoint2: CGPointMake(589.88, 602.1)];
                    [bezier5Path addCurveToPoint: CGPointMake(593.35, 600.51) controlPoint1: CGPointMake(590.63, 602.1) controlPoint2: CGPointMake(592, 601.58)];
                    [bezier5Path addLineToPoint: CGPointMake(594.14, 601.58)];
                    [bezier5Path addCurveToPoint: CGPointMake(585.84, 606.23) controlPoint1: CGPointMake(590.84, 604.94) controlPoint2: CGPointMake(587.23, 606.23)];
                    [bezier5Path closePath];
                    bezier5Path.miterLimit = 4;
                    
                    [color1 setFill];
                    [bezier5Path fill];
                    
                    
                    //// Bezier 6 Drawing
                    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
                    [bezier6Path moveToPoint: CGPointMake(463.86, 372.18)];
                    [bezier6Path addLineToPoint: CGPointMake(458.71, 372.18)];
                    [bezier6Path addLineToPoint: CGPointMake(458.71, 382.47)];
                    [bezier6Path addLineToPoint: CGPointMake(448.41, 382.47)];
                    [bezier6Path addLineToPoint: CGPointMake(448.41, 387.62)];
                    [bezier6Path addLineToPoint: CGPointMake(458.71, 387.62)];
                    [bezier6Path addLineToPoint: CGPointMake(458.71, 397.91)];
                    [bezier6Path addLineToPoint: CGPointMake(463.86, 397.91)];
                    [bezier6Path addLineToPoint: CGPointMake(463.86, 387.62)];
                    [bezier6Path addLineToPoint: CGPointMake(474.15, 387.62)];
                    [bezier6Path addLineToPoint: CGPointMake(474.15, 382.47)];
                    [bezier6Path addLineToPoint: CGPointMake(463.86, 382.47)];
                    [bezier6Path addLineToPoint: CGPointMake(463.86, 372.18)];
                    [bezier6Path closePath];
                    [bezier6Path moveToPoint: CGPointMake(484.25, 401.6)];
                    [bezier6Path addCurveToPoint: CGPointMake(489.6, 385.04) controlPoint1: CGPointMake(487.61, 396.94) controlPoint2: CGPointMake(489.6, 391.22)];
                    [bezier6Path addCurveToPoint: CGPointMake(461.28, 356.73) controlPoint1: CGPointMake(489.6, 369.41) controlPoint2: CGPointMake(476.92, 356.73)];
                    [bezier6Path addCurveToPoint: CGPointMake(432.97, 385.04) controlPoint1: CGPointMake(445.64, 356.73) controlPoint2: CGPointMake(432.97, 369.41)];
                    [bezier6Path addCurveToPoint: CGPointMake(461.28, 413.35) controlPoint1: CGPointMake(432.97, 400.68) controlPoint2: CGPointMake(445.64, 413.35)];
                    [bezier6Path addCurveToPoint: CGPointMake(477.84, 408.01) controlPoint1: CGPointMake(467.47, 413.35) controlPoint2: CGPointMake(473.18, 411.37)];
                    [bezier6Path addLineToPoint: CGPointMake(495.02, 428.65)];
                    [bezier6Path addLineToPoint: CGPointMake(505.31, 418.35)];
                    [bezier6Path addLineToPoint: CGPointMake(484.25, 401.6)];
                    [bezier6Path closePath];
                    [bezier6Path moveToPoint: CGPointMake(461.28, 405.63)];
                    [bezier6Path addCurveToPoint: CGPointMake(440.69, 385.04) controlPoint1: CGPointMake(449.91, 405.63) controlPoint2: CGPointMake(440.69, 396.41)];
                    [bezier6Path addCurveToPoint: CGPointMake(461.28, 364.45) controlPoint1: CGPointMake(440.69, 373.67) controlPoint2: CGPointMake(449.91, 364.45)];
                    [bezier6Path addCurveToPoint: CGPointMake(481.87, 385.04) controlPoint1: CGPointMake(472.66, 364.45) controlPoint2: CGPointMake(481.87, 373.67)];
                    [bezier6Path addCurveToPoint: CGPointMake(461.28, 405.63) controlPoint1: CGPointMake(481.87, 396.41) controlPoint2: CGPointMake(472.66, 405.63)];
                    [bezier6Path closePath];
                    bezier6Path.miterLimit = 4;
                    
                    [color2 setFill];
                    [bezier6Path fill];
                    
                    
                    CGContextRestoreGState(context);
                }
            }
            
            
            CGContextRestoreGState(context);
        }
    }

}


@end
