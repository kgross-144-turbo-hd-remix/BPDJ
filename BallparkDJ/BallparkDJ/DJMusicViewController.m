//
//  DJMusicViewController.m
//  BallparkDJ
//
//  Created by Timothy Goodson on 4/26/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//


#import "DJMusicViewController.h"

@interface DJMusicViewController () {
    NSTimeInterval _clipStartPoint;
    NSTimeInterval _clipLength;
    bool _volumeCaptured;
}
@end

@implementation DJMusicViewController
@synthesize clipSourceButton;
@synthesize cancelDoneSelector;
@synthesize musicPlayer;
@synthesize parentDelegate;
@synthesize parentView;
@synthesize volumeSetting;
@synthesize toolBar;
@synthesize popoverController;
@synthesize replayTimer;
@synthesize timer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    musicPlayer = [MPMusicPlayerController applicationMusicPlayer];

    if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [playPauseButton setTitle:@"⫿⫿" forState:UIControlStateNormal];
    } else {
        [playPauseButton setTitle:@"▷" forState:UIControlStateNormal];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.cancelDoneSelector setFrame:CGRectMake(0, 0, parentDelegate.window.bounds.size.width, 40)];
    } else {
        [self.cancelDoneSelector setFrame:CGRectMake(0, 0, 320, 40)];
        [self.clipSourceButton setFrame:CGRectMake(40, 42, 240, 38)];
    }

    [clipLengthSlider setValue:4.0f];
    if (clipLengthSlider.value <= 15) {
        //clipLengthLabel.text = [@"Length: " stringByAppendingString:[[NSString stringWithFormat:@"%1.1f", clipLengthSlider.value] stringByAppendingString:@" Seconds"]];
        clipLengthLabel.text = @"Length: ";
        clipLengthTextView.text = [NSString stringWithFormat:@"%1.1f", clipLengthSlider.value];
    } else {
        clipLengthLabel.text = @"Length: FULL";
        clipLengthTextView.text = @"";
    }
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(78, 16, 150, 150)];
    [self.toolBar addSubview: volumeView];
    [volumeView release];
    
    [self registerMediaPlayerNotifications];
    
    [playPauseButton useBlackStyle];
    [ffButton useBlackStyle];
    [fffButton useBlackStyle];
    [frButton useBlackStyle];
    [ffrButton useBlackStyle];
    [minusTenth useBlackStyle];
    [minusOne useBlackStyle];
    [plusTenth useBlackStyle];
    [plusOne useBlackStyle];
    [self setPlayer];
    if (self.parentView.thePlayer.musicClip.useDJClip) {
        titleLabel.text = self.parentView.thePlayer.musicClip.DJClipFilename;
        artistLabel.hidden = YES;
        startPositionLabel.hidden = YES;
        songPositionTextView.hidden = YES;
        songPositionSlider.hidden = YES;
        frButton.hidden = YES;
        ffrButton.hidden = YES;
        ffButton.hidden = YES;
        fffButton.hidden = YES;
        clipLengthLabel.hidden = YES;
        clipLengthSlider.hidden = YES;
        clipLengthTextView.hidden = YES;
        fadeOutLabel.hidden = YES;
        fadeOutSelector.hidden = YES;
        minusTenth.hidden = YES;
        minusOne.hidden = YES;
        plusOne.hidden = YES;
        plusTenth.hidden = YES;
    } else {
        artistLabel.hidden = NO;
        startPositionLabel.hidden = NO;
        songPositionTextView.hidden = NO;
        songPositionSlider.hidden = NO;
        frButton.hidden = NO;
        ffrButton.hidden = NO;
        ffButton.hidden = NO;
        fffButton.hidden = NO;
        clipLengthLabel.hidden = NO;
        clipLengthSlider.hidden = NO;
        clipLengthTextView.hidden = NO;
        fadeOutLabel.hidden = NO;
        fadeOutSelector.hidden = NO;
        minusTenth.hidden = NO;
        minusOne.hidden = NO;
        plusOne.hidden = NO;
        plusTenth.hidden = NO;
    }
}

-(void)setPlayer{
    if (self.parentView.thePlayer.musicClip.musicSelection) {
        NSArray* MusicPlayerQueue = [NSArray arrayWithObject:self.parentView.thePlayer.musicClip.musicSelection];
        MPMediaItemCollection* mpQ = [MPMediaItemCollection collectionWithItems:MusicPlayerQueue];
        [musicPlayer setQueueWithItemCollection:mpQ];
        musicPlayer.nowPlayingItem = self.parentView.thePlayer.musicClip.musicSelection;
        _clipStartPoint = self.parentView.thePlayer.musicClip.musicStartPoint;
        songPositionSlider.value = _clipStartPoint;
        fadeOutSelector.on = self.parentView.thePlayer.musicClip.doFadeOut;
        _clipLength = self.parentView.thePlayer.musicClip.clipLength;
        clipLengthSlider.value = _clipLength;
    } else {
        _clipLength = 7.0;
        clipLengthSlider.value = _clipLength;
    }
    [self updateLabels];
}

-(void)exitViewKeepingChanges{
    if ([musicPlayer nowPlayingItem] && !self.parentView.thePlayer.musicClip.useDJClip) {
        DJMusicClip* musicClip = [[DJMusicClip alloc] init];
        musicClip.musicSelection = musicPlayer.nowPlayingItem;
        musicClip.songTitle = [musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
        musicClip.musicStartPoint =songPositionSlider.value;
        musicClip.clipLength = clipLengthSlider.value;
        musicClip.doFadeOut = fadeOutSelector.on;
        musicClip.useDJClip = NO;
        musicClip.isFirst = !self.parentView.overlapSlider.topFirst;
        musicClip.clipDelay = self.parentView.overlapSlider.trailingDelay;
        [self.parentView assignMusicClip:musicClip];
        [musicClip release];
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.parentView.audioPopoverController dismissPopoverAnimated:YES];
    }
    if (self.parentDelegate.ourLeague.dataChanged) {
        [self.parentDelegate.ourLeague saveData];
    }
}

-(void)exitViewDiscardingChanges{

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.parentView.audioPopoverController dismissPopoverAnimated:YES];
    }
}

-(void)registerMediaPlayerNotifications{
    NSNotificationCenter* notificationsCenter = [NSNotificationCenter defaultCenter];
    [notificationsCenter addObserver: self
                            selector:@selector(handle_NowPlayingItemChanged:) 
                                name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification 
                              object:musicPlayer];
    [notificationsCenter addObserver:self
                            selector:@selector(handle_PlaybackStateChanged:)
                                name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                              object:musicPlayer];
    [musicPlayer beginGeneratingPlaybackNotifications];
    [notificationsCenter addObserver:self 
                            selector:@selector(handle_ClipPickerDidMakeSelectionNotification) 
                                name:@"DJClipPickerDidMakeSelection" 
                              object:nil];
}

-(void)handle_NowPlayingItemChanged :(id)notification{
    
    MPMediaItem* currentItem = [musicPlayer nowPlayingItem];
    songPositionSlider.maximumValue = [[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
    songPositionSlider.value = _clipStartPoint;
    
    NSString* titleString = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    if (titleString) {
        titleLabel.text = [NSString stringWithFormat:@"Title: %@", titleString];
    } else {
        titleLabel.text = @"Title: Unknown Title";
    }
    
    NSString* artistString = [currentItem valueForProperty:MPMediaItemPropertyArtist];
    if (artistString) {
        artistLabel.text = [NSString stringWithFormat:@"Artist: %@", artistString];
    } else {
        artistLabel.text = @"Artist Unknown";
    }
    [self updateLabels];
}

-(void)handle_PlaybackStateChanged :(id)notification{
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStatePaused) {
        [playPauseButton setTitle:@"▷" forState:UIControlStateNormal];
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        [playPauseButton setTitle:@"⫿⫿" forState:UIControlStateNormal];
    } else if (playbackState == MPMusicPlaybackStateStopped) {
        [playPauseButton setTitle:@"▷" forState:UIControlStateNormal];
         musicPlayer.nowPlayingItem = self.parentView.thePlayer.musicClip.musicSelection;
        musicPlayer.currentPlaybackTime = _clipStartPoint;
        [musicPlayer pause];
    }
    [self updateLabels];
}

- (void)viewDidUnload
{
    playPauseButton = nil;
    titleLabel = nil;
    artistLabel = nil;
    songPositionSlider = nil;
    clipLengthSlider = nil;
    clipLengthLabel = nil;
    fadeOutSelector = nil;
    self.cancelDoneSelector = nil;
    ffButton = nil;
    fffButton = nil;
    frButton = nil;
    ffrButton = nil;
    minusTenth = nil;
    minusOne = nil;
    plusTenth = nil;
    plusOne = nil;
    self.toolBar = nil;
    self.clipSourceButton = nil;
    startPositionLabel = nil;
    [clipLengthTextView release];
    clipLengthTextView = nil;
    [songPositionTextView release];
    songPositionTextView = nil;
    [fadeOutLabel release];
    fadeOutLabel = nil;
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification 
                                                  object:musicPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerPlaybackStateDidChangeNotification 
                                                  object:musicPlayer];
    [musicPlayer endGeneratingPlaybackNotifications];
    if (self.parentDelegate.ourLeague.dataChanged) {
        [self.parentDelegate.ourLeague saveData];
    }
}


- (void)dealloc {
    
    /*[playPauseButton release];
     [titleLabel release];
     [artistLabel release];
     [musicPlayer release];
     [fadeOutSelector release];
     [cancelDoneSelector release];
     [showMediaPcikerButton release];
     [ffButton release];
     [fffButton release];
     [frButton release];
     [ffrButton release];
     [minusTenth release];
     [minusOne release];
     [plusTenth release];
     [plusOne release];
     [toolBar release];
     [clipSourceButton release];
     [startPositionLabel release];*/
    [clipLengthTextView release];
    [songPositionTextView release];
    [fadeOutLabel release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    return (interfaceOrientation == UIInterfaceOrientationPortrait);

}

-(void)playerUpdate{
    //fade out if set
    if (fadeOutSelector.on) {
        if ([self.musicPlayer currentPlaybackTime] > (_clipStartPoint + (_clipLength - 1.5))) {
            if (!_volumeCaptured) {
                self.volumeSetting = self.musicPlayer.volume;
                _volumeCaptured = YES;
            }
            [self.musicPlayer setVolume:(self.musicPlayer.volume - 0.05)];
        }
    }
    //stop at end of clip
    if ([self.musicPlayer currentPlaybackTime] >= (_clipStartPoint + _clipLength)) {
        [self.musicPlayer pause];
        self.musicPlayer.currentPlaybackTime = _clipStartPoint;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(endPlayCycle) userInfo:nil repeats:NO];
    }
}

-(void)endPlayCycle{
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    musicPlayer.volume = self.volumeSetting;
    _volumeCaptured = NO;
}

-(void)updateLabels{
    //startPositionLabel.text = [@"Start Position: " stringByAppendingString:[NSString stringWithFormat:@"%1.1f", songPositionSlider.value]];
    songPositionTextView.text = [NSString stringWithFormat:@"%1.1f", songPositionSlider.value];
    if (clipLengthSlider.value <= 15) {
        //clipLengthLabel.text = [@"Length: " stringByAppendingString:[[NSString stringWithFormat:@"%1.1f", clipLengthSlider.value] stringByAppendingString:@" Seconds"]];
        clipLengthLabel.text = @"Length: ";
        clipLengthTextView.text = [NSString stringWithFormat:@"%1.1f", clipLengthSlider.value];
    } else {
        clipLengthLabel.text = @"Length: FULL";
        clipLengthTextView.text = @"";
    }
   
}

-(bool)textFieldShouldReturn:(UITextField*)textField{
    
    if (textField.tag == 0) {

        _clipLength = textField.text.floatValue;
        if (_clipLength > 16) {
            _clipLength = 16;
            textField.text = @"";
        }
        if (_clipLength < 1) {
            _clipLength = 1;
            textField.text = @"1.0";
        }
        clipLengthSlider.value = _clipLength;
        [self updateLabels];
        [self clipLengthChanged:nil];
    }
    
    if (textField.tag == 1) {
        _clipStartPoint = textField.text.floatValue;
        if (_clipStartPoint > [[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue]) {
            _clipStartPoint = [[musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue] - _clipLength;
            textField.text = [[NSNumber numberWithFloat:_clipStartPoint] stringValue];
        }
        if (_clipStartPoint < 0) {
            _clipStartPoint = 0;
            textField.text = @"0.0";
        }
        songPositionSlider.value = _clipStartPoint;
        [self updateLabels];
        [self songPositionChanged:nil];
    }
    
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)clipLengthWillChange:(id)sender {
    [self.musicPlayer pause];
}

- (IBAction)clipLengthChanged:(id)sender {
    
    NSNumberFormatter* numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setPositiveFormat:@"##.##"];
    
    if (clipLengthSlider.value <= 15) {
        //clipLengthLabel.text = [@"Length: " stringByAppendingString:[[NSString stringWithFormat:@"%1.1f", clipLengthSlider.value] stringByAppendingString:@" Seconds"]];
        clipLengthLabel.text = @"Length: ";
        clipLengthTextView.text = [NSString stringWithFormat:@"%1.1f", clipLengthSlider.value];
        _clipLength = [clipLengthSlider value];
    } else {
        clipLengthLabel.text = @"Length: FULL";
        clipLengthTextView.text = @"";
        _clipLength = [[self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue] - _clipStartPoint;
    }
    if (self.replayTimer.isValid) {
        [self.replayTimer invalidate];
    }
    self.replayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 
                                                        target:self 
                                                      selector:@selector(replay) 
                                                      userInfo:nil 
                                                       repeats:NO];
    
    [self updateLabels];
}

- (IBAction)songPositionWillChange:(id)sender {
    if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [self.musicPlayer pause];
        [timer invalidate];
    }
    
}


- (IBAction)CancelOrDonePressed:(UISegmentedControl *)sender {
    if (self.cancelDoneSelector.selectedSegmentIndex == 0) {
        [self exitViewDiscardingChanges];
    } else if (self.cancelDoneSelector.selectedSegmentIndex == 1){
        [self exitViewKeepingChanges];
    }
}

- (IBAction)songPositionChanged:(id)sender {
    
    _clipStartPoint = songPositionSlider.value;
    if (self.replayTimer.isValid) {
        [self.replayTimer invalidate];
    }
    self.replayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 
                                                        target:self 
                                                      selector:@selector(replay) 
                                                      userInfo:nil 
                                                       repeats:NO];
    [self updateLabels];
}


- (IBAction)showMediaPicker:(id)sender {
    
    if (self.clipSourceButton.selectedSegmentIndex == 0) {
        MPMediaPickerController* mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = NO;
        mediaPicker.prompt = @"Choose a song";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:mediaPicker] autorelease];
            [self.popoverController setDelegate:self];
            [self.popoverController setPopoverContentSize:CGSizeMake(360, 520) animated:YES];
            [self.popoverController presentPopoverFromRect:CGRectMake(self.clipSourceButton.frame.origin.x + self.clipSourceButton.frame.size.width/4, self.clipSourceButton.frame.origin.y + self.clipSourceButton.frame.size.height, 1, 1) 
                                                    inView: self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }else {
            [self presentModalViewController:mediaPicker animated:YES];
        }
        
        [mediaPicker release];
    } else {
        DJClipsViewController* clipsPickerViewController = [[DJClipsViewController alloc] initWithNibName:@"DJClipsPickerViewController" bundle:nil];
        clipsPickerViewController.thePlayer = self.parentView.thePlayer;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:clipsPickerViewController] autorelease];
            [self.popoverController setDelegate:self];
            [self.popoverController setPopoverContentSize:CGSizeMake(360, 520) animated:YES];
            [self.popoverController presentPopoverFromRect:CGRectMake(self.clipSourceButton.frame.origin.x + self.clipSourceButton.frame.size.width/4, self.clipSourceButton.frame.origin.y + self.clipSourceButton.frame.size.height, 1, 1) 
                                                    inView: self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        } else {
            [self presentViewController:clipsPickerViewController animated:YES completion:nil];
        }
        [clipsPickerViewController release];
    }

}

-(void)mediaPicker :(MPMediaPickerController*)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    if (mediaItemCollection) {
        [musicPlayer setQueueWithItemCollection:mediaItemCollection];
        artistLabel.hidden = NO;
        startPositionLabel.hidden = NO;
        songPositionTextView.hidden = NO;
        songPositionSlider.hidden = NO;
        frButton.hidden = NO;
        ffrButton.hidden = NO;
        ffButton.hidden = NO;
        fffButton.hidden = NO;
        clipLengthLabel.hidden = NO;
        clipLengthSlider.hidden = NO;
        clipLengthTextView.hidden = NO;
        fadeOutLabel.hidden = NO;
        fadeOutSelector.hidden = NO;
        minusTenth.hidden = NO;
        minusOne.hidden = NO;
        plusOne.hidden = NO;
        plusTenth.hidden = NO;
        [self playPause:nil];
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
}

-(void)handle_ClipPickerDidMakeSelectionNotification{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSLog(@"Dismissing clip  picker");
        [self dismissViewControllerAnimated:YES completion:(^{[self exitViewDiscardingChanges]; })];
        
    } else {
        [self.popoverController dismissPopoverAnimated:YES];
        [self exitViewDiscardingChanges];
    }
    self.parentDelegate.ourLeague.dataChanged = YES;
    [self.parentView initializeAllPlayers];
}

-(void)mediaPickerDidCancel :(MPMediaPickerController*)mediaPicker{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)playPause:(id)sender {
    if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [musicPlayer pause];
    } else {
        [musicPlayer setCurrentPlaybackTime:_clipStartPoint];
        [musicPlayer play];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(playerUpdate) userInfo:nil repeats:YES];
    }
}

- (IBAction)positionButton:(id)sender {
    
    [self.musicPlayer pause];
    switch ([sender tag]) {
        case -1:
            [songPositionSlider setValue:songPositionSlider.value - 0.1f];
            break;
        case -2:
            [songPositionSlider setValue:songPositionSlider.value - 1.0f];
            break;
        case 1:
            [songPositionSlider setValue:songPositionSlider.value + 0.1f];
            break;
        case 2:
            [songPositionSlider setValue:songPositionSlider.value + 1.0f];
            break;
        default:
            NSLog(@"Position adjust");
            break;
    }
    _clipStartPoint = songPositionSlider.value;
    
    if (self.replayTimer.isValid) {
        [self.replayTimer invalidate];
    }
    self.replayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 
                                                        target:self 
                                                      selector:@selector(replay) 
                                                      userInfo:nil 
                                                       repeats:NO];
    [self updateLabels];
}

- (IBAction)lengthButton:(id)sender {
    
    [self.musicPlayer pause];
    switch ([sender tag]) {
        case -1:
            [clipLengthSlider setValue:clipLengthSlider.value - 0.1f];
            break;
        case -2:
            [clipLengthSlider setValue:clipLengthSlider.value - 1.0f];
            break;
        case 1:
            [clipLengthSlider setValue:clipLengthSlider.value + 0.1f];
            break;
        case 2:
            [clipLengthSlider setValue:clipLengthSlider.value +1.0f];
            break;
        default:
            NSLog(@"Clip Length Adjust");
            break;
    }
    if (clipLengthSlider.value <= 15) {
        _clipLength = clipLengthSlider.value;
    } else {
        _clipLength = [[self.musicPlayer.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] floatValue];
    }
    if (self.replayTimer.isValid) {
        [self.replayTimer invalidate];
    }
    self.replayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 
                                                        target:self 
                                                      selector:@selector(replay) 
                                                      userInfo:nil 
                                                       repeats:NO];
    [self updateLabels];
}

- (IBAction)clipFormatSelector:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.parentView.thePlayer.musicClip.useDJClip = NO;
    } else {
        self.parentView.thePlayer.musicClip.useDJClip = YES;
    }
    
    if (sender.selectedSegmentIndex == 0) {
        MPMediaPickerController* mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = NO;
        mediaPicker.prompt = @"Choose a song";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:mediaPicker] autorelease];
            [self.popoverController setDelegate:self];
            [self.popoverController setPopoverContentSize:CGSizeMake(360, 520) animated:YES];
            [self.popoverController presentPopoverFromRect:CGRectMake(self.clipSourceButton.frame.origin.x + self.clipSourceButton.frame.size.width/4, self.clipSourceButton.frame.origin.y + self.clipSourceButton.frame.size.height, 1, 1) 
                                                    inView: self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }else {
            [self presentModalViewController:mediaPicker animated:YES];
        }
        
        [mediaPicker release];
    } else {
        DJClipsViewController* clipsPickerViewController = [[DJClipsViewController alloc] initWithNibName:@"DJClipsPickerViewController" bundle:nil];
        clipsPickerViewController.thePlayer = self.parentView.thePlayer;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:clipsPickerViewController] autorelease];
            [self.popoverController setDelegate:self];
            [self.popoverController setPopoverContentSize:CGSizeMake(360, 520) animated:YES];
            [self.popoverController presentPopoverFromRect:CGRectMake(self.clipSourceButton.frame.origin.x + self.clipSourceButton.frame.size.width/4, self.clipSourceButton.frame.origin.y + self.clipSourceButton.frame.size.height, 1, 1) 
                                                    inView: self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        } else {
            [self presentViewController:clipsPickerViewController animated:YES completion:nil];
        }
        [clipsPickerViewController release];
    }
}

-(void)replay{
    if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        musicPlayer.currentPlaybackTime = _clipStartPoint;
    } else {
        [self playPause:self];
    }
}

@end
