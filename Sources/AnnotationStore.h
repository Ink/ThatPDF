//
//  AnnotationStore.h
//	ThatPDF v0.3.1
//
//	Created by Brett van Zuiden.
//	Copyright © 2013 Ink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Annotation.h"

@interface AnnotationStore : NSObject

- (id)initWithPageCount:(int)page_count;
- (void) addAnnotation:(Annotation*)annotation toPage:(int)page;
- (void) addPath:(CGPathRef)path withColor:(CGColorRef)color fill:(BOOL)fill toPage:(int)page;
- (void) addText:(NSString*)text inRect:(CGRect)rect withFont:(UIFont*)font toPage:(int)page;
- (void) addCustomAnnotationWithBlock:(CustomAnnotationDrawingBlock)block toPage:(int)page;

- (void) addAnnotations:(AnnotationStore*)annotations;

- (void) undoAnnotationOnPage:(int)page;

- (NSArray*) annotationsForPage:(int)page;
- (void) drawAnnotationsForPage:(int)page inContext:(CGContextRef) context;

- (void)empty;
- (NSInteger) totalNumberOfAnnotations;

@end
