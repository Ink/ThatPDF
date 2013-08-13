//
//  InkLibrary.m
//  Ink
//

#import <Foundation/Foundation.h>

@interface InkLibrary : NSObject


//standard in memory transfers
+ (NSString *) set: (NSData*) data;
+ (NSString *) set: (NSData*) data at:(NSString*)key;
+ (NSData *) get: (NSString*) key;


//background filepath methods. low memory usage
+ (void) runBackgroundProcess;
+ (NSString *) bgSetFromFilePath: (NSString *)filepath;
+ (NSString *) bgSet: (NSData*)data;
+ (void) bgSetProcess;
+ (NSString *) bgGet: (NSString*) key;

@end
