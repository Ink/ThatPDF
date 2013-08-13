//
//  UIButton+Ink.h
//  INK Workflow Framework
//
//  Created by Jonathan Uy on 5/21/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Ink)

- (void)inkSetup:(void (^)(int selection))completion;

@end
