//
//  MainMenuTableViewCell.h
//  Triberadio
//
//  Created by YingZhi on 6/12/14.
//  Copyright (c) 2014 MobileDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *labelMenu;
@property (strong, nonatomic) IBOutlet UILabel *listNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *songCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imgBack;


@end
