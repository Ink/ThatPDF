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
#import "LibraryDirectoryViewController.h"
#import "LibraryDocumentsViewController.h"
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
#import "INKWelcomeViewController.h"
#import "HelpViewController.h"

@interface LibraryDirectoryViewController () <LibraryDirectoryDelegate, HelpViewControllerDelegate>

@end

@implementation LibraryDirectoryViewController
{
    HelpViewController *helpViewController;
    
	UIPopoverController *popoverController;

	LibraryDirectoryView *directoryView;

    LibraryDocumentsViewController *documentsViewController;
    
    LibraryUpdatingView *updatingView;
    
    UIBarButtonItem *checkButton;
    UIBarButtonItem *plusButton;
}

#pragma mark Constants

#define DEFAULT_DURATION 0.3

#pragma mark Properties

@synthesize delegate;

#pragma mark Support methods


- (void)showReaderDocument:(ReaderDocument *)document
{
    if (![self.navigationController.viewControllers containsObject:documentsViewController]) {
        [self.navigationController pushViewController:documentsViewController animated:NO];
    }
    [documentsViewController showReaderDocument:document];
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
    
    self.navigationItem.title = @"Library";
    
    directoryView = [[LibraryDirectoryView alloc] initWithFrame:self.view.bounds];
    directoryView.delegate = self; directoryView.ownViewController = self;
    [self.view addSubview:directoryView];
    
    documentsViewController = [[LibraryDocumentsViewController alloc] initWithNibName:nil bundle:nil];
    
    [self setupToolbar];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [directoryView reloadDirectory];
    
    if ([INKWelcomeViewController shouldRunWelcomeFlow]) {
        INKWelcomeViewController * welcomeViewController;
        welcomeViewController = [[INKWelcomeViewController alloc] initWithNibName:@"INKWelcomeViewController" bundle:nil];
        [self presentViewController:welcomeViewController animated:NO completion:^{}];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
	directoryView = nil;

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
	[directoryView handleMemoryWarning];

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Toolbar methods

- (void)setupToolbar {
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [infoButton addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    checkButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon-SelectFolder"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(checkButtonTapped:)];
    
    plusButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon-NewFolder"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(plusButtonTapped:)];
    
    self.navigationItem.rightBarButtonItems = @[checkButton, plusButton];
}

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
        
		[self presentViewController:helpViewController animated:YES completion:^{
            
        }];
	}
}

- (void)checkButtonTapped:(id)sender {
    [directoryView toggleEditMode];
}

- (void)plusButtonTapped:(id)sender {
    if (directoryView.editMode) {
        [directoryView presentConfirmDeleteAlert];
    } else {
        [directoryView presentAddFolderAlert];
    }
}

#pragma mark HelpViewControllerDelegate methods

- (void)dismissHelpViewController:(HelpViewController *)viewController {
    if (popoverController.popoverVisible) {
        [popoverController dismissPopoverAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark LibraryDirectoryDelegate methods

- (void)directoryView:(LibraryDirectoryView *)directoryView didSelectDocumentFolder:(DocumentFolder *)folder
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; // User defaults

	NSString *folderURI = [[[folder objectID] URIRepresentation] absoluteString]; // Folder URI

	[userDefaults setObject:folderURI forKey:kReaderSettingsCurrentFolder]; // Default folder

    //Touch the view so we can be sure it loads
    UIView *docView = documentsViewController.view;
	[documentsViewController reloadDocumentsWithFolder:folder]; // Reload documents view
    
    [self.navigationController pushViewController:documentsViewController animated:YES];
}

- (void)updateButtonStatesForEditMode:(BOOL)editMode countSelected:(NSInteger)selected {
    plusButton.enabled = (editMode && selected == 0 ? NO : YES); // Set button enabled state
    
	UIImage *checkImage = [UIImage imageNamed:(editMode ? @"Icon-Cross" : @"Icon-SelectFolder")]; // Image
    
	checkButton.image = checkImage;
    
	UIImage *newFolderImage = [UIImage imageNamed:(editMode ? @"Icon-DeleteFolder" : @"Icon-NewFolder")]; // Image
    
	plusButton.image = newFolderImage;
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
		titleLabel.textAlignment = NSTextAlignmentCenter;

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
