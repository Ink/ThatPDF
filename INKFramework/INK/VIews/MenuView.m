//
//  MenuView.m
//  testView
//
//  Created by Dave Rauchwerk on 6/17/13.
//  Copyright (c) 2013 Dave Rauchwerk. All rights reserved.
//

#import "MenuView.h"
#import "barView.h"
@implementation MenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
                
        CGRect screenRect = [[UIScreen mainScreen] bounds];

     
        
               //[[UIScreen mainScreen] bounds].size.height
        CGFloat actionWidth = 240;
        CGFloat itemHeight = 60;
        CGFloat iconWidth = 60;
        CGFloat barWidth = 15;
        CGFloat spaceBetween = 10;
        CGFloat barHeight = 20;
        CGFloat middleEdge = 350;
        
        CGFloat topBoundary = 200;
        CGFloat topBoundaryLogo = 50;
        CGFloat topBoundarySearch = 500;
        
        barView *bar = [[barView alloc] initWithFrame:(screenRect)];
        bar.backgroundColor = [UIColor clearColor];
        [self addSubview:bar];
        

    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



@end
