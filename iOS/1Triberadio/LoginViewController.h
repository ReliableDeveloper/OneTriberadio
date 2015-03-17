//
//  LoginViewController.h
//  Triberadio
//
//  Created by YingZhi on 6/12/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import "ZSVRadioPlayer.h"

@class GPPSignInButton;

@interface LoginViewController : UIViewController<UITextFieldDelegate, GPPSignInDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *loginBackImage;
- (IBAction)onTwitterLogin:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *usernameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;

@property (strong, nonatomic) IBOutlet UIButton *rememberButton;
- (IBAction)onLoginButton:(id)sender;
- (IBAction)onRegisterButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *alphaView;
@property (strong, nonatomic) IBOutlet UITextField *register_username;
@property (strong, nonatomic) IBOutlet UITextField *register_email;
@property (strong, nonatomic) IBOutlet UITextField *register_password;
@property (strong, nonatomic) IBOutlet UIView *registerBackImage;
@property (strong, nonatomic) IBOutlet UIView *lostpasswordBackImage;

@property (strong, nonatomic) IBOutlet UITextField *register_confirmpassword;
@property (strong, nonatomic) IBOutlet UIImageView *register_backImg;
- (IBAction)onRegister:(id)sender;
- (IBAction)onLostPassword:(id)sender;
- (IBAction)onReleaseRegister:(id)sender;

- (IBAction)onReleaseLostpassword:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *lostpasswordBack;
@property (strong, nonatomic) IBOutlet UIButton *registerBack;

@property (strong, nonatomic) IBOutlet UIButton *twitterBtn;


@property (strong, nonatomic) IBOutlet UIView *lostPwdAlphaView;
@property (strong, nonatomic) IBOutlet UITextField *lostPwd_username;
- (IBAction)onGetPassword:(id)sender;
@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

@property (strong, nonatomic) IBOutlet GPPSignInButton *signInButton;
- (IBAction)onGuest:(id)sender;
- (void) presentMenuViewController;
@end
