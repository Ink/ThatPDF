//
//	LibraryDocumentsView.m
//	Viewer v1.0.2
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
#import "LibraryDocumentsView.h"
#import "FoldersViewController.h"
#import "ReaderThumbRequest.h"
#import "ReaderThumbCache.h"
#import "CoreDataManager.h"
#import "DocumentsUpdate.h"
#import "DocumentFolder.h"
#import "ReaderDocument.h"
#import "UIXToolbarView.h"
#import "UIXTextEntry.h"
#import "CGPDFDocument.h"
#import <FPPicker/FPPicker.h>

#import <QuartzCore/QuartzCore.h>
#import <INK/Ink.h>

@interface LibraryDocumentsView () <ReaderThumbsViewDelegate, UIXTextEntryDelegate, FoldersViewControllerDelegate,
									UIAlertViewDelegate>
@end

@implementation LibraryDocumentsView
{
	FoldersViewController *foldersViewController;

	NSArray *documents;

	NSMutableSet *selected;

	DocumentFolder *inFolder;

	ReaderThumbsView *theThumbsView;

	ReaderDocument *openDocument;

	UIXTextEntry *theTextEntry;

	UIAlertView *theAlertView;

    FPPickerController *fpController;
}

#pragma mark Constants

#define TOOLBAR_HEIGHT 0.0f

#define THUMB_SIZE_SMALL_DEVICE 160
#define THUMB_SIZE_LARGE_DEVICE 256

#pragma mark Properties

@synthesize delegate;
@synthesize ownViewController;
@synthesize editMode;

#pragma mark Support methods

- (void)updateButtonStates
{
    [self.delegate updateButtonStatesForEditMode:editMode countSelected:[selected count]];
}

- (void)resetSelectedDocuments
{
	for (ReaderDocument *document in selected)
	{
		document.isChecked = NO; // Clear selection
	}

	[selected removeAllObjects]; // Empty the set
}

- (void)toggleEditMode
{
	editMode = (editMode ? NO : YES); // Toggle

	[self updateButtonStates]; // Update buttons

	if (editMode == NO) // Check edit mode
	{
		[self resetSelectedDocuments]; // Clear selections

		[theThumbsView refreshVisibleThumbs]; // Refresh
	}
}

- (void)resetEditMode
{
	if (editMode == YES) // Check edit mode
	{
		editMode = NO; // Clear edit mode state

		[self resetSelectedDocuments]; // Clear selections

		[self updateButtonStates]; // Update buttons
	}
}

- (NSString *)stripExtension:(NSString *)text
{
	NSString *extension = [text pathExtension]; // File extension

	if ([extension caseInsensitiveCompare:@"pdf"] == NSOrderedSame)
		return [text stringByDeletingPathExtension];
	else
		return text;
}

- (NSString *)addExtension:(NSString *)text
{
	NSString *extension = [text pathExtension]; // File extension

	if ([extension caseInsensitiveCompare:@"pdf"] != NSOrderedSame)
		return [text stringByAppendingPathExtension:@"pdf"];
	else
		return text;
}

#pragma mark LibraryDocumentsView instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = YES;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingNone;
		self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

		CGRect viewRect = self.bounds; // View's bounds

		BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);

		CGRect thumbsRect = viewRect; UIEdgeInsets insets = UIEdgeInsetsZero;

		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			thumbsRect.origin.y += TOOLBAR_HEIGHT; thumbsRect.size.height -= TOOLBAR_HEIGHT;
		}
		else // Set UIScrollView insets for non-UIUserInterfaceIdiomPad case
		{
			insets.top = TOOLBAR_HEIGHT;
		}

		theThumbsView = [[ReaderThumbsView alloc] initWithFrame:thumbsRect]; // Rest of view

		theThumbsView.contentInset = insets; theThumbsView.scrollIndicatorInsets = insets;

		theThumbsView.delegate = self; // Set the ReaderThumbsView delegate to self

		[self addSubview:theThumbsView]; // Add to container view

		NSInteger thumbSize = (large ? THUMB_SIZE_LARGE_DEVICE : THUMB_SIZE_SMALL_DEVICE); // Size

		[theThumbsView setThumbSize:CGSizeMake(thumbSize, thumbSize)]; // Thumb size based on device

		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

		[notificationCenter addObserver:self selector:@selector(documentsDidUpdate:) name:DocumentsUpdateNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(openedNewDocument:) name:DocumentsUpdateOpenNotification object:nil];

		[notificationCenter addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

		selected = [NSMutableSet new]; // Selected documents set
	}

	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleMemoryWarning
{
	// TBD
}

- (void)reloadDocumentsUpdated
{
	assert(inFolder != nil); // Must not be nil

	DocumentFolder *folder = inFolder; // Current active folder

	NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

	documents = [ReaderDocument allInMOC:mainMOC withFolder:folder]; // Specified folder

	[theThumbsView reloadThumbsContentOffset:CGPointZero];
}

- (void)reloadDocumentsWithFolder:(DocumentFolder *)folder
{
	assert(folder != nil); // Must not be nil

	if ([inFolder isEqual:folder] == NO) // New folder reload
	{
		[self resetEditMode]; // Reset edit mode on new folder select

		inFolder = folder; // Keep track of the current (visible) folder

		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

		documents = [ReaderDocument allInMOC:mainMOC withFolder:folder]; // Specified folder

        [self updateButtonStates];

		[theThumbsView reloadThumbsContentOffset:CGPointZero];
	}
}

- (void)refreshRecentDocuments
{
	if ([inFolder.type integerValue] == DocumentFolderTypeRecent)
	{
		[self reloadDocumentsUpdated]; // Refresh display
	}
}

#pragma mark ReaderThumbsViewDelegate methods

- (NSUInteger)numberOfThumbsInThumbsView:(ReaderThumbsView *)thumbsView
{
	return (documents.count);
}

- (id)thumbsView:(ReaderThumbsView *)thumbsView thumbCellWithFrame:(CGRect)frame
{
	return [[LibraryDocumentsCell alloc] initWithFrame:frame];
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView updateThumbCell:(LibraryDocumentsCell *)thumbCell forIndex:(NSInteger)index
{
	ReaderDocument *document = [documents objectAtIndex:index];

	if (document.isDeleted == NO) // Document object must not be deleted
	{
		[thumbCell showText:[document.fileName stringByDeletingPathExtension]];

		CGSize size = [thumbCell maximumContentSize]; // Get the cell's maximum content size

		NSURL *fileURL = document.fileURL; NSString *guid = document.guid; NSString *phrase = document.password; // Document

		ReaderThumbRequest *thumbRequest = [ReaderThumbRequest newForView:thumbCell fileURL:fileURL password:phrase guid:guid page:1 size:size annotations:[[document annotations] annotationsForPage:1]];

		UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:thumbRequest priority:NO]; // Request the thumbnail

		if ([image isKindOfClass:[UIImage class]]) [thumbCell showImage:image]; // Show image from cache

		BOOL checked = document.isChecked; [thumbCell showCheck:checked]; // Show checked status
        
        //Adding Ink handler onto the thumb so that you can double-tap on a thumbnail
        [thumbCell INKEnableWithUTI:@"com.adobe.pdf" dynamicBlob:^INKBlob *{
            //Constructing the blob from the local data
            INKBlob *blob = [INKBlob blobFromLocalFile:document.fileURL];
            blob.filename = document.fileName;
            blob.uti = @"com.adobe.pdf";
            return blob;
        } returnBlock:^(INKBlob *result, INKAction *action, NSError *error) {
            //We chose to handle the return actions here rather than by registering return actions,
            //so we need to do a bit of checking to see if this was a case where the user
            //canceled their action, or where they have new data to pass back and overwrite the file with.
            if ([action.type isEqualToString:INKActionType_ReturnCancel]) {
                return;
            }
            [result.data writeToURL:document.fileURL atomically:YES];
        }];
	}
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView refreshThumbCell:(LibraryDocumentsCell *)thumbCell forIndex:(NSInteger)index
{
	ReaderDocument *document = [documents objectAtIndex:index];

	if (document.isDeleted == NO) // Document object must not be deleted
	{
		BOOL checked = document.isChecked; [thumbCell showCheck:checked];
	}
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView didSelectThumbWithIndex:(NSInteger)index
{
	ReaderDocument *document = [documents objectAtIndex:index];

	if (document.isDeleted == NO) // Document object must not be deleted
	{
		if (editMode == NO) // Check edit mode (or select mode)
		{
			CFURLRef fileURL = (__bridge CFURLRef)document.fileURL; // File URL

			if (CGPDFDocumentNeedsPassword(fileURL, document.password) == NO)
			{
				[delegate documentsView:self didSelectReaderDocument:document];
			}
			else // Open a password protected document
			{
				if (theTextEntry == nil) // Create text entry dialog view
				{
					theTextEntry = [[UIXTextEntry alloc] initWithFrame:self.bounds];

					theTextEntry.delegate = self; // Set the delegate to us

					[self addSubview:theTextEntry]; // Add text entry view
				}

				openDocument = document; // Retain the password protected document to open

				[theTextEntry setTitle:NSLocalizedString(@"DocumentPassword", @"title") withType:UIXTextEntryTypeSecure];

                [theTextEntry animateShow];
			}
		}
		else // Handle being in edit mode
		{
			if (document.isChecked == YES)
				[selected removeObject:document];
			else
				[selected addObject:document];

            [self updateButtonStates];

			document.isChecked = (document.isChecked ? NO : YES); // Toggle

			[thumbsView refreshThumbWithIndex:index]; // Refresh thumb
		}
	}
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView didPressThumbWithIndex:(NSInteger)index
{
	[self toggleEditMode]; // Toggle edit mode

	if (editMode == YES) // Handle being in edit mode
	{
		ReaderDocument *document = [documents objectAtIndex:index];

		if (document.isDeleted == NO) // Document object must not be deleted
		{
			[selected addObject:document]; document.isChecked = YES; // Select document

            [self updateButtonStates];

			[thumbsView refreshThumbWithIndex:index]; // Refresh thumb
		}
	}
}

#pragma mark UIXTextEntryDelegate methods

- (BOOL)textEntryShouldReturn:(UIXTextEntry *)textEntry text:(NSString *)text
{
	BOOL should = NO; // Default status

	if ((text != nil) && (text.length > 0)) // Validate input text
	{
		if (editMode == YES) // Handle being in edit (document rename) mode
		{
			NSCharacterSet *invalidSet = [NSCharacterSet characterSetWithCharactersInString:@"/:?*"];

			if ([text rangeOfCharacterFromSet:invalidSet].location == NSNotFound) // Valid document name
			{
				NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

				BOOL exists = [ReaderDocument existsInMOC:mainMOC name:[self addExtension:text]]; // Check

				NSString *status = (exists ? NSLocalizedString(@"DocumentAlreadyExists", @"text") : nil);

				[textEntry setStatus:status]; should = (exists ? NO : YES);
			}
			else // Document name is not valid - contains an invalid set character
			{
				[textEntry setStatus:NSLocalizedString(@"InvalidDocumentName", @"text")];
			}
		}
		else // Handle being in document password mode
		{
			if (openDocument.isDeleted == NO) // Document object must not be deleted
			{
				CFURLRef fileURL = (__bridge CFURLRef)openDocument.fileURL; // Document file URL

				should = ((CGPDFDocumentNeedsPassword(fileURL, text) == NO) ? YES : NO);

				NSString *status = (should ? nil : NSLocalizedString(@"IncorrectPassword", @"text"));

				[textEntry setStatus:status]; // Update the password status text
			}
		}
	}

	return should;
}

- (void)doneButtonTappedInTextEntry:(UIXTextEntry *)textEntry text:(NSString *)text
{
	if ((text != nil) && (text.length > 0)) // Validate input text
	{
		if (editMode == YES) // Handle being in edit (document rename) mode
		{
			NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

			if (selected.count == 1) // We can only rename a single selection
			{
				ReaderDocument *document = [selected anyObject]; // Selected document

				if (document.isDeleted == NO) // Document object must not be deleted
				{
					[ReaderDocument renameInMOC:mainMOC object:document name:[self addExtension:text]];
				}

				[self resetEditMode]; [self reloadDocumentsUpdated]; // Refresh display
			}
		}
		else // Handle being in document password mode
		{
			openDocument.password = text; // Set the document password to use

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 2)), dispatch_get_main_queue(),
			^{
				[delegate documentsView:self didSelectReaderDocument:openDocument]; openDocument = nil;
			});
		}
	}

	[theTextEntry animateHide];
}

- (void)cancelButtonTappedInTextEntry:(UIXTextEntry *)textEntry
{
	[theTextEntry animateHide]; openDocument = nil;
}

#pragma mark UIButton action methods

- (void)presentRenameAlert {
    if (selected.count == 1) // Rename single selection
    {
        if (theTextEntry == nil) // Create text entry dialog view
        {
            theTextEntry = [[UIXTextEntry alloc] initWithFrame:self.bounds];
            
            theTextEntry.delegate = self; // Set the delegate to us
            
            [self addSubview:theTextEntry]; // Add text entry view
        }
        
        ReaderDocument *document = [selected anyObject]; // Selected document
        
        [theTextEntry setTitle:NSLocalizedString(@"NewDocumentName", @"title") withType:UIXTextEntryTypeText];
        
        [theTextEntry setTextField:[self stripExtension:document.fileName]]; // Show document file name
        
        [theTextEntry animateShow];
    }
}

- (void)presentDeleteAlert
{
    if (theAlertView == nil) // Create the alert view the first time we need it
    {
        theAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ConfirmDeleteTitle", @"title")
                                                  message:NSLocalizedString(@"ConfirmDeleteMessage", @"message") delegate:self cancelButtonTitle:nil
                                        otherButtonTitles:NSLocalizedString(@"Delete", @"button"), NSLocalizedString(@"Cancel", @"button"), nil];
    }
    
    [theAlertView show]; // Show the alert view
}


- (void) presentFolderViewController
{
    if ([inFolder.type integerValue] != DocumentFolderTypeRecent)
    {
        if (foldersViewController == nil) // Create the FoldersViewController
        {
            foldersViewController = [[FoldersViewController alloc] initWithNibName:nil bundle:nil];
            
            foldersViewController.delegate = self; // Set the delegate to us
        }
        
        [foldersViewController reloadData]; // Reload view controller contents
        
        foldersViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        foldersViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self.ownViewController presentViewController:foldersViewController animated:YES completion:^{
            
        }];
    }
    else // Handle recent documents folder type
    {
        NSDate *lastOpened = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0];
        
        for (ReaderDocument *document in selected) // Enumerate through selected documents
        {
            document.lastOpen = lastOpened; // Reset documents last opened date
        }
        
        [[CoreDataManager sharedInstance] saveMainManagedObjectContext]; // Save changes
        
        [self resetEditMode]; [self reloadDocumentsUpdated]; // Refresh display
    }
}

#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) // Delete (or zeroth) button tapped
	{
		NSFileManager *fileManager = [NSFileManager new]; // File manager instance

		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

		for (ReaderDocument *document in selected) // Enumerate through selected documents
		{
			if (document.isDeleted == NO) // Document object must not be deleted
			{
				[ReaderDocument deleteInMOC:mainMOC object:document fm:fileManager]; // Delete it
			}
		}

		[[CoreDataManager sharedInstance] saveMainManagedObjectContext]; // Save delete changes

		[self resetEditMode]; [self reloadDocumentsUpdated]; // Refresh display
	}
}

#pragma mark FoldersViewControllerDelegate methods

- (void)foldersViewController:(FoldersViewController *)viewController didSelectObjectID:(NSManagedObjectID *)objectID
{
	if ([inFolder.objectID isEqual:objectID] == NO) // Only if current and target are different
	{
		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

		DocumentFolder *folder = (DocumentFolder *)[mainMOC existingObjectWithID:objectID error:NULL];

		DocumentFolderType type = [folder.type integerValue]; // Get target document folder type

		for (ReaderDocument *document in selected) // Enumerate through the selected documents
		{
			document.folder = ((type != DocumentFolderTypeDefault) ? folder : nil); // Update
		}

		[[CoreDataManager sharedInstance] saveMainManagedObjectContext]; // Save changes

		[self resetEditMode]; [self reloadDocumentsUpdated]; // Refresh display
	}

    [self.ownViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)dismissFoldersViewController:(FoldersViewController *)viewController
{
    [self.ownViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark DocumentsUpdate notifications

- (void)openedNewDocument:(NSNotification *)notification
{
	assert(inFolder != nil); // Must not be nil

	if ([inFolder.type integerValue] == DocumentFolderTypeDefault)
	{
		[self resetEditMode]; [self reloadDocumentsUpdated]; // Refresh display
	}
}

- (void)documentsDidUpdate:(NSNotification *)notification
{
	BOOL reload = NO; // Reload flag

	assert(inFolder != nil); // Must not be nil

	NSDictionary *userInfo = notification.userInfo; // User info dictionary

	NSMutableSet *addedObjectIDs = [userInfo objectForKey:DocumentsUpdateAddedObjectIDs];

	NSMutableSet *deletedObjectIDs = [userInfo objectForKey:DocumentsUpdateDeletedObjectIDs];

	if (deletedObjectIDs != nil) // Handle having deleted objects
	{
		NSMutableSet *objectIDs = [NSMutableSet new]; // Visible object ID set

		for (ReaderDocument *document in documents) // Enumerate through documents
		{
			[objectIDs addObject:[document objectID]]; // Add object ID to set
		}

		reload = [objectIDs intersectsSet:deletedObjectIDs]; 
	}

	if (reload == NO) // Handle having added objects and showing the default documents folder
	{
		reload = ((addedObjectIDs != nil) && ([inFolder.type integerValue] == DocumentFolderTypeDefault));
	}

	if (reload == YES) { [self resetEditMode]; [self reloadDocumentsUpdated]; } // Refresh display
}

#pragma mark UIApplication notifications

- (void)willResignActive:(NSNotification *)notification
{
	if ((theAlertView != nil) && (theAlertView.visible == YES))
	{
		[theAlertView dismissWithClickedButtonIndex:(-1) animated:NO];
	}
}

@end

#pragma mark -

//
//	LibraryDocumentsCell class implementation
//

@implementation LibraryDocumentsCell
{
	UIView *backView;

	UIView *maskView;

	UIView *titleView;

	UILabel *titleLabel;

	UIImageView *checkIcon;

	CGSize maximumSize;

	CGRect defaultRect;
}

#pragma mark Constants

#define CONTENT_INSET 8.0f

#define TITLE_INSET_SMALL 8.0f
#define TITLE_INSET_LARGE 12.0f

#define CHECK_INSET 4.0f

#pragma mark LibraryDocumentsCell instance methods

- (CGRect)checkRectInImageView
{
	CGRect iconRect = checkIcon.frame; iconRect.origin.y = CHECK_INSET;

	iconRect.origin.x = (imageView.bounds.size.width - checkIcon.image.size.width - CHECK_INSET);

	return iconRect; // Frame position rect inside of image view
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		imageView.contentMode = UIViewContentModeCenter;

		defaultRect = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);

		maximumSize = defaultRect.size; // Maximum thumb content size

		CGFloat newWidth = ((defaultRect.size.width / 4.0f) * 3.0f);

		CGFloat offsetX = ((defaultRect.size.width - newWidth) / 2.0f);

		defaultRect.size.width = newWidth; defaultRect.origin.x += offsetX;

		imageView.frame = defaultRect; // Update the image view frame

		BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);

		CGFloat titleInset = (large ? TITLE_INSET_LARGE : TITLE_INSET_SMALL);

		CGRect titleRect = CGRectInset(defaultRect, titleInset, titleInset);

		titleRect.size.height /= 2.0f; // Half size title view height

		titleView = [[UIView alloc] initWithFrame:titleRect];

		titleView.autoresizesSubviews = NO;
		titleView.userInteractionEnabled = NO;
		titleView.contentMode = UIViewContentModeRedraw;
		titleView.autoresizingMask = UIViewAutoresizingNone;
		titleView.backgroundColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
		titleView.layer.borderColor = [UIColor colorWithWhite:0.86f alpha:1.0f].CGColor;
		titleView.layer.borderWidth = 1.0f; // Draw border around title view

		CGRect labelRect = titleView.bounds;

		titleLabel = [[UILabel alloc] initWithFrame:labelRect];

		titleLabel.autoresizesSubviews = NO;
		titleLabel.userInteractionEnabled = NO;
		titleLabel.contentMode = UIViewContentModeRedraw;
		titleLabel.autoresizingMask = UIViewAutoresizingNone;
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.font = [UIFont systemFontOfSize:13.0f];
		titleLabel.textColor = [UIColor colorWithWhite:0.16f alpha:1.0f];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
		titleLabel.numberOfLines = 0; // Fit in bounds

		[titleView addSubview:titleLabel]; // Add label to text view

		[self insertSubview:titleView belowSubview:imageView]; // Insert

		backView = [[UIView alloc] initWithFrame:defaultRect];

		backView.autoresizesSubviews = NO;
		backView.userInteractionEnabled = NO;
		backView.contentMode = UIViewContentModeRedraw;
		backView.autoresizingMask = UIViewAutoresizingNone;
		backView.backgroundColor = [UIColor colorWithWhite:0.98f alpha:1.0f];

#if (READER_SHOW_SHADOWS == TRUE) // Option

		backView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
		backView.layer.shadowRadius = 4.0f; backView.layer.shadowOpacity = 1.0f;
		backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option

		[self insertSubview:backView belowSubview:titleView]; // Insert

		maskView = [[UIView alloc] initWithFrame:imageView.bounds];

		maskView.hidden = YES;
		maskView.autoresizesSubviews = NO;
		maskView.userInteractionEnabled = NO;
		maskView.contentMode = UIViewContentModeRedraw;
		maskView.autoresizingMask = UIViewAutoresizingNone;
		maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];

		[imageView addSubview:maskView]; // Add

		UIImage *image = [UIImage imageNamed:@"Icon-Checked"];

		checkIcon = [[UIImageView alloc] initWithImage:image];

		checkIcon.hidden = YES;
		checkIcon.autoresizesSubviews = NO;
		checkIcon.userInteractionEnabled = NO;
		checkIcon.contentMode = UIViewContentModeCenter;
		checkIcon.autoresizingMask = UIViewAutoresizingNone;
		checkIcon.frame = [self checkRectInImageView];

		[imageView addSubview:checkIcon]; // Add
	}


	return self;
}

- (CGSize)maximumContentSize
{
	return maximumSize;
}

- (void)showImage:(UIImage *)image
{
	titleView.hidden = YES; // Hide title view

	NSInteger x = (self.bounds.size.width / 2.0f);
	NSInteger y = (self.bounds.size.height / 2.0f);

	CGPoint location = CGPointMake(x, y); // Center point

	CGRect viewRect = CGRectZero; viewRect.size = image.size; // Position

	imageView.bounds = viewRect; imageView.center = location; imageView.image = image;

	checkIcon.frame = [self checkRectInImageView]; // Position the check mark image

	maskView.frame = imageView.bounds; backView.bounds = viewRect; backView.center = location;

#if (READER_SHOW_SHADOWS == TRUE) // Option

	backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option
}

- (void)reuse
{
	[super reuse]; // Reuse thumb view

	titleLabel.text = nil; titleView.hidden = NO;

	imageView.image = nil; imageView.frame = defaultRect;

	checkIcon.hidden = YES; checkIcon.frame = [self checkRectInImageView];

	maskView.hidden = YES; maskView.frame = imageView.bounds; backView.frame = defaultRect;

#if (READER_SHOW_SHADOWS == TRUE) // Option

	backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option
}

- (void)showCheck:(BOOL)checked
{
	checkIcon.hidden = (checked ? NO : YES);
}

- (void)showTouched:(BOOL)touched
{
	maskView.hidden = (touched ? NO : YES);
}

- (void)showText:(NSString *)text
{
	titleLabel.text = text;
}

@end
