//
//  DJMusicViewController.h
//  BallparkDJ
//
//  Created by Timothy Goodson on 4/26/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DJAppDelegate.h"
#import "DJDetailViewController.h"
#import "DJClipsViewController.h"

@interface DJMusicViewController : UIViewController <MPMediaPickerControllerDelegate, UIPopoverControllerDelegate>{
    
    NSTimer* timer;
    IBOutlet DJGradientButton *playPauseButton;
    IBOutlet UISlider *songPositionSlider;    
    IBOutlet UILabel *startPositionLabel;
    IBOutlet UILabel *clipLengthLabel;
    IBOutlet UISlider *clipLengthSlider;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *artistLabel;
    IBOutlet UISwitch *fadeOutSelector;   
    IBOutlet DJGradientButton *ffButton;
    IBOutlet DJGradientButton *fffButton;
    IBOutlet DJGradientButton *frButton;
    IBOutlet DJGradientButton *ffrButton;
    IBOutlet DJGradientButton *minusTenth;
    IBOutlet DJGradientButton *minusOne;
    IBOutlet DJGradientButton *plusTenth;
    IBOutlet DJGradientButton *plusOne;
    IBOutlet UITextField *clipLengthTextView;
    IBOutlet UITextField *songPositionTextView;
    IBOutlet UILabel *fadeOutLabel;
}
@property(retain, nonatomic) UIPopoverController* popoverController;
@property(nonatomic, retain) MPMusicPlayerController* musicPlayer;
@property(retain, nonatomic) DJDetailViewController* parentView;
@property(strong, nonatomic) DJAppDelegate* parentDelegate;
@property(assign, nonatomic) float volumeSetting;
@property (retain, nonatomic) IBOutlet UISegmentedControl *clipSourceButton;
@property (assign, nonatomic) IBOutlet UISegmentedControl *cancelDoneSelector;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
@property (retain, nonatomic) NSTimer* replayTimer;
@property(retain, nonatomic) NSTimer* timer;

- (IBAction)clipLengthWillChange:(id)sender;
- (IBAction)clipLengthChanged:(id)sender;
- (IBAction)songPositionWillChange:(id)sender;
- (IBAction)CancelOrDonePressed:(UISegmentedControl *)sender;
- (IBAction)songPositionChanged:(id)sender;
- (IBAction)showMediaPicker:(id)sender;
- (IBAction)playPause:(id)sender;
- (IBAction)positionButton:(id)sender;
- (IBAction)lengthButton:(id)sender;
- (IBAction)clipFormatSelector:(UISegmentedControl *)sender;

-(void)registerMediaPlayerNotifications;
@end
