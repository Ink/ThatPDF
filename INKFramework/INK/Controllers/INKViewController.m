//
//  ViewController.m
//  sampleAdding
//
//  Created by Albert Swantner on 6/24/13.
//  Copyright (c) 2013 Albert Swantner. All rights reserved.
//

#import "INKViewController.h"
#import "RNBlurModalView.h"
#import "TMCache.h"
#import "InkCore.h"
#import "InkOverallView.h"

@interface INKViewController ()

@end

@implementation INKViewController

@synthesize actions;





+ (id)sharedINKVC {
    static INKViewController *sharedMyINKVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyINKVC = [[self alloc] init];
    });
    return sharedMyINKVC;
}


//add api key as arg here
- (id)init {
    if (self = [super init]) {
        
        //setAPI key
        //call fetchActions with api key to load initial list of actions.json from server into actionCache
        //INKViewController *sharedINKVC = [INKViewController sharedINKVC];
        
        
    }
    return self;
}


- (void)loadView
{
    //Get real size of APP Window
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);

    InkOverallView *INKViewC = [[InkOverallView alloc] initWithFrame:(frame)];
    INKViewC.backgroundColor = [UIColor clearColor];

    
    self.view = INKViewC;
    
    self.view.autoresizesSubviews = YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    

        
        
    

    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)triggerFlow:(INKBlob *)blob
{
    NSLog(@"blob filename: %@", blob.filename);
    
    // Create INKAction
    //INKAction *action = [INKAction action:@"Edit-A2" type:INKActionType_Edit appURL:@"sketchboard"];
    
    // Execute triple
    //INKTriple *triple = [INKTriple tripleWithAction:action blob:blob user:nil];
    // [triple triggerForReturn:^(INKBlob *blob, NSError *error) {
    //    NSLog(@"Return callback triggered with non-null blob:%@", blob);
    // }];
}
-(void)fetchBlob
{
    
    /*
    //This needs to be in the blob class
    [[TMCache sharedCache] objectForKey:self.objectTag
                                  block:^(TMCache *cache, NSString *key, id object) {
                                      INKBlob *blob = (INKBlob *)object;
                                      [self triggerFlow:(blob)];
                                  }];
    
    */
    
}
- (void)testCont:(UILongPressGestureRecognizer *)sender{
    NSLog(@"test log working");
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
