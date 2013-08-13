//
//  INKRightAction.h
//  INK
//
//  Created by Albert Swantner on 6/27/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INKLeftAction : UIButton {
    NSString* iconUrl;
    NSString* actionName;
    NSString* actionColor;

    
}

@property (nonatomic) NSString* iconUrl;
@property (nonatomic) NSString* actionName;
@property (nonatomic) NSString* actionColor;
@property (nonatomic) UIView* button1;

@end
