//
//  InkButton.m
//  Touches
//
//  Created by Albert Swantner on 5/13/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "InkButton.h"

typedef void (^ItemSelectedBlock)(int);

static BOOL isOpened = NO;
static UIViewController *popoverViewController;
static UIPopoverController *popover;

@interface InkViewController : UIViewController
{
    ItemSelectedBlock completionBlock;
}

@property(readwrite, copy) ItemSelectedBlock completionBlock;

@end

@implementation InkViewController

@synthesize completionBlock;

- (void)viewDidLoad
{
    
}
+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"INK.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

- (void)viewDidAppear:(BOOL)animated
{
    
  }

- (void)itemSelected:(id)sender
{
    [popover dismissPopoverAnimated:YES];
    
    NSInteger tagId = [sender tag];
    completionBlock(tagId);
    
    NSString *message = [[NSString alloc] initWithFormat:@"Menu Button Selected: %d", tagId];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo" message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
}

@end

@implementation InkButton

- (void)setupWithInk:(void (^)(int selection))completion
{
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(open:)];
    longPressGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:longPressGesture];
    
    InkViewController *popoverViewController = [[InkViewController alloc] init];
    [popoverViewController setCompletionBlock:completion];
    popover = [[UIPopoverController alloc] initWithContentViewController:popoverViewController];
    [popover setPopoverContentSize:CGSizeMake(340, 758)];
}

- (void)open:(id)sender {
    if (isOpened) {
        isOpened = NO;
        return;
    }
    else {
        isOpened = YES;
    }
    
    [popover presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)dealloc
{
    popoverViewController = nil;
    popover = nil;
}

@end
