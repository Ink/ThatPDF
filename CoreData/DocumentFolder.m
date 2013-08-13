//
//	DocumentFolder.m
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

#import "DocumentFolder.h"
#import "ReaderDocument.h"

@implementation DocumentFolder

#pragma mark Constants

#define kDocumentFolder @"DocumentFolder"

#pragma mark Properties

@dynamic name;
@dynamic type;
@dynamic documents;
@synthesize isChecked;

#pragma mark DocumentFolder Core Data class methods

+ (NSArray *)allInMOC:(NSManagedObjectContext *)inMOC
{
	assert(inMOC != nil); // Check parameter

	NSFetchRequest *request = [NSFetchRequest new]; // Fetch request instance

	[request setEntity:[NSEntityDescription entityForName:kDocumentFolder inManagedObjectContext:inMOC]];

	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

	[request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]]; // Sort order

	[request setReturnsObjectsAsFaults:NO]; [request setFetchBatchSize:24]; // Optimize fetch

	__autoreleasing NSError *error = nil; // Error information object

	NSArray *objectList = [inMOC executeFetchRequest:request error:&error];

	if (objectList == nil) { NSLog(@"%s %@", __FUNCTION__, error); assert(NO); }

	return objectList;
}

+ (BOOL)existsInMOC:(NSManagedObjectContext *)inMOC name:(NSString *)string
{
	assert(inMOC != nil); assert(string != nil); // Check parameters

	NSFetchRequest *request = [NSFetchRequest new]; // Fetch request instance

	[request setEntity:[NSEntityDescription entityForName:kDocumentFolder inManagedObjectContext:inMOC]];

	[request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", string]]; // Name predicate

	__autoreleasing NSError *error = nil; // Error information object

	NSUInteger count = [inMOC countForFetchRequest:request error:&error];

	if (error != nil) { NSLog(@"%s %@", __FUNCTION__, error); assert(NO); }

	return ((count > 0) ? YES : NO);
}

+ (BOOL)existsInMOC:(NSManagedObjectContext *)inMOC type:(DocumentFolderType)kind
{
	assert(inMOC != nil); // Check parameter

	NSFetchRequest *request = [NSFetchRequest new]; // Fetch request instance

	[request setEntity:[NSEntityDescription entityForName:kDocumentFolder inManagedObjectContext:inMOC]];

	[request setPredicate:[NSPredicate predicateWithFormat:@"type == %d", kind]]; // Type predicate

	__autoreleasing NSError *error = nil; // Error information object

	NSUInteger count = [inMOC countForFetchRequest:request error:&error];

	if (error != nil) { NSLog(@"%s %@", __FUNCTION__, error); assert(NO); }

	return ((count > 0) ? YES : NO);
}

+ (DocumentFolder *)folderInMOC:(NSManagedObjectContext *)inMOC type:(DocumentFolderType)kind
{
	assert(inMOC != nil); // Check parameter

	NSFetchRequest *request = [NSFetchRequest new]; // Fetch request instance

	[request setEntity:[NSEntityDescription entityForName:kDocumentFolder inManagedObjectContext:inMOC]];

	[request setPredicate:[NSPredicate predicateWithFormat:@"type == %d", kind]]; // Type predicate

	[request setReturnsObjectsAsFaults:NO]; //[request setFetchBatchSize:24]; // Optimize fetch

	__autoreleasing NSError *error = nil; // Error information object

	NSArray *objectList = [inMOC executeFetchRequest:request error:&error];

	if (objectList == nil) { NSLog(@"%s %@", __FUNCTION__, error); assert(NO); }

	return [objectList lastObject];
}

+ (DocumentFolder *)insertInMOC:(NSManagedObjectContext *)inMOC name:(NSString *)string type:(DocumentFolderType)kind
{
	assert(inMOC != nil); assert(string != nil); // Check parameters

	DocumentFolder *object = [NSEntityDescription insertNewObjectForEntityForName:kDocumentFolder inManagedObjectContext:inMOC];

	if ((object != nil) && ([object isMemberOfClass:[DocumentFolder class]])) // Valid DocumentFolder object
	{
		object.name = string; object.type = [NSNumber numberWithInteger:kind]; // Set name and type

		__autoreleasing NSError *error = nil; // Error information object

		if ([inMOC hasChanges] == YES) // Save changes
		{
			if ([inMOC save:&error] == YES) // Did save changes
			{
				NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[object objectID] forKey:DocumentFolderNotificationObjectID];

				[notificationCenter postNotificationName:DocumentFolderAddedNotification object:nil userInfo:userInfo];
			}
			else // Log any errors
			{
				NSLog(@"%s %@", __FUNCTION__, error); assert(NO);
			}
		}
	}

	return object;
}

+ (void)renameInMOC:(NSManagedObjectContext *)inMOC objectID:(NSManagedObjectID *)objectID name:(NSString *)string
{
	assert(inMOC != nil); assert(objectID != nil); assert(string != nil); // Check parameters

	DocumentFolder *object = (id)[inMOC existingObjectWithID:objectID error:NULL]; // Get object

	if ((object != nil) && ([object isMemberOfClass:[DocumentFolder class]])) // Valid object
	{
		object.name = string; // Update folder name

		__autoreleasing NSError *error = nil; // Error information object

		if ([inMOC hasChanges] == YES) // Save changes
		{
			if ([inMOC save:&error] == YES) // Did save changes
			{
				NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[object objectID] forKey:DocumentFolderNotificationObjectID];

				[notificationCenter postNotificationName:DocumentFolderRenamedNotification object:nil userInfo:userInfo];
			}
			else // Log any errors
			{
				NSLog(@"%s %@", __FUNCTION__, error); assert(NO);
			}
		}
	}
}

+ (void)deleteInMOC:(NSManagedObjectContext *)inMOC objectID:(NSManagedObjectID *)objectID
{
	assert(inMOC != nil); assert(objectID != nil); // Check parameters

	DocumentFolder *object = (id)[inMOC existingObjectWithID:objectID error:NULL]; // Get object

	if ((object != nil) && ([object isMemberOfClass:[DocumentFolder class]])) // Valid object
	{
		[inMOC deleteObject:object]; // Delete object

		__autoreleasing NSError *error = nil; // Error information object

		if ([inMOC hasChanges] == YES) // Save changes
		{
			if ([inMOC save:&error] == YES) // Did save changes
			{
				NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[object objectID] forKey:DocumentFolderNotificationObjectID];

				[notificationCenter postNotificationName:DocumentFolderDeletedNotification object:nil userInfo:userInfo];
			}
			else // Log any errors
			{
				NSLog(@"%s %@", __FUNCTION__, error); assert(NO);
			}
		}
	}
}

#pragma mark DocumentFolder Core Data instance methods

- (void)willTurnIntoFault
{
	self.isChecked = NO;
}

#pragma mark Notification name strings

NSString *const DocumentFolderAddedNotification = @"DocumentFolderAddedNotification";
NSString *const DocumentFolderRenamedNotification = @"DocumentFolderRenamedNotification";
NSString *const DocumentFolderDeletedNotification = @"DocumentFolderDeletedNotification";
NSString *const DocumentFolderNotificationObjectID = @"DocumentFolderNotificationObjectID";
NSString *const DocumentFoldersDeletedNotification = @"DocumentFoldersDeletedNotification";

@end
