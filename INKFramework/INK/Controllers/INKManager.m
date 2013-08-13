//
//  INKManager.m
//  INK
//
//  Created by Dave Rauchwerk on 7/7/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//
//  Singleton class to setup the INK + Core framework in Partner app

#import "INKManager.h"
#import "INKDB.h"
#import "INKAction.h"
#import "INKViewController.h"
#import "RNBlurModalView.h"

@implementation INKManager

@synthesize inkViewMain, sharedModal;

#pragma mark Singleton Methods




+ (id)sharedManager {
    static INKManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


//add api key as arg here
- (id)init {
    if (self = [super init]) {
        inkViewMain = [INKViewController sharedINKVC];
        //NSLog(someProperty);
        
        //setAPI key 
        //call fetchActions with api key to load initial list of actions.json from server into actionCache
        
        sharedModal= [RNBlurModalView alloc];

        
        INKDB *sharedDB = [INKDB sharedDB];
        [INKAction fetchActions];
                
        
    }
    return self;
}



- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end

//INKManager *sharedManager = [INKManager sharedManager];
