//
//	LibraryViewController.m
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
#import "LibraryDocumentsViewController.h"
#import "LibraryDocumentsView.h"
#import "ReaderViewController.h"
#import "ReaderThumbCache.h"
#import "CoreDataManager.h"
#import "DocumentsUpdate.h"
#import "DocumentFolder.h"
#import "ReaderDocument.h"
#import "CGPDFDocument.h"
#import <FPPicker/FPPicker.h>
#import "INKWelcomeViewController.h"

@interface LibraryDocumentsViewController () <LibraryDocumentsDelegate, ReaderViewControllerDelegate, FPPickerDelegate>

@end

@implementation LibraryDocumentsViewController
{
	LibraryDocumentsView *documentsView;

	ReaderViewController *readerViewController;

    FPPickerController *fpController;
    
    DocumentFolder *folder;

    UIBarButtonItem *folderButton;
    UIBarButtonItem *checkButton;
    UIBarButtonItem *addButton;
    UIBarButtonItem *editButton;
}

#pragma mark Constants

#define DEFAULT_DURATION 0.3

#pragma mark Properties

#pragma mark Support methods


- (void)showReaderDocument:(ReaderDocument *)document
{
	if (document.fileExistsAndValid == YES) // Ensure the file exists
	{
		CFURLRef fileURL = (__bridge CFURLRef)document.fileURL; // Document file URL

		if (CGPDFDocumentNeedsPassword(fileURL, document.password) == NO) // Nope
		{
            //TODO: Brettcvz - crashing because dismiss calls viewWillAppear on the old document, which isn't there anymore
            if (self.presentedViewController != nil) // Check for active view controller(s)
			{
				[self dismissViewControllerAnimated:NO completion:^{
                    
                }]; // Dismiss any view controller(s)
			}

			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; // User defaults

			if ([userDefaults boolForKey:kReaderSettingsHideStatusBar] == YES) // Status bar hide setting
			{
				UIApplication *sharedApplication = [UIApplication sharedApplication]; // UIApplication

				if (sharedApplication.statusBarHidden == NO) // The status bar is visible so hide it
				{
					[sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
				}
			}

			readerViewController = nil; // Release any old ReaderViewController first

			readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
			readerViewController.delegate = self; // Set the ReaderViewController delegate to self

			readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self.navigationController pushViewController:readerViewController animated:NO];
		}
	}
}

#pragma mark UIViewController methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

		[notificationCenter addObserver:self selector:@selector(openNewDocument:) name:DocumentsUpdateOpenNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(foldersWhereDeleted:) name:DocumentFoldersDeletedNotification object:nil];
        
		[notificationCenter addObserver:self selector:@selector(folderWasDeleted:) name:DocumentFolderDeletedNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(folderWasRenamed:) name:DocumentFolderRenamedNotification object:nil];
        


		[ReaderThumbCache purgeThumbCachesOlderThan:(86400.0 * 30.0)]; // Purge thumb caches older than 30 days
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor clearColor];
    
    // Creating the filepicker
    fpController = [[FPPickerController alloc] init];
    fpController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Set the delegate
    fpController.fpdelegate = self;
    
    // Ask for specific data types. (Optional) Default is all files.
    fpController.dataTypes = [NSArray arrayWithObjects:@"application/pdf", nil];
    
    documentsView = [[LibraryDocumentsView alloc] initWithFrame:self.view.bounds];
    
    documentsView.delegate = self; documentsView.ownViewController = self;
    [self.view addSubview:documentsView];
    
    [self setupToolbar];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    documentsView = nil;
    
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	else
		return YES;
}

- (void)didReceiveMemoryWarning
{
	[documentsView handleMemoryWarning];

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadDocumentsWithFolder:(DocumentFolder*)Folder {
    folder = Folder;
    self.navigationItem.title = folder.name;
    [documentsView reloadDocumentsWithFolder:folder]; // Show folder contents
}

#pragma mark LibraryDocumentsDelegate methods

- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *url = [info objectForKey:@"FPPickerControllerMediaURL"];
    
    NSString *documentFile = [info objectForKey:@"FPPickerControllerFilename"]; // File name
    
    NSString *documentsPath = [DocumentsUpdate documentsPath]; // Documents path
    
    NSString *documentFilePath = [documentsPath stringByAppendingPathComponent:documentFile];
    
    NSFileManager *fileManager = [NSFileManager new]; // File manager instance
    
    [fileManager moveItemAtPath:[url path] toPath:documentFilePath error:NULL]; // Move
    
    [fileManager removeItemAtPath:[url path] error:NULL]; // Delete Inbox directory
    
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
    [documentsView reloadDocumentsUpdated];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)FPPickerControllerDidCancel:(FPPickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)FPPickerController:(FPPickerController *)picker didPickMediaWithInfo:(NSDictionary *)info {
    
}

- (void)documentsView:(LibraryDocumentsView *)documentsView didSelectReaderDocument:(ReaderDocument *)document
{
	if (document.fileExistsAndValid == YES) // Ensure the file exists
	{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; // User defaults

		if ([userDefaults boolForKey:kReaderSettingsHideStatusBar] == YES) // Status bar hide setting
		{
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		}

		if (document.password == nil) // Only remember default documents that do not require a password
		{
			NSString *documentURI = [[[document objectID] URIRepresentation] absoluteString]; // Document URI

			[userDefaults setObject:documentURI forKey:kReaderSettingsCurrentDocument]; // Default document
		}

		readerViewController = nil; // Release any old ReaderViewController first

		readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];

		readerViewController.delegate = self; // Set the ReaderViewController delegate to self

		readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;

        [self.navigationController pushViewController:readerViewController animated:YES];
	}
}


- (void)updateButtonStatesForEditMode:(BOOL)editMode countSelected:(NSInteger)selected {
    checkButton.enabled = YES;
    
    addButton.image = [UIImage imageNamed:(editMode ? @"Icon-DeleteFile" : @"Icon-AddFile")];
    checkButton.image = [UIImage imageNamed:(editMode ? @"Icon-Cross" : @"Icon-SelectFile")];
    
    if (editMode) {
        editButton.enabled = (selected == 1 ? YES : NO);
        addButton.enabled = (selected > 0 ? YES : NO);
        folderButton.enabled = (selected > 0 ? YES : NO);
        
        self.navigationItem.leftBarButtonItems = @[folderButton];
        self.navigationItem.rightBarButtonItems = @[checkButton, addButton, editButton];
    } else {
        addButton.enabled = YES;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = @[checkButton, addButton];
    }
}


#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; // User defaults

	[userDefaults removeObjectForKey:kReaderSettingsCurrentDocument]; // Clear default document

	if ([userDefaults boolForKey:kReaderSettingsHideStatusBar] == YES) // Status bar hide setting
	{
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	}

	[self dismissViewControllerAnimated:NO completion:^{
        readerViewController = nil; // Release ReaderViewController
    }];

	[documentsView refreshRecentDocuments]; // Refresh if recent folder is visible
}

#pragma mark Notification observer methods

- (void)openNewDocument:(NSNotification *)notification
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; // User defaults

	NSString *documentURL = [userDefaults objectForKey:kReaderSettingsCurrentDocument]; // Document

	if (documentURL != nil) // Show default document saved in user defaults
	{
		NSURL *documentURI = [NSURL URLWithString:documentURL]; // Document URI

		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

		NSPersistentStoreCoordinator *mainPSC = [mainMOC persistentStoreCoordinator]; // Main PSC

		NSManagedObjectID *objectID = [mainPSC managedObjectIDForURIRepresentation:documentURI];

		if (objectID != nil) // We have a valid NSManagedObjectID to request a fetch of
		{
			ReaderDocument *document = (id)[mainMOC existingObjectWithID:objectID error:NULL];

			if ((document != nil) && ([document isKindOfClass:[ReaderDocument class]]))
			{
				[self showReaderDocument:document]; // Show the document
			}
		}
	}
}

#pragma mark Toolbar methods
- (void)setupToolbar {
    self.navigationItem.leftItemsSupplementBackButton = YES;
    folderButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon-Folder"] style:UIBarButtonItemStylePlain
                                                  target:self action:@selector(folderButtonTapped:)];
    
    checkButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon-SelectFile"] style:UIBarButtonItemStylePlain
                                                  target:self action:@selector(checkButtonTapped:)];
    addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon-AddFile"] style:UIBarButtonItemStylePlain
                                                target:self action:@selector(addButtonTapped:)];
    editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon-Edit"] style:UIBarButtonItemStylePlain
                                                target:self action:@selector(editButtonTapped:)];
    
    self.navigationItem.rightBarButtonItems = @[checkButton, addButton];
}

- (void)editButtonTapped:(id)sender {
    if (documentsView.editMode) {
        [documentsView presentRenameAlert];
    }
}

- (void)addButtonTapped:(id)sender {
    if (documentsView.editMode) {
        [documentsView presentDeleteAlert];
    } else {
        [self presentViewController:fpController animated:YES completion:^{
        }];
    }
}

- (void)checkButtonTapped:(id)sender {
    [documentsView toggleEditMode];
}

- (void)folderButtonTapped:(id)sender {
    if (documentsView.editMode) {
        [documentsView presentFolderViewController];
    }
}

#pragma mark DocumentFolder notifications

- (void)folderWasDeleted:(NSNotification *)notification
{
	assert(folder != nil); // Must not be nil
    
	NSDictionary *userInfo = notification.userInfo; // Notification user info
    
	NSManagedObjectID *objectID = [userInfo objectForKey:DocumentFolderNotificationObjectID];
    
	if ([[folder objectID] isEqual:objectID]) // Handle folder delete if object IDs are equal
	{
		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];
        
		DocumentFolder *defaultFolder = [DocumentFolder folderInMOC:mainMOC type:DocumentFolderTypeDefault];
        
		[self reloadDocumentsWithFolder:defaultFolder]; // Show the default folder after delete
	}
}

- (void)folderWasRenamed:(NSNotification *)notification
{
	assert(folder != nil); // Must not be nil
    
	NSDictionary *userInfo = notification.userInfo; // Notification user info
    
	NSManagedObjectID *objectID = [userInfo objectForKey:DocumentFolderNotificationObjectID];
    
	if ([[folder objectID] isEqual:objectID]) // Handle folder rename if object IDs are equal
	{
		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];
        
		DocumentFolder *newFolder = (DocumentFolder *)[mainMOC existingObjectWithID:objectID error:NULL];
        
		self.navigationItem.title = newFolder.name; // Update folder name title text
	}
}

- (void)foldersWhereDeleted:(NSNotification *)notification
{
	assert(folder != nil); // Must not be nil
    
	if ([folder.type integerValue] == DocumentFolderTypeDefault)
	{
        self.navigationItem.title = folder.name;
        [documentsView reloadDocumentsWithFolder:folder]; // Show folder contents
	}
}



@end
