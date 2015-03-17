//
//  MenuViewController.m
//  Triberadio
//
//  Created by YingZhi on 6/13/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "MenuViewController.h"
#import "MainMenuTableViewCell.h"
#import "HomeTableViewCell.h"
#import "PlaylistTableViewCell.h"
#import "ComedyTableViewCell.h"
#import "SwitchTableViewCell.h"
#import "SliderTableViewCell.h"
#import "MusicAlbumViewController.h"
#import "PhotosViewController.h"
#import "RadioPlayerViewController.h"
#import "ListSongViewController.h"
#import "HomeTableTabBar.h"
#import "HttpAPI.h"
#import "Util.h"
#import "SongInfo.h"
#import "RemoteImgListOperator.h"
#import "Track.h"
#import "MDAudioPlayerController.h"
#import "VideoViewController.h"
#import "LoginViewController.h"
#import "SCTwitter.h"
#import "DatabaseController.h"
#import "GroupView.h"
#import "PrivateView.h"
#import "ProfileView.h"
#import "NavigationController.h"
#import "AppConstant.h"
#import "YouTubeTableViewController.h"
#import "TrendingAudioViewController.h"
#define LOGOUT_URL @"http://1triberadio.com/Sorikodo/logout/?"
//#define UPLOADED_FILES @"http://1triberadio.com/Sorikodo/index.php?"
//#define ROOT_URL @"http://10.70.3.7/index.php?"
#define ROOT_URL @"http://1triberadio.com/wp-content/uploads/index.php?"
#define MENUTABLE_HEIGHT 40
#define HOMETABLE_HEIGHT 60
#define PLAYLISTTABLE_HEIGHT 50
#define COMEDYTABLE_HEIGHT 50
#define SETTINGTABLE_HEIGHT 80
#define HEADER_HEIGHT 80
#define TABBAR_HEIGHT 30

@interface MenuViewController ()<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, UISearchBarDelegate>
@property (nonatomic, readonly) RemoteImgListOperator *m_objImgListOper;
@property (strong, nonatomic) NSArray *sharebuttons;
@end

@implementation MenuViewController{
    UITableView *menuTableView;
    UITableView *userTableView;
    UITableView *homeTableView;
    UITableView *trendingTableView;
    UITableView *playlistTableView;
    UITableView *podcastTableView;
    UITableView *videoCollectionView;
    UITableView *comedyTableView;
    UITableView *nollywoodTableView;
    UITableView *photoCollectionView;
    UITableView *settingTableView;
    UIWebView *socialWebView;
    UIView      *tabBar;
    UIView      *userTabBar;
    UISearchBar *mSearchBar;
    UIButton *leftNaviBtn;
    UIButton *rightNaviBtn;
    UIButton *favouriteButton;
    UIButton *historyButton;
    UIButton *playlistButton;
    UIButton *trendingTabButton;
    UIButton *top10TabButton;
    UIButton *staffpickerTabButton;
    UIButton *classicTabButton;
    NSString *username;
    UIImage *profileImage;
//    MainMenuNavigationView *navigationView;
    BOOL bSocialLink;
    int selectedSection;
    int selectedRow;
    NSMutableArray *trendinglist;
    NSMutableArray *top10list;
    NSMutableArray *staffpicklist;
    NSMutableArray *classiclist;
    NSMutableArray *userSongList;
    NSMutableArray *songList;
    NSMutableArray *songcountlist;
    NSMutableArray *podcastsongcountlist;
    NSMutableArray *comedyList;
    NSMutableArray *comedyTermList;
    NSMutableArray *nollywoodList;
    NSMutableArray *nollywoodTermList;
    NSArray *playlistname;
    NSArray *podcastname;
    NSString *playlistype;
    NSString *userlisttype;
    NSArray *headers;
    NSString *searchTerm;
}
@synthesize m_objImgListOper = _objImgListOper;
@synthesize sharebuttons;
- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        // Do something
        self.backgroundImage = [UIImage imageNamed:@"mainbk_black"];
        self.leftWidth = 200;
        self.sideViewTintColor = [UIColor blackColor];
        self.sideViewAlpha = 0.3;
        bSocialLink = false;
        selectedSection = 0;
        selectedRow = 0;
        playlistype = @"Trending"; //Trending
        userlisttype = @"favorite";
        headers = @[
            [NSNull null],
            @"TribeRadioMenu"
            ];
        searchTerm = nil;
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
    
    //Prepare headerView(Navigation)
    
    _objImgListOper = [[RemoteImgListOperator alloc] init];
    [_objImgListOper resetListSize:20];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320+self.leftWidth, HEADER_HEIGHT)];
    UIImageView *headerImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    headerImg.image = [UIImage imageNamed:@"listing_header"];
    UIImageView *markImg = [[UIImageView alloc] initWithFrame:CGRectMake(100, 0, 150, 40)];
    markImg.image = [UIImage imageNamed:@"triberadiomark"];
    mSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(60, 40, 200, 25)];
    [mSearchBar setSearchBarStyle:UISearchBarStyleMinimal];
    [mSearchBar setBackgroundColor:[UIColor clearColor]];
    [mSearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchbarbk"]                                       forState:UIControlStateNormal];
    [mSearchBar setImage: [UIImage imageNamed:@"searchicon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [mSearchBar setTintColor:[UIColor whiteColor]];
    mSearchBar.delegate = self;
//    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDelegate:self];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
    leftNaviBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 40, 25, 25)];
    [leftNaviBtn setImage:[UIImage imageNamed:@"threelinebutton"] forState: UIControlStateNormal];
    rightNaviBtn = [[UIButton alloc] initWithFrame:CGRectMake(275, 40, 25, 25)];
    [rightNaviBtn setImage:[UIImage imageNamed:@"refresh"] forState: UIControlStateNormal];
    [leftNaviBtn addTarget:self action:@selector(onLeftNaviButton) forControlEvents:UIControlEventTouchUpInside];
    [rightNaviBtn addTarget:self action:@selector(onRightNaviButton) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:headerImg];
    [headerView addSubview:markImg];
    [headerView addSubview:leftNaviBtn];
    [headerView addSubview:mSearchBar];
    [headerView addSubview:rightNaviBtn];
    [self.view addSubview:headerView];
    
    //Prepare MenuTableView(LeftView)
    menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.leftContentView.frame.size.width, self.leftContentView.frame.size.height-HEADER_HEIGHT)];
    menuTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"itembk_darkblue"]];
    menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    menuTableView.dataSource = self;
    menuTableView.delegate = self;
    [self.leftContentView addSubview:menuTableView];

    //Prepare HomeTableTabBar(CenterView)
    userTabBar = [[UIView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, TABBAR_HEIGHT)];
    favouriteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 106, 30)];
    [favouriteButton setBackgroundImage:[UIImage imageNamed:@"favouritetabbk_hover"] forState:UIControlStateNormal];
    
    [userTabBar addSubview:favouriteButton];
    
    historyButton = [[UIButton alloc] initWithFrame:CGRectMake(106, 0, 107, 30)];
    [historyButton setBackgroundImage:[UIImage imageNamed:@"historytabbk_normal"] forState:UIControlStateNormal];
    [userTabBar addSubview:historyButton];
    
    playlistButton = [[UIButton alloc] initWithFrame:CGRectMake(213, 0, 107, 30)];
    [playlistButton setBackgroundImage:[UIImage imageNamed:@"playlisttabbk_normal"] forState:UIControlStateNormal];
    [userTabBar addSubview:playlistButton];
    [self.centerContentView addSubview:userTabBar];
    [favouriteButton addTarget:self action:@selector(onFavouriteTab) forControlEvents:UIControlEventTouchUpInside];
    [historyButton addTarget:self action:@selector(onHistoryTab) forControlEvents:UIControlEventTouchUpInside];
    [playlistButton addTarget:self action:@selector(onPlaylistTab) forControlEvents:UIControlEventTouchUpInside];

    //Prepare HomeTableTabBar(CenterView)
    tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, TABBAR_HEIGHT)];
    trendingTabButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 79, 30)];
    [trendingTabButton setBackgroundImage:[UIImage imageNamed:@"trendingtabbk_hover"] forState:UIControlStateNormal];
    
    [tabBar addSubview:trendingTabButton];
    
    top10TabButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 0, 79, 30)];
    [top10TabButton setBackgroundImage:[UIImage imageNamed:@"top10bk_normal"] forState:UIControlStateNormal];
    [tabBar addSubview:top10TabButton];
    
    staffpickerTabButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 79, 30)];
    [staffpickerTabButton setBackgroundImage:[UIImage imageNamed:@"staffpicker_normal"] forState:UIControlStateNormal];
    [tabBar addSubview:staffpickerTabButton];
    
    classicTabButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 0, 80, 30)];
    [classicTabButton setBackgroundImage:[UIImage imageNamed:@"classictabbk_normal"] forState:UIControlStateNormal];
    [tabBar addSubview:classicTabButton];
    
    [self.centerContentView addSubview: tabBar];
    
    [trendingTabButton addTarget:self action:@selector(onTrendingTab) forControlEvents:UIControlEventTouchUpInside];
    [top10TabButton addTarget:self action:@selector(onTop10Tab) forControlEvents:UIControlEventTouchUpInside];
    [staffpickerTabButton addTarget:self action:@selector(onStaffTab) forControlEvents:UIControlEventTouchUpInside];
    [classicTabButton addTarget:self action:@selector(onClassicTab) forControlEvents:UIControlEventTouchUpInside];
    [tabBar setHidden:YES];
    
    //Prepare UserTableView(CenterView)
    userTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT+TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
    userTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settingbk_lightlbue"]];
    userTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    userTableView.dataSource = self;
    userTableView.delegate = self;
    [self.centerContentView addSubview:userTableView];
    
    //Prepare HomeTableView(CenterView)
    homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT+TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
    homeTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settingbk_lightlbue"]];
    homeTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    homeTableView.dataSource = self;
    homeTableView.delegate = self;
    [self.centerContentView addSubview:homeTableView];
    [homeTableView setHidden:YES];
    
    //Prepare TrendingTableView(CenterView)
    trendingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
    trendingTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbk_portrait"]];
    trendingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    trendingTableView.dataSource = self;
    trendingTableView.delegate = self;
    [self.centerContentView addSubview:trendingTableView];
    [trendingTableView setHidden:YES];
    
    //Prepare PlaylistTableView(CenterView)
    playlistTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
    playlistTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbk_portrait"]];
    playlistTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    playlistTableView.dataSource = self;
    playlistTableView.delegate = self;
    [self.centerContentView addSubview:playlistTableView];
    [playlistTableView setHidden:YES];
    
    //Prepare PodcastTableView(CenterView)
    podcastTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
    podcastTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbk_portrait"]];
    podcastTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    podcastTableView.dataSource = self;
    podcastTableView.delegate = self;
    [self.centerContentView addSubview:podcastTableView];
    [podcastTableView setHidden:YES];
    
    //Prepare ComedyListView(CenterView)
    comedyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
    comedyTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbk_portrait"]];
    comedyTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    comedyTableView.dataSource = self;
    comedyTableView.delegate = self;
    [self.centerContentView addSubview:comedyTableView];
    [comedyTableView setHidden:YES];
    
    nollywoodTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
    nollywoodTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbk_portrait"]];
    nollywoodTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    nollywoodTableView.dataSource = self;
    nollywoodTableView.delegate = self;
    [self.centerContentView addSubview:nollywoodTableView];
    [nollywoodTableView setHidden:YES];

    //Prepare SettingTableView(CenterView)
    settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
    settingTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settingbk"]];
    settingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    settingTableView.dataSource = self;
    settingTableView.delegate = self;
    [self.centerContentView addSubview:settingTableView];
    [settingTableView setHidden:YES];
    
    socialWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
    socialWebView.delegate = self;
    socialWebView.opaque = NO;
    socialWebView.backgroundColor = nil;
    socialWebView.userInteractionEnabled=YES;
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[spinner setCenter:CGPointMake(160,200)];
	[socialWebView addSubview: spinner];
    [self.centerContentView addSubview:socialWebView];
    [socialWebView setHidden:YES];
    
    userSongList = [[NSMutableArray alloc] init];
    songList = [[NSMutableArray alloc] init];
    songcountlist = [[NSMutableArray alloc] init];
    podcastsongcountlist = [[NSMutableArray alloc] init];
    comedyList = [[NSMutableArray alloc] init];
    comedyTermList = [[NSMutableArray alloc] init];
    nollywoodList = [[NSMutableArray alloc] init];
    nollywoodTermList = [[NSMutableArray alloc] init];
    playlistname = [[NSArray alloc] initWithObjects:@"gbedu", @"love", @"Afro", @"workout", @"church", @"Old", @"Rap", nil];
    podcastname = [[NSArray alloc] initWithObjects:@"Roundtable with faozy", @"Livingroom show", @"Feel good friday session", @"Breakdown with naijaswag", @"Party mixes by various Djs",nil];
    [self getSongList:playlistype];
    [self getUserSongList:userlisttype];
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"MainMenu" ofType:@"plist"];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    self.arrayForMainMenu = [plistDict objectForKey:@"Data"];
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                             target:self
                                           selector:@selector(timerFired:)
                                           userInfo:nil
                                            repeats:YES];
    [self performSelector:@selector(startDeadTime) withObject:nil afterDelay:30];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}
- (void) onLeftNaviButton {
    if (self.screenStatus == 0) {
        if (!timer) {
            timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                      target:self
                                                    selector:@selector(timerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
        }
        [self openLeftView:YES];
    } else {
        if ([timer isValid]) {
            [timer invalidate];
        }
        timer = nil;
        [self closeSideView:YES];
    }
}

- (void) onRightNaviButton {
    searchTerm = nil;
    if(![userTableView isHidden]) {
        [userSongList removeAllObjects];
        [self getUserSongList:userlisttype];
    } else if(![homeTableView isHidden]) {
        [songList removeAllObjects];
        [self getSongList:playlistype];
    }
}

- (void) onFavouriteTab {
    [_audioPlayer stop];
    [favouriteButton setBackgroundImage:[UIImage imageNamed:@"favouritetabbk_hover"] forState:UIControlStateNormal];
    [historyButton setBackgroundImage:[UIImage imageNamed:@"historytabbk_normal"] forState:UIControlStateNormal];
    [playlistButton setBackgroundImage:[UIImage imageNamed:@"playlisttabbk_normal"] forState:UIControlStateNormal];
    userlisttype = @"favorite";
    [userSongList removeAllObjects];
    [self getUserSongList:userlisttype];
}

- (void) onHistoryTab {
    [_audioPlayer stop];
    [favouriteButton setBackgroundImage:[UIImage imageNamed:@"favouritetabbk_normal"] forState:UIControlStateNormal];
    [historyButton setBackgroundImage:[UIImage imageNamed:@"historytabbk_hover"] forState:UIControlStateNormal];
    [playlistButton setBackgroundImage:[UIImage imageNamed:@"playlisttabbk_normal"] forState:UIControlStateNormal];
    userlisttype = @"History";
    [userSongList removeAllObjects];
    [self getUserSongList:userlisttype];
}

- (void) onPlaylistTab {
    [_audioPlayer stop];
    [favouriteButton setBackgroundImage:[UIImage imageNamed:@"favouritetabbk_normal"] forState:UIControlStateNormal];
    [historyButton setBackgroundImage:[UIImage imageNamed:@"historytabbk_normal"] forState:UIControlStateNormal];
    [playlistButton setBackgroundImage:[UIImage imageNamed:@"playlisttabbk_hover"] forState:UIControlStateNormal];
    userlisttype = @"Playlist";
    [userSongList removeAllObjects];
    [self getUserSongList:userlisttype];
}

- (void) getUserSongList:(NSString *)type {
    [Util showIndicator];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    if ([type isEqual:@"favorite"]) {
        temp = [[DatabaseController database] getFavouriteSongs];
    } else if ([type isEqual:@"History"]){
        temp = [[DatabaseController database] getHistorySongs];
    } else {
        temp = [[DatabaseController database] getUserlistSongs];
    }
    if (searchTerm == nil) {
        userSongList = temp;
    } else {
        for (int i=0; i<temp.count; i++) {
            if (searchTerm != nil) {
                SongInfo *info = [temp objectAtIndex:i];
                if ([info.mSongName rangeOfString:searchTerm].location !=NSNotFound || [info.mArtistName rangeOfString:searchTerm].location !=NSNotFound) {
                    [userSongList addObject:info];
                }
            }
        }
    }
    [Util hideIndicator];
    [userTableView reloadData];
}


- (void) onTrendingTab {
    [_audioPlayer stop];
    [trendingTabButton setBackgroundImage:[UIImage imageNamed:@"trendingtabbk_hover"] forState:UIControlStateNormal];
    [top10TabButton setBackgroundImage:[UIImage imageNamed:@"top10bk_normal"] forState:UIControlStateNormal];
    [staffpickerTabButton setBackgroundImage:[UIImage imageNamed:@"staffpicker_normal"] forState:UIControlStateNormal];
    [classicTabButton setBackgroundImage:[UIImage imageNamed:@"classictabbk_normal"] forState:UIControlStateNormal];
    playlistype = @"Trending";
    [songList removeAllObjects];
    [self getSongList:playlistype];
}

- (void ) onTop10Tab {
    [_audioPlayer stop];
    [trendingTabButton setBackgroundImage:[UIImage imageNamed:@"trendingtabbk_normal"] forState:UIControlStateNormal];
    [top10TabButton setBackgroundImage:[UIImage imageNamed:@"top10bk_hover"] forState:UIControlStateNormal];
    [staffpickerTabButton setBackgroundImage:[UIImage imageNamed:@"staffpicker_normal"] forState:UIControlStateNormal];
    [classicTabButton setBackgroundImage:[UIImage imageNamed:@"classictabbk_normal"] forState:UIControlStateNormal];
    playlistype = @"Top10";
    [songList removeAllObjects];
    [self getSongList:playlistype];
}

- (void) onStaffTab {
    [_audioPlayer stop];
    [trendingTabButton setBackgroundImage:[UIImage imageNamed:@"trendingtabbk_normal"] forState:UIControlStateNormal];
    [top10TabButton setBackgroundImage:[UIImage imageNamed:@"top10bk_normal"] forState:UIControlStateNormal];
    [staffpickerTabButton setBackgroundImage:[UIImage imageNamed:@"staffpicker_hover"] forState:UIControlStateNormal];
    [classicTabButton setBackgroundImage:[UIImage imageNamed:@"classictabbk_normal"] forState:UIControlStateNormal];
    playlistype = @"StaffPick";
    [songList removeAllObjects];
    [self getSongList:playlistype];
}

- (void) onClassicTab {
    [_audioPlayer stop];
    [trendingTabButton setBackgroundImage:[UIImage imageNamed:@"trendingtabbk_normal"] forState:UIControlStateNormal];
    [top10TabButton setBackgroundImage:[UIImage imageNamed:@"top10bk_normal"] forState:UIControlStateNormal];
    [staffpickerTabButton setBackgroundImage:[UIImage imageNamed:@"staffpicker_normal"] forState:UIControlStateNormal];
    [classicTabButton setBackgroundImage:[UIImage imageNamed:@"classictabbk_hover"] forState:UIControlStateNormal];
    playlistype = @"Classic";
    [songList removeAllObjects];
    [self getSongList:playlistype];
}


- (void) getSongList:(NSString *) type {
    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@&%@=%@",ROOT_URL,@"method",@"songlist", @"category", type];
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
            [Util showIndicator];
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if (json != nil) {
                NSArray* songlist = [json objectForKey:@"songlist"];
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
                        if (searchTerm != nil) {
                            if ([info.mSongName rangeOfString:searchTerm].location != NSNotFound || [info.mArtistName rangeOfString:searchTerm].location !=NSNotFound) {
                                [songList addObject:info];
                            }
                        } else {
                            [songList addObject:info];
                        }

                    }

                }
            }
            [Util hideIndicator];
            [homeTableView reloadData];
        }
    }];

}

- (void) getTrending {
//    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@",ROOT_URL,@"method",@"count"];
//    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
//        if (resultData != nil) {
//            [Util showIndicator];
//            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
//            if (json != nil) {
//                NSArray* songlist = [json objectForKey:@"songcount"];
//                if (songlist != nil) {
//                    for (int i=0; i < [songlist count]; i++)
//                    {
//                        NSDictionary *item = [songlist objectAtIndex:i];
//                        NSString *count = [item objectForKey:@"count"];
//                        [songcountlist addObject:count];
//                    }
//                    
//                }
//            }
//            [Util hideIndicator];
            [trendingTableView reloadData];
//        }
//    }];

}

- (void) getSongCount {
    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@",ROOT_URL,@"method",@"count"];
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
            [Util showIndicator];
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if (json != nil) {
                NSArray* songlist = [json objectForKey:@"songcount"];
                if (songlist != nil) {
                    for (int i=0; i < [songlist count]; i++)
                    {
                        NSDictionary *item = [songlist objectAtIndex:i];
                        NSString *count = [item objectForKey:@"count"];
                        [songcountlist addObject:count];
                    }
                    
                }
            }
            [Util hideIndicator];
            [playlistTableView reloadData];
        }
    }];
		
}

- (void) getPodcastSongCount {
    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@",ROOT_URL,@"method",@"podcastcount"];
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
            [Util showIndicator];
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if (json != nil) {
                NSArray* songlist = [json objectForKey:@"songcount"];
                if (songlist != nil) {
                    for (int i=0; i < [songlist count]; i++)
                    {
                        NSDictionary *item = [songlist objectAtIndex:i];
                        NSString *count = [item objectForKey:@"count"];
                        [podcastsongcountlist addObject:count];
                    }
                    
                }
            }
            [Util hideIndicator];
            [podcastTableView reloadData];
        }
    }];

}

- (void) getComedyList {
    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@",ROOT_URL,@"method",@"comedylist"];
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
            [Util showIndicator];
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if (json != nil) {
                NSArray* list = [json objectForKey:@"comedylist"];
                if (list != nil) {
                    for (int i=0; i < [list count]; i++)
                    {
                        NSDictionary *item = [list objectAtIndex:i];
                        NSString *comedy = [item objectForKey:@"comedyname"];
                        NSString *comedyTerm = [item objectForKey:@"comedyterm"];
                        [comedyList addObject:comedy];
                        [comedyTermList addObject:comedyTerm];
                    }
                    
                }
            }
            [Util hideIndicator];
            [comedyTableView reloadData];
        }
    }];
    
}

- (void) getNollywoodList {
    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@",ROOT_URL,@"method",@"nollywoodlist"];
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
            [Util showIndicator];
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if (json != nil) {
                NSArray* list = [json objectForKey:@"nollywoodlist"];
                if (list != nil) {
                    for (int i=0; i < [list count]; i++)
                    {
                        NSDictionary *item = [list objectAtIndex:i];
                        NSString *video = [item objectForKey:@"videoname"];
                        NSString *videoTerm = [item objectForKey:@"videoterm"];
                        [nollywoodList addObject:video];
                        [nollywoodTermList addObject:videoTerm];
                    }
                    
                }
            }
            [Util hideIndicator];
            [nollywoodTableView reloadData];
        }
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == menuTableView) {
       return MENUTABLE_HEIGHT;
    } else if (tableView == homeTableView || tableView == userTableView) {
        return HOMETABLE_HEIGHT;
    } else if (tableView == playlistTableView || tableView == podcastTableView){
        return PLAYLISTTABLE_HEIGHT;
    } else if (tableView == comedyTableView) {
        return COMEDYTABLE_HEIGHT;
    } else {
        return COMEDYTABLE_HEIGHT;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == menuTableView) {
        return (section == 1) ? 2.0f : 0.0f;
    } else {
        return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section < 2) {
	NSObject *headerText = headers[section];
	UIView *headerView = nil;
	if (headerText != [NSNull null]) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 2.0f)];
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = headerView.bounds;
		gradient.colors = @[
                            (id)[UIColor colorWithRed:(67.0f/255.0f) green:(74.0f/255.0f) blue:(94.0f/255.0f) alpha:1.0f].CGColor,
                            (id)[UIColor colorWithRed:(57.0f/255.0f) green:(64.0f/255.0f) blue:(82.0f/255.0f) alpha:1.0f].CGColor,
                            ];
		[headerView.layer insertSublayer:gradient atIndex:0];
	}
        return headerView; }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == menuTableView) {
        return 12;
    } else if (tableView == userTableView) {
        return (userSongList?userSongList.count:0);
    } else if (tableView == homeTableView) {
        return (songList?songList.count:0);
    } else if (tableView == trendingTableView) {
        return 2;
    } else if (tableView == playlistTableView) {
        return (songcountlist?songcountlist.count:0);
    } else if (tableView == podcastTableView){
        return (podcastsongcountlist?podcastsongcountlist.count:0);
    } else if (tableView == comedyTableView) {
        return (comedyList?comedyList.count:0);
    } else if (tableView == nollywoodTableView) {
        return (nollywoodList?nollywoodList.count:0);
    } else {
        return 0;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == menuTableView) {
        switch (section) {
            case 10:
                if (socialMenuDropDown) {
                    return 3;
                }
                else
                {
                    return 1;
                }
                break;
            default:
                return 1;
                break;
        }
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == menuTableView) {   //if tableview is MenuTableView
    switch ([indexPath section]) {
        case 0: {
            MainMenuTableViewCell *cell = (MainMenuTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"MainMenuTableViewCell"];
            if(cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MainMenuTableViewCell" owner:[MainMenuTableViewCell class] options:nil];
                cell = (MainMenuTableViewCell *)[nib objectAtIndex:0];
                cell.contentView.backgroundColor = [UIColor clearColor];
            }
            if (selectedSection == [indexPath section]) {
                cell.imgBack.image = [UIImage imageNamed:@"itembk_red"];
            } else {
                cell.imgBack.image = [UIImage imageNamed:@"itembk_lightblue"];
            }
            cell.labelMenu.text = username;
            cell.imgView.image = profileImage;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [tableView setSeparatorColor:[UIColor darkGrayColor]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            cell.listNameLabel.text = @"";
            cell.songCountLabel.text = @"";
            return cell;

            break;
        }
        case 10: {                       //if click social menu
            
            switch ([indexPath row]) {
                case 0: {
                    
                    MainMenuTableViewCell *cell = (MainMenuTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"MainMenuTableViewCell"];
                    if(cell == nil)
                    {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MainMenuTableViewCell" owner:[MainMenuTableViewCell class] options:nil];
                        cell = (MainMenuTableViewCell *)[nib objectAtIndex:0];
                        cell.contentView.backgroundColor = [UIColor clearColor];
                    }
                    
                    NSDictionary* dict = [self.arrayForMainMenu objectAtIndex:indexPath.section-1];
                    if (selectedSection == 10 && selectedRow == 0) {
                        cell.imgBack.image = [UIImage imageNamed:@"itembk_red"];
                    } else {
                        if (([indexPath section]+[indexPath row])%2 == 0) cell.imgBack.image = [UIImage     imageNamed:@"itembk_lightblue"];
                        else cell.imgBack.image = [UIImage imageNamed:@"itembk_darkblue"];
                    }
                    cell.labelMenu.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"MenuLabel"]];
                    cell.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[dict objectForKey:@"Image"]]];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [tableView setSeparatorColor:[UIColor darkGrayColor]];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                    cell.listNameLabel.text = @"";
                    cell.songCountLabel.text = @"";
                    return cell;
                    
                    break;
                }
                default: {
                    MainMenuTableViewCell *cell = (MainMenuTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"MainMenuTableViewCell"];
                    if(cell == nil)
                    {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MainMenuTableViewCell" owner:[MainMenuTableViewCell class] options:nil];
                        cell = (MainMenuTableViewCell *)[nib objectAtIndex:0];
                        cell.contentView.backgroundColor = [UIColor clearColor];
                    }
                    
                    NSDictionary* dict = [self.arrayForMainMenu objectAtIndex:indexPath.section+indexPath.row-1];
                    if (selectedSection == 10 && selectedRow == [indexPath row]) {
                        cell.imgBack.image = [UIImage imageNamed:@"itembk_red"];
                    } else {
                        if (([indexPath section]+[indexPath row])%2 == 0) cell.imgBack.image = [UIImage         imageNamed:@"itembk_lightblue"];
                        else cell.imgBack.image = [UIImage imageNamed:@"itembk_darkblue"];
                    }
                    cell.labelMenu.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"MenuLabel"]];
                    cell.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[dict objectForKey:@"Image"]]];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [tableView setSeparatorColor:[UIColor darkGrayColor]];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                    cell.listNameLabel.text = @"";
                    cell.songCountLabel.text = @"";
                    return cell;
                    
                    break;
                }
            }
            
            break;
        default: {
            MainMenuTableViewCell *cell = (MainMenuTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"MainMenuTableViewCell"];
            if(cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MainMenuTableViewCell" owner:[MainMenuTableViewCell class] options:nil];
                cell = (MainMenuTableViewCell *)[nib objectAtIndex:0];
                cell.contentView.backgroundColor = [UIColor clearColor];
            }
            int index = (indexPath.section > 10)?indexPath.section+2:indexPath.section;
            NSDictionary* dict = [self.arrayForMainMenu objectAtIndex:index-1];
            if (selectedSection == [indexPath section]) {
                cell.imgBack.image = [UIImage imageNamed:@"itembk_red"];
            } else {
                int index = [indexPath section];
                if (socialMenuDropDown && index > 9) {
                    index = index + 1;
                }
                if ([indexPath section]%2 == 0) cell.imgBack.image = [UIImage imageNamed:@"itembk_lightblue"];
                else cell.imgBack.image = [UIImage imageNamed:@"itembk_darkblue"];
            }
            cell.labelMenu.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"MenuLabel"]];
            cell.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[dict objectForKey:@"Image"]]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [tableView setSeparatorColor:[UIColor darkGrayColor]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            cell.listNameLabel.text = @"";
            cell.songCountLabel.text = @"";
            return cell;

            
            break;
        }
            
        }
    }
    }
    else if(tableView == userTableView) { //if tableview is UserTableView
        HomeTableViewCell *cell = (HomeTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
        
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeTableViewCell" owner:[HomeTableViewCell class] options:nil];
            cell = (HomeTableViewCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell configurePlayerButton];
        }
        if (userSongList != nil && [userSongList count] > [indexPath section]) {
            cell.leftUtilityButtons = [self leftButtons];
            cell.delegate = self;
            SongInfo *info = [userSongList objectAtIndex:[indexPath section]];
            cell.artistNameLabel.text = [NSString stringWithFormat:@"%@-%@",info.mArtistName, info.mSongName];
            cell.artistSubLabel.text = info.likecount;
            cell.songName = info.mSongName;
            cell.avatarImg.image = [UIImage imageNamed:@"avatar.png"];
            cell.songInfo = info;
            [cell setRemoteImgOper:_objImgListOper];
            
            [cell showImgByURL:info.mPosterPath];
            
            cell.imgView.image = [UIImage imageNamed:@"HomeMenuImg.png"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.audioButton.tag = indexPath.section;
            [cell.audioButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        [tableView setSeparatorColor:[UIColor darkGrayColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        return cell;

    }
    else if(tableView == homeTableView){    //if tableview is HomeTableView
        HomeTableViewCell *cell = (HomeTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
 
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeTableViewCell" owner:[HomeTableViewCell class] options:nil];
            cell = (HomeTableViewCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell configurePlayerButton];
        }
        if (songList != nil && [songList count] > [indexPath section]) {
            cell.leftUtilityButtons = [self leftButtons];
            cell.delegate = self;
            SongInfo *info = [songList objectAtIndex:[indexPath section]];
            cell.artistNameLabel.text = [NSString stringWithFormat:@"%@-%@",info.mArtistName, info.mSongName];
            cell.artistSubLabel.text = info.likecount;
            cell.songName = info.mSongName;
            cell.avatarImg.image = [UIImage imageNamed:@"avatar.png"];
            cell.songInfo = info;
            [cell setRemoteImgOper:_objImgListOper];
            
            [cell showImgByURL:info.mPosterPath];

            cell.imgView.image = [UIImage imageNamed:@"HomeMenuImg.png"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.audioButton.tag = indexPath.section;
            [cell.audioButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];

        }
        [tableView setSeparatorColor:[UIColor darkGrayColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        return cell;
    } else if(tableView == trendingTableView){ //if tableview is trendingTableView
        ComedyTableViewCell *cell = (ComedyTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"ComedyTableViewCell"];
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ComedyTableViewCell" owner:[ComedyTableViewCell class] options:nil];
            cell = (ComedyTableViewCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        cell.imgBack.image = [UIImage imageNamed:@"itembk_lightblue"];
        if ([indexPath section] == 0) {
            cell.comedyNameLabel.text = @"Trending Video";
        } else {
            cell.comedyNameLabel.text = @"Trending Audio";
        }

        cell.imgAvatar.image = [UIImage imageNamed:@"TrendingMenuImg.png"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        [tableView setSeparatorColor:[UIColor darkGrayColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        return cell;

        
    } else if(tableView == playlistTableView){ //if tableview is PlayListTableView
        PlaylistTableViewCell *cell = (PlaylistTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"PlaylistTableViewCell"];
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaylistTableViewCell" owner:[PlaylistTableViewCell class] options:nil];
            cell = (PlaylistTableViewCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
         if (songcountlist && (songcountlist.count > [indexPath section])) {
            cell.imgBack.image = [UIImage imageNamed:@"itembk_lightblue"];
             NSString *count = [[NSString alloc] initWithFormat:@"%@%@",[songcountlist objectAtIndex:[indexPath section]],@" songs"];
            cell.songCountLabel.text = count;
            cell.listNameLabel.text = [playlistname objectAtIndex:[indexPath section]];

            cell.imgView.image = [UIImage imageNamed:@"PlaylistMenuImg.png"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
         }
        [tableView setSeparatorColor:[UIColor darkGrayColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        return cell;

    } else if(tableView == podcastTableView){ //if tableview is PlayListTableView
        PlaylistTableViewCell *cell = (PlaylistTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"PlaylistTableViewCell"];
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaylistTableViewCell" owner:[PlaylistTableViewCell class] options:nil];
            cell = (PlaylistTableViewCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        if (podcastsongcountlist && (podcastsongcountlist.count > [indexPath section])) {
            cell.imgBack.image = [UIImage imageNamed:@"itembk_lightblue"];
            NSString *count = [[NSString alloc] initWithFormat:@"%@%@",[podcastsongcountlist objectAtIndex:[indexPath section]],@" songs"];
            cell.songCountLabel.text = count;
            cell.listNameLabel.text = [podcastname objectAtIndex:[indexPath section]];
            
            cell.imgView.image = [UIImage imageNamed:@"PlaylistMenuImg.png"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [tableView setSeparatorColor:[UIColor darkGrayColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        return cell;
        
    } else if(tableView == comedyTableView){ //if tableview is ComedyTableView
        ComedyTableViewCell *cell = (ComedyTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"ComedyTableViewCell"];
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ComedyTableViewCell" owner:[ComedyTableViewCell class] options:nil];
            cell = (ComedyTableViewCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        if (comedyList && (comedyList.count > [indexPath section])) {
            cell.imgBack.image = [UIImage imageNamed:@"itembk_lightblue"];
            cell.comedyNameLabel.text = [comedyList objectAtIndex:[indexPath section]];
            
            cell.imgAvatar.image = [UIImage imageNamed:@"ComedyMenuImg.png"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [tableView setSeparatorColor:[UIColor darkGrayColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        return cell;
        
    } else { /*Nollywood TableView*/
        ComedyTableViewCell *cell = (ComedyTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"ComedyTableViewCell"];
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ComedyTableViewCell" owner:[ComedyTableViewCell class] options:nil];
            cell = (ComedyTableViewCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        if (nollywoodList && (nollywoodList.count > [indexPath section])) {
            cell.imgBack.image = [UIImage imageNamed:@"itembk_lightblue"];
            cell.comedyNameLabel.text = [nollywoodList objectAtIndex:[indexPath section]];
            
            cell.imgAvatar.image = [UIImage imageNamed:@"ComedyMenuImg.png"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [tableView setSeparatorColor:[UIColor darkGrayColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        return cell;

    }
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
    if (tableView == menuTableView) {
        selectedSection = [indexPath section];
        selectedRow = [indexPath row];
        switch ([indexPath section]) {
            case 0:
            {
                [self getUserSongList:userlisttype];
                [userTableView setHidden:NO];
                [userTabBar setHidden:NO];
                [homeTableView setHidden:YES];
                [tabBar setHidden:YES];
                [playlistTableView setHidden:YES];
                [settingTableView setHidden:YES];
                [podcastTableView setHidden:YES];
                [comedyTableView setHidden:YES];
                [nollywoodTableView setHidden:YES];
                [trendingTableView setHidden:YES];
                break;
            }
            case 1:
            {
                [self getSongList:playlistype];
                [userTableView setHidden:YES];
                [userTabBar setHidden:YES];
                [homeTableView setHidden:NO];
                [tabBar setHidden:NO];
                [playlistTableView setHidden:YES];
                [settingTableView setHidden:YES];
                [podcastTableView setHidden:YES];
                [comedyTableView setHidden:YES];
                [nollywoodTableView setHidden:YES];
                [trendingTableView setHidden:YES];
                break;
            }
            case 2:
            {
                RadioPlayerViewController *radioplayerViewController = [[RadioPlayerViewController alloc] initWithNibName:@"RadioPlayerViewController" bundle:nil];
                [radioplayerViewController setMenuViewController:self NewController:false];
                UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:radioplayerViewController];
                newNC.navigationBar.tintColor = [UIColor whiteColor];
                [self presentViewController:newNC animated:YES completion:nil];
                break;
            }
            case 3:
            {
                [songcountlist removeAllObjects];
                [self getTrending];
                [trendingTableView setHidden:NO];
                [userTableView setHidden:YES];
                [userTabBar setHidden:YES];
                [homeTableView setHidden:YES];
                [playlistTableView setHidden:YES];
                [settingTableView setHidden:YES];
                [podcastTableView setHidden:YES];
                [comedyTableView setHidden:YES];
                [nollywoodTableView setHidden:YES];
                break;
            }
            case 4:
            {
                [songcountlist removeAllObjects];
                [self getSongCount];
                [userTableView setHidden:YES];
                [userTabBar setHidden:YES];
                [homeTableView setHidden:YES];
                [playlistTableView setHidden:NO];
                [settingTableView setHidden:YES];
                [podcastTableView setHidden:YES];
                [comedyTableView setHidden:YES];
                [nollywoodTableView setHidden:YES];
                [trendingTableView setHidden:YES];
                break;
            }
            case 5:
            {
                [podcastsongcountlist removeAllObjects];
                [self getPodcastSongCount];
                [userTableView setHidden:YES];
                [userTabBar setHidden:YES];
                [homeTableView setHidden:YES];
                [playlistTableView setHidden:YES];
                [settingTableView setHidden:YES];
                [podcastTableView setHidden:NO];
                [nollywoodTableView setHidden:YES];
                [comedyTableView setHidden:YES];
                [trendingTableView setHidden:YES];
                break;
            }
            case 6:
            {
                YouTubeTableViewController *youtube = [[YouTubeTableViewController alloc] initWithNibName:@"YouTubeTableViewController" bundle:nil];
                [youtube setTrending:NO];
                UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:youtube];
                newNC.navigationBar.tintColor = [UIColor whiteColor];
                [self presentViewController:newNC animated:YES completion:nil];
                
                break;
            }
            case 7:
            {
                [comedyList removeAllObjects];
                [comedyTermList removeAllObjects];
                [self getComedyList];
                [userTableView setHidden:YES];
                [userTabBar setHidden:YES];
                [homeTableView setHidden:YES];
                [playlistTableView setHidden:YES];
                [settingTableView setHidden:YES];
                [podcastTableView setHidden:YES];
                [nollywoodTableView setHidden:YES];
                [comedyTableView setHidden:NO];
                [trendingTableView setHidden:YES];
                break;
            }
            case 8:
            {
                [nollywoodList removeAllObjects];
                [nollywoodTermList removeAllObjects];
                [self getNollywoodList];
                [userTableView setHidden:YES];
                [userTabBar setHidden:YES];
                [homeTableView setHidden:YES];
                [playlistTableView setHidden:YES];
                [settingTableView setHidden:YES];
                [podcastTableView setHidden:YES];
                [comedyTableView setHidden:YES];
                [nollywoodTableView setHidden:NO];
                [trendingTableView setHidden:YES];
                break;
            }
            case 9:
            {
                PhotosViewController *photoViewController = [[PhotosViewController alloc] initWithNibName:@"PhotosViewController" bundle:nil];
                UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:photoViewController];
                newNC.navigationBar.tintColor = [UIColor whiteColor];
                [self presentViewController:newNC animated:YES completion:nil];
                break;
            }
            case 10: {
                switch ([indexPath row]) {
                    case 0:
                    {
                        NSIndexPath *path0 = [NSIndexPath indexPathForRow:[indexPath row]+1 inSection:[indexPath section]];
                        NSIndexPath *path1 = [NSIndexPath indexPathForRow:[indexPath row]+2 inSection:[indexPath section]];
                    
                        NSArray *indexPathArray = [NSArray arrayWithObjects:path0, path1/*, path2*/, nil];
                    
                        if (socialMenuDropDown)
                        {
                            socialMenuDropDown = false;
                            [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                        }
                        else
                        {
                            socialMenuDropDown = true;
                            [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                        }

                        break;
                    }
                    case 1:
                    {
                        [userTableView setHidden:YES];
                        [userTabBar setHidden:YES];
                        [homeTableView setHidden:YES];
                        [tabBar setHidden:YES];
                        [playlistTableView setHidden:YES];
                        [settingTableView setHidden:YES];
                        [podcastTableView setHidden:YES];
                        [comedyTableView setHidden:YES];
                        [nollywoodTableView setHidden:YES];
                        [socialWebView setHidden:NO];
                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.facebook.com/1TribeRadio"]];
                        [socialWebView loadRequest:request];
                        [spinner setCenter:CGPointMake(160,200)];
                        [trendingTableView setHidden:YES];
                        break;
                    }
                    case 2:
                    {
                        [userTableView setHidden:YES];
                        [userTabBar setHidden:YES];
                        [homeTableView setHidden:YES];
                        [tabBar setHidden:YES];
                        [playlistTableView setHidden:YES];
                        [settingTableView setHidden:YES];
                        [podcastTableView setHidden:YES];
                        [comedyTableView setHidden:YES];
                        [nollywoodTableView setHidden:YES];
                        [trendingTableView setHidden:YES];
                        [socialWebView setHidden:NO];
                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://twitter.com/1TribeRadio"]];
                        [socialWebView loadRequest:request];
                        socialWebView.delegate=self;
                        [spinner setCenter:CGPointMake(160,200)];
                        [socialWebView setFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
                        break;
                    }
                }
                break;
            }
//            case 11:{
//                NavigationController *nc1 = [[NavigationController alloc] initWithRootViewController:[[GroupView alloc] init]];
//                NavigationController *nc2 = [[NavigationController alloc] initWithRootViewController:[[PrivateView alloc] init]];
//                NavigationController *nc3 = [[NavigationController alloc] initWithRootViewController:[[ProfileView alloc] init]];
//                UITabBarController* tabBarController = [[UITabBarController alloc] init];
//                tabBarController.viewControllers = [NSArray arrayWithObjects:nc1, nc2, nc3, nil];
//                tabBarController.tabBar.barTintColor = COLOR_TABBAR_BACKGROUND;
//                tabBarController.tabBar.tintColor = COLOR_TABBAR_LABEL;
//                tabBarController.tabBar.translucent = NO;
//                tabBarController.selectedIndex = 0;

                
//                MainView *chatView = [[MainView alloc] init];
//                UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:chatView];
//                newNC.navigationBar.tintColor = [UIColor whiteColor];
//                [self presentViewController:tabBarController animated:YES completion:nil];
//                break;
//            }
            case 11:{
                [[GPPSignIn sharedInstance] signOut];
                if ([SCTwitter isSessionValid]) {
                    [SCTwitter logoutCallback:^(BOOL success) {
                    }];
                }
                [appDelegate.radioPlayer pauseRadio];
                [_audioPlayer stop];
                FBSession *session = [FBSession activeSession];
                [session closeAndClearTokenInformation];
                [session close];
                [FBSession setActiveSession:nil];
                [Util hideIndicator];

                LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                [self presentViewController:loginViewController animated:NO completion:nil];
                                break;
            }
            default: {
                break;
            }
        }
        [menuTableView reloadData];
    } else if (tableView == trendingTableView) {
        if(indexPath.section == 0) {
            YouTubeTableViewController *youtube = [[YouTubeTableViewController alloc] initWithNibName:@"YouTubeTableViewController" bundle:nil];
            [youtube setTrending:YES];
            UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:youtube];
            newNC.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:newNC animated:YES completion:nil];
            
        } else {
            TrendingAudioViewController *trendingaudioViewController = [[TrendingAudioViewController alloc] initWithCoder:nil];
            UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:trendingaudioViewController];
            newNC.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:newNC animated:NO completion:nil];

        }
    } else if (tableView == playlistTableView) {
        ListSongViewController *listsongViewController = [[ListSongViewController alloc] initWithCoder:nil];
        NSString *playlistUrl = [NSString stringWithFormat:@"Playlist_%@", [playlistname objectAtIndex:[indexPath section]]];
        [listsongViewController setPlaylistUrl:playlistUrl];
        UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:listsongViewController];
        newNC.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:newNC animated:NO completion:nil];
    } else if (tableView == podcastTableView) {
        ListSongViewController *listsongViewController = [[ListSongViewController alloc] initWithCoder:nil];
        [listsongViewController setPlaylistUrl:[podcastname objectAtIndex:[indexPath section]]];
        UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:listsongViewController];
        newNC.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:newNC animated:NO completion:nil];
    } else if (tableView == comedyTableView) {
        VideoViewController *videoViewController = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
        [videoViewController setSearchTerm:[comedyTermList objectAtIndex:[indexPath section]]];
        UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:videoViewController];
        newNC.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:newNC animated:YES completion:nil];
    } else if (tableView == nollywoodTableView) {
        VideoViewController *videoViewController = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
        [videoViewController setSearchTerm:[nollywoodTermList objectAtIndex:[indexPath section]]];
        UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:videoViewController];
        newNC.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:newNC animated:YES completion:nil];
    } else if (tableView == homeTableView) {
        NSMutableArray *songs = [[NSMutableArray alloc] init];
        //[Util showIndicator];
        if (songList && songList.count > 0) {
            for (int i=0; i < songList.count; i++)
            {
                SongInfo *song = [songList objectAtIndex:i];
                if (song.mSongPath != nil && song.mSongPath != (id)[NSNull null] && song.mSongPath.length > 10) {
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
            [musicplayerViewController setCurrentTrackIndex:[indexPath section]];
            [musicplayerViewController setTracks:songs];
            [self increaseCount:0 playcount:1 HomeTableCell:(HomeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]];
            [[DatabaseController database] removeHistorySong:[songList objectAtIndex:[indexPath section]]];
            [[DatabaseController database] insertHistorySong:[songList objectAtIndex:[indexPath section]]];
            
            UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:musicplayerViewController];
            newNC.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:newNC animated:YES completion:nil];
         //   [Util hideIndicator];
            printf("yomi");
        }

    } else if (tableView == userTableView) {
        NSMutableArray *songs = [[NSMutableArray alloc] init];
    //    [Util showIndicator];
        if (userSongList && userSongList.count > 0) {
            for (int i=0; i < userSongList.count; i++)
            {
                SongInfo *song = [userSongList objectAtIndex:i];
                if (song.mSongPath != nil && song.mSongPath.length > 10) {
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
            [musicplayerViewController setCurrentTrackIndex:[indexPath section]];
            [musicplayerViewController setTracks:songs];
            [self increaseCount:0 playcount:1 HomeTableCell:(HomeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]];
            [[DatabaseController database] removeHistorySong:[userSongList objectAtIndex:[indexPath section]]];
            [[DatabaseController database] insertHistorySong:[userSongList objectAtIndex:[indexPath section]]];
            
            UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:musicplayerViewController];
            newNC.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:newNC animated:YES completion:nil];
          //  [Util hideIndicator];
        }
        
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUserProfileInfo:(NSString *)user_name ProfileImage: (UIImage *)profileImg {
    username = user_name;
    profileImage = profileImg;
}

- (void)setGuestUeser:(BOOL) isGuest {
    bGuestUser = isGuest;
}

- (void)startDeadTime {
    if (bGuestUser) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self presentViewController:loginViewController animated:NO completion:nil];
    }
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

- (void) increaseCount:(int)likecount playcount:(int)value HomeTableCell:(HomeTableViewCell*)cell{
    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",ROOT_URL,@"method",@"save", @"likecount", [[NSString alloc] initWithFormat:@"%d", likecount], @"playcount", [[NSString alloc] initWithFormat:@"%d" ,value], @"songname", cell.songName, @"artist", [cell.artistNameLabel text]];
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        int orignal_likecount = [[cell.artistSubLabel text] intValue];
        orignal_likecount ++;
        NSString *realcount = [[NSString alloc] initWithFormat:@"%d",orignal_likecount];
        [cell.artistSubLabel setText:realcount];
       
    }];
    
    
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    HomeTableViewCell *listsongCell = (HomeTableViewCell*)cell;
    switch (index) {
        case 0:
            [self increaseCount:1 playcount:0 HomeTableCell:listsongCell];
            [[DatabaseController database] removeFavouriteSong:listsongCell.songInfo];
            [[DatabaseController database] insertFavouriteSong:listsongCell.songInfo];
            break;
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
                                //[slComposerSheet addURL:[NSURL URLWithString:@"http://www.facebook.com/"]];
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
                        }else if (currentver>5) {
                            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
                            {
                                slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                                [slComposerSheet setInitialText:listsongCell.songInfo.mSongPath];
                                //[slComposerSheet addImage:[UIImage imageNamed:@"twitter.png"]];
                                //[slComposerSheet addURL:[NSURL URLWithString:@"http:///"]];
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
                            
                        }else{//ios5 以下
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com"]];
                        }
                        
                    } else {
                        
                    }

                }];
                [lplv showInView:self.centerContentView animated:YES];
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

- (void) timerFired:(NSTimer *)_timer {
    if (self.screenStatus == 1) {
        [self closeSideView:YES];
        if ([timer isValid]) {
            [timer invalidate];
        }
        timer = nil;
    }
}

#pragma mark WebView Delegate

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [Util showIndicator];
    [spinner startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [spinner stopAnimating];
    [Util hideIndicator];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    [spinner stopAnimating];
    [Util hideIndicator];
}


-(void)startAnimatingFun{
	[spinner startAnimating];
}

//To stop the activity indicator
-(void)stopAnimatingFun{
	[spinner stopAnimating];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar	{
	[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar		{
	[searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = @"";
	[searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	searchTerm = searchBar.text;
	searchBar.text = @"";
	[searchBar resignFirstResponder];
    if(![userTableView isHidden]) {
        [userSongList removeAllObjects];
        [self getUserSongList:userlisttype];
    } else if(![homeTableView isHidden]) {
        [songList removeAllObjects];
        [self getSongList:playlistype];
    }
}


@end
