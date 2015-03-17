//
//  ListSongViewController.h
//  Triberadio
//
//  Created by YingZhi on 6/15/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "BlurredViewController.h"
#import "RemoteImgListOperator.h"
#import "ZSVRadioPlayer.h"
#import "LeveyPopListView.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@class AudioPlayer;
@interface ListSongViewController : BlurredViewController<UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, LeveyPopListViewDelegate> {
    AudioPlayer *_audioPlayer;
    SLComposeViewController *slComposerSheet;

}
@property (nonatomic, readonly) RemoteImgListOperator *m_objImgListOper;

- (void)setPlaylistUrl:(NSString *)playlistname;
@end
