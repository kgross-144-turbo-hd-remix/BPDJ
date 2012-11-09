//
//  DJVoiceRecorderViewController.m
//  BallparkDJ
//
//  Created by Timothy Goodson on 6/6/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import "DJVoiceRecorderViewController.h"
#import <CoreAudio/CoreAudioTypes.h>

@interface DJVoiceRecorderViewController (){
    NSTimer* _timer;
    NSInteger _count;
    float _tmrSeconds;
}
@end

@implementation DJVoiceRecorderViewController
@synthesize parentDelegate;
@synthesize parentView;
@synthesize cancelDoneButton;
@synthesize recordButton;
@synthesize mainPic;
@synthesize elapsedTimeMeter;
@synthesize recordPauseButton;
@synthesize playButton;
@synthesize powerMeterL0;
@synthesize powerMeterL1;
@synthesize powerMeterL2;
@synthesize powerMeterL3;
@synthesize powerMeterL4;
@synthesize powerMeterL5;
@synthesize powerMeterL6;
@synthesize powerMeterL7;
@synthesize powerMeterL8;
@synthesize powerMeterL9;
@synthesize powerMeterL10;
@synthesize powerMeterL11;
@synthesize powerMeterL12;
@synthesize powerMeterL13;
@synthesize powerMeterL14;
@synthesize powerMeterL15;
@synthesize powerMeterL16;
@synthesize powerMeterL17;
@synthesize powerMeterL18;
@synthesize powerMeterL19;
@synthesize powerMeterL20;
@synthesize powerMeterL21;
@synthesize powerMeterL22;
@synthesize powerMeterL23;
@synthesize powerMeterL24;
@synthesize powerMeterL25;
@synthesize powerMeterL26;
@synthesize powerMeterL27;
@synthesize recorder = _recorder;
@synthesize isRecording;
@synthesize musicPlayer = _musicPlayer;
@synthesize filename;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

//Despite the name, this is NOT a class init, it just sets the recorder up for use
-(void)initRecorderWithFileName:(NSString *)fileName{
    self.filename = fileName;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSURL* soundFileURL = [NSURL fileURLWithPath:dPath];
    NSError* recordError = nil;
    
    NSMutableDictionary* recorderSettings = [[NSMutableDictionary alloc] init];
   
    [recorderSettings setValue:[NSNumber numberWithInt:'ima4'] forKey:AVFormatIDKey];
    [recorderSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recorderSettings setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recorderSettings setValue:[NSNumber numberWithInt:32] forKey:AVLinearPCMBitDepthKey];
    [recorderSettings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recorderSettings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    [recorderSettings setValue:[NSNumber numberWithInt:96] forKey:AVEncoderBitRateKey];
    [recorderSettings setValue:[NSNumber numberWithInt:16] forKey:AVEncoderBitDepthHintKey];
    [recorderSettings setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVSampleRateConverterAudioQualityKey];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recorderSettings error:&recordError];
    if (recordError) {
        NSLog(@"error: %@", recordError);
    }
    if (![self.recorder prepareToRecord]) {
        NSLog(@"error creating stream");
    }
    [recorderSettings release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.cancelDoneButton setFrame:CGRectMake(0, parentDelegate.window.bounds.size.height - 58, parentDelegate.window.bounds.size.width, 40)];
    } else {
        [self.cancelDoneButton setFrame:CGRectMake(0, 423, 320, 40)];
    }
    [self.recordButton useBlackStyle];
}

- (void)viewDidUnload
{
    self.elapsedTimeMeter = nil;
    self.recordPauseButton = nil;
    self.powerMeterL0 = nil;
    self.powerMeterL1 = nil;
    self.powerMeterL2 = nil;
    self.powerMeterL3 = nil;
    self.powerMeterL4 = nil;
    self.powerMeterL5 = nil;
    self.powerMeterL6 = nil;
    self.powerMeterL7 = nil;
    self.powerMeterL8 = nil;
    self.powerMeterL9 = nil;
    self.powerMeterL8 = nil;
    self.powerMeterL9 = nil;
    self.powerMeterL10 = nil;
    self.powerMeterL11 = nil;
    self.powerMeterL12 = nil;
    self.powerMeterL13 = nil;
    self.powerMeterL14 = nil;
    self.powerMeterL15 = nil;
    self.powerMeterL16 = nil;
    self.powerMeterL17 = nil;
    self.powerMeterL18 = nil;
    self.powerMeterL19 = nil;
    self.powerMeterL20 = nil;
    self.powerMeterL21 = nil;
    self.powerMeterL22 = nil;
    self.powerMeterL23 = nil;
    self.powerMeterL24 = nil;
    self.powerMeterL25 = nil;
    self.powerMeterL26 = nil;
    self.powerMeterL27 = nil;
    self.cancelDoneButton = nil;
    self.recordButton = nil;
    self.mainPic = nil;
    [self setPlayButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)dealloc {
    [elapsedTimeMeter release];
    [recordPauseButton release];
    [powerMeterL0 release];
    [powerMeterL1 release];
    [powerMeterL2 release];
    [powerMeterL3 release];
    [powerMeterL4 release];
    [powerMeterL5 release];
    [powerMeterL6 release];
    [powerMeterL7 release];
    [powerMeterL8 release];
    [powerMeterL9 release];
    [powerMeterL8 release];
    [powerMeterL9 release];
    [powerMeterL10 release];
    [powerMeterL11 release];
    [powerMeterL12 release];
    [powerMeterL13 release];
    [powerMeterL14 release];
    [powerMeterL15 release];
    [powerMeterL16 release];
    [powerMeterL17 release];
    [powerMeterL18 release];
    [powerMeterL19 release];
    [powerMeterL20 release];
    [powerMeterL21 release];
    [powerMeterL22 release];
    [powerMeterL23 release];
    [powerMeterL24 release];
    [powerMeterL25 release];
    [powerMeterL26 release];
    [powerMeterL27 release];
    [cancelDoneButton release];
    [recordButton release];
    [mainPic release];
    [playButton release];
    [super dealloc];
}

-(void)countdownToRecord{
    
    if (_count > 0) {
        
        switch (_count) {
             case 2:
                self.mainPic.image = [UIImage imageNamed:@"two.png"];
                break;
             case 1:
                self.mainPic.image = [UIImage imageNamed:@"one.png"];
                break;
            default:
                break;
        }
        _count--;
    } else {
        
        [_timer invalidate];
        self.recorder.meteringEnabled = YES;
        
        self.elapsedTimeMeter.textColor = [UIColor greenColor];
        [self.recordButton setImage:[UIImage imageNamed:@"stopButton.png"] 
                           forState:UIControlStateNormal];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 
                                                  target:self 
                                                selector:@selector(updateUI) 
                                                userInfo:nil 
                                                 repeats:YES];
        [self.recorder record];
    }
    
}

- (IBAction)recordPauseButtonDidGetPressed:(id)sender {
    
    if (!self.recorder.isRecording) {
        _count = 2;
        self.mainPic.image = [UIImage imageNamed:@"three.png"];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                  target:self 
                                                selector:@selector(countdownToRecord) 
                                                userInfo:nil 
                                                 repeats:YES];
        self.playButton.hidden = YES;
    }else {
        [_timer invalidate];
        self.recorder.meteringEnabled = NO;
        [self.recordButton setImage:[UIImage imageNamed:@"recButton.png"] 
                           forState:UIControlStateNormal];
        [self.recorder stop];
        self.playButton.hidden = NO;
        self.elapsedTimeMeter.textColor = [UIColor redColor];
        for (UIImageView* img in powerMeterL0) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL1) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL2) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL3) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL4) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL5) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL6) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL7) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL8) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL9) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL10) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL11) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL12) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL13) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL14) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL15) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL16) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL17) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL18) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL19) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL20) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL21) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL22) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL23) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL24) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL25) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL26) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            for (UIImageView* img in powerMeterL27) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }

    }
}

-(void)initializeRecordedAnnouncement{
        
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dPath = [documentsDirectory stringByAppendingPathComponent:self.filename];
    NSURL* soundFileURL = [NSURL fileURLWithPath:dPath];
    NSError* playerError = nil;
    if (_musicPlayer) {
        [_musicPlayer release];
    }
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&playerError];
    [self.musicPlayer setDelegate:self];
    
    
    if (playerError) {
        NSLog(@"error assigning recording file: %@", playerError);
    }
    
    if (![self.musicPlayer prepareToPlay]) {
        NSLog(@"error creating stream");
    }
    
    
}

- (IBAction)playButtonDidGetPressed:(id)sender {
    if (self.musicPlayer.isPlaying) {
        [self.musicPlayer stop];
        [self.playButton setImage:[UIImage imageNamed:@"playButton.png"] 
                           forState:UIControlStateNormal];
    } else {
        [self initializeRecordedAnnouncement];
        [self.musicPlayer play];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(updateUIForPlayer) userInfo:nil repeats:YES];
        [self.playButton setImage:[UIImage imageNamed:@"stopButton.png"] 
                           forState:UIControlStateNormal];
    }

}

- (IBAction)cancelDoneButtonPressed:(UISegmentedControl *)sender {
    [self.recorder stop];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (sender.selectedSegmentIndex == 0) {
            [self dismissModalViewControllerAnimated:YES];
        } else if (sender.selectedSegmentIndex == 1) {
            [self dismissModalViewControllerAnimated:YES];
        }
    } else {
        [self.parentView.audioPopoverController dismissPopoverAnimated:YES];
    }    
}

-(void)updateUIForPlayer{
    
    if (self.musicPlayer.isPlaying) {
        _tmrSeconds = [[NSNumber numberWithInt:[[NSNumber numberWithDouble:[self.musicPlayer currentTime]] doubleValue]] intValue]%60;
        [self.playButton setImage:[UIImage imageNamed:@"pauseButton.png"] 
                           forState:UIControlStateNormal];
        self.elapsedTimeMeter.text = [NSString stringWithFormat:@"%1d", _tmrSeconds];
    } else {
        [_timer invalidate];
        _tmrSeconds = 0;
        self.elapsedTimeMeter.text = [NSString stringWithFormat:@"%1d", _tmrSeconds];
        [self.playButton setImage:[UIImage imageNamed:@"playButton.png"] 
                           forState:UIControlStateNormal];
    }
}

-(void)updateUI{
    
    if ([self.recorder isRecording]) {
        self.mainPic.image = [UIImage imageNamed:@"mic.png"];
        //update power meter LEDs levels are in dB
        [self.recorder updateMeters];
        if ([self.recorder averagePowerForChannel:0] > -30.0) {
            for (UIImageView* img in powerMeterL0) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];  ////
            }
        }else{
            for (UIImageView* img in powerMeterL0) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -26.0) {
            for (UIImageView* img in powerMeterL1) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL1) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -22.5) {
            for (UIImageView* img in powerMeterL2) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL2) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -21.0) {
            for (UIImageView* img in powerMeterL3) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL3) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -19.1) {
            for (UIImageView* img in powerMeterL4) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];  /////
            }
        }else{
            for (UIImageView* img in powerMeterL4) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -16.8) {
            for (UIImageView* img in powerMeterL5) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL5) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -15.5) {
            for (UIImageView* img in powerMeterL6) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL6) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -14.6) {
            for (UIImageView* img in powerMeterL7) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]]; //////
            }
        }else{
            for (UIImageView* img in powerMeterL7) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -13.3) {
            for (UIImageView* img in powerMeterL8) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL8) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -12.4) {
            for (UIImageView* img in powerMeterL9) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL9) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -11.0) {
            for (UIImageView* img in powerMeterL10) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL10) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -10.1) {
            for (UIImageView* img in powerMeterL11) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];  /////////
            }
        }else{
            for (UIImageView* img in powerMeterL11) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -9.7) {
            for (UIImageView* img in powerMeterL12) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL12) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -9.1) {
            for (UIImageView* img in powerMeterL13) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL13) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -8.3) {
            for (UIImageView* img in powerMeterL14) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]]; ///////
            }
        }else{
            for (UIImageView* img in powerMeterL14) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -6.1) {
            for (UIImageView* img in powerMeterL15) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL15) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -5.2) {
            for (UIImageView* img in powerMeterL16) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL16) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -4.8) {
            for (UIImageView* img in powerMeterL17) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];   /////////
            }
        }else{
            for (UIImageView* img in powerMeterL17) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -4.0) {
            for (UIImageView* img in powerMeterL18) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL18) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -3.6) {
            for (UIImageView* img in powerMeterL19) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL19) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -3.0) {
            for (UIImageView* img in powerMeterL20) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];    /////////
            }
        }else{
            for (UIImageView* img in powerMeterL20) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -2.5) {
            for (UIImageView* img in powerMeterL21) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL21) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -2.0) {
            for (UIImageView* img in powerMeterL22) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL22) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -1.7) {
            for (UIImageView* img in powerMeterL23) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL23) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -1.3) {
            for (UIImageView* img in powerMeterL24) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];   ////////            
            }
        }else{
            for (UIImageView* img in powerMeterL24) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -0.8) {
            for (UIImageView* img in powerMeterL25) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];    /////
            }
        }else{
            for (UIImageView* img in powerMeterL25) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > 0.4) {
            for (UIImageView* img in powerMeterL26) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];    /////
            }
        }else{
            for (UIImageView* img in powerMeterL26) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > 0.7) {
            for (UIImageView* img in powerMeterL27) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];  ///////
            }
        }else{
            for (UIImageView* img in powerMeterL27) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }

        _tmrSeconds = [[NSNumber numberWithDouble:[self.recorder currentTime]] floatValue];
        
        self.elapsedTimeMeter.text = [NSString stringWithFormat:@"%1.1f", _tmrSeconds];
        
    } else {            
        for (UIImageView* img in powerMeterL0) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL1) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL2) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL3) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL4) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL5) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL6) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL7) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL8) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL9) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL10) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL11) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL12) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL13) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL14) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL15) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL16) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL17) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL18) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL19) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL20) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL21) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL22) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL23) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL24) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL25) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL26) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }            
        for (UIImageView* img in powerMeterL27) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
    }
}

@end
