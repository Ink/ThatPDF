//
//  INKManager.h
//  INK
//
//  Created by Dave Rauchwerk on 7/7/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//
#import "RNBlurModalView.h"
@interface INKManager : NSObject {
    UIViewController *inkViewMain;
}

@property (nonatomic, retain) UIViewController *inkViewMain;
@property (nonatomic, retain) RNBlurModalView *sharedModal;

+ (id)sharedManager;

@end
