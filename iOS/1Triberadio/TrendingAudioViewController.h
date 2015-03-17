//
//  TrendingAudioViewController.h
//  1Triberadio
//
//  Created by KostiantynMitov on 11/27/14.
//
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
@interface TrendingAudioViewController : BlurredViewController<UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, LeveyPopListViewDelegate> {
    AudioPlayer *_audioPlayer;
    SLComposeViewController *slComposerSheet;
    
}
@property (nonatomic, readonly) RemoteImgListOperator *m_objImgListOper;
@end
