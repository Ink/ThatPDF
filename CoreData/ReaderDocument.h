//
//	ReaderDocument.h
//	Viewer v1.0.0
//
//	Created by Julius Oklamcak on 2012-09-01.
//	Copyright © 2011-2013 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <CoreData/CoreData.h>
#import "AnnotationStore.h"

@class DocumentFolder;

@interface ReaderDocument : NSManagedObject

@property (nonatomic, strong, readwrite) NSString *guid;
@property (nonatomic, strong, readwrite) NSURL *fileURL;
@property (nonatomic, strong, readwrite) NSString *fileName;
@property (nonatomic, strong, readwrite) NSString *filePath;
@property (nonatomic, strong, readwrite) NSString *password;
@property (nonatomic, strong, readwrite) NSNumber *pageCount;
@property (nonatomic, strong, readwrite) NSNumber *pageNumber;
@property (nonatomic, strong, readwrite) NSNumber *fileSize;
@property (nonatomic, strong, readwrite) NSDate *fileDate;
@property (nonatomic, strong, readwrite) NSDate *lastOpen;
@property (nonatomic, strong, readwrite) NSData *tagData;
@property (nonatomic, strong, readwrite) NSManagedObject *folder;
@property (nonatomic, strong, readonly) NSMutableIndexSet *bookmarks;
@property (nonatomic, assign, readwrite) BOOL isChecked;

+ (NSArray *)allInMOC:(NSManagedObjectContext *)inMOC;
+ (NSArray *)allInMOC:(NSManagedObjectContext *)inMOC withName:(NSString *)name;
+ (NSArray *)allInMOC:(NSManagedObjectContext *)inMOC withFolder:(DocumentFolder *)object;
+ (ReaderDocument *)insertInMOC:(NSManagedObjectContext *)inMOC name:(NSString *)name path:(NSString *)path;
+ (void)renameInMOC:(NSManagedObjectContext *)inMOC object:(ReaderDocument *)object name:(NSString *)string;
+ (void)deleteInMOC:(NSManagedObjectContext *)inMOC object:(ReaderDocument *)object fm:(NSFileManager *)fm;
+ (BOOL)existsInMOC:(NSManagedObjectContext *)inMOC name:(NSString *)string;

+ (NSURL*) urlForAnnotatedDocument:(ReaderDocument *)document;

- (void)updateProperties;
- (void)saveReaderDocument;
- (void)saveReaderDocumentWithAnnotations;
- (BOOL)fileExistsAndValid;
- (AnnotationStore*) annotations;

//extern NSString *const ReaderDocumentAddedNotification;
extern NSString *const ReaderDocumentRenamedNotification;
//extern NSString *const ReaderDocumentDeletedNotification;
extern NSString *const ReaderDocumentNotificationObjectID;

@end

@interface ReaderDocument (CoreDataPrimitiveAccessors)

- (NSURL *)primitiveFileURL;
- (void)setPrimitiveFileURL:(NSURL *)url;

@end
