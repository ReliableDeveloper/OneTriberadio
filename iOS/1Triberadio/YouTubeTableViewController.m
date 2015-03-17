//
//  YouTubeTableViewController.m
//  YouTubePlayer
//
//  Created by Istvan Szabo on 2012.08.08..
//  Copyright (c) 2012 Istvan Szabo. All rights reserved.
//

#import "YouTubeTableViewController.h"
#import "YouTubeCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "ISCache.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BLYYoutubeExtractor.h"
#import "BLYYoutubeURLCollection.h"
#import "BLYYoutubeURL.h"
#import "HttpAPI.h"
#import "Util.h"

#define URL_DATA @"https://dl.dropbox.com/u/71008334/YouTube.plist"
#define ROOT_URL @"http://1triberadio.com/wp-content/uploads/index.php?"

@interface YouTubeTableViewController () {
    BOOL isTrending;
}
@end

@implementation YouTubeTableViewController
@synthesize ytvideosPlist;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"listing_header"] forBarMetrics:UIBarMetricsDefault];

    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threelinebutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoMenu)];
    self.navigationItem.leftBarButtonItem = btnMenu;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
    UIImageView *mainTitle = [[UIImageView alloc] initWithFrame:CGRectMake(40, -15, 150, 40)];
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, 20, 200, 21)];
    mainTitle.image = [UIImage imageNamed:@"triberadiomark"];
    subTitle.textColor = [UIColor whiteColor];
    subTitle.text = @"Videos";
    subTitle.font = [UIFont fontWithName:@"Arial" size:12];
    [subTitle setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:mainTitle];
    [titleView addSubview:subTitle];
    self.navigationItem.titleView = titleView;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *requestURL = @"";
    if (isTrending) {
        requestURL = [NSString stringWithFormat:@"%@%@=%@",ROOT_URL,@"method",@"trendingvideolist"];
    } else {
        requestURL = [NSString stringWithFormat:@"%@%@=%@",ROOT_URL,@"method",@"videolist"];
    }
    ytvideosPlist = [[NSMutableArray alloc] init];
    [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
            [Util showIndicator];
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if (json != nil) {
                NSArray* list = [json objectForKey:@"videolist"];
                if (list != nil) {
                    for (int i=0; i < [list count]; i++)
                    {
                        NSDictionary *item = [list objectAtIndex:i];
                        NSString *title = [item objectForKey:@"title"];
                        NSString *duration = [item objectForKey:@"duration"];
                        NSString *artist = [item objectForKey:@"artist"];
                        NSString *link = [item objectForKey:@"link"];
                        NSRange range = [link rangeOfString:@"youtu.be"];
                        NSString *videoid = [link substringFromIndex:range.location + range.length+1];
                        NSMutableDictionary *videoItem = [[NSMutableDictionary alloc] init];
                        [videoItem setValue:title forKey:@"Title"];
                        [videoItem setValue:duration forKey:@"Duration"];
                        [videoItem setValue:artist forKey:@"Author"];
                        [videoItem setValue:videoid forKey:@"VideoID"];
                        [ytvideosPlist addObject:videoItem];
                    }
                        self.headerTitle.text = [[ytvideosPlist objectAtIndex:0] valueForKey:@"Title"];

                     NSURL *imageURL1 = [NSURL URLWithString:[NSString stringWithFormat:@"http://i4.ytimg.com/vi/%@/mqdefault.jpg",[[ytvideosPlist objectAtIndex:0] valueForKey:@"VideoID"]]];
                    NSString *key1 = [NSString stringWithFormat:@"http://i4.ytimg.com/vi/%@/mqdefault.jpg",[[ytvideosPlist objectAtIndex:0] valueForKey:@"VideoID"]];
                    NSData *data1 = [ISCache objectForKey:key1];
                    if (data1) {
                        UIImage *image1 = [UIImage imageWithData:data1];
                        _headerImage.image = image1;
                    } else {
                        _headerImage.image = [UIImage imageNamed:@"thumbnail.jpg"];
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                        dispatch_async(queue, ^{
                            NSData *data1 = [NSData dataWithContentsOfURL:imageURL1];
                            [ISCache setObject:data1 forKey:key1];
                            UIImage *image1 = [UIImage imageWithData:data1];
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                _headerImage.image = image1;
                            });
                        });
                    }
                    
                }
            }
            [Util hideIndicator];
            [self.tableView reloadData];
        }
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void) gotoMenu {
    [Util hideIndicator];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadVideoPlayer:(NSString *)string
{
    
	 
    UIGraphicsEndImageContext();
    MPMoviePlayerViewController* theMoviePlayer = [[MPMoviePlayerViewController new]
                                                   initWithContentURL: [NSURL URLWithString:string]];
    
    UIGraphicsEndImageContext();
    [self presentMoviePlayerViewControllerAnimated:theMoviePlayer];
    
    
}
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ytvideosPlist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"YouTubeCell";
    
    YouTubeCell *cell = (YouTubeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YouTubeCell" owner:[YouTubeCell class] options:nil];
        cell = (YouTubeCell *)[nib objectAtIndex:0];
    }

    
    NSDictionary *videoItem = [ytvideosPlist objectAtIndex:indexPath.row];
    
    cell.ytTitle.text =[videoItem valueForKey:@"Title"];
    cell.ytDuration.text =[videoItem valueForKey:@"Duration"];
    cell.ytAuthor.text =[videoItem valueForKey:@"Author"];
    
    
    [cell.ytThumbnail.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [cell.ytThumbnail.layer setBorderWidth: 1.0];
    
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://i4.ytimg.com/vi/%@/default.jpg",[videoItem valueForKey:@"VideoID"]]];
	NSString *key = [NSString stringWithFormat:@"http://i4.ytimg.com/vi/%@/default.jpg",[videoItem valueForKey:@"VideoID"]];
	NSData *data = [ISCache objectForKey:key];
	if (data) {
		UIImage *image = [UIImage imageWithData:data];
		cell.ytThumbnail.image = image;
	} else {
		cell.ytThumbnail.image = [UIImage imageNamed:@"thumbnail.jpg"];
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSData *data = [NSData dataWithContentsOfURL:imageURL];
			[ISCache setObject:data forKey:key];
			UIImage *image = [UIImage imageWithData:data];
			dispatch_sync(dispatch_get_main_queue(), ^{
				cell.ytThumbnail.image = image;
			});
		});
	}
    
    
    
    return cell;
    
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *videoItem = [ytvideosPlist objectAtIndex:indexPath.row];
    [Util showIndicator];
    BLYYoutubeExtractor *ytExtractor = [[BLYYoutubeExtractor alloc] init];
    [ytExtractor urlsForVideoID:[videoItem valueForKey:@"VideoID"]
                   inBackground:NO
            withCompletionBlock:^(BLYYoutubeURLCollection *urls, NSError *err){
                
                if (err) {
                    NSString *errorDesc = [err localizedDescription];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:errorDesc
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [Util hideIndicator];

                    [alertView show];
                    
                    return;
                }
                [Util hideIndicator];
                Reachability *reachability = [Reachability reachabilityForInternetConnection];
                [reachability startNotifier];
                
                NetworkStatus status = [reachability currentReachabilityStatus];
                
                if (status == ReachableViaWiFi)
                {
                    BLYYoutubeURL *mediumQuality = [urls URLForVideoWithMediumQuality];
                    [self loadVideoPlayer:mediumQuality.value];
                    
                }
                else if (status == ReachableViaWWAN)
                {
                    BLYYoutubeURL *higherQuality = [urls URLForVideoWithHigherQuality];
                    [self loadVideoPlayer:higherQuality.value];
                    
                }
                
                
                
                
                
            }];
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (setCategoryError) {  }
    
    NSError *activationError = nil;
    [audioSession setActive:YES error:&activationError];
    if (activationError) {  }
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}



- (IBAction)playButton:(id)sender {

    [Util showIndicator];
    BLYYoutubeExtractor *ytExtractor = [[BLYYoutubeExtractor alloc] init];
    [ytExtractor urlsForVideoID:[_youtubePlist valueForKey:@"LatestVideoID"]
                   inBackground:NO
            withCompletionBlock:^(BLYYoutubeURLCollection *urls, NSError *err){
                
                if (err) {
                    NSString *errorDesc = [err localizedDescription];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:errorDesc
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [Util hideIndicator];

                    [alertView show];
                    
                    return;
                }
                [Util hideIndicator];
                Reachability *reachability = [Reachability reachabilityForInternetConnection];
                [reachability startNotifier];
                
                NetworkStatus status = [reachability currentReachabilityStatus];
                
                if (status == ReachableViaWiFi)
                {
                    BLYYoutubeURL *mediumQuality = [urls URLForVideoWithMediumQuality];
                    [self loadVideoPlayer:mediumQuality.value];
                    
                }
                else if (status == ReachableViaWWAN)
                {
                    BLYYoutubeURL *higherQuality = [urls URLForVideoWithHigherQuality];
                    [self loadVideoPlayer:higherQuality.value];
                    
                }
                
                
                
                
                
            }];
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (setCategoryError) {  }
    
    NSError *activationError = nil;
    [audioSession setActive:YES error:&activationError];
    if (activationError) {  }
    
        
    
}




- (IBAction)refreshButton:(id)sender {
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self performSelector:@selector(viewDidLoad) withObject:nil];
    [self.tableView reloadData];
    // show in the status bar that network activity stop
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"You must have an active network connection in order to Video" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    
}

- (void)setTrending:(BOOL) bTrending {
    isTrending = bTrending;
}

@end
