//
//	ViewerAppDelegate.m
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
#import "ThatPDFAppDelegate.h"
#import "LibraryDirectoryViewController.h"
#import "DirectoryWatcher.h"
#import "CoreDataManager.h"
#import "DocumentsUpdate.h"
#import "DocumentFolder.h"
#import <INK/INK.h>
#import "INKWelcomeViewController.h"

#include <sys/xattr.h>

@interface ThatPDFAppDelegate () <DirectoryWatcherDelegate>

@end

@implementation ThatPDFAppDelegate
{
	UIWindow *mainWindow; // Main App Window

	LibraryDirectoryViewController *rootViewController;

	DirectoryWatcher *directoryWatcher;

	NSTimer *directoryWatcherTimer;
}

#pragma mark Miscellaneous methods

- (void)registerAppDefaults
{
	NSNumber *hideStatusBar = [NSNumber numberWithBool:YES];

	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

	NSString *version = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults]; // User defaults

	NSDictionary *defaults = [NSDictionary dictionaryWithObject:hideStatusBar forKey:kReaderSettingsHideStatusBar];

	[userDefaults registerDefaults:defaults]; [userDefaults synchronize]; // Save user defaults

	[userDefaults setObject:version forKey:kReaderSettingsAppVersion]; // App version
}

- (void)prePopulateCoreData
{
	NSManagedObjectContext *mainMOC = [[CoreDataManager sharedInstance] mainManagedObjectContext];

	if ([DocumentFolder existsInMOC:mainMOC type:DocumentFolderTypeDefault] == NO) // Add default folder
	{
		NSString *folderName = NSLocalizedString(@"Documents", @"name"); // Localized default folder name

		[DocumentFolder insertInMOC:mainMOC name:folderName type:DocumentFolderTypeDefault]; // Insert it
	}
    
    if ([DocumentFolder existsInMOC:mainMOC type:DocumentFolderTypeSamples] == NO) // Add samples folder
	{
		NSString *folderName = NSLocalizedString(@"Samples", @"name"); // Localized default folder name
        
		DocumentFolder *sampleFolder = [DocumentFolder insertInMOC:mainMOC name:folderName type:DocumentFolderTypeSamples]; // Insert it
        [[DocumentsUpdate sharedInstance] addSampleDocumentsInFolder:sampleFolder];
	}
}

#pragma mark UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //When launched, we first hand the request out
    if ([Ink openURL:url sourceApplication:sourceApplication annotation:annotation]){
        //If we're opened via a url, make sure we don't show welcome flow, etc. - user should be taken directly to action
        [INKWelcomeViewController setShouldRunWelcomeFlow:NO];
        return YES;
    }
    return [[DocumentsUpdate sharedInstance] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self registerAppDefaults]; // Register various application settings defaults

	[self prePopulateCoreData]; // Pre-populate Core Data store with various default objects

    //Setting up Ink with our App key.
    [Ink setupWithAppKey:@"A651e6fb020c0979ec9z"];
    
    //Creating and registering the three actions ThatPDF supports
    INKAction *view = [INKAction actionWithUUID:@"93b3184b-4794-4f70-b3f7-017995011de2"];
    INKAction *annotate = [INKAction actionWithUUID:@"28c55e09-cba1-4eff-9ad5-89d44b9d8c64"];
    INKAction *sign = [INKAction actionWithUUID:@"21e76a62-e7fb-4cc1-94d5-33cfe37c5886"];
    
    [Ink registerAction:view withTarget:self selector:@selector(viewBlob:action:error:)];
    [Ink registerAction:annotate withTarget:self selector:@selector(annotateBlob:action:error:)];
    [Ink registerAction:sign withTarget:self selector:@selector(signBlob:action:error:)];
    
	if ((launchOptions != nil) && ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] != nil))
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kReaderSettingsCurrentDocument]; // Clear
	}

	NSString *documentsPath = [DocumentsUpdate documentsPath]; // Application Documents path

	u_int8_t value = 1; // Value for iCloud and iTunes 'do not backup' item setxattr() function

	setxattr([documentsPath fileSystemRepresentation], "com.apple.MobileBackup", &value, 1, 0, 0);

	if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0f) // Only if iOS 5.0 and newer
	{
		directoryWatcher = [DirectoryWatcher watchFolderWithPath:documentsPath delegate:self];
	}

	mainWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds]; // Main application window

	mainWindow.backgroundColor = [UIColor scrollViewTexturedBackgroundColor]; // Window background color

	rootViewController = [[LibraryDirectoryViewController alloc] initWithNibName:nil bundle:nil]; // Root
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

    [mainWindow setRootViewController:navController];
    
	[mainWindow makeKeyAndVisible]; // Make it the key window and visible
    
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of
	// temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application
	// and it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers,
	// and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kReaderSettingsCurrentDocument]; // Clear
	[[NSUserDefaults standardUserDefaults] synchronize]; // Save user defaults
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough
	// application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of transition from the background to the inactive state: here you can undo many
	// of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive.
	// If the application was previously in the background, optionally refresh the user interface.

	[[DocumentsUpdate sharedInstance] queueDocumentsUpdate]; // Queue a documents update
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate.
	// See also applicationDidEnterBackground:.

	[[NSUserDefaults standardUserDefaults] synchronize]; // Save user defaults
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	// Free up as much memory as possible by purging cached data objects that can be recreated
	// (or reloaded from disk) later.

	NSLog(@"%s", __FUNCTION__);
}

#pragma mark Ink actions
//This action just opens the passed in file, but doesn't enter any annotation mode
- (void) viewBlob:(INKBlob *)blob action:(INKAction*)action error:(NSError*)error
{
    //Opening the file
    [[DocumentsUpdate sharedInstance] handleOpenBlob:blob];
    
    //Clearing annotations
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:DocumentsSetAnnotationModeOffNotification object:nil userInfo:nil];
}

//This action just opens the passed in file, and enters annotation mode (with a red pen)
- (void) annotateBlob:(INKBlob *)blob action:(INKAction*)action error:(NSError*)error
{
    //Opening the file
    [[DocumentsUpdate sharedInstance] handleOpenBlob:blob];
    
    //Jumping into Annotation mode
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:DocumentsSetAnnotationModeRedPenNotification object:nil userInfo:nil];
}

//This action just opens the passed in file, and enters signing mode (draw with thin black pen)
- (void) signBlob:(INKBlob *)blob action:(INKAction*)action error:(NSError*)error
{
    //Opening the file
    [[DocumentsUpdate sharedInstance] handleOpenBlob:blob];
    
    //Jumping into Signing mode
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:DocumentsSetAnnotationModeSignNotification object:nil userInfo:nil];
}

#pragma mark ViewerAppDelegate instance methods

- (void)dealloc
{
	[directoryWatcherTimer invalidate];
}

#pragma mark DirectoryWatcherDelegate methods

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
	if (directoryWatcherTimer != nil) { [directoryWatcherTimer invalidate]; directoryWatcherTimer = nil; } // Invalidate and release previous timer

	directoryWatcherTimer = [NSTimer scheduledTimerWithTimeInterval:4.8 target:self selector:@selector(watcherTimerFired:) userInfo:nil repeats:NO];
}

- (void)watcherTimerFired:(NSTimer *)timer
{
	[directoryWatcherTimer invalidate]; directoryWatcherTimer = nil; // Invalidate and release timer

	[[DocumentsUpdate sharedInstance] queueDocumentsUpdate]; // Queue a documents update
}

@end
