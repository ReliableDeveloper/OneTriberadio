//
//  ListSongViewCell.m
//  Triberadio
//
//  Created by YingZhi on 6/15/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import "ListSongViewCell.h"
#import "RemoteImgListOperator.h"
@implementation ListSongViewCell
@synthesize m_objRemoteImgListOper = _objRemoteImgListOper;
@synthesize m_strURL = _strURL;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)prepareForReuse
{
    self.avatarImg.image = nil;
    self.avatarfillImg.image = nil;
    self.artistNameLabel.text = @"";
    
    [super prepareForReuse];
}

- (void)setRemoteImgOper:(RemoteImgListOperator *)objOper
{
    if (_objRemoteImgListOper != objOper)
    {
        if (_objRemoteImgListOper)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:_objRemoteImgListOper.m_strSuccNotificationName object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:_objRemoteImgListOper.m_strFailedNotificationName object:nil];
        }else{}
        
        _objRemoteImgListOper = objOper;
        
        if (_objRemoteImgListOper)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(remoteImgSucc:)
                                                         name:_objRemoteImgListOper.m_strSuccNotificationName
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(remoteImgFailed:)
                                                         name:_objRemoteImgListOper.m_strFailedNotificationName
                                                       object:nil];
        }else{}
    }else{}
}

- (void)showImgByURL:(NSString *)strURL
{
    _strURL = strURL ? strURL : @"";
    
    __block NSString *blockStrURL = [strURL copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (blockStrURL.length > 1)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_objRemoteImgListOper)
                    {
                        [_objRemoteImgListOper getRemoteImgByURL:blockStrURL withProgress:nil];
                    }else{}
                });
            }else{}
        });
    });
}

#pragma mark - RemoteImgListOper notification

- (void)remoteImgSucc:(NSNotification *)noti
{
    if (noti && noti.userInfo && noti.userInfo.allKeys && (noti.userInfo.allKeys.count > 0))
    {
        NSString *strURL;
        NSData *dataImg;
        
        strURL = [noti.userInfo.allKeys objectAtIndex:0];
        dataImg = [noti.userInfo objectForKey:strURL];
        if (_strURL && [_strURL isEqualToString:strURL])
        {
            //            self.artistNameLabel.text = [NSString stringWithFormat:@"Success %@", _strURL];
            self.avatarImg.image = [UIImage imageNamed:@"avatar_fill.png"];
            self.avatarfillImg.image = [UIImage imageWithData:dataImg];
        }else{}
        
    }else{}
}

- (void)remoteImgFailed:(NSNotification *)noti
{
    if (noti && noti.userInfo && noti.userInfo.allKeys && (noti.userInfo.allKeys.count > 0))
    {
        NSString *strURL;
        strURL = [noti.userInfo.allKeys objectAtIndex:0];
        if (_strURL && [_strURL isEqualToString:strURL])
        {
            //            self.artistNameLabel.text = [NSString stringWithFormat:@"Failed %@", _strURL];
        }else{}
        
    }else{}
}

- (void)configurePlayerButton
{
    // use initWithFrame to drawRect instead of initWithCoder from xib
    self.audioButton = [[AudioButton alloc] initWithFrame:CGRectMake(260, 10, 50, 50)];
    [self.contentView addSubview:self.audioButton];
}


@end
