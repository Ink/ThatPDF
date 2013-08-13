//
//  barView.m
//  testView
//
//  Created by Dave Rauchwerk on 6/17/13.
//  Copyright (c) 2013 Dave Rauchwerk. All rights reserved.
//

#import "barView.h"

@implementation barView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code


    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    UIColor *color = [UIColor clearColor];
    self.backgroundColor = color;
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 0.546 green: 0.703 blue: 1 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 38.5, 1240, 70)];
    [fillColor setFill];
    [rectanglePath fill];
    [strokeColor setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
    
    
    
 
 }




@end
