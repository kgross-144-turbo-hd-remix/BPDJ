//
//  DJClipsViewController.m
//  BallparkDJ
//
//  Created by Timothy Goodson on 7/22/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import "DJClipsViewController.h"
#import "DJGradientButton.h"

@interface DJClipsViewController ()

@end

@implementation DJClipsViewController
@synthesize clips;
@synthesize thePlayer;
@synthesize parentViewController;
@synthesize musicPlayer = _musicPlayer;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clips = [NSArray arrayWithObjects:
             @"Latin_Industries", 
             @"RetroFuture", 
             @"Who_Likes_To_Party", 
             nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"clipCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clipCell"] autorelease];
    }
    
    cell.textLabel.text = [@"           " stringByAppendingString:[clips objectAtIndex:indexPath.row]];
    
    DJGradientButton* cellPlayButton = [[DJGradientButton alloc] initWithFrame:CGRectMake(2, 6, 52, 32)];
    [cellPlayButton useBlackStyle];
    cellPlayButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [cellPlayButton setTitle:@"Play" forState:UIControlStateNormal];
    cellPlayButton.tag = indexPath.row;
    [cellPlayButton addTarget:self action:@selector(handle_cellButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:cellPlayButton];
    [cellPlayButton release];
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    self.thePlayer.musicClip.DJClipFilename = [clips objectAtIndex:indexPath.row];
    self.thePlayer.musicClip.useDJClip = YES;
    self.thePlayer.musicClip.doFadeOut = NO;
    self.thePlayer.musicClip.clipDelay = 3;
    NSNotification* clipPickerDidMakeSelection = [NSNotification notificationWithName:@"DJClipPickerDidMakeSelection" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:clipPickerDidMakeSelection];
}

#pragma mark - Music Player


-(void)handle_cellButtonPushed:(id)sender{
    
    UIButton* button = (UIButton*)sender;
    if (self.musicPlayer.isPlaying) {
        [self.musicPlayer stop];
        [button setTitle:@"Play" forState:UIControlStateNormal];
    }else {
        NSURL* djClipURL = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:[clips objectAtIndex:button.tag] ofType:@"mp3"]];
        NSError* playerError = nil;
        
        if (_musicPlayer) {
            [_musicPlayer release]; 
        }
        _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:djClipURL error:&playerError];
        if (playerError) {
            NSLog(@"ClipIcker Error assigning file");
        }
        if (![self.musicPlayer prepareToPlay]) {
            NSLog(@"Error Creating stream - clip picker");
        }
        [button setTitle:@"Stop" forState:UIControlStateNormal];
        self.musicPlayer.delegate = self;
        [self.musicPlayer play];
    }

}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        [self.tableView reloadData];
    }
}

@end
