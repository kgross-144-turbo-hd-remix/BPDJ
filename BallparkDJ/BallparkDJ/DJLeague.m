//
//  DJLeague.m
//  Dj3
//
//  Created by Timothy Goodson on 5/11/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import "DJLeague.h"

//***********************DJMusicClip Class******************************
//*******************************************************************

@implementation DJMusicClip
@synthesize musicSelection = _musicSelection;
@synthesize songTitle = _songTitle;
@synthesize musicStartPoint = _musicStartPoint;
@synthesize clipLength = _clipLength;
@synthesize doFadeOut = _doFadeOut;
@synthesize clipDelay = _clipDelay;
@synthesize isFirst = _isFirst;
@synthesize useDJClip = _useDJClip;
@synthesize DJClipFilename = _DJClipFilename;

-(id)init{
    if (self = [super init]) {
        self.useDJClip = NO;
    }
    return self;
}

#pragma mark PERSISTANT_DATA
#define djMusicSelection @"musicSelectionKey"
#define djSongTitle @"songTitleKey"
#define djMusicStartPoint @"musicStartPointKey"
#define djCliplength @"clipLengthKey"
#define djDoFadeOut @"doFadeOutKey"
#define djClipDelay @"clipDelayKey"
#define djIsFirst @"isFirstKey"
#define djUseDJClip @"useDJClip"
#define djDJClipFilename @"djClipFilename"

-(void) encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.musicSelection forKey:djMusicSelection];
    [encoder encodeObject:self.songTitle forKey:djSongTitle];
    [encoder encodeDouble:self.musicStartPoint forKey:djMusicStartPoint];
    [encoder encodeDouble:self.clipLength forKey:djCliplength];
    [encoder encodeBool:self.doFadeOut forKey:djDoFadeOut];
    [encoder encodeDouble:self.clipDelay forKey:djClipDelay];
    [encoder encodeBool:self.isFirst forKey:djIsFirst];
    [encoder encodeBool:self.useDJClip forKey:djUseDJClip];
    [encoder encodeObject:self.DJClipFilename forKey:djDJClipFilename];
}

-(id) initWithCoder:(NSCoder *)decoder{
    
    self = [super init];
    if (self) {
        [self setMusicSelection:[decoder decodeObjectForKey:djMusicSelection]]; 
        [self setMusicStartPoint:[decoder decodeDoubleForKey:djMusicStartPoint]];
        [self setClipLength:[decoder decodeDoubleForKey:djCliplength]];
        [self setDoFadeOut:[decoder decodeBoolForKey:djDoFadeOut]];
    }
    return self;
}

-(void)dealloc{
    [_musicSelection release];
    [_songTitle release];
    [_DJClipFilename release];
    [super dealloc];
}
@end

//***********************DJPlayer Class******************************
//*******************************************************************

@implementation DJPlayer
@synthesize playerName = _playerName;
@synthesize playerNumber = _playerNumber;
@synthesize musicClip = _musicClip;


#pragma mark PERSISTANT_DATA
#define djPlayerName @"playerNameKey"
#define djPlayerNumber @"playerNumberKey"
#define djMusicClip @"musicClipKey"

-(void) encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:[self playerName] forKey:djPlayerName];
    [encoder encodeInt:[self playerNumber] forKey:djPlayerNumber];
    [encoder encodeObject:[self musicClip] forKey:djMusicClip];
}

-(id) initWithCoder:(NSCoder *)decoder{
    self = [super init];
    if (self) {
        [self setPlayerName:[decoder decodeObjectForKey:djPlayerName]]; 
        [self setPlayerNumber:[decoder decodeIntForKey:djPlayerNumber]];
        [self setMusicClip:[decoder decodeObjectForKey:djMusicClip]];
    }
    return self;
}

-(void)dealloc{
    [_playerName release];
    [_musicClip release];
    [super dealloc];
}
@end

//***************************DJTeam Class******************************
//*********************************************************************

@implementation DJTeam
@synthesize thePlayers = _thePlayers;
@synthesize theLineup = _theLineup;
@synthesize teamName;
-(id)init{
    self = [super init];
    if (self){
        _theLineup = [[NSMutableArray alloc] init];
        _thePlayers = [[NSMutableArray alloc]  init];
    }
    return self;
}

-(void)addPlayerToPlayers:(DJPlayer *)p{
    [[self thePlayers] addObject:p];
}

-(void)addPlayerToLineup:(DJPlayer *)p{
    [[self theLineup] addObject:p];
    
}

#pragma mark PERSISTANT_DATA
#define djPlayers @"playersKey"
#define djLineup @"lineupKey"

-(void) encodeWithCoder:(NSCoder *)encoder{

}

-(id) initWithCoder:(NSCoder *)decoder{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)dealloc{
    [_teamName release];
    [_theLineup release];
    [_thePlayers release];
    [super dealloc];
}
@end

//**************************DJLeague Class*****************************
//*********************************************************************

@implementation DJLeague
@synthesize theTeams = _theTeams;
@synthesize leagueName = _leagueName;

-(id)init{
    self = [super init];
    if (self){
        _theTeams = [[NSMutableArray alloc] init];
    }
    return self;    
}

-(void)addTeam:(DJTeam *)t{
    [[self theTeams] addObject:t];
}

#pragma mark PERSISTANT_DATA
#define djLeagueName @"leagueNameKey"
#define djTeams @"teamsKey"

-(void) encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:[self leagueName] forKey:djLeagueName];
}

-(id) initWithCoder:(NSCoder *)decoder{

    if (self) {
        [self setLeagueName:[decoder decodeObjectForKey:djLeagueName]]; 
    }
    return self;
}

-(void)dealloc{
    [_theTeams release];
    [_leagueName release];
    [super dealloc];
}
@end

//****************************DJData Class******************************
//**********************************************************************

@implementation DJData
@synthesize theLeague = _theLeague;
@synthesize dataPath = _dataPath;
@synthesize gameTeam1, gameTeam2;
@synthesize dataChanged = _dataChanged;

#define djDataKey @"Data"
#define djDataFile @"data.plist"
#define djTeamName @"teamNameKey_"
#define djNumberOfTeams @"numberOfTeamsKey"
#define djNumberOfPlayers @"numberOfPlayersKey"

-(id)init{
    self = [super init];
    if (self){
        self.dataChanged = NO;
        _theLeague = [[DJLeague alloc] init];
        [self makeDataPath];
        [self loadDataFromFileSystem];
    }
    return self;
}

-(void)makeDataPath{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dPath = [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
    self.dataPath = [NSURL fileURLWithPath:dPath];
}

-(void)loadDataFromFileSystem{
    
    //unarchive persistent data
  
    NSData* codedLeague = [[NSData alloc] initWithContentsOfURL:[self dataPath]];
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedLeague];
    
    NSInteger numberOfTeams = [unarchiver decodeIntForKey:djNumberOfTeams];
    [[self theLeague] setLeagueName:[unarchiver decodeObjectForKey:djLeagueName]];
    for (int i = 0; i < numberOfTeams; ++i) {
        DJTeam* t = [[[DJTeam alloc] init] autorelease];
        NSString* teamKey = [djTeamName stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]];
        [t setTeamName:[unarchiver decodeObjectForKey:teamKey]];
        NSString* numPlayers = [djNumberOfPlayers stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]];
        NSInteger numberOfPlayers = [unarchiver decodeIntForKey:numPlayers];
        for (int j = 0; j < numberOfPlayers; ++j) {
            DJPlayer* p = [[[DJPlayer alloc] init] autorelease];
            NSString* pname = [djPlayerName stringByAppendingString:[[NSNumber numberWithInt:j] stringValue]];
            pname = [pname stringByAppendingString:teamKey];
            [p setPlayerName:[unarchiver decodeObjectForKey:pname]];
            NSString* pnumber = [djPlayerNumber stringByAppendingString:[[NSNumber numberWithInt:j] stringValue]];
            pnumber = [pnumber stringByAppendingString:teamKey];
            [p setPlayerNumber:[unarchiver decodeIntForKey:pnumber]];
            //music clip data
            DJMusicClip* m = [[[DJMusicClip alloc] init] autorelease];
            NSString* musicClipKey = [djMusicSelection stringByAppendingString:pname];
            [m setMusicSelection:[unarchiver decodeObjectForKey:musicClipKey]];
            NSString* songTitleKey = [djSongTitle stringByAppendingString:pname];
            [m setSongTitle:[unarchiver decodeObjectForKey:songTitleKey]];
            NSString* musicStartKey = [djMusicStartPoint stringByAppendingString:pname];
            [m setMusicStartPoint:[unarchiver decodeDoubleForKey:musicStartKey]];
            NSString* clipLengthKey = [djCliplength stringByAppendingString:pname];
            [m setClipLength:[unarchiver decodeDoubleForKey:clipLengthKey]];
            NSString* doFadeOutKey = [djDoFadeOut stringByAppendingString:pname];
            [m setDoFadeOut:[unarchiver decodeBoolForKey:doFadeOutKey]];
            NSString* clipDelayKey = [djClipDelay stringByAppendingString:pname];
            [m setClipDelay:[unarchiver decodeDoubleForKey:clipDelayKey]];
            NSString* isFirstKey = [djIsFirst stringByAppendingString:pname];
            [m setIsFirst:[unarchiver decodeBoolForKey:isFirstKey]];
            NSString* useDJCLipKey = [djUseDJClip stringByAppendingString:pname];
            [m setUseDJClip:[unarchiver decodeBoolForKey:useDJCLipKey]];
            NSString* djClipFilenameKey = [djDJClipFilename stringByAppendingString:pname];
            [m setDJClipFilename:[unarchiver decodeObjectForKey:djClipFilenameKey]];
            [p setMusicClip:m];
            [t addPlayerToPlayers:p];
        }
        [[self theLeague] addTeam:t];
    }    
    [unarchiver finishDecoding];  
    [codedLeague release];
    [unarchiver release];
}


-(void)saveData{
    
    if ([self theLeague] == nil) {
        return;
    }
    
    if (self.dataChanged) {
        DJData* saveData = self;
        //Queue a thread to save the data with block
        dispatch_queue_t fileSaveQueue = dispatch_queue_create("BallparkDJ Save", NULL);
        dispatch_async(fileSaveQueue, ^{
            NSMutableData* leagueData = [[[NSMutableData alloc] init] autorelease];
            NSKeyedArchiver* archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:leagueData] autorelease];
            
            [archiver encodeObject:[[saveData theLeague] leagueName] forKey:djLeagueName];
            [archiver encodeInt:[[[saveData theLeague] theTeams] count] forKey:djNumberOfTeams];
            for (int i = 0; i < [[[saveData theLeague] theTeams] count]; ++i) {
                NSString* teamNameKey = [djTeamName stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]];
                NSString* tName = [[[[saveData theLeague] theTeams] objectAtIndex:i] teamName];
                [archiver encodeObject:tName forKey:teamNameKey];
                NSString* numPlayers = [djNumberOfPlayers stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]];
                [archiver encodeInt:[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] count] forKey:numPlayers];
                for (int j = 0; j < [[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] count]; ++j) {
                    NSString* playerName = [djPlayerName stringByAppendingString:[[NSNumber numberWithInt:j] stringValue]];
                    playerName = [playerName stringByAppendingString:teamNameKey];
                    NSString* playerNumber = [djPlayerNumber stringByAppendingString:[[NSNumber numberWithInt:j] stringValue]];
                    playerNumber = [playerNumber stringByAppendingString:teamNameKey];
                    [archiver encodeInt:[[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] objectAtIndex:j] playerNumber]forKey:playerNumber];
                    NSString* pname = [[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers]  objectAtIndex:j] playerName];
                    [archiver encodeObject:pname forKey:playerName];
                    //Music clip data
                    NSString* musicClipKey = [djMusicSelection stringByAppendingString:playerName];
                    [archiver encodeObject:[[[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] objectAtIndex:j] musicClip] musicSelection] forKey:musicClipKey];
                    NSString* songTitleKey = [djSongTitle stringByAppendingString:playerName];
                    [archiver encodeObject:[[[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] objectAtIndex:j] musicClip] songTitle] forKey:songTitleKey];
                    NSString* musicStartKey = [djMusicStartPoint stringByAppendingString:playerName];
                    [archiver encodeDouble:[[[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] objectAtIndex:j] musicClip] musicStartPoint] forKey:musicStartKey];
                    NSString* clipLengthKey = [djCliplength stringByAppendingString:playerName];
                    [archiver encodeDouble:[[[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] objectAtIndex:j] musicClip] clipLength] forKey:clipLengthKey];
                    NSString* doFadeOutKey = [djDoFadeOut stringByAppendingString:playerName];
                    [archiver encodeBool:[[[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] objectAtIndex:j] musicClip] doFadeOut] forKey:doFadeOutKey];
                    NSString* clipDelayKey = [djClipDelay stringByAppendingString:playerName];
                    [archiver encodeDouble:[[[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] objectAtIndex:j] musicClip] clipDelay] forKey:clipDelayKey];
                    NSString* isFirstKey = [djIsFirst stringByAppendingString:playerName];
                    [archiver encodeBool:[[[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] objectAtIndex:j] musicClip] isFirst] forKey:isFirstKey];
                    NSString* useDJCLipKey = [djUseDJClip stringByAppendingString:playerName];
                    [archiver encodeBool:[[[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] objectAtIndex:j] musicClip] useDJClip] forKey:useDJCLipKey];
                    NSString* djClipFilenameKey = [djDJClipFilename stringByAppendingString:playerName];
                    [archiver encodeObject:[[[[[[[saveData theLeague] theTeams] objectAtIndex:i] thePlayers] objectAtIndex:j] musicClip] DJClipFilename] forKey:djClipFilenameKey];
                }
            }
            [archiver finishEncoding];
            
            NSError* writeError = nil;
            [leagueData writeToURL:[saveData dataPath] options:NSDataWritingAtomic error:&writeError];
            
            if (writeError) {
                NSLog(@"error: %@", writeError);
            }
        });
        dispatch_release(fileSaveQueue);
        self.dataChanged = NO;
    }
}


-(void)reOrderLineupItem:(NSIndexPath *)originPath toIndexPath:(NSIndexPath *)destinationPath{
    
    //to change the order of the lineup
    DJPlayer* tmpPlayer = [[[[[self theLeague] theTeams] objectAtIndex:originPath.section] theLineup] objectAtIndex:originPath.row];
    [[[[[self theLeague] theTeams] objectAtIndex:originPath.section] theLineup] removeObjectAtIndex:originPath.row];
    [[[[[self theLeague] theTeams] objectAtIndex:destinationPath.section] theLineup] insertObject:tmpPlayer atIndex:destinationPath.row];
    self.dataChanged = YES;
    
}

-(void)dealloc{
    [_theLeague release];
    [_dataPath release];
    if (self.dataChanged) {
        [self saveData];
    }
    [super dealloc];
}
@end