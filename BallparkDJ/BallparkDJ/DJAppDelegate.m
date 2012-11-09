//
//  DJAppDelegate.m
//  BallparkDJ
//
//  Created by Timothy Goodson on 5/11/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import "DJAppDelegate.h"
#import "DJDetailViewController.h"
#import "DJLeagueViewController.h"
#import "DJMusicViewController.h"
#import "DJPlayersViewController.h"
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>

@interface DJAppDelegate () {
    NSTimer* _timer;
}

@end

@implementation DJAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize ourLeague = _ourLeague;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //init window
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];    
    [self.window makeKeyAndVisible];
    
    //main model
    _ourLeague = [[DJData alloc] init];

    //start with initial data if new app
    if ([[[[self ourLeague] theLeague] theTeams] count] == 0) {
        [self createDummyData];
        [self switchViewToLeague];
    }

    //Set audio to mix
    NSError* audioSessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"%@", audioSessionError);
    }
    OSStatus propertyError = 0;
    UInt32 mixWithOthers = YES;
    propertyError = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(mixWithOthers), &mixWithOthers);
    if (propertyError != 0) {
        NSLog(@"Error setting audio sessions property: %@", propertyError);
    }
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
    //set up initial view
    [self switchViewToLeague];
    return YES;    

}

-(void)createDummyData{
    
    //used to create a dummy league for dev
    for (int i = 0; i < 5; ++i) {
     DJTeam* t = [[DJTeam alloc] init];
     NSString* ts = @"Team ";
     NSString* s = [[NSNumber numberWithInt:i] stringValue];
     ts = [ts stringByAppendingString:s];
     [t setTeamName:ts];
     [[[[self ourLeague] theLeague] theTeams] addObject:t];
     for (int j = 0; j < 12; ++j) {
         DJPlayer* p = [[DJPlayer alloc] init];
         NSString* n = @"Player ";            
         NSString* is = [[NSNumber numberWithInt:i] stringValue];
         NSString* na = [n stringByAppendingString:is];
         n = [na stringByAppendingString:[[NSNumber numberWithInt:j] stringValue]];
         [p setPlayerName:n];
         [p setPlayerNumber:j];
         [[[[[[self ourLeague] theLeague] theTeams] objectAtIndex:i] thePlayers] addObject:p];
     }
     }
     [[[self ourLeague] theLeague] setLeagueName:@"Community Fun League"];
     [[self ourLeague] saveData]; 
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (self.ourLeague.dataChanged) {
        [self.ourLeague saveData];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if (self.ourLeague.dataChanged) {
        [self.ourLeague saveData];
    }
}

-(void)splashScreenDelay{
    [self switchViewToLeague];
    [_timer invalidate];
}

-(void)switchViewToEdit:(NSInteger)teamIndex{
    
    NSString* xibName = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        xibName = @"DJPlayersViewController_iPhone";
    } else {
        xibName = @"DJPlayersViewController_iPad";
    }
    DJPlayersViewController* playersViewController = [[[DJPlayersViewController alloc] initWithNibName:xibName bundle:nil] autorelease];
    [playersViewController setTeamIndex:teamIndex];
    [playersViewController assignData:[self.ourLeague.theLeague.theTeams objectAtIndex:teamIndex]];
    [playersViewController setParentDelegate:self];
    _navigationController = [[[UINavigationController alloc] initWithRootViewController:playersViewController] autorelease];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.title = @"Players";
    self.window.rootViewController = self.navigationController;
}

-(void)switchViewToLeague{
    NSString* nibName = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        nibName = @"DJLeagueViewController_iPhone";
    } else {
        nibName = @"DJLeagueViewController_iPad";
    }
    DJLeagueViewController* leagueViewController = [[DJLeagueViewController alloc] initWithNibName:
        nibName bundle:nil];
    [leagueViewController assignData:self.ourLeague.theLeague];
    [leagueViewController setParentDelegate:self];
    [leagueViewController autorelease];
    self.window.rootViewController = leagueViewController;
}

@end
