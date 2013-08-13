//
//  ViewController.m
//  UItest
//
//  Created by Albert Swantner on 6/14/13.
//  Copyright (c) 2013 Albert Swantner. All rights reserved.
//

#import "InkOverallView.h"
#import "InkHeader.h"
#import "INKRightAction.h"
#import "INKLeftAction.h"
#import "UIView+Ink.h"
#import "previewView.h"
#import "INKIcon.h"
#import "INKManager.h"

//Import Framework in Real Project
#import "InkCore.h"

@interface InkOverallView ()


@end

@implementation InkOverallView

@synthesize actionList, currentBlob;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        // Initialization code
        
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    

    
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat rightBarWidth, rightBoundary;
    CGFloat leftBarWidth;
    CGFloat helpTop, closeTop;
    CGFloat topBoundary;
    CGRect logoContainer, previewContainer;
    CGRect previewButtonFrameBorder, previewButtonFrame;
    CGRect infoButtonFrameBorder, infoButtonFrame;
    CGRect rightShadowFrame;

    
    //Determine orientation and change placement of items
    if (width == 768) {
        //Portrait Styles
        helpTop = 25;
        rightBoundary = 394; //Right Action Items Starting Location
        rightBarWidth = 374; //Width of right Action Items
        leftBarWidth = 374;
        closeTop = 25; //Starting position for close button
        topBoundary = 680; //Height of Left and Right Action Lists
        logoContainer = CGRectMake(width/2 - 100, 23, 187, 145); //Container for Logo
        previewContainer = CGRectMake(245, 192, 295, 373); //Container for Preview
        previewButtonFrameBorder = CGRectMake(540, 336, 85, 85);
        previewButtonFrame = CGRectMake(550, 346, 65, 65);
        infoButtonFrameBorder = CGRectMake(160, 336, 85, 85);
        infoButtonFrame = CGRectMake(170, 346, 65, 65);
        rightShadowFrame = CGRectMake(0, 650, 374, 650);

    }
    else {
        //Landscape Styles
        rightBoundary = 682;
        rightBarWidth = 335;
        helpTop = height - 75;
        closeTop = 75;
        topBoundary = 300;
        leftBarWidth = 285;
        logoContainer = CGRectMake(79.5, 41, 121, 99);
        previewContainer = CGRectMake(316, 205, 328, 426);
        previewButtonFrameBorder = CGRectMake(316, 631, 85, 85);
        previewButtonFrame = CGRectMake(326, 641, 65, 65);
        infoButtonFrameBorder = CGRectMake(391, 631, 85, 85);
        infoButtonFrame = CGRectMake(401, 641, 65, 65);
        rightShadowFrame = CGRectMake(0, 0, 285, self.bounds.size.height);

    }

    //Right Action Items
    
    CGRect  viewRightRect = CGRectMake(rightBoundary, topBoundary, rightBarWidth, 300);
    UIView *rightAction = [[UIView alloc] initWithFrame:viewRightRect];
    
    CGRect  viewLeftRect = CGRectMake(10, topBoundary, leftBarWidth, 300);
    UIView *leftAction = [[UIView alloc] initWithFrame:viewLeftRect];
    CGFloat itemHeight = 70;
    
    /*
    NSError *error = nil;
    
    NSURL *url = [NSURL URLWithString:@"http://albertut.com/sampledata.json"];
    
    NSString *json = [NSString stringWithContentsOfURL:url
                                              encoding:NSASCIIStringEncoding
                                                 error:&error];
    NSLog(@"\nJSON: %@ \n Error: %@", json, error);
    NSData *jsonData = [json dataUsingEncoding:NSASCIIStringEncoding];
    NSArray *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    */
    //Right Actions
     
     
    //NSArray *actionNames = [jsonDict valueForKey: @"actions"];
    
    NSUInteger numObjects = [actionList count];
    NSLog(@"Number of Items %lu", (unsigned long)numObjects);
    
    NSInteger count = 0;
    
    
    //Left Black Bar
    
    UIView *rightShadow = [[UIView alloc] initWithFrame:rightShadowFrame];
    rightShadow.alpha = 0.8;
    rightShadow.backgroundColor = [UIColor blackColor];
    [self addSubview:rightShadow];
    
    //Header bar
    CGRect  headerContainer = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    InkHeader *header = [[InkHeader alloc] initWithFrame:headerContainer];
    [self addSubview:header];
    
    //Right Actions
    for (id action in actionList) {
        
        //Right hand side actions
        CGRect rightActionFrame = CGRectMake(0,itemHeight*count, rightBarWidth, itemHeight);
        INKRightAction *rightActionButton = [[INKRightAction alloc] initWithFrame:rightActionFrame];
        
        
        rightActionButton.tag = count;
        
        //Tap Only
        [rightActionButton addTarget:self action:@selector(actionRightPressed:) forControlEvents:UIControlEventTouchDown];
        
        //Long Press
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [rightActionButton addGestureRecognizer:longPress];
        
        //INKAction *actionItem = [INKAction alloc];
        //actionItem = action;
        
        //[action getType];
        //[action getAppUrl];
        //Label for Action
        //NSString *labelServer = object.name;
        rightActionButton.actionName = [action name];
        
        //Icon for Action
        //NSString *iconUrlServer= object.
        rightActionButton.iconUrl = [action iconSmallURL];
        
        //Multiple Options
        rightActionButton.options = NO;
        
        [rightAction addSubview:rightActionButton];
        
        count++;
    }
     
     
    [self addSubview:rightAction];
    
    //End Right action items
    
    
    //Left Actions
    NSArray *leftActions = _leftActionList;
    
    NSUInteger numObjectsLeft = [leftActions count];
    NSLog(@"Number of Items%lu", (unsigned long)numObjectsLeft);
    
    NSUInteger countLeft = 0;
    for (id action in leftActions) {
    
        //Left hand side actions
        CGRect leftActionFrame = CGRectMake(0,itemHeight*countLeft, leftBarWidth, itemHeight);
        INKLeftAction *leftActionButton = [[INKLeftAction alloc] initWithFrame:leftActionFrame];
        leftActionButton.tag = countLeft;

        [leftActionButton addTarget:self action:@selector(actionLeftPressed:) forControlEvents:UIControlEventTouchDown];
        
        //Label for Action
        NSString *labelServerLeft = [action name];
        leftActionButton.actionName = labelServerLeft;
        
        //Icon for Action
        //NSString *iconUrlServerLeft= [object valueForKey: @"icon_sm"];
        //leftActionButton.iconUrl = iconUrlServerLeft;
        leftActionButton.iconUrl = [action iconSmallURL];

        
        //Color for button
        //NSString *buttonColor= [action color];
        leftActionButton.actionColor = @"red";
        
        [leftAction addSubview:leftActionButton];
        
        countLeft++;
    }
    [self addSubview:leftAction];
    
    //End Left Actions
    
    //INK Logo
    UIImageView *myImageView = [[UIImageView alloc] initWithFrame:logoContainer];
    myImageView.image=[UIImage imageNamed:@"INK.bundle/inklogo.png"];
    [self addSubview:myImageView];

    
    //Close Button
    CGRect closeButtonFrame = CGRectMake(width-94, closeTop, 65, 65);
    INKIcon *closeButton = [[INKIcon alloc] initWithFrame:closeButtonFrame];
    closeButton.iconType = @"close";
    closeButton.backgroundColor = [UIColor colorWithRed:203.0/255.0 green:203.0/255.0 blue:203.0/255.0 alpha:(100.0/100.0)];
    
    [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    //Help Button
    CGRect helpButtonFrame = CGRectMake(15, helpTop, 65, 65);
    INKIcon *helpButton = [[INKIcon alloc] initWithFrame:helpButtonFrame];
    helpButton.iconType = @"help";
    helpButton.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:189.0/255.0 blue:49.0/255.0 alpha:(100.0/100.0)];
    [helpButton addTarget:self action:@selector(closed:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:helpButton];
    
    //Info Button with 10px black background
    UIView *infoButtonFrameBorderView = [[UIView alloc] initWithFrame:infoButtonFrameBorder];
    infoButtonFrameBorderView.backgroundColor = [UIColor blackColor];
    INKIcon *infoButton = [[INKIcon alloc] initWithFrame:infoButtonFrame];
    infoButton.iconType = @"info";
    infoButton.backgroundColor = [UIColor colorWithRed:92.0/255.0 green:162.0/255.0 blue:205.0/255.0 alpha:(100.0/100.0)];
    [infoButton addTarget:self action:@selector(closed:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:infoButtonFrameBorderView];
    [self addSubview:infoButton];
    
    //Preview Button
    UIView *previewButtonFrameBorderView = [[UIView alloc] initWithFrame:previewButtonFrameBorder];
    previewButtonFrameBorderView.backgroundColor = [UIColor blackColor];
    INKIcon *previewButton = [[INKIcon alloc] initWithFrame:previewButtonFrame];
    previewButton.iconType = @"preview";
    previewButton.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:189.0/255.0 blue:49.0/255.0 alpha:(100.0/100.0)];
    [previewButton addTarget:self action:@selector(closed:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:previewButtonFrameBorderView];
    [self addSubview:previewButton];
    
    //Quick Look Preview
    
    previewView *preview = [[previewView alloc] initWithFrame:previewContainer];
    //*****DAVE HOW DO I GET BLOB URL IN HERE??
    //preview.blobUrl = [INKBlob.url];
    [self addSubview:preview];
    

    
}

-(void)hide
{
    INKManager *sharedManager = [INKManager sharedManager];

    [sharedManager.sharedModal hide];
}
- (void)longPress:(UILongPressGestureRecognizer*)gesture {
        NSLog(@"Long Press me again");
}

-(void) closed:(UIButton*)sender {
    NSLog(@"Close Pressed");
    
}

-(void) actionRightPressed:(UIButton*)sender {
    NSInteger index = sender.tag;
    
    
    INKBlob *targetBlob = self.currentBlob;
    INKAction *targetAction = [self.actionList objectAtIndex:index];
    INKUser *targetUser = [INKUser current];
    NSLog(@"Action right pressed");
    NSLog(@"Action to be performed: %@", targetAction.appUrl);
    
    INKTriple *triple = [INKTriple tripleWithAction:targetAction blob:targetBlob user:targetUser];
    
    [self hide];
    
    [triple trigger:^(INKBlob *result, NSError *error) {
        NSLog(@"return");
    }];
}

-(void) actionLeftPressed:(UIButton*)sender {
    NSInteger index = sender.tag;
    
    
    INKBlob *targetBlob = self.currentBlob;
    INKAction *targetAction = [self.leftActionList objectAtIndex:index];
    INKUser *targetUser = [INKUser current];
    NSLog(@"Action Left pressed");
    NSLog(@"Action to be performed: %@", targetAction.appUrl);
    
    INKTriple *triple = [INKTriple tripleWithAction:targetAction blob:targetBlob user:targetUser];
    
    [self hide];
    
    [triple trigger:^(INKBlob *result, NSError *error) {
        NSLog(@"return");
    }];
}


@end

