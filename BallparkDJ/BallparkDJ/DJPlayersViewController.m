//
//  DJPlayersViewController.m
//  BallparkDJ
//
//  Created by Timothy Goodson on 6/23/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import "DJPlayersViewController.h"
#import "DJGradientButton.h"

@interface DJPlayersViewController (){
    NSTimeInterval _clipStartPoint;
    NSTimeInterval _clipLength;
    BOOL _volumeCaptured, _setPlaying, _iPodClipValid;
}

@end

@implementation DJPlayersViewController
@synthesize playersTable;
@synthesize bottomButtonBar = _bottomButtonBar;
@synthesize parentDelegate;
@synthesize teamIndex = _teamIndex;
@synthesize playerIndex = _playerIndex;
@synthesize detailViewController = _detailViewController;
@synthesize theTeam;
@synthesize teamNameViewController;
@synthesize fileName = _fileName;
@synthesize musicPlayer = _musicPlayer;
@synthesize djClipPlayer = _djClipPlayer;
@synthesize volumeSetting = _volumeSetting;
@synthesize iPodMusicPlayer = _iPodMusicPlayer;
@synthesize timer = _timer;
@synthesize directorTimer = _directorTimer;

#pragma mark - ViewController stuff

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Players", @"Players");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerTextViewNotifications];
    //nav bar buttons
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(self.bottomButtonBar.frame.size.width/2 - 75, 16, 150, 150)];
    [self.bottomButtonBar addSubview: volumeView];
    [volumeView release];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else return YES;
}

- (void)viewDidUnload
{
    
    self.playersTable = nil;
    self.bottomButtonBar = nil;
    self.parentDelegate = nil;
    self.theTeam = nil;
    self.detailViewController = nil;
    self.teamNameViewController = nil;
    self.timer = nil;
    self.directorTimer = nil;
    //un-register notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UITextViewTextDidEndEditingNotification 
                                                  object:self.detailViewController.playerNameField];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UITextViewTextDidEndEditingNotification 
                                                  object:self.detailViewController.PlayerNumberField];
    if (self.teamNameViewController) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:self.teamNameViewController.teamNameTextField];
    }
    //save persistent data if changed
    if (self.parentDelegate.ourLeague.dataChanged) {
        [self.parentDelegate.ourLeague saveData];
    }
    [super viewDidUnload];
}

- (void)dealloc {
    [playersTable release];
    [parentDelegate release];
    [_detailViewController release];
    [theTeam release];
    [teamNameViewController release];
    [_timer release];
    [_directorTimer release];
    if (self.parentDelegate.ourLeague.dataChanged) {
        [self.parentDelegate.ourLeague saveData];
    }
    [_bottomButtonBar release];
    [super dealloc];
}

#pragma mark - text field notifications

-(void)registerTeamNameTextViewNotifications{
    NSNotificationCenter* notificationsCenter = [NSNotificationCenter defaultCenter];
    [notificationsCenter addObserver:self 
                            selector:@selector(handle_TeamName_TextDidEndEditingNotification:) 
                                name:UITextFieldTextDidEndEditingNotification 
                              object:self.teamNameViewController.teamNameTextField];
}

-(void)registerTextViewNotifications{    
    NSNotificationCenter* notificationsCenter = [NSNotificationCenter defaultCenter];
    [notificationsCenter addObserver:self
                            selector:@selector(handle_NameTextDidEndEditingNotification:) 
                                name:UITextViewTextDidEndEditingNotification 
                              object:self.detailViewController.playerNameField];
    [notificationsCenter addObserver:self
                            selector:@selector(handle_NumberTextDidEndEditingNotification:) 
                                name:UITextViewTextDidEndEditingNotification 
                              object:self.detailViewController.PlayerNumberField];
}

-(void)handle_NameTextDidEndEditingNotification:(id)notification{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dPath = [documentsDirectory stringByAppendingPathComponent:self.fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dPath]) {
        NSString* newFileName = [self.theTeam.teamName stringByAppendingString:self.detailViewController.playerNameField.text];
        NSError* fileError = nil;
        [[NSFileManager defaultManager] moveItemAtPath:dPath toPath:[documentsDirectory stringByAppendingPathComponent:newFileName] error:&fileError];
        if (fileError) {
            NSLog(@"Error changing file name");
        }
    }
    [[self.theTeam.theLineup objectAtIndex:self.playerIndex] setPlayerName:self.detailViewController.playerNameField.text];
    [self.playersTable reloadData];
    self.parentDelegate.ourLeague.dataChanged = YES;
}

-(void)handle_NumberTextDidEndEditingNotification:(id)notification{
    [[self.theTeam.theLineup objectAtIndex:self.playerIndex] setPlayerNumber:self.detailViewController.PlayerNumberField.text.intValue];
    [self.playersTable reloadData];
    self.parentDelegate.ourLeague.dataChanged = YES;
}

-(void)handle_TeamName_TextDidEndEditingNotification:(id)notification{
    [self.theTeam setTeamName:self.teamNameViewController.teamNameTextField.text];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.playersTable reloadData];
    self.parentDelegate.ourLeague.dataChanged = YES;
}

#pragma mark - standard business

- (IBAction)teamButtonPressed:(UIBarButtonItem *)sender {
    [self.parentDelegate switchViewToLeague];
}

-(void)assignData:(DJTeam *)team{
    self.theTeam = team;
    [self.theTeam.theLineup removeAllObjects];
    for (int i = 0; i < self.theTeam.thePlayers.count; ++i) {
        [self.theTeam.theLineup addObject:[self.theTeam.thePlayers objectAtIndex:i]];
    }
}

//==========================================================================================
#pragma mark - Table View
//==========================================================================================

//TableView delegate methods and related
-(void)insertNewObject:(id)sender{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    DJPlayer* p = [[[DJPlayer alloc] init] autorelease];
    [p setPlayerName:@"Player-New"];
    [self.theTeam.thePlayers insertObject:p atIndex:0];
    [self.theTeam.theLineup insertObject:p atIndex:0];
    [self.playersTable insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.playersTable reloadData];
    self.parentDelegate.ourLeague.dataChanged = YES;
    self.playerIndex = 0;
    [self callDetailViewOnRow:0];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    if (!editing) {
        [playersTable setEditing:NO animated:YES];
    } else {
        [playersTable setEditing:YES animated:YES];
    }
}

-(void)callDetailViewOnRow:(NSInteger)selectedRow{
    
    if (self.navigationController.topViewController != self.detailViewController) {
        NSString* xibName = nil;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            xibName = @"DJDetailViewController_iPhone";
        } else {
            xibName = @"DJDetailViewController_iPad";
        }
        _detailViewController = [[DJDetailViewController alloc] initWithNibName:xibName bundle:nil];
        self.detailViewController.parentDelegate = self.parentDelegate;
        self.detailViewController.teamIndex = self.teamIndex;
        self.detailViewController.thePlayer = [self.theTeam.theLineup objectAtIndex:selectedRow];
        self.detailViewController.playerIndex = selectedRow;
        self.detailViewController.playerNameField.text = [[self.theTeam.theLineup objectAtIndex:selectedRow] playerName];
        self.detailViewController.PlayerNumberField.text = [[NSNumber numberWithInt:[[self.theTeam.theLineup objectAtIndex:selectedRow] playerNumber]] stringValue];
    }    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

-(void)handle_cellButtonPressed:(id)sender{
    
    UIButton* button = (UIButton*)sender;
    NSInteger selectedRow = button.tag;    
    self.playerIndex = selectedRow;
    [self callDetailViewOnRow:selectedRow];
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return self.theTeam.teamName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.theTeam.theLineup.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"PlayerCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];        
    }
    
    //strip the cell first
    [[cell.contentView viewWithTag:6981] removeFromSuperview];
    
    // Configure the cell... 
    
    NSString* player = [[self.theTeam.theLineup objectAtIndex:indexPath.row] playerName];   
    cell.textLabel.text = [@"                " stringByAppendingString:player]; 
    
    
    UILabel* playerNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, (cell.frame.size.height - 30)/2, 40, 30)];
    playerNumberLabel.backgroundColor = [UIColor clearColor];
    playerNumberLabel.textAlignment = UITextAlignmentLeft;
    playerNumberLabel.font = [UIFont boldSystemFontOfSize:18];
    playerNumberLabel.text = [@"#" stringByAppendingString:[[NSNumber numberWithInt:[[self.theTeam.theLineup objectAtIndex:indexPath.row] playerNumber]] stringValue]];
    playerNumberLabel.tag = 6981;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    DJGradientButton* myEditButton = [[DJGradientButton alloc] initWithFrame:CGRectMake(2,6,52,32)];
    [myEditButton useBlackStyle];
    myEditButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [myEditButton setTitle:@"Edit" forState:UIControlStateNormal];
    myEditButton.tag = indexPath.row;
    [myEditButton addTarget:self action:@selector(handle_cellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView* stopImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stopOverlay.png"]];
    stopImage.tag = 1212;
    stopImage.hidden = YES;
    [cell.contentView addSubview:myEditButton];
    [cell.contentView addSubview:playerNumberLabel];
    [cell.contentView addSubview:stopImage];
    [playerNumberLabel release];
    [myEditButton release];
    cell.showsReorderControl = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.theTeam.thePlayers removeObjectAtIndex:indexPath.row];
        [self.theTeam.theLineup removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //nothing
    }
    self.parentDelegate.ourLeague.dataChanged = YES;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    _setPlaying = NO;
    [self allStop];
    [[[[self.playersTable cellForRowAtIndexPath:indexPath] contentView] viewWithTag:1212] setHidden:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"selectRow at %d", indexPath.row);
    if (_setPlaying) {
        [[[[self.playersTable cellForRowAtIndexPath:indexPath] contentView] viewWithTag:1212] setHidden:YES];
        [self allStop];
    } else {
        _setPlaying = YES;
        [[[[self.playersTable cellForRowAtIndexPath:indexPath] contentView] viewWithTag:1212] setHidden:NO];
        self.playerIndex = indexPath.row;
        if (self.iPodMusicPlayer.nowPlayingItem != [[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] musicSelection]) {
            [self initializeAllPlayers];
        }
        [self playSet];
    }
        
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSIndexPath* originPath = [NSIndexPath indexPathForRow:sourceIndexPath.row 
                                                 inSection:self.teamIndex];
    NSIndexPath* destinationPath = [NSIndexPath indexPathForRow:destinationIndexPath.row 
                                                      inSection:self.teamIndex];
    [self.parentDelegate.ourLeague reOrderLineupItem:originPath toIndexPath:destinationPath];
    [tableView reloadData];
    
}

//=============================================================================================
#pragma mark - audio
//=============================================================================================


-(void)assignFileName{
    self.fileName = [self.theTeam.teamName stringByAppendingString:[[self.theTeam.theLineup objectAtIndex:self.playerIndex] playerName]];
}

-(void)initializeAllPlayers{

        if (![[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] useDJClip]) {
            [self initializeIPodMusicPlayer];
        } else {
            [self initializeDJMusicPlayer];
        }
        [self initializeRecordedAnnouncement];
    
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
    if (self.directorTimer.isValid) {
        [self.directorTimer invalidate];
    }
}

-(void)playerUpdate{
    if (_iPodClipValid) {
        //fade out if set
        if ([[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] doFadeOut]) {
            if (self.iPodMusicPlayer.currentPlaybackTime > (_clipStartPoint + (_clipLength - 1.5))) {
                if (!_volumeCaptured) {
                    self.volumeSetting = self.iPodMusicPlayer.volume;
                    _volumeCaptured = YES;
                }
                [self.iPodMusicPlayer setVolume:([self.iPodMusicPlayer volume] - 0.05)];
            }
        }
        //stop at end of clip
        if (self.iPodMusicPlayer.currentPlaybackTime > (_clipStartPoint + _clipLength)) {
            [self.iPodMusicPlayer stop];
            [self.timer invalidate];
            self.iPodMusicPlayer.currentPlaybackTime = _clipStartPoint;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(endPlayCycle) userInfo:nil repeats:NO];
        }
    } else {
        [self endPlayCycle];
        NSLog(@"iPodClip Invalid");
    }

}

-(void)endPlayCycle{

    [self.timer invalidate];

    self.iPodMusicPlayer.volume = self.volumeSetting;
    _volumeCaptured = NO;
    [self advanceSelection];
}


-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (_setPlaying) {
        _setPlaying = NO;
    }
    if ([[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] isFirst]) {
        //[self advanceSelection];
    }
    if (player == self.djClipPlayer) {
        [self advanceSelection];
    }
}

-(void)advanceSelection{
    NSLog(@"Advance selection at %d", self.playersTable.indexPathForSelectedRow.row);  
    [[[[self.playersTable cellForRowAtIndexPath:self.playersTable.indexPathForSelectedRow] contentView] viewWithTag:1212] setHidden:YES];
    NSIndexPath* nextIndexPath = [NSIndexPath indexPathForRow:self.playersTable.indexPathForSelectedRow.row+1 inSection:0];
    if (nextIndexPath.row > [self.playersTable numberOfRowsInSection:0]-1) {
        nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
        
    [self.playersTable selectRowAtIndexPath:nextIndexPath 
                                    animated:YES 
                                scrollPosition:UITableViewScrollPositionMiddle];
    self.playerIndex = nextIndexPath.row;
    //[self tableView:playersTable didSelectRowAtIndexPath:nextIndexPath];
    [self initializeAllPlayers];
}

-(void)initializeIPodMusicPlayer{
    if (!self.iPodMusicPlayer) {
        self.iPodMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    }
    if ([[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] musicSelection]) {
        
        NSArray* MusicPlayerQueue = [NSArray arrayWithObject:[[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] musicSelection]];
        MPMediaItemCollection* mpQ = [MPMediaItemCollection collectionWithItems:MusicPlayerQueue];
        [self.iPodMusicPlayer setQueueWithItemCollection:mpQ];
        self.iPodMusicPlayer.nowPlayingItem = [[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] musicSelection];
        _iPodClipValid = YES;
        _clipStartPoint = [[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] musicStartPoint];
        self.iPodMusicPlayer.currentPlaybackTime = _clipStartPoint;
        _clipLength = [[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] clipLength];
        
    } else {
        _iPodClipValid = NO;
        NSLog(@"No Music Clip Found for %i", self.playerIndex);
    } 
    
}

- (void)clipPlay{
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(playerUpdate) userInfo:nil repeats:YES];
    if (_iPodClipValid) {
        [self.iPodMusicPlayer play];  
    }
          
    
}

-(void)initializeRecordedAnnouncement{
    
    [self assignFileName];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dPath = [documentsDirectory stringByAppendingPathComponent:self.fileName];
    NSURL* soundFileURL = [NSURL fileURLWithPath:dPath];
    NSError* playerError = nil;
    self.musicPlayer.volume = 1.0f;
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&playerError];
    [self.musicPlayer setDelegate:self];
    
    if (playerError) {
        NSLog(@"error assigning recording file: %@ %@", playerError, self.fileName);
    }
    
    if (![self.musicPlayer prepareToPlay]) {
        NSLog(@"error creating stream");
    }
}

- (void)announcePlay{
    
    [self initializeRecordedAnnouncement];
    [self.musicPlayer play];
}

-(void)initializeDJMusicPlayer{
    
    NSURL* djClipURL = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:[[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] DJClipFilename] ofType:@"mp3"]]
    ;
    NSError* djPlayerError = nil;
    if (_djClipPlayer) {
        [_djClipPlayer release];
    }
    _djClipPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:djClipURL error:&djPlayerError];
    _djClipPlayer.delegate = self;
    if (djPlayerError) {
        NSLog(@"Error assigning DJClip file: %@", djPlayerError);
    }
    if (![self.djClipPlayer prepareToPlay]) {
        NSLog(@"Error creating stream - djClip");
    }
}

-(void)djClipPlay{
    if (!_djClipPlayer) {
        [self initializeDJMusicPlayer];
    }
    [self.djClipPlayer play];
}

- (void)playSet{
    
    _setPlaying = YES;
    if ([[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] isFirst]) {
        if ([[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] useDJClip]) {
            [self djClipPlay];
        } else {
            [self clipPlay];
        }
    } else {
        [self announcePlay];
    }
    
    self.directorTimer = [NSTimer scheduledTimerWithTimeInterval:[[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] clipDelay] target:self selector:@selector(director) userInfo:nil repeats:NO];
    
}

-(void)director{
    if ([[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] isFirst]) {
        [self announcePlay];
        
    } else {
        if ([[[self.theTeam.theLineup objectAtIndex:self.playerIndex] musicClip] useDJClip]) {
            [self djClipPlay];
        } else {
            [self clipPlay];  
        }      
    }
    [self.directorTimer invalidate];
}

@end
