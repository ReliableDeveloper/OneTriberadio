//
//  WebVideoViewController.m
//  YTBrowser
//
//  Created by Marin Todorov on 09/01/2013.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "WebVideoViewController.h"

@implementation WebVideoViewController
{
    IBOutlet UIWebView* webView;
}
@synthesize sharebuttons;
@synthesize title;
@synthesize url;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    
    sharebuttons = [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"facebook_share.png"],@"img",@"Facebook",@"text", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"twitter_share.png"],@"img",@"Twitter",@"text", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:[UIImage imageNamed:@"google_share.png"],@"img",@"Google+",@"text", nil],
                    nil];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"listing_header"] forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *btnShare = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ShareButton"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoShare)];
    self.navigationItem.rightBarButtonItem = btnShare;
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

    VideoLink* link = self.video.link[0];
    NSString* videoId = nil;
    NSArray *queryComponents = [link.href.query componentsSeparatedByString:@"&"];
    for (NSString* pair in queryComponents) {
        NSArray* pairComponents = [pair componentsSeparatedByString:@"="];
        if ([pairComponents[0] isEqualToString:@"v"]) {
            videoId = pairComponents[1];
            break;
        }
    }
    
    if (!videoId) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Video ID not found in video URL" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil]show];
        return;
    }
    
    NSLog(@"Embed video id: %@", videoId);
    
    NSString *htmlString = @"<html><head>\
    <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 320\"/></head>\
    <body style=\"background:#000;margin-top:0px;margin-left:0px\">\
    <iframe id=\"ytplayer\" type=\"text/html\" width=\"320\" height=\"240\"\
    src=\"http://www.youtube.com/embed/%@?autoplay=1\"\
    frameborder=\"0\"/>\
    </body></html>";
    
    htmlString = [NSString stringWithFormat:htmlString, videoId, videoId];
    
    
    
    [webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://www.youtube.com/"]];

}

-(void) gotoShare {
    LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"Share on..." options:sharebuttons handler:^(NSInteger anIndex) {
        if (anIndex == 0) {
            if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=6) {
                if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
                {
                    slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                    NSString *message = [NSString stringWithFormat:@"I'm watching %@ %@ on the all new 1triberadio app", title, [url absoluteString]];
                    [slComposerSheet setInitialText:message];
                    //[slComposerSheet addImage:[UIImage imageNamed:@"ios6.jpg"]];
                    //[slComposerSheet addURL:[NSURL URLWithString:@"http://www.facebook.com/"]];
                    [self presentViewController:slComposerSheet animated:YES completion:nil];
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
            }else if (currentver==6) {
                if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
                {
                    slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                    //[slComposerSheet addImage:[UIImage imageNamed:@"ios6.jpg"]];
                    //[slComposerSheet addURL:[NSURL URLWithString:@"http://www.twitter.com/"]];
                    [self presentViewController:slComposerSheet animated:YES completion:nil];
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
    [lplv showInView:self.view animated:YES];}


-(void) gotoMenu {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - LeveyPopListView delegates
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex {
    
}
- (void)leveyPopListViewDidCancel {
    
}

@end
