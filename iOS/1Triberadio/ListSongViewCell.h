//
//  ListSongViewCell.h
//  Triberadio
//
//  Created by YingZhi on 6/15/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "AudioButton.h"
#import "SongInfo.h"

@class RemoteImgListOperator;
@interface ListSongViewCell : SWTableViewCell
@property (strong, nonatomic) IBOutlet UILabel *songNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
//@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIImageView *avatarfillImg;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImg;
@property (nonatomic, readonly) RemoteImgListOperator *m_objRemoteImgListOper;
@property (nonatomic, readonly, copy) NSString *m_strURL;
@property (strong, nonatomic) IBOutlet AudioButton *audioButton;
@property (strong, nonatomic) SongInfo *songInfo;
- (void)setRemoteImgOper:(RemoteImgListOperator *)objOper;
- (void)showImgByURL:(NSString *)strURL;
- (void)configurePlayerButton;
@end
