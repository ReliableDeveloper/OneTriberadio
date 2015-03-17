//
//  MusicAlbumViewController.h
//  Triberadio
//
//  Created by YingZhi on 6/15/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicAlbumViewController : UICollectionViewController{
    CGPoint dragStartPt;
    bool dragging;
    NSMutableDictionary *selectedIdx;
}

@end
