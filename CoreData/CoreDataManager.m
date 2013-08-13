//
//	CoreDataManager.m
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

#import "CoreDataManager.h"

@implementation CoreDataManager
{
	NSManagedObjectModel *mainManagedObjectModel;

	NSPersistentStoreCoordinator *mainPersistentStoreCoordinator;

	NSManagedObjectContext *mainManagedObjectContext;
}

#pragma mark CoreDataManager class methods

+ (CoreDataManager *)sharedInstance
{
	static dispatch_once_t predicate = 0;

	static CoreDataManager *object = nil; // Object

	dispatch_once(&predicate, ^{ object = [self new]; });

	return object; // CoreDataManager singleton
}

+ (NSURL *)applicationDocumentsDirectory
{
	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	return [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
}

+ (NSURL *)applicationSupportDirectory
{
	NSFileManager *fileManager = [NSFileManager new]; // File manager instance

	return [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
}

+ (NSURL *)applicationCoreDataStoreFileURL
{
	return [[CoreDataManager applicationSupportDirectory] URLByAppendingPathComponent:@"Reader.sqlite"]; // Data store file URL
}

#pragma mark CoreDataManager instance methods

- (NSManagedObjectModel *)mainManagedObjectModel
{
	if (mainManagedObjectModel == nil) // Create ManagedObjectModel
	{
		assert([NSThread isMainThread] == YES); // Create it only on the main thread

		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Reader" withExtension:@"momd"];

		mainManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	}

	return mainManagedObjectModel;
}

- (NSPersistentStoreCoordinator *)mainPersistentStoreCoordinator
{
	if (mainPersistentStoreCoordinator == nil) // Create PersistentStoreCoordinator
	{
		assert([NSThread isMainThread] == YES); // Create it only on the main thread

		NSURL *storeURL = [CoreDataManager applicationCoreDataStoreFileURL]; // DB

		__autoreleasing NSError *error = nil; // Error information object

		NSDictionary *migrate = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
								[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

		mainPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self mainManagedObjectModel]];

		if ([mainPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:migrate error:&error] == nil)
		{
			// Replace this implementation with code to handle the error appropriately.

			// assert() causes the application to generate a crash log and terminate. You should not use this function in a
			// shipping application, although it may be useful during development. If it is not possible to recover from the
			// error, display an alert panel that instructs the user to quit the application by pressing the Home button.

			// Typical reasons for an error here include:
			// * The persistent store is not accessible;
			// * The schema for the persistent store is incompatible with current managed object model.
			// Check the error message to determine what the actual problem was.

			// If the persistent store is not accessible, there is typically something wrong with the file path.
			// Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

			// If you encounter schema incompatibility errors during development, you can reduce their frequency by:
			// * Simply deleting the existing store:
			// [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

			// * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
			// [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
			// [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

			// Lightweight migration will only work for a limited set of schema changes.
			// Consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

			NSLog(@"%s %@", __FUNCTION__, error); assert(NO);
		}
	}

	return mainPersistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainManagedObjectContext
{
	if (mainManagedObjectContext == nil) // Create ManagedObjectContext
	{
		assert([NSThread isMainThread] == YES); // Create it only on the main thread

		NSPersistentStoreCoordinator *coordinator = [self mainPersistentStoreCoordinator];

		if (coordinator != nil) // Check for valid PersistentStoreCoordinator
		{
			mainManagedObjectContext = [NSManagedObjectContext new]; // New MOC

			[mainManagedObjectContext setPersistentStoreCoordinator:coordinator];
		}
	}

	return mainManagedObjectContext;
}

- (NSManagedObjectContext *)newManagedObjectContext
{
	NSManagedObjectContext *someManagedObjectContext = nil;

	NSPersistentStoreCoordinator *coordinator = [self mainPersistentStoreCoordinator];

	if (coordinator != nil) // Check for valid PersistentStoreCoordinator
	{
		someManagedObjectContext = [NSManagedObjectContext new]; // New MOC

		[someManagedObjectContext setPersistentStoreCoordinator:coordinator];
	}

	return someManagedObjectContext;
}

- (void)saveMainManagedObjectContext
{
	assert([NSThread isMainThread] == YES); // Main thread only

	if (mainManagedObjectContext != nil) // Save ManagedObjectContext
	{
		__autoreleasing NSError *error = nil; // Error information object

		if ([mainManagedObjectContext hasChanges] == YES) // Save changes
		{
			if ([mainManagedObjectContext save:&error] == NO) // Log any errors
			{
				// Replace this implementation with code to handle the error appropriately.

				// assert() causes the application to generate a crash log and terminate. You should not use this function in a
				// shipping application, although it may be useful during development. If it is not possible to recover from the
				// error, display an alert panel that instructs the user to quit the application by pressing the Home button.

				NSLog(@"%s %@", __FUNCTION__, error); assert(NO);
			}
		}
	}
}

@end
