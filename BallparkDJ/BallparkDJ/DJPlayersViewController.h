//
//  DJPlayersViewController.h
//  BallparkDJ
//
//  Created by Timothy Goodson on 6/23/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJAppDelegate.h"
#import "DJDetailViewController.h"
#import "DJTeamNameViewController.h"

@interface DJPlayersViewController : UIViewController <AVAudioPlayerDelegate, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSInteger _teamIndex;
    NSInteger _playerIndex;
    AVAudioPlayer* _musicPlayer;
    AVAudioPlayer* _djClipPlayer;
    MPMusicPlayerController* _iPodMusicPlayer;
    NSString* _fileName;
}
@property(retain, nonatomic) NSTimer* timer;
@property(strong, nonatomic) NSTimer* directorTimer;
@property(retain, nonatomic) NSString* fileName;
@property(strong, nonatomic) AVAudioPlayer* musicPlayer;
@property(strong, nonatomic) AVAudioPlayer* djClipPlayer;
@property(retain, nonatomic) MPMusicPlayerController* iPodMusicPlayer;
@property(assign, nonatomic) float volumeSetting;
@property (retain, nonatomic) DJAppDelegate* parentDelegate;
@property(assign, nonatomic) NSInteger teamIndex;
@property(assign, nonatomic) NSInteger playerIndex;
@property (retain, nonatomic) DJDetailViewController *detailViewController;
@property(retain, nonatomic) DJTeam* theTeam;
@property(strong, nonatomic) DJTeamNameViewController* teamNameViewController;
@property (retain, nonatomic) IBOutlet UITableView *playersTable;
@property (retain, nonatomic) IBOutlet UIToolbar *bottomButtonBar;

-(void)assignData :(DJTeam*)team;

- (IBAction)teamButtonPressed:(UIBarButtonItem *)sender;
@end
