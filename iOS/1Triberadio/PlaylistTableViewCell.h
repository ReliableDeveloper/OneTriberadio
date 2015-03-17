//
//  PlaylistTableViewCell.h
//  1Triberadio
//
//  Created by YingZhi on 22/6/14.
//
//

#import <UIKit/UIKit.h>

@interface PlaylistTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgBack;

@property (strong, nonatomic) IBOutlet UIImageView *imgView;

@property (strong, nonatomic) IBOutlet UILabel *listNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *songCountLabel;

@end
