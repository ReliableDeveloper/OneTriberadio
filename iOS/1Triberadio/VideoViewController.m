//
//  VideoViewController.m
//  1Triberadio
//
//  Created by YingZhi on 15/7/14.
//
//

#import "VideoViewController.h"
#import "MGBox.h"
#import "MGScrollView.h"

#import "JSONModelLib.h"
#import "VideoModel.h"

#import "PhotoBox.h"
#import "WebVideoViewController.h"
#import "Util.h"
#import "SelectVideo1.h"

@interface VideoViewController ()
{
    IBOutlet MGScrollView* scroller;
    MGBox* searchBox;
    
    NSArray* videos;
    NSString *mSearchTerm;
}
@end

@implementation VideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setSearchTerm:(NSString *)searchTerm {
    mSearchTerm = searchTerm;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"listing_header"] forBarMetrics:UIBarMetricsDefault];
//    
//    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"searchbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoSearch)];
//    self.navigationItem.rightBarButtonItem = btnSearch;
//    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threelinebutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoMenu)];
//    self.navigationItem.leftBarButtonItem = btnMenu;
//    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
//    UIImageView *mainTitle = [[UIImageView alloc] initWithFrame:CGRectMake(40, -15, 150, 40)];
//    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, 20, 200, 21)];
//    mainTitle.image = [UIImage imageNamed:@"triberadiomark"];
//    subTitle.textColor = [UIColor whiteColor];
//    subTitle.text = @"Videos";
//    subTitle.font = [UIFont fontWithName:@"Arial" size:12];
//    [subTitle setTextAlignment:NSTextAlignmentCenter];
//    [titleView addSubview:mainTitle];
//    [titleView addSubview:subTitle];
//    self.navigationItem.titleView = titleView;
    
    SelectVideo1 *selectVideo1 = [[SelectVideo1 alloc] initWith:mSearchTerm];
    [self.navigationController pushViewController:selectVideo1 animated:YES];
    
//    scroller.contentLayoutMode = MGLayoutGridStyle;
//    scroller.bottomPadding = 8;
//    scroller.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];
    
    
    
    //setup the search box
//    searchBox = [MGBox boxWithSize:CGSizeMake(320,0)];
//    searchBox.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];

    //add search box
//    [scroller.boxes addObject: searchBox];
    
    //fire up the first search
//    [self searchYoutubeVideosForTerm: @"Olamide"];

}

//-(void)searchYoutubeVideosForTerm:(NSString*)term
//{
//    [Util showIndicator];
//    NSLog(@"Searching for '%@' ...", term);
//    
//    //URL escape the term
//    term = [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    //make HTTP call
////    NSString* searchCall = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?q=%@&max-results=50&alt=json", term];
//
////    NSString* searchCall = @"http://gdata.youtube.com/feeds/api/videos?q=Olamide&max-results=50&alt=json";
////    NSString* searchCall = @"http://gdata.youtube.com/feeds/api/videos/kFDu6ACKLKo/related?v=2";
//    NSString* searchCall = @"http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?time=today";
//    [JSONHTTPClient getJSONFromURLWithString: searchCall
//                                  completion:^(NSDictionary *json, JSONModelError *err) {
//                                      
//                                      //got JSON back
//                                      NSLog(@"Got JSON from web: %@", json);
//                                      
//                                      if (err) {
//                                          [[[UIAlertView alloc] initWithTitle:@"Error"
//                                                                      message:@"Network is unavailabe now. Please check WIFI state!"
//                                                                     delegate:nil
//                                                            cancelButtonTitle:@"Close"
//                                                            otherButtonTitles: nil] show];
//                                          [Util hideIndicator];
//                                          [self gotoMenu];
//                                          return;
//
//                                      }
//                                      
//                                      //initialize the models
//                                      videos = [VideoModel arrayOfModelsFromDictionaries:
//                                                json[@"feed"][@"entry"]
//                                                ];
//                                      
//                                      if (videos) NSLog(@"Loaded successfully models");
//                                      
//                                      //show the videos
//                                      [self showVideos];
//                                  }];
//}
//
//-(void)showVideos
//{
//    //clean the old videos
//    [scroller.boxes removeObjectsInRange:NSMakeRange(1, scroller.boxes.count-1)];
//    
//    //add boxes for all videos
//    for (int i=0;i<videos.count;i++) {
//        
//        //get the data
//        VideoModel* video = videos[i];
//        MediaThumbnail* thumb = video.thumbnail[0];
//        
//        //create a box
//        PhotoBox *box = [PhotoBox photoBoxForURL:thumb.url title:video.title];
//        box.onTap = ^{
//            WebVideoViewController *controller = [[WebVideoViewController alloc] initWithNibName:@"WebVideoViewController" bundle:nil];
//            controller.video = video;
//            controller.title = video.title;
//            UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:controller];
//            newNC.navigationBar.tintColor = [UIColor whiteColor];
//            [self presentViewController:newNC animated:YES completion:nil];
//
//        };
//        
//        //add the box
//        [scroller.boxes addObject:box];
//    }
//
//    //re-layout the scroll view
//    [scroller layoutWithSpeed:0.3 completion:nil];
//    [Util hideIndicator];
//}

- (void) gotoSearch {
    
}

- (void) gotoMenu {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
