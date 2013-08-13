//
//	LibraryDocumentsView.h
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

#import <UIKit/UIKit.h>

#import "ReaderThumbsView.h"
#import "UIXToolbarView.h"

@class LibraryDocumentsView;
@class DocumentFolder;
@class ReaderDocument;

@protocol LibraryDocumentsDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(UIXToolbarView *)toolbar addFileButton:(UIButton *)button;

- (void)documentsView:(LibraryDocumentsView *)documentsView didSelectReaderDocument:(ReaderDocument *)document;

- (void)enableContainerScrollView:(BOOL)enabled;

@end

@interface LibraryDocumentsView : UIView

@property (nonatomic, unsafe_unretained, readwrite) id <LibraryDocumentsDelegate> delegate;

@property (nonatomic, unsafe_unretained, readwrite) UIViewController *ownViewController;

- (void)reloadDocumentsUpdated;

- (void)reloadDocumentsWithFolder:(DocumentFolder *)folder;

- (void)refreshRecentDocuments;

- (void)handleMemoryWarning;

@end

#pragma mark -

//
//	LibraryDocumentsCell class interface
//

@interface LibraryDocumentsCell : ReaderThumbView

- (CGSize)maximumContentSize;

- (void)showText:(NSString *)text;

- (void)showCheck:(BOOL)checked;

@end
