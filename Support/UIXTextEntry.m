//
//	UIXTextEntry.m
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

#import "UIXTextEntry.h"

#import <QuartzCore/QuartzCore.h>

@interface UIXTextEntry () <UITextFieldDelegate>

@end

@implementation UIXTextEntry
{
	UIView *theDialogView;

	UIView *theContentView;

	UIToolbar *theToolbar;

	UILabel *theTitleLabel;

	UITextField *theTextField;

	UIBarButtonItem *theDoneButton;

	UILabel *theStatusLabel;

	NSInteger visibleCenterY;
	NSInteger hiddenCenterY;
}

#pragma mark Constants

#define TITLE_X 80.0f
#define TITLE_Y 12.0f
#define TITLE_HEIGHT 20.0f

#define CONTENT_X 16.0f

#define TEXT_FIELD_Y 80.0f
#define TEXT_FIELD_HEIGHT 27.0f

#define STATUS_LABEL_Y 118.0f
#define STATUS_LABEL_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f

#define DIALOG_WIDTH_LARGE 448.0f
#define DIALOG_WIDTH_SMALL 304.0f
#define DIALOG_HEIGHT 152.0f

#define TEXT_LENGTH_LIMIT 128

#define DEFAULT_DURATION 0.3

#pragma mark Properties

@synthesize delegate;

#pragma mark UIXTextEntry instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.36f]; // View tint
		self.hidden = YES; self.alpha = 0.0f; // Start hidden

		BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);

		visibleCenterY = (large ? (DIALOG_HEIGHT * 1.25f) : (DIALOG_HEIGHT - (TOOLBAR_HEIGHT / 2.0f)));

		CGFloat dialogWidth = (large ? DIALOG_WIDTH_LARGE : DIALOG_WIDTH_SMALL); // Dialog width

		CGFloat dialogY = (0.0f - DIALOG_HEIGHT); // Start off screen
		CGFloat dialogX = ((self.bounds.size.width - dialogWidth) / 2.0f);
		CGRect dialogRect = CGRectMake(dialogX, dialogY, dialogWidth, DIALOG_HEIGHT);

		theDialogView = [[UIView alloc] initWithFrame:dialogRect]; hiddenCenterY = theDialogView.center.y;

		theDialogView.autoresizesSubviews = NO;
		theDialogView.contentMode = UIViewContentModeRedraw;
		theDialogView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		theDialogView.backgroundColor = [UIColor clearColor];

		theDialogView.layer.shadowRadius = 3.0f;
		theDialogView.layer.shadowOpacity = 1.0f;
		theDialogView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
		theDialogView.layer.shadowPath = [UIBezierPath bezierPathWithRect:theDialogView.bounds].CGPath;

		theContentView = [[UIView alloc] initWithFrame:theDialogView.bounds];

		theContentView.autoresizesSubviews = NO;
		theContentView.contentMode = UIViewContentModeRedraw;
		theContentView.autoresizingMask = UIViewAutoresizingNone;
		theContentView.backgroundColor = [UIColor whiteColor];

		CGRect toolbarRect = theContentView.bounds; toolbarRect.size.height = TOOLBAR_HEIGHT;

		theToolbar = [[UIToolbar alloc] initWithFrame:toolbarRect];
		theToolbar.autoresizingMask = UIViewAutoresizingNone;
		theToolbar.barStyle = UIBarStyleBlack;
		theToolbar.translucent = YES;

		UIBarButtonItem *doneButton =	[[UIBarButtonItem alloc]
										initWithTitle:NSLocalizedString(@"Done", @"button")
										style:UIBarButtonItemStyleDone
										target:self action:@selector(doneButtonTapped:)];

		theDoneButton = doneButton; doneButton.enabled = NO; // Disable button

		UIBarButtonItem *exitButton =	[[UIBarButtonItem alloc]
										initWithTitle:NSLocalizedString(@"Cancel", @"button")
										style:UIBarButtonItemStyleBordered
										target:self action:@selector(cancelButtonTapped:)];

		UIBarButtonItem *flexiSpace =	[[UIBarButtonItem alloc]
										initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
										target:nil action:NULL];

		theToolbar.items = [NSArray arrayWithObjects:exitButton, flexiSpace, doneButton, nil];

		[theContentView addSubview:theToolbar]; // Add toolbar to view

		CGFloat titleWidth = (theToolbar.bounds.size.width - (TITLE_X + TITLE_X));

		CGRect titleRect = CGRectMake(TITLE_X, TITLE_Y, titleWidth, TITLE_HEIGHT);

		theTitleLabel = [[UILabel alloc] initWithFrame:titleRect];

		theTitleLabel.textAlignment = UITextAlignmentCenter;
		theTitleLabel.backgroundColor = [UIColor clearColor];
		theTitleLabel.font = [UIFont systemFontOfSize:17.0f];
		theTitleLabel.textColor = [UIColor whiteColor];
		theTitleLabel.adjustsFontSizeToFitWidth = YES;
		theTitleLabel.minimumFontSize = 15.0f;

		[theContentView addSubview:theTitleLabel]; // Add label to view

		CGFloat contentWidth = (theContentView.bounds.size.width - (CONTENT_X + CONTENT_X));

		CGRect fieldRect = CGRectMake(CONTENT_X, TEXT_FIELD_Y, contentWidth, TEXT_FIELD_HEIGHT);

		theTextField = [[UITextField alloc] initWithFrame:fieldRect];

		theTextField.returnKeyType = UIReturnKeyDone;
		theTextField.enablesReturnKeyAutomatically = YES;
		theTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		theTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		theTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		theTextField.borderStyle = UITextBorderStyleRoundedRect;
		theTextField.font = [UIFont systemFontOfSize:17.0f];
		theTextField.delegate = self;

		[theContentView addSubview:theTextField]; // Add text field to view

		CGRect statusRect = CGRectMake(CONTENT_X, STATUS_LABEL_Y, contentWidth, STATUS_LABEL_HEIGHT);

		theStatusLabel = [[UILabel alloc] initWithFrame:statusRect];

		theStatusLabel.textAlignment = UITextAlignmentCenter;
		theStatusLabel.backgroundColor = [UIColor clearColor];
		theStatusLabel.font = [UIFont systemFontOfSize:16.0f];
		theStatusLabel.textColor = [UIColor grayColor];
		theStatusLabel.adjustsFontSizeToFitWidth = YES;
		theStatusLabel.minimumFontSize = 14.0f;

		[theContentView addSubview:theStatusLabel];

		[theDialogView addSubview:theContentView];

		[self addSubview:theDialogView];
	}

	return self;
}

- (void)setStatus:(NSString *)text
{
	theStatusLabel.text = text; // Update status text
}

- (void)setTextField:(NSString *)text
{
	theDoneButton.enabled = ((text.length > 0) ? YES : NO);

	theTextField.text = text; // Update text field text
}

- (void)setTitle:(NSString *)text withType:(UIXTextEntryType)type
{
	theTitleLabel.text = text; // Update title text

	[self setStatus:nil]; [self setTextField:nil]; // Clear

	switch (type) // UIXTextEntry keyboard type settings
	{
		case UIXTextEntryTypeURL: // URL input settings
		{
			theTextField.keyboardType = UIKeyboardTypeURL;
			theTextField.autocorrectionType = UITextAutocorrectionTypeNo;
			theTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			theTextField.secureTextEntry = NO;
			break;
		}

		case UIXTextEntryTypeText: // Text input settings
		{
			theTextField.keyboardType = UIKeyboardTypeDefault;
			theTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
			theTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
			theTextField.secureTextEntry = NO;
			break;
		}

		case UIXTextEntryTypeSecure: // Secure input settings
		{
			theTextField.keyboardType = UIKeyboardTypeDefault;
			theTextField.autocorrectionType = UITextAutocorrectionTypeNo;
			theTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			theTextField.secureTextEntry = YES;
			break;
		}
	}
}

- (void)animateHide
{
	if (self.hidden == NO) // Visible
	{
		self.userInteractionEnabled = NO;

		[theTextField resignFirstResponder]; // Hide keyboard

		[UIView animateWithDuration:DEFAULT_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear
			animations:^(void)
			{
				self.alpha = 0.0f; // Fade out

				CGPoint location = theDialogView.center;
				location.y = hiddenCenterY; // Off screen Y
				theDialogView.center = location;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)animateShow
{
	if (self.hidden == YES) // Hidden
	{
		self.hidden = NO; // Show hidden views

		[UIView animateWithDuration:DEFAULT_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear
			animations:^(void)
			{
				self.alpha = 1.0f; // Fade in

				CGPoint location = theDialogView.center;
				location.y = visibleCenterY; // On screen Y
				theDialogView.center = location;
			}
			completion:^(BOOL finished)
			{
				self.userInteractionEnabled = YES;
			}
		];

		[theTextField becomeFirstResponder]; // Show keyboard
	}
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSInteger insertDelta = (string.length - range.length);

	NSInteger editedLength = (textField.text.length + insertDelta);

	theDoneButton.enabled = ((editedLength > 0) ? YES : NO); // Button state

	if (editedLength > TEXT_LENGTH_LIMIT) // Limit input text field to length
	{
		if (string.length == 1) // Check for return as the final character
		{
			NSCharacterSet *newLines = [NSCharacterSet newlineCharacterSet];

			NSRange rangeOfCharacterSet = [string rangeOfCharacterFromSet:newLines];

			if (rangeOfCharacterSet.location != NSNotFound) return TRUE;
		}

		return FALSE;
	}
	else
		return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

	theTextField.text = [theTextField.text stringByTrimmingCharactersInSet:trimSet];

	BOOL should = [delegate textEntryShouldReturn:self text:theTextField.text]; // Check

	if (should == YES) [delegate doneButtonTappedInTextEntry:self text:theTextField.text];

	return should;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	theDoneButton.enabled = NO; // Disable button

	return YES;
}

#pragma mark UIBarButtonItem action methods

- (void)doneButtonTapped:(id)sender
{
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

	theTextField.text = [theTextField.text stringByTrimmingCharactersInSet:trimSet];

	BOOL should = [delegate textEntryShouldReturn:self text:theTextField.text]; // Check

	if (should == YES) [delegate doneButtonTappedInTextEntry:self text:theTextField.text];
}

- (void)cancelButtonTapped:(id)sender
{
	theTextField.text = nil; theStatusLabel.text = nil;

	[delegate cancelButtonTappedInTextEntry:self];
}

@end
