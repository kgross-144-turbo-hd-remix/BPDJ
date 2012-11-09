//
//  DJAppDelegate.h
//  BallparkDJ
//
//  Created by Timothy Goodson on 5/11/12.
//  Copyright (c) 2012 BallpartkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJLeague.h"


@interface DJAppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) UINavigationController *navigationController;
@property (retain, nonatomic) UISplitViewController *splitViewController;
@property (retain, nonatomic) DJData* ourLeague;

-(void)switchViewToEdit:(NSInteger)teamIndex;
-(void)switchViewToLeague;

@end
