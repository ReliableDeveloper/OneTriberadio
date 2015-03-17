//
//  Database.m
//  Test
//
//  Created by WangHaoMing on 3/25/14.
//  Copyright (c) 2014 WangHaoMing. All rights reserved.
//

#import "DatabaseController.h"

#define DB_FILENAME @"1triberadio.db"

@implementation DatabaseController
@synthesize dbFilePath = _dbFilePath;

static DatabaseController *_database;

+ (DatabaseController *)database
{
    if (_database == nil) {
        _database = [[super alloc] init];
    }
    return _database;
}

- (NSString *)dbFilePath
{
    if (!_dbFilePath) {
        NSString *databaseSourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_FILENAME];
        NSString *docPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:DB_FILENAME];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:docPath])
            [fileManager copyItemAtPath:databaseSourcePath toPath:docPath error:nil];
        _dbFilePath = docPath;
    }
    return _dbFilePath;
}

- (id)init
{
    if ((self = [super init])) {
        NSString *sqLiteDb = [self dbFilePath];
        if (sqlite3_open([sqLiteDb UTF8String], &_db) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

- (void)dealloc
{
    sqlite3_close(_db);
}

- (BOOL)insertFavouriteSong:(SongInfo*) songInfo
{
    BOOL ret = YES;
    NSString *query = [NSString stringWithFormat:@"INSERT INTO favouritesongs \
                       (songname, artistname, songpath, posterpath, likecount) values ('%@', '%@', '%@', '%@', '%@')",
                       songInfo.mSongName, songInfo.mArtistName, songInfo.mSongPath, songInfo.mPosterPath, songInfo.likecount];
    if (sqlite3_exec(_db, [query UTF8String], nil, nil, nil) != SQLITE_OK) {
        ret = NO;
        NSLog(@"%s", sqlite3_errmsg(_db));
    }
    
    return ret;
}

- (BOOL)updateFavouriteSong:(SongInfo *)songInfo
{
    BOOL retVal = NO;
    NSString *query = @"UPDATE favouritesongs SET songname=?, artistname=?, songpath=?, posterpath=?, likecount=?";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 0, [songInfo.mSongName UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 1, [songInfo.mArtistName UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [songInfo.mSongPath UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [songInfo.mPosterPath UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 4, [songInfo.likecount UTF8String], -1, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            retVal = YES;
        }
        sqlite3_finalize(statement);
    }
    
    return retVal;
}

- (BOOL)removeFavouriteSong:(SongInfo *)songInfo
{
    BOOL ret = YES;
    NSString *query = [NSString stringWithFormat:@"DELETE FROM favouritesongs WHERE songname=%@ AND artistname=%@", songInfo.mSongName, songInfo.mArtistName];
    if (sqlite3_exec(_db, [query UTF8String], nil, nil, nil) != SQLITE_OK) {
        ret = NO;
        NSLog(@"%s", sqlite3_errmsg(_db));
    }
    
    return ret;
}

- (NSMutableArray *)getFavouriteSongs
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT songname, artistname, songpath, posterpath, likecount FROM favouritesongs";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *songnameChars = (char *) sqlite3_column_text(statement, 0);
            char *artistnameChars = (char *) sqlite3_column_text(statement, 1);
            char *songpathChars = (char *) sqlite3_column_text(statement, 2);
            char *posterpathChars = (char*) sqlite3_column_text(statement, 3);
            char *likecountChars = (char*) sqlite3_column_text(statement, 4);
            NSString *songname = [[NSString alloc] initWithUTF8String:songnameChars];
            NSString *artistname = [[NSString alloc] initWithUTF8String:artistnameChars];
            NSString *songpath = [[NSString alloc] initWithUTF8String:songpathChars];
            NSString *posterpath = [[NSString alloc] initWithUTF8String:posterpathChars];
            NSString *likecount = [[NSString alloc] initWithUTF8String:likecountChars];
            SongInfo *info = [[SongInfo alloc] init];
            info.mSongName = songname;
            info.mArtistName = artistname;
            info.mSongPath = songpath;
            info.mPosterPath = posterpath;
            info.likecount = likecount;
            [retArray addObject:info];
        }
        sqlite3_finalize(statement);
    }
    return  retArray;
}

- (BOOL)insertHistorySong:(SongInfo*) songInfo
{
    BOOL ret = YES;
    NSString *query = [NSString stringWithFormat:@"INSERT INTO historysongs \
                       (songname, artistname, songpath, posterpath, likecount) values ('%@', '%@', '%@', '%@', '%@')",
                       songInfo.mSongName, songInfo.mArtistName, songInfo.mSongPath, songInfo.mPosterPath, songInfo.likecount];
    if (sqlite3_exec(_db, [query UTF8String], nil, nil, nil) != SQLITE_OK) {
        ret = NO;
        NSLog(@"%s", sqlite3_errmsg(_db));
    }
    
    return ret;
}

- (BOOL)updateHistorySong:(SongInfo *)songInfo
{
    BOOL retVal = NO;
    NSString *query = @"UPDATE historysongs SET songname=?, artistname=?, songpath=?, posterpath=?, likecount=?";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 0, [songInfo.mSongName UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 1, [songInfo.mArtistName UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [songInfo.mSongPath UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [songInfo.mPosterPath UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 4, [songInfo.likecount UTF8String], -1, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            retVal = YES;
        }
        sqlite3_finalize(statement);
    }
    
    return retVal;
}

- (BOOL)removeHistorySong:(SongInfo *)songInfo
{
    BOOL ret = YES;
    NSString *query = [NSString stringWithFormat:@"DELETE FROM historysongs WHERE songname=%@ AND artistname=%@", songInfo.mSongName, songInfo.mArtistName];
    if (sqlite3_exec(_db, [query UTF8String], nil, nil, nil) != SQLITE_OK) {
        ret = NO;
        NSLog(@"%s", sqlite3_errmsg(_db));
    }
    
    return ret;
}

- (NSMutableArray *)getHistorySongs
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT songname, artistname, songpath, posterpath, likecount FROM historysongs";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *songnameChars = (char *) sqlite3_column_text(statement, 0);
            char *artistnameChars = (char *) sqlite3_column_text(statement, 1);
            char *songpathChars = (char *) sqlite3_column_text(statement, 2);
            char *posterpathChars = (char*) sqlite3_column_text(statement, 3);
            char *likecountChars = (char*) sqlite3_column_text(statement, 4);
            NSString *songname = [[NSString alloc] initWithUTF8String:songnameChars];
            NSString *artistname = [[NSString alloc] initWithUTF8String:artistnameChars];
            NSString *songpath = [[NSString alloc] initWithUTF8String:songpathChars];
            NSString *posterpath = [[NSString alloc] initWithUTF8String:posterpathChars];
            NSString *likecount = [[NSString alloc] initWithUTF8String:likecountChars];
            SongInfo *info = [[SongInfo alloc] init];
            info.mSongName = songname;
            info.mArtistName = artistname;
            info.mSongPath = songpath;
            info.mPosterPath = posterpath;
            info.likecount = likecount;
            [retArray addObject:info];
        }
        sqlite3_finalize(statement);
    }
    return  retArray;
}

- (BOOL)insertUserlistSong:(SongInfo*) songInfo
{
    BOOL ret = YES;
    NSString *query = [NSString stringWithFormat:@"INSERT INTO userlistsongs \
                       (songname, artistname, songpath, posterpath, likecount) values ('%@', '%@', '%@', '%@', '%@')",
                       songInfo.mSongName, songInfo.mArtistName, songInfo.mSongPath, songInfo.mPosterPath, songInfo.likecount];
    if (sqlite3_exec(_db, [query UTF8String], nil, nil, nil) != SQLITE_OK) {
        ret = NO;
        NSLog(@"%s", sqlite3_errmsg(_db));
    }
    
    return ret;
}

- (BOOL)updateUserlistSong:(SongInfo *)songInfo
{
    BOOL retVal = NO;
    NSString *query = @"UPDATE userlistsongs SET songname=?, artistname=?, songpath=?, posterpath=?, likecount=?";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 0, [songInfo.mSongName UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 1, [songInfo.mArtistName UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [songInfo.mSongPath UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [songInfo.mPosterPath UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 4, [songInfo.likecount UTF8String], -1, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            retVal = YES;
        }
        sqlite3_finalize(statement);
    }
    
    return retVal;
}

- (BOOL)removeUserlistSong:(SongInfo *)songInfo
{
    BOOL ret = YES;
    NSString *query = [NSString stringWithFormat:@"DELETE FROM userlistsongs WHERE songname=%@ AND artistname=%@", songInfo.mSongName, songInfo.mArtistName];
    if (sqlite3_exec(_db, [query UTF8String], nil, nil, nil) != SQLITE_OK) {
        ret = NO;
        NSLog(@"%s", sqlite3_errmsg(_db));
    }
    
    return ret;
}

- (NSMutableArray *)getUserlistSongs
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT songname, artistname, songpath, posterpath, likecount FROM userlistsongs";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *songnameChars = (char *) sqlite3_column_text(statement, 0);
            char *artistnameChars = (char *) sqlite3_column_text(statement, 1);
            char *songpathChars = (char *) sqlite3_column_text(statement, 2);
            char *posterpathChars = (char*) sqlite3_column_text(statement, 3);
            char *likecountChars = (char*) sqlite3_column_text(statement, 4);
            NSString *songname = [[NSString alloc] initWithUTF8String:songnameChars];
            NSString *artistname = [[NSString alloc] initWithUTF8String:artistnameChars];
            NSString *songpath = [[NSString alloc] initWithUTF8String:songpathChars];
            NSString *posterpath = [[NSString alloc] initWithUTF8String:posterpathChars];
            NSString *likecount = [[NSString alloc] initWithUTF8String:likecountChars];
            SongInfo *info = [[SongInfo alloc] init];
            info.mSongName = songname;
            info.mArtistName = artistname;
            info.mSongPath = songpath;
            info.mPosterPath = posterpath;
            info.likecount = likecount;
            [retArray addObject:info];
        }
        sqlite3_finalize(statement);
    }
    return  retArray;
}

@end
