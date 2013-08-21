//
//	LibraryDirectoryView.m
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
#import "LibraryDirectoryView.h"
#import "HelpViewController.h"
#import "CoreDataManager.h"
#import "DocumentFolder.h"
#import "UIXToolbarView.h"
#import "UIXTextEntry.h"

#import <QuartzCore/QuartzCore.h>

@interface LibraryDirectoryView () <ReaderThumbsViewDelegate, UIXTextEntryDelegate, HelpViewControllerDelegate,
									UIAlertViewDelegate, UIPopoverControllerDelegate>
@end

@implementation LibraryDirectoryView
{
	HelpViewController *helpViewController;

	UIPopoverController *popoverController;

	NSArray *directories;

	NSMutableSet *selected;

	UIXToolbarView *theToolbar;

	ReaderThumbsView *theThumbsView;

	UIXTextEntry *theTextEntry;

	UIAlertView *theAlertView;

	UIButton *theCheckButton;
	UIButton *thePlusButton;

	UILabel *theTitleLabel;

	BOOL editMode;
}

#pragma mark Constants

#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f
#define TITLE_HEIGHT 28.0f

#define INFO_BUTTON_WIDTH 32.0f
#define CHECK_BUTTON_WIDTH 36.0f
#define PLUS_BUTTON_WIDTH 36.0f
#define EDIT_BUTTON_WIDTH 44.0f

#define TOOLBAR_HEIGHT 44.0f

#define THUMB_WIDTH_LARGE_DEVICE 192
#define THUMB_HEIGHT_LARGE_DEVICE 120

#define THUMB_WIDTH_SMALL_DEVICE 160
#define THUMB_HEIGHT_SMALL_DEVICE 104

#pragma mark Properties

@synthesize delegate;
@synthesize ownViewController;

#pragma mark Support methods

- (void)updateButtonStates
{
	thePlusButton.enabled = (editMode ? NO : YES); // Set button enabled state

	UIImage *checkImage = [UIImage imageNamed:(editMode ? @"Icon-Cross" : @"Icon-SelectFolder")]; // Image

	[theCheckButton setImage:checkImage forState:UIControlStateNormal]; // Set check button image

	UIImage *newFolderImage = [UIImage imageNamed:(editMode ? @"Icon-DeleteFolder" : @"Icon-NewFolder")]; // Image

	[thePlusButton setImage:newFolderImage forState:UIControlStateNormal]; // Set plus button image
}

- (void)resetSelectedFolders
{
	for (DocumentFolder *folder in selected)
	{
		folder.isChecked = NO; // Clear selection
	}

	[selected removeAllObjects]; // Empty the set
}

- (void)toggleEditMode
{
	editMode = (editMode ? NO : YES); // Toggle

	[self updateButtonStates]; // Update buttons

	if (editMode == NO) // Check edit mode
	{
		[self resetSelectedFolders]; // Clear selections

		[theThumbsView refreshVisibleThumbs]; // Refresh
	}
}

- (void)resetEditMode
{
	editMode = NO; // Clear edit mode state

	[self resetSelectedFolders]; // Clear selections

	[self updateButtonStates]; // Update buttons
}

#pragma mark LibraryDirectoryView instance methods

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

		CGRect toolbarRect = viewRect; toolbarRect.size.height = TOOLBAR_HEIGHT;

		theToolbar = [[UIXToolbarView alloc] initWithFrame:toolbarRect]; // At top

		BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);

		CGFloat buttonSpace = (large ? BUTTON_SPACE : 0.0f); CGFloat toolbarWidth = theToolbar.bounds.size.width;

		CGFloat leftButtonX = buttonSpace; CGFloat titleX = buttonSpace; CGFloat titleWidth = (toolbarWidth - (buttonSpace + buttonSpace));

		UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];

		infoButton.frame = CGRectMake(leftButtonX, BUTTON_Y, INFO_BUTTON_WIDTH, BUTTON_HEIGHT);
		[infoButton addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		infoButton.autoresizingMask = UIViewAutoresizingNone;
		infoButton.showsTouchWhenHighlighted = YES;
		infoButton.exclusiveTouch = YES;

		[theToolbar addSubview:infoButton]; // Add to toolbar

		titleX += (INFO_BUTTON_WIDTH + buttonSpace); titleWidth -= (INFO_BUTTON_WIDTH + buttonSpace);

		CGFloat rightButtonX = (toolbarWidth - (CHECK_BUTTON_WIDTH + buttonSpace));

		theCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];

		theCheckButton.frame = CGRectMake(rightButtonX, BUTTON_Y, CHECK_BUTTON_WIDTH, BUTTON_HEIGHT);
		[theCheckButton setImage:[UIImage imageNamed:@"Icon-SelectFolder"] forState:UIControlStateNormal];
		[theCheckButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		theCheckButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		theCheckButton.showsTouchWhenHighlighted = YES;
		theCheckButton.exclusiveTouch = YES;

		[theToolbar addSubview:theCheckButton]; // Add to toolbar

		titleWidth -= (CHECK_BUTTON_WIDTH + buttonSpace); // Adjust title width

		rightButtonX -= (PLUS_BUTTON_WIDTH + buttonSpace); // Next button position

		thePlusButton = [UIButton buttonWithType:UIButtonTypeCustom];

		thePlusButton.frame = CGRectMake(rightButtonX, BUTTON_Y, PLUS_BUTTON_WIDTH, BUTTON_HEIGHT);
		[thePlusButton setImage:[UIImage imageNamed:@"Icon-NewFolder"] forState:UIControlStateNormal];
		[thePlusButton addTarget:self action:@selector(plusButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		thePlusButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		thePlusButton.showsTouchWhenHighlighted = YES;
		thePlusButton.exclusiveTouch = YES;

		[theToolbar addSubview:thePlusButton]; // Add to toolbar

		titleWidth -= (PLUS_BUTTON_WIDTH + buttonSpace); // Adjust title width

		rightButtonX -= (EDIT_BUTTON_WIDTH + buttonSpace); // Next button position

		CGRect titleRect = CGRectMake(titleX, BUTTON_Y, titleWidth, TITLE_HEIGHT);

		theTitleLabel = [[UILabel alloc] initWithFrame:titleRect];

		theTitleLabel.textAlignment = NSTextAlignmentCenter;
		theTitleLabel.font = [UIFont systemFontOfSize:19.0f];
		theTitleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
		theTitleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];
		theTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		theTitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		theTitleLabel.backgroundColor = [UIColor clearColor];
		theTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		theTitleLabel.adjustsFontSizeToFitWidth = YES;
		theTitleLabel.minimumScaleFactor = 14.0f/19.f;

		theTitleLabel.text = NSLocalizedString(@"ThatPDF Document Library", @"text");

		[theToolbar addSubview:theTitleLabel]; // Add to toolbar

		[self addSubview:theToolbar]; // Add toolbar to container view

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

		[self insertSubview:theThumbsView belowSubview:theToolbar]; // Add to container view

		NSInteger thumbWidth = (large ? THUMB_WIDTH_LARGE_DEVICE : THUMB_WIDTH_SMALL_DEVICE); // Width

		NSInteger thumbHeight = (large ? THUMB_HEIGHT_LARGE_DEVICE : THUMB_HEIGHT_SMALL_DEVICE); // Height

		[theThumbsView setThumbSize:CGSizeMake(thumbWidth, thumbHeight)]; // Thumb size based on device

		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

		[notificationCenter addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

		selected = [NSMutableSet new]; // Selected folders set
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

- (void)reloadDirectory
{
	directories = nil; // Release any old directory list

	NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

	directories = [DocumentFolder allInMOC:mainMOC]; // Get current directory list

	[theThumbsView reloadThumbsContentOffset:CGPointZero];
}

#pragma mark ReaderThumbsViewDelegate methods

- (NSUInteger)numberOfThumbsInThumbsView:(ReaderThumbsView *)thumbsView
{
	return (directories.count);
}

- (id)thumbsView:(ReaderThumbsView *)thumbsView thumbCellWithFrame:(CGRect)frame
{
	return [[LibraryDirectoryCell alloc] initWithFrame:frame];
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView updateThumbCell:(LibraryDirectoryCell *)thumbCell forIndex:(NSInteger)index
{
	DocumentFolder *folder = [directories objectAtIndex:index];

	if (folder.isDeleted == NO) // Object must not be deleted
	{
		BOOL checked = folder.isChecked; [thumbCell showCheck:checked];

		NSString *name = folder.name; [thumbCell showText:name];
	}
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView refreshThumbCell:(LibraryDirectoryCell *)thumbCell forIndex:(NSInteger)index
{
	DocumentFolder *folder = [directories objectAtIndex:index];

	if (folder.isDeleted == NO) // Object must not be deleted
	{
		BOOL checked = folder.isChecked; [thumbCell showCheck:checked];
	}
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView didSelectThumbWithIndex:(NSInteger)index
{
	DocumentFolder *folder = [directories objectAtIndex:index];

	if (editMode == NO) // Check edit mode
	{
		[delegate directoryView:self didSelectDocumentFolder:folder];
	}
	else // Handle being in edit mode
	{
		if (folder.isChecked == YES)
			[selected removeObject:folder];
		else
			[selected addObject:folder];

		thePlusButton.enabled = ((selected.count > 0) ? YES : NO);

		folder.isChecked = (folder.isChecked ? NO : YES); // Toggle

		[thumbsView refreshThumbWithIndex:index]; // Refresh thumb
	}
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView didPressThumbWithIndex:(NSInteger)index
{
	[self toggleEditMode]; // Toggle edit mode

	if (editMode == YES) // Handle being in edit mode
	{
		DocumentFolder *folder = [directories objectAtIndex:index];

		[selected addObject:folder]; folder.isChecked = YES; // Select folder

		thePlusButton.enabled = YES; // Enable buttons

		[thumbsView refreshThumbWithIndex:index]; // Refresh thumb
	}
}

#pragma mark UIXTextEntryDelegate methods

- (BOOL)textEntryShouldReturn:(UIXTextEntry *)textEntry text:(NSString *)text
{
	BOOL should = NO; // Default status

	if ((text != nil) && (text.length > 0)) // Validate input text
	{
		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

		BOOL exists = [DocumentFolder existsInMOC:mainMOC name:text]; // Test for existing folder

		NSString *status = (exists ? NSLocalizedString(@"FolderAlreadyExists", @"text") : nil);

		[textEntry setStatus:status]; should = (exists ? NO : YES);
	}

	return should;
}

- (void)doneButtonTappedInTextEntry:(UIXTextEntry *)textEntry text:(NSString *)text
{
	if ((text != nil) && (text.length > 0)) // Validate input text
	{
		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

		if (editMode == NO) // Check edit mode
		{
			DocumentFolder *folder = [DocumentFolder insertInMOC:mainMOC name:text type:DocumentFolderTypeUser];

			if (folder != nil) [self reloadDirectory]; // Refresh folder display
		}
		else // Handle being in edit mode
		{
			if (selected.count == 1) // Rename single selection
			{
				DocumentFolder *folder = [selected anyObject]; // Selected folder

				[DocumentFolder renameInMOC:mainMOC objectID:[folder objectID] name:text];

				[self resetEditMode]; [self reloadDirectory]; // Refresh folder display
			}
		}
	}

	[theTextEntry animateHide]; [delegate enableContainerScrollView:YES];
}

- (void)cancelButtonTappedInTextEntry:(UIXTextEntry *)textEntry
{
	[theTextEntry animateHide]; [delegate enableContainerScrollView:YES];
}

#pragma mark UIButton action methods

- (void)infoButtonTapped:(UIButton *)button
{
	if (helpViewController == nil) // Create the HelpViewController
	{
		helpViewController = [[HelpViewController alloc] initWithNibName:nil bundle:nil];

		helpViewController.delegate = self; // Set the delegate to us
	}

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) // Popover
	{
		if (popoverController == nil) // Create a UIPopoverController for the HelpViewController
		{
			popoverController = [[UIPopoverController alloc] initWithContentViewController:helpViewController];

			//popoverController.delegate = self; // Set the delegate to us
		}

		if (popoverController.popoverVisible == NO) // Show popover
		{
			popoverController.popoverContentSize = helpViewController.contentSizeForViewInPopover;

			[popoverController presentPopoverFromRect:button.frame inView:button.superview permittedArrowDirections:1 animated:YES];
		}
		else // Dismiss the popover
		{
			[popoverController dismissPopoverAnimated:YES];
		}
	}
	else // Modal view controller
	{
		helpViewController.modalPresentationStyle = UIModalPresentationFullScreen;
		helpViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

		[self.ownViewController presentViewController:helpViewController animated:YES completion:^{
            
        }];
	}
}

- (void)checkButtonTapped:(UIButton *)button
{
	[self toggleEditMode]; // Toggle edit mode
}

- (void)editButtonTapped:(UIButton *)button
{
	if (editMode == YES) // Check edit mode
	{
		if (selected.count == 1) // Rename single selection
		{
			if (theTextEntry == nil) // Create text entry dialog view
			{
				theTextEntry = [[UIXTextEntry alloc] initWithFrame:self.bounds];

				theTextEntry.delegate = self; // Set the delegate to us

				[self addSubview:theTextEntry]; // Add view
			}

			DocumentFolder *folder = [selected anyObject]; // Selected folder

			[theTextEntry setTitle:NSLocalizedString(@"NewFolderName", @"title") withType:UIXTextEntryTypeText];

			[theTextEntry setTextField:folder.name]; // Start with current folder name

			[delegate enableContainerScrollView:NO]; [theTextEntry animateShow];
		}
	}
}

- (void)plusButtonTapped:(UIButton *)button
{
	if (editMode == NO) // Check edit mode
	{
		if (theTextEntry == nil) // Create text entry dialog view
		{
			theTextEntry = [[UIXTextEntry alloc] initWithFrame:self.bounds];

			theTextEntry.delegate = self; // Set the delegate to us

			[self addSubview:theTextEntry]; // Add view
		}

		[theTextEntry setTitle:NSLocalizedString(@"NewFolderName", @"title") withType:UIXTextEntryTypeText];

		[delegate enableContainerScrollView:NO]; [theTextEntry animateShow];
	}
	else // Handle being in edit mode
	{
		if (theAlertView == nil) // Create the alert view the first time we need it
		{
			theAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ConfirmDeleteTitle", @"title")
							message:NSLocalizedString(@"ConfirmDeleteMessage", @"message") delegate:self cancelButtonTitle:nil
							otherButtonTitles:NSLocalizedString(@"Delete", @"button"), NSLocalizedString(@"Cancel", @"button"), nil];
		}

		[theAlertView show]; // Show the alert view
	}
}

#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) // Delete (or zeroth) button tapped
	{
		NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

		for (DocumentFolder *folder in selected) // Enumerate through selected folders
		{
            int type =[folder.type integerValue];
			if (type == DocumentFolderTypeUser || type == DocumentFolderTypeSamples) // Only user folders or sample folder
			{
				[DocumentFolder deleteInMOC:mainMOC objectID:[folder objectID]]; // Delete
			}
		}

		[self resetEditMode]; [self reloadDirectory]; // Refresh folder display

		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

		[notificationCenter postNotificationName:DocumentFoldersDeletedNotification object:nil userInfo:nil];
	}
}

#pragma mark HelpViewControllerDelegate methods

- (void)dismissHelpViewController:(HelpViewController *)viewController
{
	[self.ownViewController dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark UIApplication notifications

- (void)willResignActive:(NSNotification *)notification
{
	if ((theAlertView != nil) && (theAlertView.visible == YES))
	{
		[theAlertView dismissWithClickedButtonIndex:(-1) animated:NO];
	}

	if ((popoverController != nil) && (popoverController.popoverVisible == YES))
	{
		[popoverController dismissPopoverAnimated:NO];
	}
}

@end

#pragma mark -

//
//	LibraryDirectoryCell class implementation
//

@implementation LibraryDirectoryCell
{
	UILabel *textLabel;

	UIImageView *checkIcon;

	CGRect defaultRect;
}

#pragma mark Constants

#define CONTENT_INSET 8.0f

#define TEXT_INSET_WIDTH_LARGE 32.0f
#define TEXT_INSET_HEIGHT_LARGE 24.0f

#define TEXT_INSET_WIDTH_SMALL 20.0f
#define TEXT_INSET_HEIGHT_SMALL 16.0f

#define CHECK_IMAGE_X_LARGE 126.0f
#define CHECK_IMAGE_Y_LARGE 28.0f

#define CHECK_IMAGE_X_SMALL 108.0f
#define CHECK_IMAGE_Y_SMALL 20.0f

#pragma mark LibraryDirectoryCell instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		imageView.contentMode = UIViewContentModeCenter;

		defaultRect = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);

		BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);

		NSString *folderImageName = (large ? @"Folder-Large" : @"Folder-Small");

		CGFloat textInsetWidth = (large ? TEXT_INSET_WIDTH_LARGE : TEXT_INSET_WIDTH_SMALL);
		CGFloat textInsetHeight = (large ? TEXT_INSET_HEIGHT_LARGE : TEXT_INSET_HEIGHT_SMALL);

		CGFloat checkImageX = (large ? CHECK_IMAGE_X_LARGE : CHECK_IMAGE_X_SMALL);
		CGFloat checkImageY = (large ? CHECK_IMAGE_Y_LARGE : CHECK_IMAGE_Y_SMALL);

		imageView.frame = defaultRect; // Update image view frame
		imageView.image = [UIImage imageNamed:folderImageName];

		CGRect textRect = CGRectInset(defaultRect, textInsetWidth, textInsetHeight);

		textRect.size.height += 2.0f; // Adjust for background folder image

		textLabel = [[UILabel alloc] initWithFrame:textRect];

		textLabel.autoresizesSubviews = NO;
		textLabel.contentMode = UIViewContentModeRedraw;
		textLabel.autoresizingMask = UIViewAutoresizingNone;
		textLabel.font = [UIFont systemFontOfSize:(large ? 17.0f : 16.0f)];
		textLabel.textColor = [UIColor colorWithWhite:0.24f alpha:1.0f];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.textAlignment = NSTextAlignmentCenter;
		//textLabel.adjustsFontSizeToFitWidth = YES;
		//textLabel.minimumFontSize = 14.0f;
		//textLabel.layer.cornerRadius = 4.0f;
		textLabel.numberOfLines = 0;

		[self insertSubview:textLabel aboveSubview:imageView];

		UIImage *image = [UIImage imageNamed:@"Icon-Checked"];

		checkIcon = [[UIImageView alloc] initWithImage:image];

		CGRect checkRect = checkIcon.frame;
		checkRect.origin = CGPointMake(checkImageX, checkImageY);
		checkIcon.frame = checkRect; checkIcon.hidden = YES;

		[self insertSubview:checkIcon aboveSubview:textLabel];
	}

	return self;
}

- (void)reuse
{
	checkIcon.hidden = YES; textLabel.text = nil;

	textLabel.backgroundColor = [UIColor clearColor];
}

- (void)showCheck:(BOOL)checked
{
	checkIcon.hidden = (checked ? NO : YES);
}

- (void)showTouched:(BOOL)touched
{
	textLabel.backgroundColor = (touched ? [UIColor colorWithWhite:0.0f alpha:0.2f] : [UIColor clearColor]);
}

- (void)showText:(NSString *)text
{
	textLabel.text = text;
}

@end
