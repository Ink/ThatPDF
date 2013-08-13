//
//	DocumentFolder.h
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

@class ReaderDocument;

typedef enum
{
	DocumentFolderTypeUser = 0,
	DocumentFolderTypeDefault = 1,
	DocumentFolderTypeRecent = 2,
    DocumentFolderTypeSamples = 3
}	DocumentFolderType;

@interface DocumentFolder : NSManagedObject

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSNumber *type;
@property (nonatomic, strong, readwrite) NSSet *documents;
@property (nonatomic, assign, readwrite) BOOL isChecked;

+ (NSArray *)allInMOC:(NSManagedObjectContext *)inMOC;
+ (BOOL)existsInMOC:(NSManagedObjectContext *)inMOC name:(NSString *)string;
+ (BOOL)existsInMOC:(NSManagedObjectContext *)inMOC type:(DocumentFolderType)kind;
+ (DocumentFolder *)folderInMOC:(NSManagedObjectContext *)inMOC type:(DocumentFolderType)kind;
+ (DocumentFolder *)insertInMOC:(NSManagedObjectContext *)inMOC name:(NSString *)string type:(DocumentFolderType)kind;
+ (void)renameInMOC:(NSManagedObjectContext *)inMOC objectID:(NSManagedObjectID *)objectID name:(NSString *)string;
+ (void)deleteInMOC:(NSManagedObjectContext *)inMOC objectID:(NSManagedObjectID *)objectID;

extern NSString *const DocumentFolderAddedNotification;
extern NSString *const DocumentFolderRenamedNotification;
extern NSString *const DocumentFolderDeletedNotification;
extern NSString *const DocumentFolderNotificationObjectID;
extern NSString *const DocumentFoldersDeletedNotification;

@end

@interface DocumentFolder (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(ReaderDocument *)value;
- (void)removeDocumentsObject:(ReaderDocument *)value;
- (void)addDocuments:(NSSet *)value;
- (void)removeDocuments:(NSSet *)value;

@end
