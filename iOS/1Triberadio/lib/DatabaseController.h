//
//  Database.h
//  Test
//
//  Created by WangHaoMing on 3/25/14.
//  Copyright (c) 2014 WangHaoMing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SongInfo.h"

@interface DatabaseController : NSObject
{
    sqlite3 *_db;
}

@property (nonatomic, readonly) NSString *dbFilePath;

+ (DatabaseController *)database;
- (BOOL)insertFavouriteSong:(SongInfo*) songInfo;
- (BOOL)updateFavouriteSong:(SongInfo *)songInfo;
- (BOOL)removeFavouriteSong:(SongInfo *)songInfo;
- (NSMutableArray *)getFavouriteSongs;

- (BOOL)insertHistorySong:(SongInfo*) songInfo;
- (BOOL)updateHistorySong:(SongInfo *)songInfo;
- (BOOL)removeHistorySong:(SongInfo *)songInfo;
- (NSMutableArray *)getHistorySongs;

- (BOOL)insertUserlistSong:(SongInfo*) songInfo;
- (BOOL)updateUserlistSong:(SongInfo *)songInfo;
- (BOOL)removeUserlistSong:(SongInfo *)songInfo;
- (NSMutableArray *)getUserlistSongs;
@end
