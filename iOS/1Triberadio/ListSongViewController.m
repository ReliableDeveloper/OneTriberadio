//
//  ListSongViewController.m
//  Triberadio
//
//  Created by YingZhi on 6/15/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import "ListSongViewController.h"
#import "ListSongViewCell.h"
#import "HttpAPI.h"
#import "Util.h"
#import "SongInfo.h"
#import "Track+Provider.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MDAudioPlayerController.h"
#import <QuartzCore/QuartzCore.h>
#import "AudioPlayer.h"
#import "DatabaseController.h"
#import "AppDelegate.h"

#define TABLE_HEIGHT 60
#define ROOT_URL @"http://1triberadio.com/wp-content/uploads/index.php?"
//#define ROOT_URL @"http://10.70.3.7/index.php?"
@interface ListSongViewController (){
    NSString *mPlaylistName;
    NSMutableArray *songList;
}
@property (nonatomic) BOOL useCustomCells;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *sharebuttons;
@end

@implementation ListSongViewController
{
    UITableView *songTableView;
}
@synthesize m_objImgListOper = _objImgListOper;
@synthesize sharebuttons;
- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        // Do something
        self.backgroundImage = [UIImage imageNamed:@"settingbk_lightlbue"];
        self.leftWidth = 320;
        self.sideViewTintColor = [UIColor blackColor];
        self.sideViewAlpha = 0.3;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharebuttons = [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"facebook_share.png"],@"img",@"Facebook",@"text", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"twitter_share.png"],@"img",@"Twitter",@"text", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"google_share.png"],@"img",@"Google+",@"text", nil],
                    nil];
    
    _objImgListOper = [[RemoteImgListOperator alloc] init];
    [_objImgListOper resetListSize:20];
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"listing_header"] forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"searchbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoSearch)];
    self.navigationItem.rightBarButtonItem = btnSearch;
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threelinebutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoMenu)];
    self.navigationItem.leftBarButtonItem = btnMenu;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
    UIImageView *mainTitle = [[UIImageView alloc] initWithFrame:CGRectMake(40, -15, 150, 40)];
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, 20, 200, 21)];
    mainTitle.image = [UIImage imageNamed:@"triberadiomark"];
    subTitle.textColor = [UIColor whiteColor];
    subTitle.text = @"Media";
    subTitle.font = [UIFont fontWithName:@"Arial" size:12];
    [subTitle setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:mainTitle];
    [titleView addSubview:subTitle];
    self.navigationItem.titleView = titleView;
     
    songTableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-self.leftWidth, 60, self.leftContentView.frame.size.width, self.leftContentView.frame.size.height-60)];
    songTableView.backgroundColor = [UIColor clearColor];
    songTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    songTableView.dataSource = self;
    songTableView.delegate = self;
   
    
    
    // If you set the seperator inset on iOS 6 you get a NSInvalidArgumentException...weird
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        songTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
    }
    [self.leftContentView addSubview:songTableView];
    songList = [[NSMutableArray alloc] init];
    [self getSongList];
}

- (void) getSongList {
    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@&%@=%@",ROOT_URL,@"method",@"playlist", @"type", mPlaylistName];
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
            [Util showIndicator];
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if (json != nil) {
                NSArray* songlist = [json objectForKey:@"playlist"];
                if (songlist != nil) {
                    for (int i=0; i < [songlist count]; i++)
                    {
                        NSDictionary *item = [songlist objectAtIndex:i];
                        NSString *name = [item objectForKey:@"name"];
                        NSString *artist = [item objectForKey:@"artist"];
                        NSString *path = [item objectForKey:@"path"];
                        NSString *poster = [item objectForKey:@"poster"];
                        NSString *likecount = [item objectForKey:@"likecount"];
                        
                        SongInfo *info = [[SongInfo alloc] init];
                        info.mSongName = name;
                        info.mArtistName = artist;
                        info.mSongPath = path;
                        info.mPosterPath = poster;
                        info.likecount =  likecount;
                        [songList addObject:info];
                    }
                    
                }
            }
            [Util hideIndicator];
            [songTableView reloadData];
        }
    }];
    
}


- (void) gotoSearch {
    
}

- (void) gotoMenu {
    [_audioPlayer stop];
    [self dismissViewControllerAnimated:NO completion:nil];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return songList ? songList.count : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ListSongViewCell *cell = (ListSongViewCell*) [tableView dequeueReusableCellWithIdentifier:@"ListSongViewCell"];
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListSongViewCell" owner:[ListSongViewCell class] options:nil];
        cell = (ListSongViewCell *)[nib objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor clearColor];
        [cell configurePlayerButton];
    }
    

    cell.songNameLabel.text = @"Random Song Name";
    cell.artistNameLabel.text = @"Artist Name";
    
    
    if (songList != nil && [songList count] > [indexPath row]) {
        cell.leftUtilityButtons = [self leftButtons];
        cell.delegate = self;
        SongInfo *info = [songList objectAtIndex:[indexPath row]];
        cell.artistNameLabel.text = info.mArtistName;
        cell.songNameLabel.text = info.mSongName;
        cell.avatarImg.image = [UIImage imageNamed:@"avatar.png"];
        [cell setRemoteImgOper:_objImgListOper];
        [cell showImgByURL:info.mPosterPath];
        cell.songInfo = info;
        cell.audioButton.tag = indexPath.row;
        [cell.audioButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [tableView setSeparatorColor:[UIColor darkGrayColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    return cell;
}

- (void)playAudio:(AudioButton *)button
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSInteger index = button.tag;
    SongInfo *song = [songList objectAtIndex:index];
    
    if (_audioPlayer == nil) {
        _audioPlayer = [[AudioPlayer alloc] init];
    }
    
    if ([_audioPlayer.button isEqual:button]) {
        [appDelegate.radioPlayer pauseRadio];
        [_audioPlayer play];
    } else {
        [_audioPlayer stop];
        
        _audioPlayer.button = button;
        
        if (song.mSongPath != nil && song.mSongPath.length > 10) {
            NSString *path = song.mSongPath;
            NSRange range;
            range.location = 8;
            range.length = path.length-10;
            path = [path substringWithRange:range];
            NSString *correct = [path stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
            _audioPlayer.url = [NSURL URLWithString:correct];
            [appDelegate.radioPlayer pauseRadio];
            [_audioPlayer play];
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [Util showIndicator];
    NSMutableArray *songs = [[NSMutableArray alloc] init];
	if (songList && songList.count > 0) {
        for (int i=0; i < songList.count; i++)
        {
            SongInfo *song = [songList objectAtIndex:i];
            
            if (song.mSongPath != nil && ![song.mSongPath isKindOfClass:[NSNull class]] && song.mSongPath.length > 10) {
                NSString *path = song.mSongPath;
                NSRange range;
                range.location = 8;
                range.length = path.length-10;
                path = [path substringWithRange:range];
                NSString *correct = [path stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                Track *track = [[Track alloc] init];
                [track setArtist:song.mArtistName];
                [track setTitle:song.mSongName];
                [track setAudioFileURL:[NSURL URLWithString:correct]];
                [track setAudioBackImageURL:[NSURL URLWithString:song.mPosterPath]];
                [songs addObject:track];
            }
        }
     
        [_audioPlayer stop];
        [appDelegate.radioPlayer pauseRadio];
        MDAudioPlayerController *musicplayerViewController = [[MDAudioPlayerController alloc] initWithNibName:@"MDAudioPlayerController" bundle:nil];
        [musicplayerViewController setCurrentTrackIndex:[indexPath row]];
        [musicplayerViewController setTracks:songs];

        [self increaseCount:1 playcount:1 ListSongCell:(ListSongViewCell*)[tableView cellForRowAtIndexPath:indexPath]];
        [[DatabaseController database] removeHistorySong:[songList objectAtIndex:[indexPath row]]];
        [[DatabaseController database] insertHistorySong:[songList objectAtIndex:[indexPath row]]];
        
        UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:musicplayerViewController];
        newNC.navigationBar.tintColor = [UIColor whiteColor];

        [self presentViewController:newNC animated:YES completion:nil];
        [Util hideIndicator];
        printf("yomi");
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor clearColor] icon:[UIImage imageNamed:@"LikeButton.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor clearColor] icon:[UIImage imageNamed:@"AddButton.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
    [UIColor clearColor] icon:[UIImage imageNamed:@"ShareButton.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor clearColor] icon:[UIImage imageNamed:@"MoreButton.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor blackColor] title:@""];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor blackColor] title:@""];
    return leftUtilityButtons;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set background color of cell here if you don't want default white
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void) increaseCount:(int)likecount playcount:(int)value ListSongCell:(ListSongViewCell*)cell{
 
    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",ROOT_URL,@"method",@"save", @"likecount", [[NSString alloc] initWithFormat:@"%d", likecount], @"playcount", [[NSString alloc] initWithFormat:@"%d" ,value], @"songname", [cell.songNameLabel text], @"artist", [cell.artistNameLabel text]];
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
        }
        printf("yomi");
    }];

    
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    ListSongViewCell *listsongCell = (ListSongViewCell*)cell;

    switch (index) {
        case 0:
            [self increaseCount:1 playcount:0 ListSongCell:listsongCell];
            [[DatabaseController database] removeFavouriteSong:listsongCell.songInfo];
            [[DatabaseController database] insertFavouriteSong:listsongCell.songInfo];
            break; printf("yomi");
        case 1:
            [[DatabaseController database] removeUserlistSong:listsongCell.songInfo];
            [[DatabaseController database] insertUserlistSong:listsongCell.songInfo];
            break;
        case 2:
            {
                LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"Share on..." options:sharebuttons handler:^(NSInteger anIndex) {
                    if (anIndex == 0) {
                        if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=6) {
                              if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
                            {
                            slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                            [slComposerSheet setInitialText:listsongCell.songInfo.mSongPath];
                            //[slComposerSheet addImage:[UIImage imageNamed:@"facebookshare.png"]];
                              //      [slComposerSheet addURL:[NSURL URLWithString:@"http://www.facebook.com/"]];
                            [self presentViewController:slComposerSheet animated:YES completion:nil];
                            } else {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Authentication Message" message:@"Please set up your Facebook account in Settings" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                [alert show];
                            }
                            
                            [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                                NSLog(@"start completion block");
                                NSString *output;
                                switch (result) {
                                    case SLComposeViewControllerResultCancelled:
                                        output = @"Action Cancelled";
                                        break;
                                    case SLComposeViewControllerResultDone:
                                        output = @"Post Successfull";
                                        break;
                                    default:
                                        break;
                                }
                                if (result != SLComposeViewControllerResultCancelled)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Message" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                    [alert show];
                                }
                            }];
                            
                        }else{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com"]];
                        }
                    } else if (anIndex == 1){
                        int currentver = [[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue];
                        //ios5
                        if (currentver==5 ) {
                            // Set up the built-in twitter composition view controller.
                            TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
                            // Set the initial tweet text. See the framework for additional properties that can be set.
                            [tweetViewController setInitialText:@"IOS5 twitter"];
                            // Create the completion handler block.
                            [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                                // Dismiss the tweet composition view controller.
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }];
                            
                            // Present the tweet composition view controller modally.
                              [self presentViewController:tweetViewController animated:YES completion:nil];
                            //ios6
                        } else if (currentver>5) {
                            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
                            {
                                slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                                [slComposerSheet setInitialText:listsongCell.songInfo.mSongPath];
                                //[slComposerSheet addImage:[UIImage imageNamed:@"twitter.png"]];
                                //[slComposerSheet addURL:[NSURL URLWithString:@"#1triberadio"]];
                                [self presentViewController:slComposerSheet animated:YES completion:nil];
                            } else {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Authentication Message" message:@"Please set up your twitter account in Settings" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                [alert show];
                            }

                            
                            [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                                NSLog(@"start completion block");
                                NSString *output;
                                switch (result) {
                                    case SLComposeViewControllerResultCancelled:
                                        output = @"Action Cancelled";
                                        break;
                                    case SLComposeViewControllerResultDone:
                                        output = @"Post Successfull";
                                        break;
                                    default:
                                        break;
                                }
                                if (result != SLComposeViewControllerResultCancelled)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Message" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                    [alert show];
                                }
                            }];
                            
                        }else{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com"]];
                        }

                    } else {
                        
                    }
                }];
                [lplv showInView:self.leftContentView animated:YES];
            }
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

#pragma mark - LeveyPopListView delegates
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex {
  
}
- (void)leveyPopListViewDidCancel {
    
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

- (void)setPlaylistUrl:(NSString *)playlistname{
    mPlaylistName = playlistname;
}



@end
