//
//  InkButtonsViewController.h
//  UItest
//
//  Created by Albert Swantner on 6/14/13.
//  Copyright (c) 2013 Albert Swantner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "InkCore.h"

@interface InkOverallView : UIView <QLPreviewControllerDataSource, QLPreviewControllerDelegate> {
    int currentPreviewIndex;
}

@property (nonatomic) NSMutableArray* actionList;
@property (nonatomic) NSMutableArray* leftActionList;
@property (nonatomic) INKBlob * currentBlob;

@end
