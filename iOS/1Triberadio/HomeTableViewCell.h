//
//  HomeTableViewCell.h
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
@interface HomeTableViewCell : SWTableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatarImg;
@property (strong, nonatomic) IBOutlet UIImageView *avatarFillImg;
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *artistSubLabel;
@property (strong, nonatomic) NSString *songName;
@property (nonatomic, readonly) RemoteImgListOperator *m_objRemoteImgListOper;
@property (nonatomic, readonly, copy) NSString *m_strURL;
@property (strong, nonatomic) IBOutlet AudioButton *audioButton;
@property (strong, nonatomic) SongInfo *songInfo;
- (void)setRemoteImgOper:(RemoteImgListOperator *)objOper;
- (void)showImgByURL:(NSString *)strURL;
- (void)configurePlayerButton;
@end
