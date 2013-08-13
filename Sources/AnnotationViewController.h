//
//  AnnotationViewController.h
//  Viewer
//
//  Created by Brett van Zuiden on 7/10/13.
//
//

#import <UIKit/UIKit.h>

#import "ReaderDocument.h"
#import "Annotation.h"
#import "ReaderContentView.h"

extern NSString *const AnnotationViewControllerType_None;
extern NSString *const AnnotationViewControllerType_Sign;
extern NSString *const AnnotationViewControllerType_RedPen;
extern NSString *const AnnotationViewControllerType_Text;

@interface AnnotationViewController : UIViewController
@property NSString *annotationType;
@property ReaderDocument *document;
@property NSInteger currentPage;

- (id)initWithDocument:(ReaderDocument *)document;
- (void)moveToPage:(int)page contentView:(ReaderContentView*) view;
- (void) hide;
- (void) clear;
- (void) undo;

- (AnnotationStore*) annotations;

@end