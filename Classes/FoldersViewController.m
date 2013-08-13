//
//	FoldersViewController.m
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
#import "FoldersViewController.h"
#import "CoreDataManager.h"
#import "DocumentFolder.h"
#import "UIXToolbarView.h"

@interface FoldersViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FoldersViewController
{
	UIXToolbarView *theToolbar;

	UILabel *theTitleLabel;

	UITableView *theTableView;

	NSMutableArray *folders;
}

#pragma mark Constants

#define BUTTON_Y 7.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define TITLE_Y 8.0f
#define TITLE_HEIGHT 28.0f

#define CANCEL_BUTTON_WIDTH 56.0f

#define TOOLBAR_HEIGHT 44.0f

#define MAXIMUM_TABLE_WIDTH 288.0f
#define MAXIMUM_TABLE_HEIGHT 464.0f

#define TABLE_CELL_HEIGHT 42.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark UIViewController methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		folders = [NSMutableArray new]; // Document folders list
	}

	return self;
}

- (void)reloadData
{
	[folders removeAllObjects]; // Remove all document folders from list

	NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

	NSArray *folderList = [DocumentFolder allInMOC:mainMOC]; // Get current folder list

	for (DocumentFolder *folder in folderList) // Enumerate thru current folder list
	{
		if ([folder.type integerValue] != DocumentFolderTypeRecent) [folders addObject:folder];
	}

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		CGFloat maxHeight = ((TABLE_CELL_HEIGHT * folders.count) + TOOLBAR_HEIGHT);

		if (maxHeight > MAXIMUM_TABLE_HEIGHT) maxHeight = MAXIMUM_TABLE_HEIGHT; // Limit height

		self.contentSizeForViewInPopover = CGSizeMake(MAXIMUM_TABLE_WIDTH, maxHeight);
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	assert(delegate != nil); // Check delegate

	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

	CGRect viewRect = self.view.bounds; // View controller's view bounds

	CGRect toolbarRect = viewRect; toolbarRect.size.height = TOOLBAR_HEIGHT;

	theToolbar = [[UIXToolbarView alloc] initWithFrame:toolbarRect]; // At top

	CGFloat toolbarWidth = theToolbar.bounds.size.width; // Toolbar width

	CGFloat titleX = BUTTON_SPACE; CGFloat titleWidth = (toolbarWidth - (BUTTON_SPACE + BUTTON_SPACE));

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
		UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H"];
		UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N"];

		UIImage *buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
		UIImage *buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];

		titleWidth -= (CANCEL_BUTTON_WIDTH + BUTTON_SPACE); // Adjust title width

		CGFloat rightButtonX = (toolbarWidth - (CANCEL_BUTTON_WIDTH + BUTTON_SPACE)); // X

		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom]; // Cancel button

		cancelButton.frame = CGRectMake(rightButtonX, BUTTON_Y, CANCEL_BUTTON_WIDTH, BUTTON_HEIGHT);
		[cancelButton setTitle:NSLocalizedString(@"Cancel", @"button") forState:UIControlStateNormal];
		[cancelButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[cancelButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[cancelButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[cancelButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		cancelButton.exclusiveTouch = YES;

		[theToolbar addSubview:cancelButton]; // Add to toolbar
	}
	else // Large device
	{
		self.contentSizeForViewInPopover = CGSizeMake(MAXIMUM_TABLE_WIDTH, MAXIMUM_TABLE_HEIGHT);
	}

	CGRect titleRect = CGRectMake(titleX, TITLE_Y, titleWidth, TITLE_HEIGHT);

	theTitleLabel = [[UILabel alloc] initWithFrame:titleRect];

	theTitleLabel.textAlignment = UITextAlignmentCenter;
	theTitleLabel.font = [UIFont systemFontOfSize:19.0f];
	theTitleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
	theTitleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];
	theTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	theTitleLabel.backgroundColor = [UIColor clearColor];
	theTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);

	theTitleLabel.text = NSLocalizedString(@"Folders", @"title");

	[theToolbar addSubview:theTitleLabel]; // Add title to toolbar

	[self.view addSubview:theToolbar]; // Add toolbar to controller view

	CGRect tableRect = viewRect; tableRect.origin.y += TOOLBAR_HEIGHT; tableRect.size.height -= TOOLBAR_HEIGHT;

	theTableView = [[UITableView alloc] initWithFrame:tableRect]; // Rest of view

	theTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	theTableView.dataSource = self; theTableView.delegate = self; // Set the delegates to self

	theTableView.rowHeight = TABLE_CELL_HEIGHT;

	[self.view addSubview:theTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[theTableView reloadData]; // Reload table data

	theTableView.contentOffset = CGPointZero;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[theTableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[folders removeAllObjects];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
	theToolbar = nil;

	theTitleLabel = nil;

	theTableView = nil;

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
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
}
*/

/*
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}
*/

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([delegate respondsToSelector:@selector(foldersViewController:didSelectObjectID:)])
	{
		DocumentFolder *folder = [folders objectAtIndex:indexPath.row]; // Folder at row

		[delegate foldersViewController:self didSelectObjectID:[folder objectID]];
	}
}

#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tvCellFolder"];

	if (cell == nil) // Create a brand new UITableViewCell for our use
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tvCellFolder"];

		cell.textLabel.font = [UIFont systemFontOfSize:17.0]; cell.textLabel.textAlignment = UITextAlignmentCenter;

		cell.selectionStyle = UITableViewCellSelectionStyleGray; // Use gray instead of blue
	}

	DocumentFolder *folder = [folders objectAtIndex:indexPath.row]; // Folder at row

	cell.textLabel.text = folder.name;

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return (folders.count);
}

#pragma mark UIButton action methods

- (void)cancelButtonTapped:(UIButton *)button
{
	[delegate dismissFoldersViewController:self];
}

@end
