//
//	DocumentsUpdate.m
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

#import "ReaderConstants.h"
#import "DocumentsUpdate.h"
#import "CoreDataManager.h"
#import "ReaderDocument.h"

@implementation DocumentsUpdate
{
	NSOperationQueue *workQueue;
}

#pragma mark DocumentsUpdate class methods

+ (DocumentsUpdate *)sharedInstance
{
	static dispatch_once_t predicate = 0;

	static DocumentsUpdate *object = nil; // Object

	dispatch_once(&predicate, ^{ object = [self new]; });

	return object; // DocumentsUpdate singleton
}

+ (NSString *)documentsPath
{
	NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	return [documentsPaths objectAtIndex:0]; // Path to the application's "~/Documents" directory
}

#pragma mark DocumentsUpdate instance methods

- (id)init
{
	if ((self = [super init]))
	{
		workQueue = [NSOperationQueue new];

		[workQueue setName:@"DocumentsUpdateWorkQueue"];

		[workQueue setMaxConcurrentOperationCount:1];
	}

	return self;
}

- (void)cancelAllOperations
{
	[workQueue cancelAllOperations];
}

- (void)queueDocumentsUpdate
{
	if (workQueue.operationCount < 1) // Limit the number of DocumentsUpdate operations in work queue
	{
		DocumentsUpdateOperation *updateOp = [DocumentsUpdateOperation new]; [updateOp setThreadPriority:0.25];

		[workQueue addOperation:updateOp]; // Queue up a documents update operation
	}
}

- (BOOL)handleOpenURL:(NSURL *)theURL
{
	BOOL handled = NO; // Handled flag

	if ([theURL isFileURL] == YES) // File URLs only
	{
		NSString *inboxFilePath = [theURL path]; // File path string

		NSString *inboxPath = [inboxFilePath stringByDeletingLastPathComponent];

		if ([[inboxPath lastPathComponent] isEqualToString:@"Inbox"]) // Inbox test
		{
			NSString *documentFile = [inboxFilePath lastPathComponent]; // File name

			NSString *documentsPath = [DocumentsUpdate documentsPath]; // Documents path

			NSString *documentFilePath = [documentsPath stringByAppendingPathComponent:documentFile];

			NSFileManager *fileManager = [NSFileManager new]; // File manager instance

			[fileManager moveItemAtPath:inboxFilePath toPath:documentFilePath error:NULL]; // Move

			[fileManager removeItemAtPath:inboxPath error:NULL]; // Delete Inbox directory

			NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

			NSArray *documentList = [ReaderDocument allInMOC:mainMOC withName:documentFile];

			ReaderDocument *document = nil; // ReaderDocument object

			if (documentList.count > 0) // Document exists
			{
				document = [documentList objectAtIndex:0];
			}
			else // Insert the new document into the object store
			{
				document = [ReaderDocument insertInMOC:mainMOC name:documentFile path:documentsPath];

				[[CoreDataManager sharedInstance] saveMainManagedObjectContext]; // Save changes
			}

			if (document != nil) // We have a document to show
			{
				NSString *documentURI = [[[document objectID] URIRepresentation] absoluteString]; // Document URI

				[[NSUserDefaults standardUserDefaults] setObject:documentURI forKey:kReaderSettingsCurrentDocument];

				NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

				[notificationCenter postNotificationName:DocumentsUpdateOpenNotification object:nil userInfo:nil];

				handled = YES; // We handled the open URL request
			}
		}
	}

	return handled;
}

- (BOOL) handleOpenBlob:(INKBlob *)theBlob {
    NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];
    
    // Insert the new document into the object store
    NSString *filename = theBlob.filename;
    // We can't be sure we will always have a filename, so add a safeguard
    if (!filename) {
        filename = @"Document.pdf";
    }
    //We get wierd issues if it's not a .pdf
    if (![[filename pathExtension] isEqualToString:@"pdf"]) {
        filename = [filename stringByAppendingString:@".pdf"];
    }
    //The PDF loader crashes if we have spaces, so we replace them with dashes
    filename = [filename stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    //Writing the blob data to the filesystem
    NSString *documentsPath = [DocumentsUpdate documentsPath]; // Documents path
    NSString *documentFilePath = [documentsPath stringByAppendingPathComponent:filename];
    [theBlob.data writeToFile:documentFilePath atomically:YES];
    
    //Creating the CoreData object
    ReaderDocument *document = [ReaderDocument insertInMOC:mainMOC name:filename path:documentsPath];
        
    [[CoreDataManager sharedInstance] saveMainManagedObjectContext]; // Save changes
    
    if (document != nil) // We have a document to show
    {
        NSString *documentURI = [[[document objectID] URIRepresentation] absoluteString]; // Document URI
        
        [[NSUserDefaults standardUserDefaults] setObject:documentURI forKey:kReaderSettingsCurrentDocument];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

        [notificationCenter postNotificationName:DocumentsUpdateOpenNotification object:nil userInfo:nil];
        return YES;
    } else {
        return NO;
    }
}

-(void) addSampleDocumentsInFolder:(DocumentFolder*)sampleFolder {
    NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];
    NSString *documentsPath = [DocumentsUpdate documentsPath]; // Documents path
    
    //NDA
    NSString *filename = @"NDA.pdf";
    NSString *documentFilePath = [documentsPath stringByAppendingPathComponent:filename];
    NSString *ndaPath = [[NSBundle mainBundle] pathForResource:@"nda" ofType:@"pdf"];
    [[NSFileManager defaultManager] copyItemAtPath:ndaPath toPath:documentFilePath error:nil];
    
    ReaderDocument *ndaDocument = [ReaderDocument insertInMOC:mainMOC name:filename path:documentsPath];
    ndaDocument.folder = sampleFolder;
    
    //lease
    filename = @"LeaseAgreement.pdf";
    documentFilePath = [documentsPath stringByAppendingPathComponent:filename];
    NSString *leasePath = [[NSBundle mainBundle] pathForResource:@"leaseagreement" ofType:@"pdf"];
    [[NSFileManager defaultManager] copyItemAtPath:leasePath toPath:documentFilePath error:nil];
    
    ReaderDocument *leaseDocument = [ReaderDocument insertInMOC:mainMOC name:filename path:documentsPath];
    leaseDocument.folder = sampleFolder;

    [[CoreDataManager sharedInstance] saveMainManagedObjectContext]; // Save changes
}


#pragma mark Notification name strings

NSString *const DocumentsUpdateOpenNotification = @"DocumentsUpdateOpenNotification";
NSString *const DocumentsSetAnnotationModeSignNotification = @"DocumentsSetAnnotationModeSignNotification";
NSString *const DocumentsSetAnnotationModeRedPenNotification = @"DocumentsSetAnnotationModeRedPenNotification";
NSString *const DocumentsSetAnnotationModeOffNotification = @"DocumentsSetAnnotationModeOffNotification";

@end

#pragma mark -

//
//	DocumentsUpdateOperation class implementation
//

@implementation DocumentsUpdateOperation

#pragma mark DocumentsUpdateOperation methods

- (void)main
{
	__autoreleasing NSError *error = nil; // Error information object

	NSString *documentsPath = [DocumentsUpdate documentsPath]; // Documents path

	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	NSArray *fileList = [fileManager contentsOfDirectoryAtPath:documentsPath error:&error];

	if (fileList != nil) // Process documents directory contents
	{
		NSMutableSet *fileSet = [NSMutableSet new]; // File name set

		for (NSString *fileName in fileList) // Enumerate directory contents
		{
			if ([[fileName pathExtension] caseInsensitiveCompare:@"pdf"] == NSOrderedSame)
			{
				[fileSet addObject:fileName]; // Add the '.pdf' file to the file set
			}
		}

		NSMutableSet *dataSet = [NSMutableSet new]; // Database file name set

		NSMutableDictionary *nameDictionary = [NSMutableDictionary new]; // Objects

		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

		NSManagedObjectContext *workMOC = [[CoreDataManager sharedInstance] newManagedObjectContext];

		[notificationCenter addObserver:self selector:@selector(handleContextDidSaveNotification:)
							name:NSManagedObjectContextDidSaveNotification object:workMOC];

		NSArray *documentList = [ReaderDocument allInMOC:workMOC]; // All document objects

		for (ReaderDocument *document in documentList) // Enumerate document objects
		{
			NSString *fileName = document.fileName; // Get the document file name

			[nameDictionary setObject:document forKey:fileName]; // Track objects

			[dataSet addObject:fileName]; // Add the file name to the data set
		}

		NSMutableSet *addSet = [fileSet mutableCopy]; [addSet minusSet:dataSet]; // Add set

		NSMutableSet *delSet = [dataSet mutableCopy]; [delSet minusSet:fileSet]; // Delete set

		BOOL postUpdate = (((addSet.count > 0) || (delSet.count > 0)) ? YES : NO);

		if (postUpdate) [notificationCenter postNotificationName:DocumentsUpdateBeganNotification object:nil userInfo:nil];

		for (NSString *fileName in addSet) // Enumerate documents to add set
		{
			NSString *fullFilePath = [documentsPath stringByAppendingPathComponent:fileName];

			NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fullFilePath error:NULL];

			NSDate *fileDate = [fileAttributes objectForKey:NSFileModificationDate]; // File date

			NSTimeInterval timeInterval = fabs([fileDate timeIntervalSinceNow]); // File age

			if (timeInterval > 10.0) // Add the file - iOS 5 file sharing sync hack'n'kludge'n'bodge
			{
				ReaderDocument *object = [ReaderDocument insertInMOC:workMOC name:fileName path:documentsPath];

				assert(object != nil); // Object insert failure should never happen
			}
		}

		for (NSString *fileName in delSet) // Enumerate documents to delete set
		{
			ReaderDocument *object = [nameDictionary objectForKey:fileName]; // Object

			[ReaderDocument deleteInMOC:workMOC object:object fm:fileManager]; // Delete
		}

		if ([workMOC hasChanges] == YES) // Save changes
		{
			if ([workMOC save:&error] == NO) // Log any errors
			{
				NSLog(@"%s %@", __FUNCTION__, error); assert(NO);
			}
		}

		[notificationCenter removeObserver:self name:NSManagedObjectContextDidSaveNotification object:workMOC]; 

		if (postUpdate) [notificationCenter postNotificationName:DocumentsUpdateEndedNotification object:nil userInfo:nil];
	}
	else // Log any errors
	{
		NSLog(@"%s %@", __FUNCTION__, error); assert(NO);
	}
}

#pragma mark Notification observer methods

- (void)handleContextDidSaveNotification:(NSNotification *)notification
{
	dispatch_sync(dispatch_get_main_queue(), // Merge synchronously on main thread
	^{
		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

		[mainMOC mergeChangesFromContextDidSaveNotification:notification]; // Merge the changes
	});

	NSDictionary *userInfo = [notification userInfo]; // Notification information

	if (userInfo != nil) // Process the user notification information
	{
		NSMutableSet *deletedObjectIDs = [NSMutableSet new]; // Deleted set

		NSArray *deletedObjects = [userInfo objectForKey:NSDeletedObjectsKey];

		if (deletedObjects != nil) // We have deleted objects
		{
			for (NSManagedObject *object in deletedObjects) // Enumerate them
			{
				[deletedObjectIDs addObject:[object objectID]]; // Add object ID
			}
		}

		NSMutableSet *insertedObjectIDs = [NSMutableSet new]; // Inserted set

		NSArray *insertedObjects = [userInfo objectForKey:NSInsertedObjectsKey];

		if (insertedObjects != nil) // We have inserted objects
		{
			for (NSManagedObject *object in insertedObjects) // Enumerate them
			{
				[insertedObjectIDs addObject:[object objectID]]; // Add object ID
			}
		}

		NSMutableDictionary *updateInfo = [NSMutableDictionary new]; // Update info

		if (deletedObjectIDs.count > 0) // We have deleted object IDs
		{
			[updateInfo setObject:deletedObjectIDs forKey:DocumentsUpdateDeletedObjectIDs];
		}

		if (insertedObjectIDs.count > 0) // We have inserted object IDs
		{
			[updateInfo setObject:insertedObjectIDs forKey:DocumentsUpdateAddedObjectIDs];
		}

		if (updateInfo.count > 0) // Post an update notification
		{
			dispatch_async(dispatch_get_main_queue(), // Notify asynchronously on main thread
			^{
				NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

				[notificationCenter postNotificationName:DocumentsUpdateNotification object:nil userInfo:updateInfo];
			});
		}
	}
}

#pragma mark Notification name strings

NSString *const DocumentsUpdateNotification = @"DocumentsUpdateNotification";
NSString *const DocumentsUpdateAddedObjectIDs = @"DocumentsUpdateAddedObjectIDs";
NSString *const DocumentsUpdateDeletedObjectIDs = @"DocumentsUpdateDeletedObjectIDs";
NSString *const DocumentsUpdateBeganNotification = @"DocumentsUpdateBeganNotification";
NSString *const DocumentsUpdateEndedNotification = @"DocumentsUpdateEndedNotification";

@end
