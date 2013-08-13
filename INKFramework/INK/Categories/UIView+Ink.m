//
//  UIImageView+Ink.m
//  INK Workflow Framework
//
//  Created by Jonathan Uy on 5/17/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//
#import "UIView+Ink.h"
#import "LoadableCategoryUIView.h"
#import "RNBlurModalView.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
#import "TMCache.h"
#import <objc/runtime.h>
#import "InkCore.h"
#import "INKViewController.h"
#import "INKManager.h"
#import "InkOverallView.h"


//static UIPopoverController *popoverUIImageView;
//static ItemSelectedBlock completionBlockUIImageView;
static char const * const ObjectTagKey = "ObjectTag";
static char const * const UTITagKey = "UTITag";
static char const * const ReturnBlockTagKey = "ReturnBlockTag";


MAKE_CATEGORIES_LOADABLE(UIView_Ink);

@implementation UIView (Ink)

@dynamic objectTag,UTITag ;

//Use Associative Refrences to store the TMCache Key for the NSCoding encoded object related to the instance of a UIView - http://oleb.net/blog/2011/05/faking-ivars-in-objc-categories-with-associative-references/

- (id)objectTag {
    return objc_getAssociatedObject(self, ObjectTagKey);
}

- (void)setObjectTag:(id)newObjectTag {
    objc_setAssociatedObject(self, ObjectTagKey, newObjectTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)UTITag {
    return objc_getAssociatedObject(self, UTITagKey);
}

- (void)setUTITag:(id)newUTITag{
    objc_setAssociatedObject(self, UTITagKey, newUTITag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)returnBlockTag {
    return objc_getAssociatedObject(self, ReturnBlockTagKey);
}

- (void)setReturnBlockTag:(id)newReturnBlockTag {
    objc_setAssociatedObject(self, ReturnBlockTagKey, newReturnBlockTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) INKEnable:(INKBlob *(^)(void))Block withUTI:(NSString *)UTI {
    [self INKEnable:Block withUTI:UTI onReturn:nil];
}

- (void) INKEnable:(INKBlob *(^)(void))Block withUTI:(NSString *)UTI onReturn:(void *(^)(INKAction *returnAction))ReturnBlock
{
    
    [self setObjectTag:Block];
    [self setUTITag:UTI];
    [self setReturnBlockTag:ReturnBlock];
    NSLog(@"ref created");
    self.userInteractionEnabled = YES;
    //The target of this LP gesture should be the main INKView controller
    UITapGestureRecognizer *dblTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openINKUI:)];
    dblTapGesture.numberOfTouchesRequired = 2;
    dblTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:dblTapGesture];
    NSLog(@" inksetup run");
    
}



- (void)openINKUI:(UITapGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        NSString *tagS = [NSString alloc];
        tagS = self.UTITag;
        NSLog(tagS);
        INKBlob * (^blobBlock)(void) = self.objectTag;
        
        //NSMutableArray *blobArray = [INKAction actionsForB];
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        //STYLE - The INKViewController should be used here to coordinate the view presentation.  This category should simply act as a proxy to the INKViewController methods.
       
        INKBlob *blobT = blobBlock();
        InkOverallView *INKViewC = [[InkOverallView alloc] initWithFrame:(frame)];
        INKViewC.actionList = [INKAction actionsForB];
        //TODO:
        INKViewC.leftActionList = [INKAction leftActionsForB];
        INKViewC.currentBlob =  blobT;
        //RNBlurModalView *modal = [[RNBlurModalView alloc] initWithView:(INKViewC)];
       
        INKManager *sharedManager = [INKManager sharedManager];
        
        [sharedManager.sharedModal initWithView:(INKViewC)];
        [sharedManager.sharedModal hideCloseButton:YES];
        [sharedManager.sharedModal show];
        //[modal show];
            
    }
    
    else {
        
        NSLog(@"Long press end or change detected.");
        
    }
    
    
}

@end
