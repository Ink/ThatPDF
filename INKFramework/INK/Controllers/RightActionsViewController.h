
/*
     File: RootViewController.h
 Abstract: View controller that sets up the table view and serves as the table view's data source and delegate.
 */

@interface RightActionsViewController : UITableViewController {
	NSArray *actions;
}

@property (nonatomic, retain) NSArray *actions;

@end
