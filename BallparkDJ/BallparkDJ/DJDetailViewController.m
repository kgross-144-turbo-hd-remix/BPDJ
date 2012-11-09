//
//  DJDetailViewController.m
//  BallparkDJ
//
//  Created by Timothy Goodson on 5/11/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import "DJDetailViewController.h"
#import "DJMusicViewController.h"
#import "DJVoiceRecorderViewController.h"
#import <CoreAudio/CoreAudioTypes.h>

@interface DJDetailViewController (){

    double _clipLength;
    double _clipStartPoint;
    BOOL _setPlaying;
    BOOL _volumeCaptured;
    BOOL _isNewPlayer;
    BOOL _setExists;
}
@property (retain, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DJDetailViewController
@synthesize musicPlayer = _musicPlayer;
@synthesize djClipPlayer = _djClipPlayer;
@synthesize iPodMusicPlayer = _iPodMusicPlayer;
@synthesize volumeSetting;
@synthesize fileName;
@synthesize parentDelegate;
@synthesize thePlayer = _thePlayer;
@synthesize teamIndex;
@synthesize playerIndex;
@synthesize playerNameField = _playerNameField;
@synthesize PlayerNumberField = _PlayerNumberField;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize audioPopoverController = _audioPopoverController;
@synthesize recordButton = _recordButton;
@synthesize editButton = _editButton;
@synthesize toolBar = _toolBar;
@synthesize overlapLabel = _overlapLabel;
@synthesize playSetButton = _playSetButton;
@synthesize playRecordingButton = _playRecordingButton;
@synthesize playClipButton = _playClipButton;
@synthesize overlapSlider = _overlapSlider;
@synthesize directorTimer = _directorTimer;
@synthesize timer = _timer;
@synthesize overlapEditField = _overlapEditField;

#pragma mark - view methods

- (void)configureView
{
    [self assignFileName];

    [self.editButton useBlackStyle];
    [self.recordButton useBlackStyle];
    [self.playSetButton useBlackStyle];
    [self.playRecordingButton useBlackStyle];
    [self.playClipButton useBlackStyle];
    if (self.thePlayer) {
        self.playerNameField.text = self.thePlayer.playerName;
        self.PlayerNumberField.text = [[NSNumber numberWithInt:self.thePlayer.playerNumber] stringValue];
        if (self.thePlayer.playerName.length >= 6) {
            if ([[self.thePlayer.playerName substringToIndex:6] isEqualToString:@"Player"]) {
                _isNewPlayer = YES;
                [self.playerNameField becomeFirstResponder];
                self.playerNameField.selectedRange = NSMakeRange(0, self.thePlayer.playerName.length);
            }
        }
    } 
    [self handle_DJSliderValueDidChangeNotification:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(self.parentViewController.view.frame.size.width/2 - 75, 16, 150, 150)];
        [self.toolBar addSubview:volumeView];
        [volumeView release];
    } else {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(675, 32, 150, 150)];
        [self.navigationController.view addSubview: volumeView];
        [volumeView release];
    }

    _overlapSlider = [[DJOverlapSlider alloc] initWithFrame:CGRectMake(100, 700, 500, 300)];
    [self setSliderValues];
    [self.view addSubview:self.overlapSlider];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            [self.overlapSlider setFrame:CGRectMake(self.view.frame.size.width/2 - 175, 710, 350, 180)];
        } else if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])){
            [self.overlapSlider setFrame:CGRectMake(self.view.frame.size.width/2 - 50, 516, 350, 180)];
        }
    } else {
        [self.overlapSlider setFrame:CGRectMake(0, 256, 320, 120)];
    }

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleDeviceDidRotateNotification:) 
                                                 name:UIDeviceOrientationDidChangeNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handle_DJSliderValueDidChangeNotification:) 
                                                 name:@"DJSliderValueDidChangeNotification" 
                                               object:nil];
    [self configureView];
}

-(void)viewDidAppear:(BOOL)animated{
    [self initializeAllPlayers];
}

-(void)setSliderValues{
    self.overlapSlider.trailingDelay = self.thePlayer.musicClip.clipDelay;
    self.overlapSlider.maxValueTop = [self.musicPlayer duration];
    if (self.overlapSlider.maxValueTop < 3) {
        self.overlapSlider.maxValueTop = 3;
    }
    if (self.thePlayer.musicClip) 
    {
        self.overlapSlider.trailingDelay = self.thePlayer.musicClip.clipDelay;
        if (self.thePlayer.musicClip.useDJClip) {
            if (!_djClipPlayer) {
                [self initializeDJMusicPlayer];
            }
            self.overlapSlider.maxValueBottom = self.djClipPlayer.duration;
        } else {
            self.overlapSlider.maxValueBottom = self.thePlayer.musicClip.clipLength;
        }
        
    }
}

-(bool)textFieldShouldReturn:(UITextField*)textField{
    
    if (self.thePlayer.musicClip.isFirst) {
        self.overlapSlider.trailingDelay = textField.text.floatValue - self.overlapSlider.maxValueTop;
    } else {
        self.overlapSlider.trailingDelay = self.overlapSlider.maxValueTop - textField.text.floatValue;
    }
    
    [textField resignFirstResponder];
    return NO;
}

- (void)viewDidUnload
{
    self.musicPlayer = nil;
    self.recordButton = nil;
    self.editButton = nil;
    self.playSetButton = nil;
    self.playRecordingButton = nil;
    self.playClipButton = nil;
    self.toolBar = nil;
    self.thePlayer = nil;
    self.playerNameField = nil;
    self.PlayerNumberField = nil;
    self.iPodMusicPlayer = nil;
    self.djClipPlayer = nil;
    self.fileName = nil;
    self.audioPopoverController = nil;
    self.overlapSlider = nil;
    [parentDelegate release];
    if (self.parentDelegate.ourLeague.dataChanged) {
        [self.parentDelegate.ourLeague saveData];
    }
    [self setOverlapLabel:nil];
    [self setOverlapEditField:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [_musicPlayer release];
    [_recordButton release];
    [_editButton release];
    [_playSetButton release];
    [_playRecordingButton release];
    [_playClipButton release];
    [_toolBar release];
    [_thePlayer release];
    [_playerNameField release];
    [_PlayerNumberField release];
    [_iPodMusicPlayer release];
    [_djClipPlayer release];
    [_audioPopoverController release];
    [_overlapSlider release];
    [parentDelegate release];
    if (self.parentDelegate.ourLeague.dataChanged) {
        [self.parentDelegate.ourLeague saveData];
    }
   
    [_overlapLabel release];
    [_overlapEditField release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

-(void)handleDeviceDidRotateNotification:(NSNotification*)notification{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            [self.overlapSlider setFrame:CGRectMake(self.view.frame.size.width/2 - 175, 710, 350, 180)];
        } else if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])){
            [self.overlapSlider setFrame:CGRectMake(self.view.frame.size.width/2 - 175, 516, 350, 180)];
        }
    }
}

-(void)handle_DJSliderValueDidChangeNotification:(NSNotification*)notification{
    
    if (self.thePlayer.musicClip) {
        self.thePlayer.musicClip.clipDelay = self.overlapSlider.trailingDelay;
        self.thePlayer.musicClip.isFirst = !self.overlapSlider.topFirst;
    }
    self.parentDelegate.ourLeague.dataChanged = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(playSet:) userInfo:nil repeats:NO];
    float overlapText = 0;
    if (self.overlapSlider.topFirst) {
        overlapText = [[NSNumber numberWithFloat:self.overlapSlider.maxValueTop - self.overlapSlider.trailingDelay] floatValue];
    } else {
        overlapText = [[NSNumber numberWithFloat:self.overlapSlider.maxValueTop + self.overlapSlider.trailingDelay] floatValue];
    }
    self.overlapEditField.text = [NSString stringWithFormat:@"%1.1f", overlapText];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Player Details", @"Player Details");
    }
    return self;
}


#pragma mark - textField handlers

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	if ( [text isEqualToString: @"\n"] ) {
		[textView resignFirstResponder];
        if (_isNewPlayer) {
            [self.PlayerNumberField becomeFirstResponder];
            self.PlayerNumberField.selectedRange = NSMakeRange(0, self.thePlayer.playerName.length);
            _isNewPlayer = NO;
        }
		return NO;
	}
	return YES;
}

#pragma mark - Audio Players

-(void)initializeAllPlayers{
    if (!self.thePlayer) {
        NSLog(@"Player Item is nil");
    } else {
        _setExists = YES;
        if (!self.thePlayer.musicClip.useDJClip) {
            [self initializeIPodMusicPlayer];
        } else {
            [self initializeDJMusicPlayer];
        }
        [self initializeRecordedAnnouncement];
    }
    if (_setExists) {
        self.overlapSlider.hidden = NO;
        self.overlapLabel.hidden = NO;
    } else {
        self.overlapSlider.hidden = YES;
        self.overlapLabel.hidden = YES;
    }
    //[self setSliderValues];
}

-(void)assignFileName{
    self.fileName = [[[self.parentDelegate.ourLeague.theLeague.theTeams objectAtIndex:self.teamIndex] teamName] stringByAppendingString:self.thePlayer.playerName];

}

-(void)assignMusicClip:(DJMusicClip*)clip{
    self.thePlayer.musicClip = clip;
    [self setSliderValues];
    [self initializeAllPlayers];
    self.parentDelegate.ourLeague.dataChanged = YES;
    [self.parentDelegate.ourLeague saveData];
}

-(void)initializeIPodMusicPlayer{
    if (!self.iPodMusicPlayer) {
        self.iPodMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    }
    if (self.thePlayer.musicClip.musicSelection) {
        
        NSArray* MusicPlayerQueue = [NSArray arrayWithObject:self.thePlayer.musicClip.musicSelection];
        MPMediaItemCollection* mpQ = [MPMediaItemCollection collectionWithItems:MusicPlayerQueue];
        [self.iPodMusicPlayer setQueueWithItemCollection:mpQ];
        self.iPodMusicPlayer.nowPlayingItem = self.thePlayer.musicClip.musicSelection;
        
        _clipStartPoint = self.thePlayer.musicClip.musicStartPoint;
        self.iPodMusicPlayer.currentPlaybackTime = _clipStartPoint;
        _clipLength = self.thePlayer.musicClip.clipLength;
        self.playClipButton.hidden = NO;

    } else {
        self.playClipButton.hidden = YES;
        _setExists = NO;
        NSLog(@"No Music Clip Found");
    } 

}

- (IBAction)clipPlay:(UIButton *)sender {

    if (self.thePlayer.musicClip.useDJClip) {
        if (self.djClipPlayer.isPlaying) {
            [self.djClipPlayer stop];
        } else {
            [self djClipPlay];
        }
    } else {
        if ([self.iPodMusicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
            [self.iPodMusicPlayer pause];
        } else {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(playerUpdate) userInfo:nil repeats:YES];
            [self.iPodMusicPlayer play];  
        }
    }
}

- (IBAction)clipEdit:(UIButton *)sender {
    DJMusicViewController* musicClipViewController = [[[DJMusicViewController alloc] initWithNibName:@"DJMusicViewController" bundle:nil] autorelease];
    [musicClipViewController setParentView:self];
    [musicClipViewController setParentDelegate:self.parentDelegate];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:musicClipViewController animated:YES completion:nil];
    } else {
        _audioPopoverController = [[UIPopoverController alloc] initWithContentViewController:musicClipViewController];
        self.audioPopoverController.delegate = self;
        [self.audioPopoverController setPopoverContentSize:CGSizeMake(360, 520) animated:YES];
        [self.audioPopoverController presentPopoverFromRect:CGRectMake(self.editButton.frame.origin.x, self.editButton.frame.origin.y + self.editButton.frame.size.height/2, 10, 10) 
                                                     inView: self.view
                                   permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
}

-(void)playerUpdate{
    //fade out if set
    if (self.thePlayer.musicClip.doFadeOut) {
        if ([self.iPodMusicPlayer currentPlaybackTime] > (_clipStartPoint + (_clipLength - 1.5))) {
            if (!_volumeCaptured) {
                self.volumeSetting = self.iPodMusicPlayer.volume;
                _volumeCaptured = YES;
            }
            [self.iPodMusicPlayer setVolume:([self.iPodMusicPlayer volume] - 0.05)];
        }
    }
    //stop at end of clip
    if ([self.iPodMusicPlayer currentPlaybackTime] > (_clipStartPoint + _clipLength)) {
        [self.iPodMusicPlayer stop];
        _clipLength = 0;
        _clipStartPoint = 0;
        [self.timer invalidate];
        self.iPodMusicPlayer.currentPlaybackTime = _clipStartPoint;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(endPlayCycle) userInfo:nil repeats:NO];
    }
}

-(void)endPlayCycle{
    [self.timer invalidate];
    self.iPodMusicPlayer.volume = self.volumeSetting;
    _volumeCaptured = NO;
    [self initializeAllPlayers];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (_setPlaying) {
        _setPlaying = NO;
    }
}

- (IBAction)announceEdit:(UIButton *)sender {
    DJVoiceRecorderViewController* voiceRecorder = [[DJVoiceRecorderViewController alloc] initWithNibName:@"DJVoiceRecorderViewController" bundle:nil];
    voiceRecorder.parentDelegate = self.parentDelegate;
    voiceRecorder.parentView = self;
    [self assignFileName];
    [voiceRecorder initRecorderWithFileName:self.fileName];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:voiceRecorder animated:YES completion:nil];
    } else {
        _audioPopoverController = [[UIPopoverController alloc] initWithContentViewController:voiceRecorder];
        self.audioPopoverController.delegate = self;
        [self.audioPopoverController setPopoverContentSize:CGSizeMake(420, 480) animated:YES];
        [self.audioPopoverController presentPopoverFromRect:CGRectMake(self.recordButton.frame.origin.x, self.recordButton.frame.origin.y + self.recordButton.frame.size.height/2, 1, 1) inView: self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
    
}

-(void)initializeRecordedAnnouncement{
    
    [self assignFileName];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dPath = [documentsDirectory stringByAppendingPathComponent:self.fileName];
    NSURL* soundFileURL = [NSURL fileURLWithPath:dPath];
    NSError* playerError = nil;
    if (_musicPlayer) {
        [_musicPlayer release];
    }
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&playerError];
    [self.musicPlayer setDelegate:self];
    self.playRecordingButton.hidden = NO;
    
    if (playerError) {
        NSLog(@"error assigning recording file: %@", playerError);
        self.playRecordingButton.hidden = YES;
        _setExists = NO;
    }
    
    if (![self.musicPlayer prepareToPlay]) {
        NSLog(@"error creating stream");
        self.playRecordingButton.hidden = YES;
        _setExists = NO;
    }
    
    
}

- (IBAction)announcePlay:(UIButton *)sender {

    [self initializeRecordedAnnouncement];
    [self.musicPlayer play];

}

-(void)initializeDJMusicPlayer{
    
    NSURL* djClipURL = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:self.thePlayer.musicClip.DJClipFilename ofType:@"mp3"]]
    ;
    NSError* djPlayerError = nil;
    if (_djClipPlayer) {
        [_djClipPlayer release];
    }
    _djClipPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:djClipURL error:&djPlayerError];
    self.playClipButton.hidden = NO;
    if (djPlayerError) {
        NSLog(@"Error assigning DJClip file: %@", djPlayerError);
        self.playClipButton.hidden = YES;
        _setExists = NO;
    }
    if (![self.djClipPlayer prepareToPlay]) {
        NSLog(@"Error creating stream - djClip");
        self.playClipButton.hidden = YES;
        _setExists = NO;
    }
}

-(void)djClipPlay{
    if (!_djClipPlayer) {
        [self initializeDJMusicPlayer];
    }
    [self.djClipPlayer play];
}



- (IBAction)playSet:(UIButton *)sender {
    
    if (_setPlaying) {
        [self.playSetButton setTitle:@"Play Announcement" forState:UIControlStateNormal];
        [self allStop];
        _setPlaying = NO;
    } else {
        [self.playSetButton setTitle:@"Stop" forState:UIControlStateNormal];
        _setPlaying = YES;
        if (self.thePlayer.musicClip.isFirst) {
            if (self.thePlayer.musicClip.useDJClip) {
                [self djClipPlay];
            } else {
                [self clipPlay:nil];
            }
            
        } else {
            [self announcePlay:nil];
        }
        
        self.directorTimer = [NSTimer scheduledTimerWithTimeInterval:self.thePlayer.musicClip.clipDelay target:self selector:@selector(director) userInfo:nil repeats:NO];
        
    }
}

-(void)allStop{
    if (self.iPodMusicPlayer) {
        [self.iPodMusicPlayer pause];
    }
    if (self.djClipPlayer) {
        [self.djClipPlayer stop];
    }
    if (self.musicPlayer) {
        [self.musicPlayer stop];
    }
    _setPlaying = NO;
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    if (self.directorTimer.isValid) {
        [self.directorTimer invalidate];
    }
    [self initializeAllPlayers];
}

-(void)director{
    if (self.thePlayer.musicClip.isFirst) {
        [self announcePlay:nil];
        
    } else {
        if (self.thePlayer.musicClip.useDJClip) {
            [self djClipPlay];
        } else {
            [self clipPlay:nil];  
        }
      
    }
    [self.directorTimer invalidate];
}


@end
