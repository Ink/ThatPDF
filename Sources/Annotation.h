//
//  Annotation.h
//  Viewer
//
//  Created by Brett van Zuiden on 7/9/13.
//
//

#import <Foundation/Foundation.h>

typedef void (^CustomAnnotationDrawingBlock)(CGContextRef);

@interface Annotation : NSObject

- (void) drawInContext:(CGContextRef) context;

@end

@interface CustomAnnotation : Annotation
@property (readwrite, copy) CustomAnnotationDrawingBlock block;
+ (id)customAnnotationWithBlock:(CustomAnnotationDrawingBlock)block;
@end;

@interface TextAnnotation : Annotation
@property NSString *text;
@property CGRect rect;
@property UIFont *font;

+ (id)textAnnotationWithText:(NSString*)text inRect:(CGRect)rect withFont:(UIFont*)font;
@end

@interface PathAnnotation: Annotation
@property CGPathRef path;
@property CGColorRef color;
@property BOOL fill;
@property CGFloat lineWidth;
+ (id) pathAnnotationWithPath:(CGPathRef)path color:(CGColorRef)color fill:(BOOL)fill;
+ (id) pathAnnotationWithPath:(CGPathRef)path color:(CGColorRef)color lineWidth:(CGFloat)width fill:(BOOL)fill;
@end

