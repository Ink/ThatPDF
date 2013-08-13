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
#import "LibraryViewController.h"
#import "LibraryDirectoryView.h"
#import "LibraryDocumentsView.h"
#import "ReaderViewController.h"
#import "ReaderThumbCache.h"
#import "CoreDataManager.h"
#import "DocumentsUpdate.h"
#import "DocumentFolder.h"
#import "ReaderDocument.h"
#import "CGPDFDocument.h"
#import <FPPicker/FPPicker.h>

@interface LibraryViewController () <LibraryDirectoryDelegate, LibraryDocumentsDelegate, ReaderViewControllerDelegate, UIScrollViewDelegate, FPPickerDelegate>

@end

@implementation LibraryViewController
{
	UIScrollView *theScrollView;

	LibraryDirectoryView *directoryView;

	LibraryDocumentsView *documentsView;

	ReaderViewController *readerViewController;

	LibraryUpdatingView *updatingView;

	NSMutableArray *contentViews;

	NSInteger visibleViewTag;

	CGSize lastAppearSize;
    
    FPPickerController *fpController;

	BOOL isVisible;
}

#pragma mark Constants

#define DIRECTORY_TAG 1
#define DOCUMENTS_TAG 2

#define DEFAULT_DURATION 0.3

#pragma mark Properties

@synthesize delegate;

#pragma mark Support methods

- (void)updateScrollViewContentSize
{
	NSInteger count = contentViews.count;

    //BRETTCVZ: Removed assert
    if (count == 0) {
        NSLog(@"Count was 1");
        count = 1;
    }
    
	CGFloat contentHeight = theScrollView.bounds.size.height;

	CGFloat contentWidth = (theScrollView.bounds.size.width * count);

	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
	[self updateScrollViewContentSize]; // Update content size

	CGPoint contentOffset = CGPointZero; // Content offset for visible view

	CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

	for (UIView *contentView in contentViews) // Enumerate content views
	{
		contentView.frame = viewRect; // Update content view frame

		if (contentView.tag == visibleViewTag) contentOffset = viewRect.origin;

		viewRect.origin.x += viewRect.size.width; // Next position
	}

	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)showReaderDocument:(ReaderDocument *)document
{
	if (document.fileExistsAndValid == YES) // Ensure the file exists
	{
		CFURLRef fileURL = (__bridge CFURLRef)document.fileURL; // Document file URL

		if (CGPDFDocumentNeedsPassword(fileURL, document.password) == NO) // Nope
		{
            //TODO: Brettcvz - crashing because dismiss calls viewWillAppear on the old document, which isn't there anymore
            if (self.modalViewController != nil) // Check for active view controller(s)
			{
				[self dismissModalViewControllerAnimated:NO]; // Dismiss any view controller(s)
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

			[self presentModalViewController:readerViewController animated:NO];
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

		[notificationCenter addObserver:self selector:@selector(showUpdatingView:) name:DocumentsUpdateBeganNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(hideUpdatingView:) name:DocumentsUpdateEndedNotification object:nil];

		[ReaderThumbCache purgeThumbCachesOlderThan:(86400.0 * 30.0)]; // Purge thumb caches older than 30 days
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor clearColor];

	CGRect viewRect = self.view.bounds; // View controller's view bounds

	theScrollView = [[UIScrollView alloc] initWithFrame:viewRect]; // All

	theScrollView.bounces = NO;
	theScrollView.scrollsToTop = NO;
	theScrollView.pagingEnabled = YES;
	theScrollView.delaysContentTouches = NO;
	theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.showsHorizontalScrollIndicator = NO;
	theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.backgroundColor = [UIColor clearColor];
	theScrollView.userInteractionEnabled = YES;
	theScrollView.autoresizesSubviews = NO;
	theScrollView.delegate = self;

	[self.view addSubview:theScrollView];

	updatingView = [[LibraryUpdatingView alloc] initWithFrame:viewRect]; // All

	[self.view addSubview:updatingView];

	contentViews = [NSMutableArray new];
    
    // Creating the filepicker
    fpController = [[FPPickerController alloc] init];
    fpController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Set the delegate
    fpController.fpdelegate = self;
    
    // Ask for specific data types. (Optional) Default is all files.
    fpController.dataTypes = [NSArray arrayWithObjects:@"application/pdf", nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateScrollViewContentViews]; // Update content views
		}

		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	BOOL reload = NO; isVisible = YES;

	if (contentViews.count == 0) // Add content views
	{
		CGRect viewRect = theScrollView.bounds; // Initial view frame

		directoryView = [[LibraryDirectoryView alloc] initWithFrame:viewRect];

		directoryView.delegate = self; directoryView.ownViewController = self; directoryView.tag = DIRECTORY_TAG;

		[theScrollView addSubview:directoryView]; [contentViews addObject:directoryView]; // Add

		viewRect.origin.x += viewRect.size.width; // Next view frame position

		documentsView = [[LibraryDocumentsView alloc] initWithFrame:viewRect];

		documentsView.delegate = self; documentsView.ownViewController = self; documentsView.tag = DOCUMENTS_TAG;

		[theScrollView addSubview:documentsView]; [contentViews addObject:documentsView]; // Add

		viewRect.origin.x += viewRect.size.width; // Next view frame position

		visibleViewTag = directoryView.tag; // Set the visible view tag

		reload = YES; // Reload content views
	}

	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == true)
	{
		[self updateScrollViewContentSize]; // Set the content size
	}

	if (reload == YES) // Reload views
	{
		[directoryView reloadDirectory]; DocumentFolder *folder = nil;

		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; // User defaults

		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

		NSPersistentStoreCoordinator *mainPSC = [mainMOC persistentStoreCoordinator]; // Main PSC

		NSString *folderURL = [userDefaults objectForKey:kReaderSettingsCurrentFolder]; // Folder

		if (folderURL != nil) // Show default folder saved in settings
		{
			NSURL *folderURI = [NSURL URLWithString:folderURL]; // Folder URI

			NSManagedObjectID *objectID = [mainPSC managedObjectIDForURIRepresentation:folderURI];

			if (objectID != nil) folder = (id)[mainMOC existingObjectWithID:objectID error:NULL];
		}

		if (folder == nil) // Show default documents folder
		{
			folder = [DocumentFolder folderInMOC:mainMOC type:DocumentFolderTypeDefault];

			NSString *folderURI = [[[folder objectID] URIRepresentation] absoluteString]; // Folder URI

			[userDefaults setObject:folderURI forKey:kReaderSettingsCurrentFolder]; // Default folder
		}

		assert(folder != nil); [documentsView reloadDocumentsWithFolder:folder]; // Show folder contents

		NSString *documentURL = [userDefaults objectForKey:kReaderSettingsCurrentDocument]; // Document

		if (documentURL != nil) // Show default document saved in user defaults
		{
			NSURL *documentURI = [NSURL URLWithString:documentURL]; // Document URI

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
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	lastAppearSize = self.view.bounds.size; // Track view size
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
	lastAppearSize = CGSizeZero; visibleViewTag = 0;

	theScrollView = nil; documentsView = nil; directoryView = nil;

	updatingView = nil; contentViews = nil; isVisible = NO;

	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	else
		return YES;
}

/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//if (isVisible == NO) return; // iOS present modal bodge
}
*/

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge

	[self updateScrollViewContentViews]; // Update content views

	lastAppearSize = CGSizeZero; // Reset view size tracking
}

/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//if (isVisible == NO) return; // iOS present modal bodge

	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
}
*/

- (void)didReceiveMemoryWarning
{
	[documentsView handleMemoryWarning];

	[directoryView handleMemoryWarning];

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat contentOffsetX = scrollView.contentOffset.x;

	for (UIView *contentView in contentViews) // Enumerate content views
	{
		if (contentView.frame.origin.x == contentOffsetX)
		{
			visibleViewTag = contentView.tag; break;
		}
	}
}

- (void)enableContainerScrollView:(BOOL)enabled
{
	theScrollView.scrollEnabled = enabled;
}

#pragma mark LibraryDirectoryDelegate methods

- (void)tappedInToolbar:(UIXToolbarView *)toolbar infoButton:(UIButton *)button
{
	if ([delegate respondsToSelector:@selector(dismissLibraryViewController:)])
	{
		[delegate dismissLibraryViewController:self]; // Dismiss the view controller
	}
}

- (void)directoryView:(LibraryDirectoryView *)directoryView didSelectDocumentFolder:(DocumentFolder *)folder
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; // User defaults

	NSString *folderURI = [[[folder objectID] URIRepresentation] absoluteString]; // Folder URI

	[userDefaults setObject:folderURI forKey:kReaderSettingsCurrentFolder]; // Default folder

	[documentsView reloadDocumentsWithFolder:folder]; // Reload documents view

	for (UIView *contentView in contentViews) // Enumerate content views
	{
		if (contentView.tag == DOCUMENTS_TAG) // Found the documents view
		{
			CGPoint contentOffset = contentView.frame.origin; // Get origin

			[theScrollView setContentOffset:contentOffset animated:YES];

			visibleViewTag = contentView.tag; break;
		}
	}
}

#pragma mark LibraryDocumentsDelegate methods

- (void)tappedInToolbar:(UIXToolbarView *)toolbar addFileButton:(UIButton *)button {
    [self presentViewController:fpController animated:YES completion:^{
        
    }];
}

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

		[self presentModalViewController:readerViewController animated:NO];
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

	[self dismissModalViewControllerAnimated:NO]; readerViewController = nil; // Release ReaderViewController

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

- (void)showUpdatingView:(NSNotification *)notification
{
	dispatch_async(dispatch_get_main_queue(),
	^{
		[self->updatingView animateShow];
	});
}

- (void)hideUpdatingView:(NSNotification *)notification
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 2)), dispatch_get_main_queue(),
	^{
		[self->updatingView animateHide];
	});
}

@end

#pragma mark -

//
//	LibraryUpdatingView class implementation
//

@implementation LibraryUpdatingView
{
	UIActivityIndicatorView *activityView;

	UILabel *titleLabel;
}

#pragma mark Constants

#define TITLE_X 6.0f
#define TITLE_Y 52.0f
#define TITLE_WIDTH 128.0f
#define TITLE_HEIGHT 28.0f

#pragma mark LibraryDirectoryCell instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f]; // View tint
		self.hidden = YES; self.alpha = 0.0f; // Start off hidden

		NSInteger centerX = (self.bounds.size.width / 2.0f); // Center X
		NSInteger offsetY = (self.bounds.size.height / 3.0f); // Offset Y

		UIViewAutoresizing resizingMask = UIViewAutoresizingNone;
		resizingMask |= (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		resizingMask |= (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);

		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

		CGRect activityFrame = activityView.frame;
		NSInteger activityX = (centerX - (activityFrame.size.width / 2.0f));
		NSInteger activityY = (offsetY - (activityFrame.size.height / 2.0f));
		activityFrame.origin = CGPointMake(activityX, activityY);
		activityView.frame = activityFrame;

		activityView.autoresizingMask = resizingMask;

		[self addSubview:activityView]; // Add to view

		NSString *labelText = NSLocalizedString(@"Updating", "text");

		NSInteger labelX = (centerX - (TITLE_WIDTH / 2.0f) + TITLE_X);
		NSInteger labelY = (offsetY - (TITLE_HEIGHT / 2.0f) + TITLE_Y);
		CGRect labelFrame = CGRectMake(labelX, labelY, TITLE_WIDTH, TITLE_HEIGHT);

		titleLabel = [[UILabel alloc] initWithFrame:labelFrame];

		titleLabel.font = [UIFont systemFontOfSize:17.0f];
		titleLabel.text = [labelText stringByAppendingString:@"..."];
		titleLabel.textColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textAlignment = UITextAlignmentCenter;

		titleLabel.autoresizingMask = resizingMask;

		[self addSubview:titleLabel]; // Add to view
	}

	return self;
}

- (void)animateHide
{
	if (self.hidden == NO)
	{
		[activityView stopAnimating]; // Stop

		[UIView animateWithDuration:DEFAULT_DURATION delay:0.0
			options:UIViewAnimationOptionCurveLinear
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.userInteractionEnabled = NO;
				self.hidden = YES;
			}
		];
	}
}

- (void)animateShow
{
	if (self.hidden == YES)
	{
		[activityView startAnimating]; // Start

		[UIView animateWithDuration:DEFAULT_DURATION delay:0.0
			options:UIViewAnimationOptionCurveLinear
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:^(BOOL finished)
			{
				self.userInteractionEnabled = YES;
			}
		];
	}
}

@end
