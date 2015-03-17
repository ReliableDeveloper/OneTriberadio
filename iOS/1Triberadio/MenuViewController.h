//
//  MenuViewController.h
//  Triberadio
//
//  Created by YingZhi on 6/13/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "BlurredViewController.h"
#import "AudioPlayer.h"
#import "ZSVRadioPlayer.h"
#import "LeveyPopListView.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface MenuViewController : BlurredViewController<UITextFieldDelegate,SWTableViewCellDelegate, LeveyPopListViewDelegate>{
    BOOL socialMenuDropDown;
    AudioPlayer *_audioPlayer;
    NSTimer *timer;
    BOOL bGuestUser;
    SLComposeViewController *slComposerSheet;
    UIActivityIndicatorView *spinner;
}
@property (nonatomic, retain) NSMutableArray* arrayForMainMenu;
- (void)setUserProfileInfo:(NSString *)user_name ProfileImage: (UIImage *)profileImg;
- (void)timerFired:(NSTimer*) timer;
- (void)setGuestUeser:(BOOL) isGuest;
- (void)startDeadTime;
@end
