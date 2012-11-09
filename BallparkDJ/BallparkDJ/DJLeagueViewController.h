//
//  DJLeagueViewController.h
//  BallparkDJ
//
//  Created by Timothy Goodson on 5/21/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJLeague.h"
#import <UIKit/UIControl.h>
#import "DJTeamNameViewController.h"
#import "DJDetailViewController.h"
#import "DJLeague.h"
#import "DJAppDelegate.h"

@interface DJLeagueViewController : UIViewController <UIPopoverControllerDelegate>
@property (strong, nonatomic) DJAppDelegate* parentDelegate;
@property(strong, nonatomic) DJLeague* theLeague;
@property (assign, nonatomic) IBOutlet UITableView *teamTable;
@property(strong, nonatomic) DJTeamNameViewController* teamNameViewController;
@property (strong, nonatomic) UISplitViewController *splitViewController;
@property(retain, nonatomic) NSIndexPath* rowUnderEdit;

-(void)assignData:(DJLeague*)theData;
- (IBAction)addNewTeam:(UIBarButtonItem *)sender;
@end
