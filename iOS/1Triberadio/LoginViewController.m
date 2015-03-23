//
//  LoginViewController.m
//  Triberadio
//
//  Created by YingZhi on 6/12/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import "LoginViewController.h"
#import "MenuViewController.h"
#import "RadioPlayerViewController.h"
#import "HttpAPI.h"
#import "GRAlertView.h"
#import "AppDelegate.h"
#import "Util.h"
#import "SCTwitter.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Facebook-iOS-SDK/FacebookSDK/FBSettings.h>
#import <GooglePlus/GooglePlus.h>

#define LOGIN_URL       @"http://1triberadio.com/Sorikodo/login/?"
#define REGISTER_URL    @"http://1triberadio.com/Sorikodo/signup/?"
#define LOSTPASSWORD_URL @"http://1triberadio.com/Sorikodo/lostpwd/?"
#define USERNAME        @"username"
#define PASSWORD        @"password"
#define EMAIL           @"email"
#define LOGINED_USER    @"*logineduser*"

@interface LoginViewController ()<NSXMLParserDelegate, FBLoginViewDelegate, UIAlertViewDelegate>
{
    bool loginSuccess;
    bool rememberPassword;
    NSString *facebook_username;
    UIImage *profileImage;
    MenuViewController *mainMenuViewController;
    BOOL bPresent;
}

@end

@implementation LoginViewController
@synthesize usernameText;
@synthesize passwordText;
@synthesize loginBackImage;
@synthesize rememberButton;
@synthesize register_username;
@synthesize register_password;
@synthesize register_confirmpassword;
@synthesize register_email;
@synthesize alphaView;
@synthesize lostPwdAlphaView;
@synthesize lostPwd_username;
@synthesize fbLoginView;
@synthesize loggedInUser;
@synthesize profilePic;
@synthesize registerBackImage;
@synthesize lostpasswordBackImage;
@synthesize registerBack;
@synthesize lostpasswordBack;
@synthesize twitterBtn;
@synthesize signInButton;

static NSString * const kClientId = @"903878062522-0d9bmk92lmqcbcmht7jevh54cuos8qup.apps.googleusercontent.com";
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
    [usernameText setDelegate:self];
    [passwordText setDelegate:self];
    [register_username setDelegate:self];
    [register_email setDelegate:self];
    [register_password setDelegate:self];
    [register_confirmpassword setDelegate:self];
    [lostPwd_username setDelegate:self];
    [rememberButton addTarget:self action:@selector(onRemember) forControlEvents:UIControlEventTouchUpInside];
    [alphaView setHidden:YES];
    [lostPwdAlphaView setHidden:YES];
    [profilePic setHidden:YES];
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    if([preferences objectForKey:@"remember"] != nil)
    {
        if([preferences boolForKey:@"remember"]) {
            [rememberButton setBackgroundImage:[UIImage imageNamed:@"button_checked"] forState:UIControlStateNormal];
            NSString *username = (NSString*) [preferences objectForKey:@"username"];
            NSString *password = (NSString*) [preferences objectForKey:@"password"];
            [usernameText setText:username];
            [passwordText setText:password];
            [passwordText setSecureTextEntry:YES];
            [usernameText setTextColor:[UIColor blackColor]];
            [passwordText setTextColor:[UIColor blackColor]];
            rememberPassword = true;
        } else {
            [rememberButton setBackgroundImage:[UIImage imageNamed:@"button_normal"] forState:UIControlStateNormal];
            [usernameText setText:@"Enter your username"];
            [passwordText setText:@"Enter your password"];
            [passwordText setSecureTextEntry:NO];
            [usernameText setTextColor:[UIColor darkGrayColor]];
            [passwordText setTextColor:[UIColor darkGrayColor]];
            rememberPassword = false;
        }
    } else {
        rememberPassword = true;
        [rememberButton setBackgroundImage:[UIImage imageNamed:@"button_checked"] forState:UIControlStateNormal];
    }
    
    if ([SCTwitter isSessionValid]) {
        [twitterBtn setBackgroundImage:[UIImage imageNamed:@"twitter_logout.png"] forState:UIControlStateNormal];
    } else {
        [twitterBtn setBackgroundImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
    }
    
    [signInButton setImage:[UIImage imageNamed:@"google.png"] forState:UIControlStateNormal];
    //GoogleSign
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    //signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    [self saveSocialType:1];
    [signIn trySilentAuthentication];
    fbLoginView = [[FBLoginView alloc] init];
    fbLoginView.delegate = self;
    bPresent = false;

    // The event handling method
      mainMenuViewController = [[MenuViewController alloc] initWithCoder:nil];
      if (profileImage != nil && loggedInUser != nil) {
        [mainMenuViewController setUserProfileInfo:facebook_username ProfileImage:profileImage];
        [mainMenuViewController setGuestUeser:NO];
        [self presentViewController:mainMenuViewController animated:YES completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([SCTwitter isSessionValid] || [[NSUserDefaults standardUserDefaults] boolForKey:@"remember"]) {
        if ([SCTwitter isSessionValid]) {
            [self onLoginWithTwitter];
        } else {
            [self onLoginButton:nil];
        }
    }
}

- (void) presentMenuViewController{
    [self presentViewController:mainMenuViewController animated:NO completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == usernameText) {
        if([usernameText textColor] != [UIColor blackColor])
        {
            [usernameText setTextColor:[UIColor blackColor]];
            [usernameText setText:@""];
        }
    } else if(textField == passwordText){
        if([passwordText textColor] != [UIColor blackColor])
        {
            [passwordText setText:@""];
            [passwordText setSecureTextEntry:YES];
            [passwordText setTextColor:[UIColor blackColor]];
        }
    } else if(textField == register_username) {
        if([register_username textColor] != [UIColor blackColor])
        {
            [register_username setTextColor:[UIColor blackColor]];
            [register_username setText:@""];
        }
    } else if(textField == register_email) {
        if([register_email textColor] != [UIColor blackColor])
        {
            [register_email setTextColor:[UIColor blackColor]];
            [register_email setText:@""];
        }
    } else if(textField == register_password) {
        if([register_password textColor] != [UIColor blackColor])
        {
            [register_password setTextColor:[UIColor blackColor]];
            [register_password setText:@""];
            [register_password setSecureTextEntry:YES];
        }
    } else if(textField == register_confirmpassword) {
        if([register_confirmpassword textColor] != [UIColor blackColor])
        {
            [register_confirmpassword setTextColor:[UIColor blackColor]];
            [register_confirmpassword setText:@""];
            [register_confirmpassword setSecureTextEntry:YES];
        }
    } else if(textField == lostPwd_username) {
        if([textField textColor] != [UIColor blackColor])
        {
            [textField setTextColor:[UIColor blackColor]];
            [textField setText:@""];
        }
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

}

- (void)onRemember {
    if (rememberPassword) {
        [rememberButton setBackgroundImage:[UIImage imageNamed:@"button_normal"] forState:UIControlStateNormal];
    } else {
        [rememberButton setBackgroundImage:[UIImage imageNamed:@"button_checked"] forState:UIControlStateNormal];
    }
    rememberPassword = !rememberPassword;
}

#pragma mark - GPPSignInDelegate
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        // Do some error handling here.
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    [[self navigationController] pushViewController:viewController animated:YES];
}

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
//        self.signInButton.hidden = YES;
        // Perform other actions here, such as showing a sign-out button
        NSString *user = [[GPPSignIn sharedInstance] userID];
        NSString *userEmail = [[GPPSignIn sharedInstance] userEmail];
//        MenuViewController *mainMenuViewController = [[MenuViewController alloc] initWithCoder:nil];
        if (user != nil) {
            [mainMenuViewController setUserProfileInfo:user ProfileImage:[UIImage imageNamed:@"profile_defaultImg.png"]];
        } else {
            [mainMenuViewController setUserProfileInfo:userEmail ProfileImage:[UIImage imageNamed:@"profile_defaultImg.png"]];
        }
        [mainMenuViewController setGuestUeser:NO];
        [self saveSocialType:1];
        [self presentViewController:mainMenuViewController animated:YES completion:nil];

        
    } else {
        self.signInButton.hidden = NO;
        // Perform other actions here
    }
}

-(void)saveSocialType:(NSInteger) type {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    
    NSString* currentLevelKey = @"socialtype";
   
   [preferences setInteger:type forKey:currentLevelKey];
    //  Save to disk
   [preferences synchronize];
}

- (void)disconnect {
    [[GPPSignIn sharedInstance] disconnect];
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        NSLog(@"Received error %@", error);
    } else {
        // The user is signed out and disconnected.
        // Clean up user data as specified by the Google+ terms.
    }
}

#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {

}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    facebook_username = user.first_name;
    profilePic.profileID = user.objectID;
    loggedInUser = user;
    if (![facebook_username isEqual:nil] && user.objectID != nil) {
        [self performSelector:@selector(getUserImageFromFBView) withObject:nil afterDelay:3.0];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // test to see if we can use the share dialog built into the Facebook application
    FBShareDialogParams *p = [[FBShareDialogParams alloc] init];
    p.link = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
    self.profilePic.profileID = nil;
    facebook_username = nil;
    loggedInUser = nil;
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results
    NSLog(@"FBLoginView encountered an error=%@", error);
}

-(void)getUserImageFromFBView{
    for (NSObject *obj in [profilePic subviews]) {
        if ([obj isMemberOfClass:[UIImageView class]]) {
            UIImageView *objImg = (UIImageView *)obj;
            profileImage = objImg.image;
            break;
        }
    }
//    profileImageView.image = profileImage;
    if (profileImage != nil && !bPresent) {
        bPresent = true;
        [mainMenuViewController setUserProfileInfo:facebook_username ProfileImage:profileImage];
        [self saveSocialType:0];
        [self presentViewController:mainMenuViewController animated:YES completion:nil];
    }
}

- (IBAction)onTwitterLogin:(id)sender {
    if ([SCTwitter isSessionValid]) {
        [SCTwitter logoutCallback:^(BOOL success) {
            SCAlert(@"Alert", @"Logout successfully");
            [twitterBtn setBackgroundImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
        }];
    } else {
        __weak typeof (self) weakSelf = self;
        [SCTwitter loginViewControler:self callback:^(BOOL success){
            __strong typeof (weakSelf) strongSelf = weakSelf;
        if (success) {
            [twitterBtn setBackgroundImage:[UIImage imageNamed:@"twitter_logout.png"] forState:UIControlStateNormal];
            [Util showIndicator];
            [strongSelf performSelector:@selector(onLoginWithTwitter) withObject:nil afterDelay:2.0];
        }
    }];
    }
}

- (void) onLoginWithTwitter {
    [Util hideIndicator];
    __weak typeof (self) weakSelf = self;
    [SCTwitter getUserInformationCallback:^(BOOL success, id result) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (success) {
            [mainMenuViewController setUserProfileInfo:result[@"user"] ProfileImage:[UIImage imageNamed:@"profile_defaultImg.png"]];
        } else {
            [mainMenuViewController setUserProfileInfo:@"" ProfileImage:[UIImage imageNamed:@"profile_defaultImg.png"]];
        }
        
        [mainMenuViewController setGuestUeser:NO];
        [strongSelf presentViewController:mainMenuViewController animated:YES completion:nil];
    }];
}


- (IBAction)onLoginButton:(id)sender {
    loginSuccess = false;
    NSString *username = usernameText.text;
    NSString *password = passwordText.text;
    if (([usernameText textColor] == [UIColor blackColor]) && [passwordText isSecureTextEntry] && username.length > 0 && password.length > 0) {
    
        NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@&%@=%@",LOGIN_URL,USERNAME, username, PASSWORD, password];
        [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
            if (resultData != nil) {
                NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
                [preferences setBool:rememberPassword forKey:@"remember"];
                if(rememberPassword) {
                    [preferences setValue:username forKey:@"username"];
                    [preferences setValue:password forKey:@"password"];
                }
                //  Save to disk
                const BOOL didSave = [preferences synchronize];
                
                if(!didSave)
                {
                    //  Couldn't save (I've never seen this happen in real world testing)
                }
                
                
                NSString *data = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                NSString *strTemp = [self extractString:data toLookFor:@"<respond>" skipForwardX:0 toStopBefore:@"</respond>"];
                if ([strTemp isEqual:@"<respond>1</respond>"]) {
                                                [Util hideIndicator];
                    [mainMenuViewController setUserProfileInfo:username ProfileImage:[UIImage imageNamed:@"profile_defaultImg.png"]];
                    [mainMenuViewController setGuestUeser:NO];
                    [self presentViewController:mainMenuViewController animated:YES completion:nil];
                    loginSuccess = true;
                } else {
                    NSString *msg = [self extractString:data toLookFor:@"<message>" skipForwardX:0 toStopBefore:@"</message>"];
                    msg = [msg stringByReplacingOccurrencesOfString:@"<message>" withString:@""];
                    msg = [msg stringByReplacingOccurrencesOfString:@"</message>" withString:@""];
                    [self showAlertScreen:@"Authentification Failure" content:msg];
                }
            }
        }];
    }
    
}

- (IBAction)onRegisterButton:(id)sender {
    if ([alphaView isHidden] == NO) {
        NSString *username = register_username.text;
        NSString *password = register_password.text;
        NSString *confirmpassword = register_confirmpassword.text;
        NSString *mail = register_email.text;
        if (([register_username textColor] == [UIColor blackColor]) && [register_password isSecureTextEntry] && [register_confirmpassword isSecureTextEntry] && ([register_email textColor] == [UIColor blackColor]) && username.length > 0 && mail.length > 0 && password.length > 0 && confirmpassword.length > 0) {
            if ([password isEqual:confirmpassword]) {
                NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@&%@=%@&%@=%@",REGISTER_URL,USERNAME, username, PASSWORD, password, EMAIL, mail];
                [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
                    if (resultData != nil) {
                        NSString *data = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                        NSString *strTemp = [self extractString:data toLookFor:@"<respond>" skipForwardX:0 toStopBefore:@"</respond>"];
                        if ([strTemp isEqual:@"<respond>1</respond>"]) {
                            [alphaView setHidden:YES];
                            [usernameText setText:username];
                            [usernameText setTextColor:[UIColor blackColor]];
                            [passwordText setText:password];
                            [passwordText setSecureTextEntry:YES];
                            [Util hideIndicator];

                            [mainMenuViewController setUserProfileInfo:username ProfileImage:[UIImage imageNamed:@"profile_defaultImg.png"]];
                            [self presentViewController:mainMenuViewController animated:YES completion:nil];
                        } else {
                            NSString *msg = [self extractString:data toLookFor:@"<message>" skipForwardX:0 toStopBefore:@"</message>"];
                            msg = [msg stringByReplacingOccurrencesOfString:@"<message>" withString:@""];
                            msg = [msg stringByReplacingOccurrencesOfString:@"</message>" withString:@""];
                            [self showAlertScreen:@"Register Failure" content:msg];
                        }
                    }
                }];

            } else {
                [self showAlertScreen:@"Error" content:@"Password is not matched"];
            }
        }
    }
    
}

-(void) showAlertScreen:(NSString*) title content:(NSString*)content {
    GRAlertView *alert = [[GRAlertView alloc] initWithTitle:title
                                                    message:content
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    alert.style = GRAlertStyleAlert;
    [alert show];
}


- (IBAction)onRegister:(id)sender {
    if([alphaView isHidden]) {
        [alphaView setHidden:NO];
    }
}

- (IBAction)onLostPassword:(id)sender {
    if([lostPwdAlphaView isHidden]) {
        [lostPwdAlphaView setHidden:NO];
    }
}

- (IBAction)onReleaseRegister:(id)sender {
    [alphaView setHidden:YES];
}

- (IBAction)onReleaseLostpassword:(id)sender {
    [lostPwdAlphaView setHidden:YES];
}
- (IBAction)onGetPassword:(id)sender {
    NSString *username = lostPwd_username.text;
    if (([lostPwd_username textColor] == [UIColor blackColor]) && username.length > 0) {
        
        NSString *requestURL = [NSString stringWithFormat:@"%@%@=%@",LOSTPASSWORD_URL,USERNAME, username];
        [HttpAPI sendLoginRequest:NO url:requestURL completionBlock:^(BOOL success, NSData *resultData, NSError *err) {
            if (resultData != nil) {
                NSString *data = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                NSString *strTemp = [self extractString:data toLookFor:@"<respond>" skipForwardX:0 toStopBefore:@"</respond>"];
                if ([strTemp isEqual:@"<respond>1</respond>"]) {
                    [lostPwdAlphaView setHidden:YES];
                    NSString *msg = [self extractString:data toLookFor:@"<message>" skipForwardX:0 toStopBefore:@"</message>"];
                    msg = [msg stringByReplacingOccurrencesOfString:@"<message>" withString:@""];
                    msg = [msg stringByReplacingOccurrencesOfString:@"</message>" withString:@""];
                    [self showAlertScreen:@"Success" content:msg];
                    
                } else {
                    NSString *msg = [self extractString:data toLookFor:@"<message>" skipForwardX:0 toStopBefore:@"</message>"];
                    msg = [msg stringByReplacingOccurrencesOfString:@"<message>" withString:@""];
                    msg = [msg stringByReplacingOccurrencesOfString:@"</message>" withString:@""];
                    [self showAlertScreen:@"Error" content:msg];
                }
            }
        }];
    }

}

- (NSString *)extractString:(NSString *)fullString toLookFor:(NSString *)lookFor skipForwardX:(NSInteger)skipForward toStopBefore:(NSString *)stopBefore
{
    
    NSRange firstRange = [fullString rangeOfString:lookFor];
    NSRange secondRange = [[fullString substringFromIndex:firstRange.location + skipForward] rangeOfString:stopBefore];
    NSRange finalRange = NSMakeRange(firstRange.location + skipForward, secondRange.location + [stopBefore length]);
    
    return [fullString substringWithRange:finalRange];
}

- (IBAction)onGuest:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"As a guest, your history,favorites and playlists will not be saved once you close this app" delegate:self cancelButtonTitle:@"No" otherButtonTitles:nil];
    [alertView addButtonWithTitle:@"Yes"];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        mainMenuViewController = [[MenuViewController alloc] initWithCoder:nil  ];
        [mainMenuViewController setUserProfileInfo:@"Guest" ProfileImage:[UIImage imageNamed:@"profile_defaultImg.png"]];
        [mainMenuViewController setGuestUeser:YES];
        RadioPlayerViewController *radioplayerViewController = [[RadioPlayerViewController alloc] initWithNibName:@"RadioPlayerViewController" bundle:nil];
        [radioplayerViewController setMenuViewController:mainMenuViewController NewController:true];
        [radioplayerViewController setParent:(LoginViewController*)self];
        
        UINavigationController *newNC = [[UINavigationController alloc] initWithRootViewController:radioplayerViewController];
        newNC.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:newNC animated:YES completion:nil];

    }
}


#pragma - IGSessionDelegate

-(void)igDidLogin {
    NSLog(@"Instagram did login");
    // here i can store accessToken
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [mainMenuViewController setUserProfileInfo:appDelegate.instagram.username ProfileImage:[UIImage imageNamed:@"profile_defaultImg.png"]];
    [mainMenuViewController setGuestUeser:NO];
    [self presentViewController:mainMenuViewController animated:YES completion:nil];

    
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)igDidLogout {
    NSLog(@"Instagram did logout");
    // remove the accessToken
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igSessionInvalidated {
    NSLog(@"Instagram session was invalidated");
}
@end
