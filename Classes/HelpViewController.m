//
//	HelpViewController.m
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

#import "HelpViewController.h"
#import "UIXToolbarView.h"

@interface HelpViewController () <UIWebViewDelegate>

@end

@implementation HelpViewController
{
	UIXToolbarView *theToolbar;

	UILabel *theTitleLabel;

	UIWebView *theWebView;

	BOOL htmlLoaded;
}

#pragma mark Constants

#define BUTTON_Y 7.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define TITLE_Y 8.0f
#define TITLE_HEIGHT 28.0f

#define CLOSE_BUTTON_WIDTH 56.0f

#define TOOLBAR_HEIGHT 44.0f

#define MAXIMUM_HELP_WIDTH 512.0f
#define MAXIMUM_HELP_HEIGHT 648.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark UIViewController methods

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		// Custom initialization
	}

	return self;
}
*/

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

		titleWidth -= (CLOSE_BUTTON_WIDTH + BUTTON_SPACE); // Adjust title width

		CGFloat rightButtonX = (toolbarWidth - (CLOSE_BUTTON_WIDTH + BUTTON_SPACE)); // X

		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom]; // Close button

		closeButton.frame = CGRectMake(rightButtonX, BUTTON_Y, CLOSE_BUTTON_WIDTH, BUTTON_HEIGHT);
		[closeButton setTitle:NSLocalizedString(@"Close", @"button") forState:UIControlStateNormal];
		[closeButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[closeButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[closeButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[closeButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		closeButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		closeButton.exclusiveTouch = YES;

		[theToolbar addSubview:closeButton]; // Add to toolbar
	}
	else // Large device
	{
		self.contentSizeForViewInPopover = CGSizeMake(MAXIMUM_HELP_WIDTH, MAXIMUM_HELP_HEIGHT);
	}

	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

	NSString *name = [infoDictionary objectForKey:(NSString *)kCFBundleNameKey];

	NSString *version = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];

	CGRect titleRect = CGRectMake(titleX, TITLE_Y, titleWidth, TITLE_HEIGHT);

	theTitleLabel = [[UILabel alloc] initWithFrame:titleRect];

	theTitleLabel.textAlignment = UITextAlignmentCenter;
	theTitleLabel.font = [UIFont systemFontOfSize:17.0f];
	theTitleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
	theTitleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];
	theTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	theTitleLabel.backgroundColor = [UIColor clearColor];
	theTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);

	theTitleLabel.text = [NSString stringWithFormat:@"%@ v%@", name, version];

	[theToolbar addSubview:theTitleLabel]; // Add title to toolbar

	[self.view addSubview:theToolbar]; // Add toolbar to controller view

	CGRect helpRect = viewRect; helpRect.origin.y += TOOLBAR_HEIGHT; helpRect.size.height -= TOOLBAR_HEIGHT;

	theWebView = [[UIWebView alloc] initWithFrame:helpRect]; // Rest of view

	theWebView.scalesPageToFit = NO;
	theWebView.dataDetectorTypes = UIDataDetectorTypeNone;
	theWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theWebView.delegate = self;

	[self.view insertSubview:theWebView belowSubview:theToolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (htmlLoaded == NO) // Load help HTML file when needed
	{
		NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"help.html" ofType:nil]; // Help HTML file

		NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];

		NSURL *baseURLPath = [NSURL fileURLWithPath:[htmlFile stringByDeletingLastPathComponent] isDirectory:YES];

		[theWebView loadHTMLString:htmlString baseURL:baseURLPath]; htmlLoaded = YES;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
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
	theWebView.delegate = nil;

	theWebView = nil; theTitleLabel = nil; theToolbar = nil;

	[super viewDidUnload]; htmlLoaded = NO;
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

- (void)dealloc
{
	theWebView.delegate = nil;
}

#pragma mark UIWebViewDelegate methods

/*
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}
*/

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)type
{
	BOOL should = YES; // Default

	if (type == UIWebViewNavigationTypeLinkClicked) // Handle taps on links
	{
		[[UIApplication sharedApplication] openURL:[request URL]]; should = NO;
	}

	return should;
}

/*
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}
*/

#pragma mark UIButton action methods

- (void)closeButtonTapped:(UIButton *)button
{
	[delegate dismissHelpViewController:self];
}

@end
