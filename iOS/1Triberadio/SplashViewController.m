//
//  SplashViewController.m
//  1Triberadio
//
//  Created by YingZhi on 20/6/14.
//
//

#import "SplashViewController.h"
#import "LoginViewController.h"
#import "VideoViewController.h"
#import "MenuViewController.h"
#import "RadioPlayerViewController.h"
#import "HttpAPI.h"

#define LOGIN_URL       @"http://1triberadio.com/Sorikodo/login/?"
#define REGISTER_URL    @"http://1triberadio.com/Sorikodo/signup/?"
#define LOSTPASSWORD_URL @"http://1triberadio.com/Sorikodo/lostpwd/?"
#define USERNAME        @"username"
#define PASSWORD        @"password"
#define EMAIL           @"email"
#define LOGINED_USER    @"*logineduser*"

@interface SplashViewController ()
{
    MenuViewController *mainMenuViewController;
    LoginViewController *loginViewController;
}
@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mainMenuViewController = [[MenuViewController alloc] initWithCoder:nil];
        loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }
    return self;
}

- (void)initApp {
//    mainMenuViewController = [[MenuViewController alloc] initWithCoder:nil  ];
//    [mainMenuViewController setUserProfileInfo:@"Guest" ProfileImage:[UIImage imageNamed:@"profile_defaultImg.png"]];
//    [mainMenuViewController setGuestUeser:YES];
//    RadioPlayerViewController *radioplayerViewController = [[RadioPlayerViewController alloc] initWithNibName:@"RadioPlayerViewController" bundle:nil];
//    [radioplayerViewController setMenuViewController:mainMenuViewController NewController:true];
//    [radioplayerViewController setParent:(SplashViewController*)self];
//    
//    UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:radioplayerViewController];
//    newNC.navigationBar.tintColor = [UIColor whiteColor];
//    [self presentViewController:newNC animated:YES completion:nil];


}

//- (void) presentMenuViewController:(ZSVRadioPlayer*) radioPlayer {
//    [mainMenuViewController setRadio:radioPlayer];
//    [self presentViewController:mainMenuViewController anima n ¬ted:NO completion:nil];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(initApp) withObject:nil afterDelay:2];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    if([preferences objectForKey:@"remember"] != nil)
    {
        if([preferences boolForKey:@"remember"]) {
            NSString *username = (NSString*) [preferences objectForKey:@"username"];
            NSString *password = (NSString*) [preferences objectForKey:@"password"];
            
            NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@&%@=%@",LOGIN_URL,USERNAME, username, PASSWORD, password];
            [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
                if (resultData != nil) {
                    NSString *data = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                    NSString *strTemp = [self extractString:data toLookFor:@"<respond>" skipForwardX:0 toStopBefore:@"</respond>"];
                    if ([strTemp isEqual:@"<respond>1</respond>"]) {
                        [mainMenuViewController setUserProfileInfo:username ProfileImage:[UIImage imageNamed:@"profile_defaultImg.png"]];
                        [mainMenuViewController setGuestUeser:NO];
                        [self presentViewController:mainMenuViewController animated:YES completion:nil];
                    } else {
                        //
                    }
                }
            }];
        }
    }
    else
    {
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
}

- (NSString *)extractString:(NSString *)fullString toLookFor:(NSString *)lookFor skipForwardX:(NSInteger)skipForward toStopBefore:(NSString *)stopBefore
{
    
    NSRange firstRange = [fullString rangeOfString:lookFor];
    NSRange secondRange = [[fullString substringFromIndex:firstRange.location + skipForward] rangeOfString:stopBefore];
    NSRange finalRange = NSMakeRange(firstRange.location + skipForward, secondRange.location + [stopBefore length]);
    
    return [fullString substringWithRange:finalRange];
}

@end
