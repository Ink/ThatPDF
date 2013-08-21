//
//	ReaderAnnotateToolbar.h
//	ThatPDF v0.3.1
//
//	Created by Brett van Zuiden.
//	Copyright © 2013 Ink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIXToolbarView.h"


@class ReaderAnnotateToolbar;
@class ReaderDocument;

@protocol ReaderAnnotateToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInAnnotateToolbar:(ReaderAnnotateToolbar *)toolbar doneButton:(UIButton *)button;
- (void)tappedInAnnotateToolbar:(ReaderAnnotateToolbar *)toolbar cancelButton:(UIButton *)button;
- (void)tappedInAnnotateToolbar:(ReaderAnnotateToolbar *)toolbar signButton:(UIButton *)button;
- (void)tappedInAnnotateToolbar:(ReaderAnnotateToolbar *)toolbar redPenButton:(UIButton *)button;
- (void)tappedInAnnotateToolbar:(ReaderAnnotateToolbar *)toolbar textButton:(UIButton *)button;
- (void)tappedInAnnotateToolbar:(ReaderAnnotateToolbar *)toolbar undoButton:(UIButton *)button;

@end

@interface ReaderAnnotateToolbar : UIXToolbarView

@property (nonatomic, unsafe_unretained, readwrite) id <ReaderAnnotateToolbarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

- (void)hideToolbar;
- (void)showToolbar;

- (void)setUndoButtonState:(BOOL)state;
- (void)setSignButtonState:(BOOL)state;
- (void)setRedPenButtonState:(BOOL)state;
- (void)setTextButtonState:(BOOL)state;

@end
