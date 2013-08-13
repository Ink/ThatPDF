//
//	ReaderDocument.m
//	Viewer v1.0.1
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

#import "ReaderDocument.h"
#import "DocumentFolder.h"
#import "ReaderThumbCache.h"
#import "CGPDFDocument.h"
#import "AnnotationStore.h"

#import <fcntl.h>

@implementation ReaderDocument
{
	NSMutableIndexSet *_bookmarks;
    AnnotationStore *_annotations;
}

#pragma mark Constants

#define kReaderDocument @"ReaderDocument"

#pragma mark Properties

@dynamic guid;
@dynamic fileURL;
@dynamic fileName;
@dynamic filePath;
@dynamic password;
@dynamic pageCount;
@dynamic pageNumber;
@dynamic fileSize;
@dynamic fileDate;
@dynamic lastOpen;
@dynamic tagData;
@dynamic folder;
@dynamic bookmarks;
@synthesize isChecked;

#pragma mark ReaderDocument class methods

+ (NSString *)GUID
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);

	CFStringRef theString = CFUUIDCreateString(NULL, theUUID);

	NSString *unique = [NSString stringWithString:(__bridge id)theString];

	CFRelease(theString); CFRelease(theUUID); // Cleanup CF objects

	return unique;
}

+ (NSString *)applicationPath
{
	static dispatch_once_t predicate = 0;

	static NSString *applicationPath = nil; // Application path string

	dispatch_once(&predicate, // Thread-safe create copy of the application path the first time it is needed
	^{
		NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

		applicationPath = [[[documentsPaths objectAtIndex:0] stringByDeletingLastPathComponent] copy]; // Strip "Documents"
	});

	return applicationPath;
}

+ (NSString *)relativeFilePath:(NSString *)fullFilePath
{
	assert(fullFilePath != nil); // Ensure that the full file path is not nil

	NSString *applicationPath = [ReaderDocument applicationPath]; // Get the application path

	NSRange range = [fullFilePath rangeOfString:applicationPath]; // Look for the application path

	assert(range.location != NSNotFound); // Ensure that the application path is in the full file path

	return [fullFilePath stringByReplacingCharactersInRange:range withString:@""]; // Strip it out
}

#pragma mark ReaderDocument Core Data class methods

+ (NSArray *)allInMOC:(NSManagedObjectContext *)inMOC
{
	assert(inMOC != nil); // Check parameter

	NSFetchRequest *request = [NSFetchRequest new]; // Fetch request instance

	[request setEntity:[NSEntityDescription entityForName:kReaderDocument inManagedObjectContext:inMOC]];

	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES];

	[request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]]; // Sort order

	[request setReturnsObjectsAsFaults:YES]; [request setFetchBatchSize:32]; // Optimize fetch

	__autoreleasing NSError *error = nil; // Error information object

	NSArray *objectList = [inMOC executeFetchRequest:request error:&error];

	if (objectList == nil) { NSLog(@"%s %@", __FUNCTION__, error); assert(NO); }

	return objectList;
}

+ (NSArray *)allInMOC:(NSManagedObjectContext *)inMOC withName:(NSString *)name
{
	assert(inMOC != nil); assert(name != nil); // Check parameters

	NSFetchRequest *request = [NSFetchRequest new]; // Fetch request instance

	[request setEntity:[NSEntityDescription entityForName:kReaderDocument inManagedObjectContext:inMOC]];

	[request setPredicate:[NSPredicate predicateWithFormat:@"fileName == %@", name]]; // Matching file name

	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES];

	[request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]]; // Sort order

	[request setReturnsObjectsAsFaults:YES]; [request setFetchBatchSize:32]; // Optimize fetch

	__autoreleasing NSError *error = nil; // Error information object

	NSArray *objectList = [inMOC executeFetchRequest:request error:&error];

	if (objectList == nil) { NSLog(@"%s %@", __FUNCTION__, error); assert(NO); }

	return objectList;
}

+ (NSArray *)allInMOC:(NSManagedObjectContext *)inMOC withFolder:(DocumentFolder *)object
{
	assert(inMOC != nil); assert(object != nil); // Check parameters

	NSPredicate *predicate = nil; NSSortDescriptor *sortDescriptor = nil;

	switch ([object.type integerValue]) // Document folder type
	{
        case DocumentFolderTypeSamples:
		case DocumentFolderTypeUser: // User folder type
		{
			predicate = [NSPredicate predicateWithFormat:@"folder == %@", object]; // Folder
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES];
			break;
		}

		case DocumentFolderTypeDefault: // Default folder type
		{
			predicate = [NSPredicate predicateWithFormat:@"folder == %@", NULL]; // No folder
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES];
			break;
		}

		case DocumentFolderTypeRecent: // Recent folder type
		{
			NSDate *since = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0];
			predicate = [NSPredicate predicateWithFormat:@"lastOpen > %@", since]; // Opened
			sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastOpen" ascending:NO];
			break;
		}
	}

	NSFetchRequest *request = [NSFetchRequest new]; // Fetch request instance

	[request setEntity:[NSEntityDescription entityForName:kReaderDocument inManagedObjectContext:inMOC]];

	[request setPredicate:predicate]; [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

	[request setReturnsObjectsAsFaults:YES]; [request setFetchBatchSize:32]; // Optimize fetch request

	__autoreleasing NSError *error = nil; // Error information object

	NSArray *objectList = [inMOC executeFetchRequest:request error:&error];

	if (objectList == nil) { NSLog(@"%s %@", __FUNCTION__, error); assert(NO); }

	return objectList;
}

+ (ReaderDocument *)insertInMOC:(NSManagedObjectContext *)inMOC name:(NSString *)name path:(NSString *)path
{
	assert(inMOC != nil); assert(name != nil); assert(path != nil); // Check parameters

	ReaderDocument *object = [NSEntityDescription insertNewObjectForEntityForName:kReaderDocument inManagedObjectContext:inMOC];

	if ((object != nil) && ([object isMemberOfClass:[ReaderDocument class]])) // We have a valid ReaderDocument object
	{
		object.fileName = name; // Document file name

		object.guid = [ReaderDocument GUID]; // Document GUID

		object.pageNumber = [NSNumber numberWithInteger:1]; // Start on page 1

		object.filePath = [ReaderDocument relativeFilePath:path]; // Relative path to file

		object.lastOpen = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0]; // Last opened

		object.fileDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0]; // File date

		object.fileSize = [NSNumber numberWithUnsignedLongLong:0ull]; // File size
	}

	return object;
}

+ (void)renameInMOC:(NSManagedObjectContext *)inMOC object:(ReaderDocument *)object name:(NSString *)string
{
	assert(inMOC != nil); assert(object != nil); assert(string != nil); // Check parameters

	NSString *applicationPath = [ReaderDocument applicationPath]; // Application path

	NSString *fullPath = [applicationPath stringByAppendingPathComponent:object.filePath];

	NSString *oldFilePath = [fullPath stringByAppendingPathComponent:object.fileName];

	NSString *newFilePath = [fullPath stringByAppendingPathComponent:string];

	__autoreleasing NSError *error = nil; // Error information object

	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	BOOL status = [fileManager moveItemAtPath:oldFilePath toPath:newFilePath error:&error];

	if (status == YES) // Check rename status
	{
		object.fileURL = nil; // Clear file URL

		object.fileName = string; // New file name

		if ([inMOC hasChanges] == YES) // Save changes
		{
			if ([inMOC save:&error] == YES) // Did save changes
			{
				NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[object objectID] forKey:ReaderDocumentNotificationObjectID];

				[notificationCenter postNotificationName:ReaderDocumentRenamedNotification object:nil userInfo:userInfo];
			}
			else // Log any errors
			{
				NSLog(@"%s %@", __FUNCTION__, error); assert(NO);
			}
		}
	}
	else // Rename failed
	{
		NSLog(@"%s %@", __FUNCTION__, error);
	}
}

+ (void)deleteInMOC:(NSManagedObjectContext *)inMOC object:(ReaderDocument *)object fm:(NSFileManager *)fm
{
	assert(inMOC != nil); assert(object != nil); assert(fm != nil); // Check parameters

	[ReaderThumbCache removeThumbCacheWithGUID:object.guid]; // Delete the thumb cache

	[fm removeItemAtURL:object.fileURL error:NULL]; // Delete the document file

	[inMOC deleteObject:object]; // Delete the object
}

+ (BOOL)existsInMOC:(NSManagedObjectContext *)inMOC name:(NSString *)string
{
	assert(inMOC != nil); assert(string != nil); // Check parameters

	NSFetchRequest *request = [NSFetchRequest new]; // Fetch request instance

	[request setEntity:[NSEntityDescription entityForName:kReaderDocument inManagedObjectContext:inMOC]];

	[request setPredicate:[NSPredicate predicateWithFormat:@"fileName == %@", string]]; // Name predicate

	__autoreleasing NSError *error = nil; // Error information object

	NSUInteger count = [inMOC countForFetchRequest:request error:&error];

	if (error != nil) { NSLog(@"%s %@", __FUNCTION__, error); assert(NO); }

	return ((count > 0) ? YES : NO);
}

#pragma mark ReaderDocument Core Data instance methods

- (NSURL *)fileURL
{
	[self willAccessValueForKey:@"fileURL"];

	NSURL *theURL = [self primitiveFileURL];

	[self didAccessValueForKey:@"fileURL"];

	if (theURL == nil) // Create the file URL when needed
	{
		NSString *applicationPath = [ReaderDocument applicationPath]; // Application path

		NSString *fullPath = [applicationPath stringByAppendingPathComponent:self.filePath];

		theURL = [NSURL fileURLWithPath:[fullPath stringByAppendingPathComponent:self.fileName]];

		[self setPrimitiveFileURL:theURL]; // Store the file URL for later use
	}

	return theURL;
}

- (void)setFileURL:(NSURL *)theURL
{
	[self willChangeValueForKey:@"fileURL"];

	[self setPrimitiveValue:theURL forKey:@"fileURL"];

	[self didChangeValueForKey:@"fileURL"];
}

- (NSMutableIndexSet *)bookmarks
{
	if (_bookmarks == nil) // Create on first access
	{
		if (self.tagData != nil) // Unarchive tag (bookmarks) data
		{
			NSIndexSet *set = [NSKeyedUnarchiver unarchiveObjectWithData:self.tagData];

			if ((set != nil) && [set isKindOfClass:[NSIndexSet class]]) // Validate
			{
				_bookmarks = [set mutableCopy]; // Mutable copy of index set
			}
		}

		if (_bookmarks == nil) // Create bookmarks set
		{
			_bookmarks = [NSMutableIndexSet new];
		}
	}

	return _bookmarks;
}

- (void)updateProperties
{
	CFURLRef docURLRef = (__bridge CFURLRef)self.fileURL; // File URL

	CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateWithURL(docURLRef);

	if (thePDFDocRef != NULL) // Get the number of pages in the document
	{
		NSInteger pageCount = CGPDFDocumentGetNumberOfPages(thePDFDocRef);
        _annotations = [[AnnotationStore alloc] initWithPageCount:pageCount];
		self.pageCount = [NSNumber numberWithInteger:pageCount];

		CGPDFDocumentRelease(thePDFDocRef); // Cleanup
	}

	NSString *fullFilePath = [self.fileURL path]; // Full file path

	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fullFilePath error:NULL];

	self.fileDate = [fileAttributes objectForKey:NSFileModificationDate]; // File date

	self.fileSize = [fileAttributes objectForKey:NSFileSize]; // File size
}

- (void)saveReaderDocument
{
	if (_bookmarks != nil) // Archive bookmarks (tag) data
	{
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_bookmarks];

		if ([self.tagData isEqualToData:data] == NO) self.tagData = data;
	}

	NSManagedObjectContext *saveMOC = self.managedObjectContext;

	if (saveMOC != nil) // Save managed object context
	{
		if ([saveMOC hasChanges] == YES) // Save changes
		{
			__autoreleasing NSError *error = nil; // Error information object

			if ([saveMOC save:&error] == NO) // Log any errors
			{
				NSLog(@"%s %@", __FUNCTION__, error); assert(NO);
			}
		}
	}
}

- (void)saveReaderDocumentWithAnnotations {
    NSURL *annotatedDocURL = [ReaderDocument urlForAnnotatedDocument:self];
    [[NSFileManager defaultManager] replaceItemAtURL:self.fileURL withItemAtURL:annotatedDocURL backupItemName:nil options:0 resultingItemURL:nil error:nil];

    [self saveReaderDocument];
}

- (BOOL)fileExistsAndValid
{
	BOOL state = NO; // Status

	if (self.isDeleted == NO) // Not deleted
	{
		NSString *filePath = [self.fileURL path]; // Path

		const char *path = [filePath fileSystemRepresentation];

		int fd = open(path, O_RDONLY); // Open the file

		if (fd > 0) // We have a valid file descriptor
		{
			const char sig[1024]; // File signature buffer

			ssize_t len = read(fd, (void *)&sig, sizeof(sig));

			state = (strnstr(sig, "%PDF", len) != NULL);

			close(fd); // Close the file
		}
	}

	return state;
}

- (void)willTurnIntoFault
{
	_bookmarks = nil; self.isChecked = NO;
}

#pragma mark Annotations code
- (AnnotationStore*) annotations {
    if (!_annotations) {
        _annotations = [[AnnotationStore alloc] initWithPageCount:[self.pageCount intValue]];
    }
    return _annotations;
}

+ (NSURL*) urlForAnnotatedDocument:(ReaderDocument *)document
{
    CGPDFDocumentRef doc = CGPDFDocumentCreateX((__bridge CFURLRef)document.fileURL, document.password);
    
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:@"annotated.pdf"];
    //CGRectZero means the default page size is 8.5x11
    //We don't care about the default anyway, because we set each page to be a specific size
    UIGraphicsBeginPDFContextToFile(tempPath, CGRectZero, nil);
    
    //Iterate over each page - 1-based indexing (obnoxious...)
    int pages = [document.pageCount intValue];
    for (int i = 1; i <= pages; i++) {
        CGPDFPageRef page = CGPDFDocumentGetPage (doc, i); // grab page i of the PDF
        CGRect bounds = [ReaderDocument boundsForPDFPage:page];
        
        //Create a new page
        UIGraphicsBeginPDFPageWithInfo(bounds, nil);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        // flip context so page is right way up
        CGContextTranslateCTM(context, 0, bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawPDFPage (context, page); // draw the page into graphics context
        
        //Annotations
        NSArray *annotations = [document.annotations annotationsForPage:i];
        if (annotations) {
            NSLog(@"Writing %d annotations", [annotations count]);
            //Flip back right-side up
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextTranslateCTM(context, 0, -bounds.size.height);
            
            for (Annotation *anno in annotations) {
                [anno drawInContext:context];
            }
        }
    }
    
    UIGraphicsEndPDFContext();
    
    CGPDFDocumentRelease (doc);
    
    return [NSURL fileURLWithPath:tempPath];
}

+ (CGRect) boundsForPDFPage:(CGPDFPageRef) page{
    CGRect cropBoxRect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    CGRect mediaBoxRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
    
    int pageAngle = CGPDFPageGetRotationAngle(page); // Angle
    
    float pageWidth, pageHeight, pageOffsetX, pageOffsetY;
    switch (pageAngle) // Page rotation angle (in degrees)
    {
        default: // Default case
        case 0: case 180: // 0 and 180 degrees
        {
            pageWidth = effectiveRect.size.width;
            pageHeight = effectiveRect.size.height;
            pageOffsetX = effectiveRect.origin.x;
            pageOffsetY = effectiveRect.origin.y;
            break;
        }
            
        case 90: case 270: // 90 and 270 degrees
        {
            pageWidth = effectiveRect.size.height;
            pageHeight = effectiveRect.size.width;
            pageOffsetX = effectiveRect.origin.y;
            pageOffsetY = effectiveRect.origin.x;
            break;
        }
    }
    
    return CGRectMake(pageOffsetX, pageOffsetY, pageWidth, pageHeight);
}

#pragma mark Notification name strings

//NSString *const ReaderDocumentAddedNotification = @"ReaderDocumentAddedNotification";
NSString *const ReaderDocumentRenamedNotification = @"ReaderDocumentRenamedNotification";
//NSString *const ReaderDocumentDeletedNotification = @"ReaderDocumentDeletedNotification";
NSString *const ReaderDocumentNotificationObjectID = @"ReaderDocumentNotificationObjectID";

@end
