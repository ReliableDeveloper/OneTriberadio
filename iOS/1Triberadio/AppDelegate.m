//
//  AppDelegate.m
//  1Triberadio
//
//  Created by YingZhi on 20/6/14.
//
//

#import "AppDelegate.h"
#import "SplashViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RadioPlayerViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "SCTwitter.h"
#import <GooglePlus/GooglePlus.h>
#import <Parse/Parse.h>
#import <ParseUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "AppConstant.h"

#define APP_ID @"7fdec8b31f564f599f8684dc526c7daf"

@implementation AppDelegate

@synthesize window = _window;
@synthesize radioController = _radioController;
@synthesize NAVIGATIONcontroller,bgTaskId;
//static  MPMoviePlayerController *moviePlayer=nil;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    
    NSString* currentLevelKey = @"socialtype";
    NSInteger type = 0;
    if( [preferences objectForKey:currentLevelKey] != nil)
    {
       //  Get current level
        type = [preferences integerForKey:currentLevelKey];
    }
    if ([url.absoluteString rangeOfString:@"facebook"].location != NSNotFound) {
        BOOL handleFBUrl = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
        return handleFBUrl;
    } else {
        return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [FBProfilePictureView class];
    
    [Parse setApplicationId:@"hn42aQubuMYrWiaaPx0UHfR1O5hXBT2oJFg4rxIJ" clientKey:@"Gl53xxqMeOBZamOUWvVgbPVPt5DdyXHt6nXCMPSU"];
//	//---------------------------------------------------------------------------------------------------------------------------------------------
	[PFFacebookUtils initializeFacebook];
//	//---------------------------------------------------------------------------------------------------------------------------------------------
	[PFImageView class];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    SplashViewController *splashViewController = [[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:nil];
    self.window.rootViewController = splashViewController;
    [self.window makeKeyAndVisible];
    
   [SCTwitter initWithConsumerKey:@"D6vneoIuMP0pdBZJAV7gg" consumerSecret:@"wWc59eahiaES9ZCZ7wp28Rw4hcURG4fmIXvvwJiaR8"];
    
    
    self.instagram = [[Instagram alloc] initWithClientId:APP_ID
                                                delegate:nil];
    self.radioPlayer = [ZSVRadioPlayer new];
    
    //-----------PUSHWOOSH PART-----------
    // set custom delegate for push handling, in our case - view controller
    PushNotificationManager * pushManager = [PushNotificationManager pushManager];
    pushManager.delegate = self;
    
    // handling push on app start
    [[PushNotificationManager pushManager] handlePushReceived:launchOptions];
    
    // make sure we count app open in Pushwoosh stats
    [[PushNotificationManager pushManager] sendAppOpen];
    
    // register for push notifications!
    [[PushNotificationManager pushManager] registerForPushNotifications];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

// system push notification registration success callback, delegate to pushManager
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

// system push notifications callback, delegate to pushManager
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}

- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification {
    NSLog(@"Push notification received");
    
}
@end
