//
//  DJClipsViewController.h
//  BallparkDJ
//
//  Created by Timothy Goodson on 7/22/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "DJLeague.h"

@interface DJClipsViewController : UITableViewController <AVAudioPlayerDelegate>
@property(strong, nonatomic) AVAudioPlayer* musicPlayer;
@property(strong, nonatomic) NSArray* clips;
@property(strong, nonatomic) DJPlayer* thePlayer;
@end
