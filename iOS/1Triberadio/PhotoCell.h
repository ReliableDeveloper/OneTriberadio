//
//  PhotoCell.h
//  1Triberadio
//
//  Created by YingZhi on 15/7/14.
//
//

#import <UIKit/UIKit.h>
@class RemoteImgListOperator;
@interface PhotoCell : UICollectionViewCell

@property (nonatomic, readonly, copy) NSString *m_strURL;
@property (nonatomic, readonly) RemoteImgListOperator *m_objRemoteImgListOper;
- (void)setRemoteImgOper:(RemoteImgListOperator *)objOper;
- (void)showImgByURL:(NSString *)strURL;
@property (strong, nonatomic) UIImageView *myImage;

@end
