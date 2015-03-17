//
//  PhotoCell.m
//  1Triberadio
//
//  Created by YingZhi on 15/7/14.
//
//

#import "PhotoCell.h"
#import "RemoteImgListOperator.h"
@implementation PhotoCell
@synthesize m_objRemoteImgListOper = _objRemoteImgListOper;
@synthesize m_strURL = _strURL;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)prepareForReuse
{
   
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
            self.myImage.image = [UIImage imageWithData:dataImg];
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

@end
