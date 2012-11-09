//
//  DJLeague.h
//  Ballpark DJ (r)
//
//  Created by Timothy Goodson on 5/11/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

//class for audio object
@interface DJMusicClip : NSObject <NSCoding>{
    MPMediaItem* _musicSelection;
    NSString* _songTitle;
    float _musicStartPoint;
    float _clipLength;
    float _clipDelay;
    bool _doFadeOut;
    bool _isFirst;
    bool _useDJClip;
    NSString* _DJClipFilename;
}
@property(retain, nonatomic) MPMediaItem* musicSelection;
@property(retain, nonatomic) NSString* songTitle;
@property(assign, nonatomic) float musicStartPoint;
@property(assign, nonatomic) float clipLength;
@property(assign, nonatomic) float clipDelay;
@property(assign, nonatomic) bool doFadeOut;
@property(assign, nonatomic) bool isFirst;
@property(assign, nonatomic) bool useDJClip;
@property(copy, nonatomic) NSString* DJClipFilename;
@end

//class for player object
@interface DJPlayer : NSObject <NSCoding>{
    NSString* _playerName;
    NSInteger _playerNumber;
    DJMusicClip* _musicClip;
}
@property(retain, nonatomic) NSString* playerName;
@property(assign, nonatomic) NSInteger playerNumber;
@property(retain, nonatomic) DJMusicClip* musicClip;
@end

//class for team object
@interface DJTeam : NSObject <NSCoding>{
    NSMutableArray* _thePlayers;
    NSMutableArray* _theLineup;
    NSString* _teamName;
}
@property(retain, nonatomic)NSMutableArray* thePlayers;
@property(retain, nonatomic)NSMutableArray* theLineup;
@property(retain, nonatomic)NSString* teamName;
-(id)init;
-(void)addPlayerToPlayers:(DJPlayer*) p;
-(void)addPlayerToLineup:(DJPlayer*) p;
@end

//class for league object: collection of teams
@interface DJLeague : NSObject <NSCoding>{
    NSMutableArray* _theTeams;
    NSString* _leagueName;
}
@property(retain, nonatomic)NSMutableArray* theTeams;
@property(retain, nonatomic)NSString* leagueName;
-(id)init;
-(void)addTeam:(DJTeam*) t;
@end

//data object class
@interface DJData : NSObject{
    DJLeague* _theLeague;
    NSURL* _dataPath;
    BOOL dataChanged;
}
@property(retain, nonatomic)DJLeague* theLeague;
@property(retain, nonatomic)NSURL* dataPath;
@property(assign, nonatomic) NSInteger gameTeam1;
@property(assign, nonatomic) NSInteger gameTeam2;
@property(assign, atomic) BOOL dataChanged;
-(id)init;
-(void)saveData;
-(void)reOrderLineupItem:(NSIndexPath*)originPath toIndexPath:(NSIndexPath*)destinationPath;
@end