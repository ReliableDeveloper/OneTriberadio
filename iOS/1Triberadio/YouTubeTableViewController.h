//
//  YouTubeTableViewController.h
//  YouTubePlayer
//
//  Created by Istvan Szabo on 2012.08.08..
//  Copyright (c) 2012 Istvan Szabo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YouTubeTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *ytvideosPlist;
@property (nonatomic, strong) NSDictionary *youtubePlist;
@property (strong, nonatomic) IBOutlet UIImageView *headerImage;
@property (strong, nonatomic) IBOutlet UILabel *headerTitle;

- (IBAction)playButton:(id)sender;
- (IBAction)refreshButton:(id)sender;
- (void)loadVideoPlayer:(NSString *)string;
- (void)setTrending:(BOOL) bTrending;
@end
