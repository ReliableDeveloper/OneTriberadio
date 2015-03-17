//
//  PhotosViewController.h
//  Triberadio
//
//  Created by YingZhi on 6/12/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImgListOperator.h"
@interface PhotosViewController : UICollectionViewController{
    CGPoint dragStartPt;
    bool dragging;
    NSMutableDictionary *selectedIdx;
}
@property (nonatomic, readonly) RemoteImgListOperator *m_objImgListOper;
@end


