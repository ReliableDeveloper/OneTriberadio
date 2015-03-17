//
//  RadioPlayerViewController.h
//  1Triberadio
//
//  Created by YingZhi on 23/6/14.
//
//

#import <UIKit/UIKit.h>
#import "ZSVRadioPlayer.h"
#import "MenuViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>

@class AudioStreamer;

@interface RadioPlayerViewController : UIViewController{
	NSTimer *progressUpdateTimer;
	NSString *currentImageName;
    
    MenuViewController *menuViewController;
    LoginViewController *loginViewController;
    bool bNewViewController;
    SLComposeViewController *slComposerSheet;
}
- (IBAction)onPlayButton:(id)sender;
- (IBAction)onVolumnButton:(id)sender;
- (void) setMenuViewController:(MenuViewController*) viewcontroller NewController:(bool)value;
- (void) setParent:(LoginViewController*) parent;
@property(nonatomic,retain)AppDelegate *appDel;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *volumnButton;
@property (strong, nonatomic) IBOutlet UIImageView *backImg;
@property(nonatomic,retain)NSTimer *aRtimer;
- (IBAction)onSharingFacebook:(id)sender;
- (IBAction)onSharingTwitter:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;


@end
