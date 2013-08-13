//
//  InkButton.h
//  Touches
//
//  Created by Albert Swantner on 5/13/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InkButton:UIButton;

- (void)setupWithInk:(void (^)(int selection))completion;

@end
