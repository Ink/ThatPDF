//
//  AnnotationStore.h
//  Viewer
//
//  Created by Brett van Zuiden on 7/9/13.
//
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

@end
