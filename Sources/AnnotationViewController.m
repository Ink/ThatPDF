//
//  AnnotationViewController.m
//	ThatPDF v0.3.1
//
//	Created by Brett van Zuiden.
//	Copyright © 2013 Ink. All rights reserved.
//

#import "AnnotationViewController.h"

NSString *const AnnotationViewControllerType_None = @"None";
NSString *const AnnotationViewControllerType_Sign = @"Sign";
NSString *const AnnotationViewControllerType_RedPen = @"RedPen";
NSString *const AnnotationViewControllerType_Text = @"Text";

int const ANNOTATION_IMAGE_TAG = 431;
CGFloat const TEXT_FIELD_WIDTH = 300;
CGFloat const TEXT_FIELD_HEIGHT = 32;

@interface AnnotationViewController ()

@end

@implementation AnnotationViewController {
    CGPoint lastPoint;
    UIImageView *image;
    UIView *pageView;
    CGColorRef annotationColor;
    CGColorRef signColor;
    NSString *_annotationType;
    AnnotationStore *annotationStore;
    //We need both because of the UIBezierPath nonsense
    NSMutableArray *currentPaths;
    CGMutablePathRef currPath;
    
    BOOL didMove;
    
    UITextField *textField;
}

@dynamic annotationType;

- (id) initWithDocument:(ReaderDocument *)readerDocument
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.annotationType = AnnotationViewControllerType_None;
        self.document = readerDocument;
        
        annotationColor = [UIColor redColor].CGColor;
        signColor = [UIColor blackColor].CGColor;
        self.currentPage = 0;
        image = [[UIImageView alloc] initWithImage:nil];
        image.frame = CGRectMake(0,0,100,100); //so we don't error out
        currentPaths = [NSMutableArray array];
        
        annotationStore = [[AnnotationStore alloc] initWithPageCount:[readerDocument.pageCount intValue]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.userInteractionEnabled = ![self.annotationType isEqualToString:AnnotationViewControllerType_None];
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor clearColor];
  
    image = [self createImageView];
    [pageView addSubview:image];

    textField = [self createTextField];
    [pageView addSubview:textField];
}

- (UIImageView*) createImageView {
    UIImageView *temp = [[UIImageView alloc] initWithImage:nil];
    temp.frame = pageView.frame;
    temp.tag = ANNOTATION_IMAGE_TAG;
    return temp;
}

- (UITextField*) createTextField {
    UITextField *temp = [[UITextField alloc] initWithFrame:CGRectMake(400, 400, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT)];
    temp.hidden = YES;
    temp.borderStyle = UITextBorderStyleLine;
    return temp;
}

- (NSString*) annotationType {
    return _annotationType;
}

- (void) setAnnotationType:(NSString *)annotationType {
    //Close current annotation
    [self finishCurrentAnnotation];
    _annotationType = annotationType;
    self.view.userInteractionEnabled = ![self.annotationType isEqualToString:AnnotationViewControllerType_None];
}

- (void) finishCurrentAnnotation {
    Annotation* annotation = [self getCurrentAnnotation];
    if (annotation) {
        [annotationStore addAnnotation:annotation toPage:self.currentPage];
    }
    
    if ([self.annotationType isEqualToString:AnnotationViewControllerType_Text]) {
        [self refreshDrawing];
    }

    textField.hidden = YES;
    [currentPaths removeAllObjects];
    currPath = nil;
}

- (AnnotationStore*) annotations {
    [self finishCurrentAnnotation];
    return annotationStore;
}

- (Annotation*) getCurrentAnnotation {
    if ([self.annotationType isEqualToString:AnnotationViewControllerType_Text]) {
        if (!textField.hidden) {
            [textField resignFirstResponder];
            return [TextAnnotation textAnnotationWithText:textField.text inRect:textField.frame withFont:textField.font];
        }
        return nil;
    }
    
    if (!currPath && [currentPaths count] == 0) {
        return nil;
    }
    
    CGMutablePathRef basePath = CGPathCreateMutable();
    for (UIBezierPath *bpath in currentPaths) {
        CGPathAddPath(basePath, NULL, bpath.CGPath);
    }
    CGPathAddPath(basePath, NULL, currPath);
    
    if ([self.annotationType isEqualToString:AnnotationViewControllerType_RedPen]) {
        return [PathAnnotation pathAnnotationWithPath:basePath color:annotationColor lineWidth:5.0 fill:NO];
    }
    if ([self.annotationType isEqualToString:AnnotationViewControllerType_Sign]) {
        return [PathAnnotation pathAnnotationWithPath:basePath color:signColor lineWidth:3.0 fill:NO];
    }
    return nil;
}

- (void) moveToPage:(int)page contentView:(ReaderContentView*) view {
    if (page != self.currentPage || !pageView) {
        [self finishCurrentAnnotation];
        
        self.currentPage = page;
        
        pageView = [view contentView];
        //Create a new one because the old one may be deallocated or have a deallocated parent
        //First, erase any contents though
        if (image.superview != nil) {
            image.image = nil;
        }
        if (textField.superview != nil) {
            textField.hidden = YES;
        }
        
        image = [self createImageView];
        [pageView addSubview:image];
        textField = [self createTextField];
        [pageView addSubview:textField];
        
        [self refreshDrawing];
    }
}

- (void) clear{
    //Setting up a blank image to start from. This displays the current drawing
    image.image = nil;
    currPath = nil;
    [currentPaths removeAllObjects];
    [annotationStore empty];
}

- (void) hide {
    [self.view removeFromSuperview];
}

- (void) undo {
    //Immediate path
    if (currPath != nil) {
        currPath = nil;
    } else if ([currentPaths count] > 0) {
        //if we have a current path, undo it
        [currentPaths removeLastObject];
    } else {
        //pop from store
        [annotationStore undoAnnotationOnPage:self.currentPage];
    }
    
    [self refreshDrawing];
}

- (void) refreshDrawing {
    UIGraphicsBeginImageContextWithOptions(pageView.frame.size, NO, 1.5f);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //Draw previous paths
    [annotationStore drawAnnotationsForPage:self.currentPage inContext:currentContext];
    
    CGContextSetShouldAntialias(currentContext, YES);
    CGContextSetLineJoin(currentContext, kCGLineJoinRound);
    if ([self.annotationType isEqualToString:AnnotationViewControllerType_RedPen]) {
        //Setup style
        CGContextSetLineCap(currentContext, kCGLineCapRound);
        CGContextSetLineWidth(currentContext, 5.0);
        CGContextSetStrokeColorWithColor(currentContext, annotationColor);
    }
    if ([self.annotationType isEqualToString:AnnotationViewControllerType_Sign]) {
        //Setup style
        CGContextSetLineCap(currentContext, kCGLineCapRound);
        CGContextSetLineWidth(currentContext, 3.0);
        CGContextSetStrokeColorWithColor(currentContext, signColor);
    }
    
    //Draw Paths
    for (UIBezierPath *path in currentPaths) {
        CGContextAddPath(currentContext, path.CGPath);
    }
    
    CGContextAddPath(currentContext, currPath);
    CGContextStrokePath(currentContext);
    
    //Saving
    image.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:pageView];
    
    if ([self.annotationType isEqualToString:AnnotationViewControllerType_Text]) {
        if (textField.hidden) {
            [textField becomeFirstResponder];
        }

        if ([textField pointInside:[touch locationInView:textField] withEvent:nil]) {
            [textField becomeFirstResponder];
        } else {
            textField.frame = CGRectMake(lastPoint.x + 20, lastPoint.y, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT);
        }
        textField.hidden = NO;
    } else {
        if (currPath) {
            [currentPaths addObject:[UIBezierPath bezierPathWithCGPath:currPath]];
        }
        currPath = CGPathCreateMutable();
        
        CGPathMoveToPoint(currPath, NULL, lastPoint.x, lastPoint.y);
        
    }
    didMove = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    didMove = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:pageView];
    
    if ([self.annotationType isEqualToString:AnnotationViewControllerType_Text]) {
        textField.frame = CGRectMake(lastPoint.x + 20, lastPoint.y, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT);
    } else {
        //Update path
        CGPathAddLineToPoint(currPath, NULL, currentPoint.x, currentPoint.y);
        [self refreshDrawing];
    }
    
    lastPoint = currentPoint;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.annotationType isEqualToString:AnnotationViewControllerType_Text]) {
        return;
    }

    if (!didMove) {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:pageView];
        CGPathAddEllipseInRect(currPath, NULL, CGRectMake(currentPoint.x - 2.f, currentPoint.y - 2.f, 4.f, 4.f));
        [self refreshDrawing];
    }
    didMove = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
