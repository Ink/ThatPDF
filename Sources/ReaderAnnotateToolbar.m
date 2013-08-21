//
//  ReaderAnnotateToolbar.m
//  Viewer
//
//  Created by Brett van Zuiden on 7/10/13.
//
//

#import "ReaderAnnotateToolbar.h"
#import <INK/Ink.h>

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define DONE_BUTTON_WIDTH 56.0f
#define CANCEL_BUTTON_WIDTH 60.0f
#define RED_PEN_BUTTON_WIDTH 40.0f
#define SIGN_BUTTON_WIDTH 40.0f
#define TEXT_BUTTON_WIDTH 40.0f

#define UNDO_BUTTON_WIDTH 56.0f

#define TITLE_HEIGHT 28.0f

@implementation ReaderAnnotateToolbar {
    UIButton *signButton;
    UIButton *redPenButton;
    UIButton *textButton;
    UIButton *undoButton;
    UIImage *buttonH;
    UIImage *buttonN;

}

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		CGFloat viewWidth = self.bounds.size.width;
        
		UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H"];
		UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N"];
        
		buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
		buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        
		CGFloat titleX = BUTTON_X; CGFloat titleWidth = (viewWidth - (titleX + titleX));
        
		CGFloat leftButtonX = BUTTON_X; // Left button start X position
        
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
		cancelButton.frame = CGRectMake(leftButtonX, BUTTON_Y, CANCEL_BUTTON_WIDTH, BUTTON_HEIGHT);
        if ([Ink appShouldReturn]) {
            [cancelButton setTitle:NSLocalizedString(@"Back", @"button") forState:UIControlStateNormal];
        } else {
            [cancelButton setTitle:NSLocalizedString(@"Cancel", @"button") forState:UIControlStateNormal];
        }
		[cancelButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[cancelButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[cancelButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[cancelButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		cancelButton.autoresizingMask = UIViewAutoresizingNone;
		cancelButton.exclusiveTouch = YES;
        
		[self addSubview:cancelButton]; leftButtonX += (CANCEL_BUTTON_WIDTH + BUTTON_SPACE);
        
		titleX += (CANCEL_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (CANCEL_BUTTON_WIDTH + BUTTON_SPACE);
        
        //Give the undo some padding
        titleX += BUTTON_SPACE * 2;
        leftButtonX += BUTTON_SPACE * 2;
        
        undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
		undoButton.frame = CGRectMake(leftButtonX, BUTTON_Y, UNDO_BUTTON_WIDTH, BUTTON_HEIGHT);
        [undoButton setTitle:NSLocalizedString(@"Undo", @"button") forState:UIControlStateNormal];
		[undoButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
        [undoButton setTitleColor:[UIColor colorWithWhite:0.5f alpha:1.0f] forState:UIControlStateDisabled];
		[undoButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[undoButton addTarget:self action:@selector(undoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[undoButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[undoButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		undoButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		undoButton.autoresizingMask = UIViewAutoresizingNone;
		undoButton.exclusiveTouch = YES;
        //Default enabled because we don't manage state yet
        //undoButton.enabled = NO;
        
		[self addSubview:undoButton]; leftButtonX += (UNDO_BUTTON_WIDTH + BUTTON_SPACE);
        
        //right side
        CGFloat rightButtonX = viewWidth; // Right button start X position
        
        rightButtonX -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        doneButton.frame = CGRectMake(rightButtonX, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);
        [doneButton setTitle:NSLocalizedString(@"Done", @"button") forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[doneButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[doneButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		doneButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        
        doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        doneButton.exclusiveTouch = YES;
        
        [self addSubview:doneButton]; titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
        rightButtonX -= (SIGN_BUTTON_WIDTH + BUTTON_SPACE);
        
        signButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        signButton.frame = CGRectMake(rightButtonX, BUTTON_Y, SIGN_BUTTON_WIDTH, BUTTON_HEIGHT);
        [signButton setImage:[UIImage imageNamed:@"Reader-Sign"] forState:UIControlStateNormal];
        [signButton addTarget:self action:@selector(signButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [signButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [signButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        signButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        signButton.exclusiveTouch = YES;
        
        [self addSubview:signButton]; titleWidth -= (SIGN_BUTTON_WIDTH + BUTTON_SPACE);
        
        rightButtonX -= (RED_PEN_BUTTON_WIDTH + BUTTON_SPACE);
        
        redPenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        redPenButton.frame = CGRectMake(rightButtonX, BUTTON_Y, RED_PEN_BUTTON_WIDTH, BUTTON_HEIGHT);
        [redPenButton setImage:[UIImage imageNamed:@"Reader-RedPen"] forState:UIControlStateNormal];
        [redPenButton addTarget:self action:@selector(redPenButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [redPenButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [redPenButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        redPenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        redPenButton.exclusiveTouch = YES;
        
        [self addSubview:redPenButton]; titleWidth -= (RED_PEN_BUTTON_WIDTH + BUTTON_SPACE);
        
        rightButtonX -= (RED_PEN_BUTTON_WIDTH + BUTTON_SPACE);
        
        textButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        textButton.frame = CGRectMake(rightButtonX, BUTTON_Y, TEXT_BUTTON_WIDTH, BUTTON_HEIGHT);
        [textButton setImage:[UIImage imageNamed:@"Reader-Text"] forState:UIControlStateNormal];
        [textButton addTarget:self action:@selector(textButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [textButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [textButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        textButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        textButton.exclusiveTouch = YES;
        
        [self addSubview:textButton]; titleWidth -= (TEXT_BUTTON_WIDTH + BUTTON_SPACE);
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			CGRect titleRect = CGRectMake(titleX, BUTTON_Y, titleWidth, TITLE_HEIGHT);
            
			UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];
            
			titleLabel.textAlignment = NSTextAlignmentCenter;
			titleLabel.font = [UIFont systemFontOfSize:19.0f];
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			titleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
			titleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumScaleFactor = 14.0f/19.f;
			titleLabel.text = @"Add annotations";
            
			[self addSubview:titleLabel];
		}
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)hideToolbar
{
	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.hidden = YES;
         }
         ];
	}
}

- (void)showToolbar
{
	if (self.hidden == YES)
	{        
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.hidden = NO;
             self.alpha = 1.0f;
         }
                         completion:NULL
         ];
	}
}

- (void)setUndoButtonState:(BOOL)state {
    undoButton.enabled = state;
}

- (void)setSignButtonState:(BOOL)state {
    UIImage *image = (state ? buttonH : buttonN);
    [signButton setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)setRedPenButtonState:(BOOL)state {
    UIImage *image = (state ? buttonH : buttonN);
    [redPenButton setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)setTextButtonState:(BOOL)state {
    UIImage *image = (state ? buttonH : buttonN);
    [textButton setBackgroundImage:image forState:UIControlStateNormal];
}

#pragma mark UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
	[delegate tappedInAnnotateToolbar:self doneButton:button];
}

- (void)cancelButtonTapped:(UIButton *)button
{
	[delegate tappedInAnnotateToolbar:self cancelButton:button];
}

- (void)undoButtonTapped:(UIButton *)button
{
	[delegate tappedInAnnotateToolbar:self undoButton:button];
}

- (void)signButtonTapped:(UIButton *)button
{
	[delegate tappedInAnnotateToolbar:self signButton:button];
}

- (void)redPenButtonTapped:(UIButton *)button
{
    button.selected = !button.selected;
	[delegate tappedInAnnotateToolbar:self redPenButton:button];
}

- (void)textButtonTapped:(UIButton *)button
{
    button.selected = !button.selected;
	[delegate tappedInAnnotateToolbar:self textButton:button];
}

@end
