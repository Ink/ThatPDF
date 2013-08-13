//
//  UIButton+Ink.m
//  INK Workflow Framework
//
//  Created by Jonathan Uy on 5/21/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "UIButton+Ink.h"
#import "InkViewController2.h"
#import "LoadableCategory.h"

static UIPopoverController *popoverUIButton;
static ItemSelectedBlock completionBlockUIButton;
//hack to make compiler include categories in static framework see: https://github.com/kstenerud/iOS-Universal-Framework

MAKE_CATEGORIES_LOADABLE(UIButton_Ink);

@implementation UIButton (Ink)




- (void)inkSetup:(void (^)(int selection))completion
{
    
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(open:)];
    longPressGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:longPressGesture];
    
    completionBlockUIButton = completion;
}

- (void)open:(id)sender
{

    NSLog(@"sender arg %@", sender);

    //create blob
    
    //check actions for blob
    
    //show ink UI
    
    if (!popoverUIButton) {
        InkViewController2 *popoverViewController2;
        popoverViewController2 = [[InkViewController2 alloc] init];
        [popoverViewController2 setCompletionBlock:completionBlockUIButton];
        popoverUIButton = [[UIPopoverController alloc] initWithContentViewController:popoverViewController2];
        [popoverUIButton setPopoverContentSize:CGSizeMake(300, 200)];
        [popoverViewController2 setPopoverRef:popoverUIButton];
    }
    
    if(![popoverUIButton isPopoverVisible]) {
        [popoverUIButton presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


//when user taps action right button
//-create INKAction instance
//-look up action based on button clicked id
//-set +INKaction to action from button
//trigger action


//Background?
//Hide INK UI set state to triggered

- (void)dealloc
{
    popoverUIButton = nil;
}

@end
