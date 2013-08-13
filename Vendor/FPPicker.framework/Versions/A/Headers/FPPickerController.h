//
//  NavigationController.h
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FPExternalHeaders.h"

@interface FPPickerController : UINavigationController <UIImagePickerControllerDelegate, FPSourcePickerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, assign) id <FPPickerDelegate> fpdelegate;
@property (nonatomic, strong) NSArray *sourceNames;
@property (nonatomic, strong) NSArray *dataTypes;

//imagepicker properties
@property (nonatomic) BOOL allowsEditing;
@property (nonatomic) UIImagePickerControllerQualityType videoQuality;
@property (nonatomic) NSTimeInterval videoMaximumDuration;
@property (nonatomic) BOOL showsCameraControls;
@property (nonatomic, strong) UIView *cameraOverlayView;
@property (nonatomic) CGAffineTransform cameraViewTransform;

@property (nonatomic) UIImagePickerControllerCameraDevice cameraDevice;
@property (nonatomic) UIImagePickerControllerCameraFlashMode cameraFlashMode;

@property (nonatomic) BOOL shouldUpload;
@property (nonatomic) BOOL shouldDownload;

@end
