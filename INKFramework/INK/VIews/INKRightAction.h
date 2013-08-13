//
//  INKRightAction.h
//  INK
//
//  Created by Albert Swantner on 6/27/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INKRightAction : UIButton {
    NSString* iconUrl;
    NSString* actionName;
    BOOL options;
    
}

@property (nonatomic) NSString* iconUrl;
@property (nonatomic) NSString* actionName;
@property (nonatomic) BOOL options;
@property (nonatomic) UIView* button1;
@property (nonatomic) UIView* button1right1;
@property (nonatomic) UIView* button1right2;
@property (nonatomic) UIView* button1right3;


@end
