
/*
     File: RootViewController.m
 Abstract: View controller that sets up the table view and serves as the table view's data source and delegate.
 
  Version: 2.1
 
  Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "RightActionsViewController.h"


@implementation RightActionsViewController

@synthesize actions;


- (void)viewDidLoad {
	self.title = nil;//NSLocalizedString(@"Time Zones", @"Time Zones title");
    [self.tableView setRowHeight: 80.00];
    self.navigationController.navigationBar.hidden=YES;
    

    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *actionNames = [actions valueForKey: @"actions"];

	return [actionNames count];
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 6;
    return 1.0;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) ];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *MyIdentifier = @"MyIdentifier";
	
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		// Use the default cell style.
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
	}
    
	// Set up the cell.
	NSUInteger row = [indexPath section];
    NSArray *actionNames = [actions valueForKey: @"actions"];

     NSLog(@"LIST OF ACTIONS?%@", [actionNames[row] valueForKey: @"action"]);

    NSURL *url = [NSURL URLWithString:@"http://albertut.com/acrobat.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *appIcon = [[UIImage alloc] initWithData:data];
    
    cell.textLabel.text = [actionNames[row] valueForKey:@"action"];
    cell.imageView.image = appIcon;
    cell.backgroundColor = [UIColor whiteColor];
    
    //cell.textColor = [UIColor whiteColor];
	
	return cell;
}

/*
 To conform to Human Interface Guildelines, since selecting a row would have no effect (such as navigation), make sure that rows cannot be selected.
 */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}


- (void)dealloc {
	//[actions release];
	//[super dealloc];
}
	

@end
