//
//	DirectoryWatcher.h
//	Version: 1.3
//
//	Released by Apple on 2011-03-18.
//	Copyright 2011 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DirectoryWatcher;

@protocol DirectoryWatcherDelegate <NSObject>

@required // Delegate protocols

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher;

@end

@interface DirectoryWatcher : NSObject
{
	id <DirectoryWatcherDelegate> __unsafe_unretained delegate;

	CFFileDescriptorRef dirKQRef;
	int dirFD;
	int kq;
}

@property (nonatomic, unsafe_unretained, readwrite) id <DirectoryWatcherDelegate> delegate;

+ (DirectoryWatcher *)watchFolderWithPath:(NSString *)watchPath delegate:(id<DirectoryWatcherDelegate>)watchDelegate;

- (void)invalidate;

@end
