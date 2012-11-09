//
//  DJDetailViewController.h
//  BallparkDJ
//
//  Created by Timothy Goodson on 5/11/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSettings.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DJLeague.h"
#import "DJAppDelegate.h"
#import "DJGradientButton.h"
#import "DJOverlapSlider.h"


@interface DJDetailViewController : UIViewController <AVAudioPlayerDelegate, UIPopoverControllerDelegate>{
@private
    AVAudioPlayer* _musicPlayer;
    AVAudioPlayer* _djClipPlayer;
    MPMusicPlayerController* _iPodMusicPlayer;
}
@property(strong, nonatomic) AVAudioPlayer* musicPlayer;
@property(strong, nonatomic) AVAudioPlayer* djClipPlayer;
@property(retain, nonatomic) MPMusicPlayerController* iPodMusicPlayer;
@property(assign, nonatomic) float volumeSetting;
@property(retain, nonatomic) DJPlayer* thePlayer;
@property(assign, nonatomic) NSInteger teamIndex;
@property(assign, nonatomic) NSInteger playerIndex;
@property(retain, nonatomic) NSString* fileName;

@property (retain, nonatomic) DJAppDelegate* parentDelegate;
@property (assign, nonatomic) IBOutlet UITextView *playerNameField;
@property (assign, nonatomic) IBOutlet UITextView *PlayerNumberField;
@property(retain, nonatomic) UIPopoverController* audioPopoverController;
@property (retain, nonatomic) DJOverlapSlider* overlapSlider;
@property (retain, nonatomic) IBOutlet DJGradientButton *recordButton;
@property (retain, nonatomic) IBOutlet DJGradientButton *editButton;
@property (retain, nonatomic) IBOutlet DJGradientButton *playSetButton;
@property (retain, nonatomic) IBOutlet DJGradientButton *playRecordingButton;
@property (retain, nonatomic) IBOutlet DJGradientButton *playClipButton;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
@property (retain, nonatomic) IBOutlet UILabel *overlapLabel;
@property(retain, nonatomic) NSTimer* directorTimer;
@property(retain, nonatomic) NSTimer* timer;
@property (retain, nonatomic) IBOutlet UITextField *overlapEditField;

-(void)assignFileName;
-(void)assignMusicClip:(DJMusicClip*)clip;
-(void)initializeAllPlayers;
- (IBAction)clipEdit:(UIButton *)sender;
- (IBAction)clipPlay:(UIButton *)sender;
- (IBAction)announceEdit:(UIButton *)sender;
- (IBAction)announcePlay:(UIButton *)sender;
- (IBAction)playSet:(UIButton *)sender;

@end
