//
//  InkViewController2.m
//  INK Workflow Framework
//
//  Created by Jonathan Uy on 5/21/13.
//  Copyright (c) 2013 Computer Club. All rights reserved.
//

#import "InkViewController2.h"

@interface InkViewController2 ()

@end

@implementation InkViewController2

@synthesize completionBlock, popoverRef;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [button1 setTag:1];
    [button1 setTitle:@"Button 1" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = CGRectMake(0, 50, self.view.frame.size.width, 44);
    [button2 setTag:2];
    [button2 setTitle:@"Button 2" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button3.frame = CGRectMake(0, 100, self.view.frame.size.width, 44);
    [button3 setTag:3];
    [button3 setTitle:@"Button 3" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button4.frame = CGRectMake(0, 150, self.view.frame.size.width, 44);
    [button4 setTag:4];
    [button4 setTitle:@"Button 4" forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
}

- (void)itemSelected:(id)sender
{
    [popoverRef dismissPopoverAnimated:YES];
    
    NSInteger tagId = [sender tag];
    
    completionBlock(tagId);
    
    NSString *message = [[NSString alloc] initWithFormat:@"Menu Button Selected: %d", tagId];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo" message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
}

@end
