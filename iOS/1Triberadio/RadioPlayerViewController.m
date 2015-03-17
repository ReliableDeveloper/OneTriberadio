//
//  RadioPlayerViewController.m
//  1Triberadio
//
//  Created by YingZhi on 23/6/14.
//
//

#import "RadioPlayerViewController.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "MenuViewController.h"
#import "HttpAPI.h"
#define RADIO_URL @"http://174.142.97.228:9000"
#define ROOT_URL @"http://1triberadio.com/wp-content/uploads/index.php?"
#define RADIOINFO_URL @"http://makeavoice.com/shoutcast/websitecodes/nowplaying.php?ip=174.142.97.228&port=9000&refresh=10&scrolling=yes"
//static ZSVRadioPlayer *radioPlayer;
//#define RADIO_URL @"http://shoutmedia.abc.net.au:10326"
@interface RadioPlayerViewController () {
    BOOL bMute;
    NSMutableArray *photoList;
    int photoIndex;
}

@end

@implementation RadioPlayerViewController
@synthesize playButton;
@synthesize volumnButton;
@synthesize appDel;
@synthesize aRtimer;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"listing_header"] forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"threelinebutton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoMenu)];
    self.navigationItem.leftBarButtonItem = btnMenu;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
    UIImageView *mainTitle = [[UIImageView alloc] initWithFrame:CGRectMake(40, -15, 150, 40)];
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, 20, 200, 21)];
    mainTitle.image = [UIImage imageNamed:@"triberadiomark"];
    subTitle.textColor = [UIColor whiteColor];
    subTitle.text = @"Radio";
    subTitle.font = [UIFont fontWithName:@"Arial" size:12];
    [subTitle setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:mainTitle];
    [titleView addSubview:subTitle];
    self.navigationItem.titleView = titleView;
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

    bMute = false;
	[self setButtonImageNamed:@"radiostopbutton.png"];
    [appDelegate.radioPlayer playRadioWithURLString:RADIO_URL];
    [self setButtonImageNamed:@"radiostopbutton.png"];
    photoList = [[NSMutableArray alloc] init];
    photoIndex = 0;
    [NSTimer scheduledTimerWithTimeInterval:1200.0f
                                             target:self
                                           selector:@selector(backgroundTimer:)
                                           userInfo:nil
                                            repeats:YES];
    NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self
                                   selector:@selector(artistTimer:)
                                   userInfo:nil
                                    repeats:YES];
    [timer fire];
    [self getPhotoList];
}

- (void) gotoMenu {
//    [radioPlayer pauseRadio];
//	if (progressUpdateTimer)
//	{
//		[progressUpdateTimer invalidate];
//		progressUpdateTimer = nil;
//	}
    if (bNewViewController) {
        [self dismissViewControllerAnimated:NO completion:^{
            [loginViewController presentMenuViewController];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

 -(void)presentMenuViewController
 {
     
     [self presentViewController:menuViewController animated:YES completion:NULL];
     
 }
                 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setButtonImageNamed:(NSString *)imageName
{
	if (!imageName)
	{
		imageName = @"radioplaybutton.png";
	}
	currentImageName = imageName;
	[playButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}


- (IBAction)onPlayButton:(id)sender {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([currentImageName isEqual:@"radioplaybutton.png"])
	{
      	[self setButtonImageNamed:@"radiostopbutton.png"];
        [appDelegate.radioPlayer resumePlay];
	}
	else
	{
        [self setButtonImageNamed:@"radioplaybutton.png"];
        [appDelegate.radioPlayer pauseRadio];
	}
}

- (IBAction)onVolumnButton:(id)sender {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (bMute) {
       [appDelegate.radioPlayer muteVolume:NO];
        [volumnButton setBackgroundImage:[UIImage imageNamed:@"soundon"] forState:UIControlStateNormal];
        bMute = NO;
    } else {
        [appDelegate.radioPlayer muteVolume:YES];
        [volumnButton setBackgroundImage:[UIImage imageNamed:@"soundoff"] forState:UIControlStateNormal];
        bMute = YES;
    }
}

- (void) setMenuViewController:(MenuViewController*) viewcontroller NewController:(bool)value {
    menuViewController = viewcontroller;
    bNewViewController = value;
}

- (void) setParent:(LoginViewController*) parent {
    loginViewController = parent;
}

- (IBAction)onSharingFacebook:(id)sender {
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=6) {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            slComposerSheet = [[SLComposeViewController alloc] init];
            slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            NSString *initText = [NSString stringWithFormat:@"#NP '%@' on 1triberadio app #1triberadio @1triberadio", self.artistNameLabel.text];
            [slComposerSheet setInitialText:initText];
            // [slComposerSheet addImage:[UIImage imageNamed:@"sharemark.png"]];
           // [slComposerSheet addURL:[NSURL URLWithString:@"http://www.facebook.com/"]];
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
        
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com"]];
    }

}

- (IBAction)onSharingTwitter:(id)sender {
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
            NSString *initText = [NSString stringWithFormat:@"#NP '%@' on #1triberadio app @1triberadio", self.artistNameLabel.text];
            [slComposerSheet setInitialText:initText];
            //[slComposerSheet addImage:[UIImage imageNamed:@"sharemark.png"]];
            //[slComposerSheet addURL:[NSURL URLWithString:@"http://www.twitter.com/"]];
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

}

- (void) backgroundTimer:(NSTimer *)_timer {
    if (photoIndex == [photoList count]) {
        photoIndex = 0;
    }
    [self.backImg setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[photoList objectAtIndex:photoIndex]]]]];
    photoIndex ++;
}

- (void) artistTimer:(NSTimer *)_timer {

    [HttpAPI sendLoginRequestNoIndicator:NO url:RADIOINFO_URL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
            NSString *radioinfo = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
            NSRange firstPos = [radioinfo rangeOfString:@"<br>"];
            NSRange endPos = [radioinfo rangeOfString:@"<br>List"];
            NSRange correct;
            correct.location = firstPos.location+8;
            correct.length = endPos.location-firstPos.location-8;
            NSString *artistInfo = [radioinfo substringWithRange:correct];
            [self.artistNameLabel setText:artistInfo];
        }
    }];
}

- (void) getPhotoList {
    NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@",ROOT_URL,@"method",@"imagelist"];
    [HttpAPI sendLoginRequestNoIndicator:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
        if (resultData != nil) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            if (json != nil) {
                NSArray* songlist = [json objectForKey:@"imagelist"];
                if (songlist != nil) {
                    for (int i=0; i < [songlist count]; i++)
                    {
                        NSDictionary *item = [songlist objectAtIndex:i];
                        NSString *path = [item objectForKey:@"link"];
                        [photoList addObject:path];
                    }
                    
                }
            }

        }
    }];
    
}

@end
